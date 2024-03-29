########################################
###         PIPELINE                 ###
########################################


# Define a connection to GitHub using AWS CodeStar Connections.
# This connection allows AWS services to access a GitHub repository.
resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}

# Create an S3 bucket to store the artifacts used or generated by the pipeline.
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "uda-pipeline-bucket" # The name of the bucket.
}

# Apply a public access block to the S3 bucket to ensure it is not publicly accessible.
resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



# Define an IAM policy for the CodePipeline to access the S3 bucket.
resource "aws_iam_policy" "codepipeline_bucket_policy" {
  name   = "codepipeline-bucket-policy"
  policy = data.aws_iam_policy_document.bucket_policy_document.json
}

# Create a policy document that grants the CodePipeline service permission to assume a role.
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Define a policy document with permissions for CodePipeline actions on S3, CodeStar Connections, and CodeBuild.
data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.github.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = [aws_codebuild_project.uda_codebuild.arn]
  }
}

# Create an IAM role for CodePipeline with the assume role policy.
resource "aws_iam_role" "codepipeline_role" {
  name               = "codepipeline_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach the policy document to the CodePipeline role, granting the necessary permissions.
resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

# Define the AWS CodePipeline with source and build stages.
resource "aws_codepipeline" "uda_pipeline" {
  name     = "uda-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  # Define the artifact store location, which is the previously created S3 bucket.
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket # The bucket name.
    type     = "S3"
  }

  # Define the source stage of the pipeline, which pulls source code from GitHub.
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "ywateba/microservices-at-scale-aws-kubernetes"
        BranchName       = "main" # Branch to use.
      }
    }
  }

  # Define the build stage of the pipeline, which builds the code using AWS CodeBuild.
  stage {
    name = "Build"
    action {
      name             = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"] # Input artifacts from the previous stage.
      output_artifacts = ["build_output"] # Output artifacts for this stage.
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.uda_codebuild.name # The name of the CodeBuild project.
      }
    }
  }
}
