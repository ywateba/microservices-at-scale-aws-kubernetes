

##########################################
###          CODEBUILD                 ###
##########################################
# Create a codebuild project on Aws
resource "aws_codebuild_project" "uda_codebuild" {
  name          = "uda_codebuild"
  build_timeout = "60"
  service_role  = aws_iam_role.uda_codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/ywateba/microservices-at-scale-aws-kubernetes.git"
    buildspec       = "buildspec.yaml"
  }

}

# create a role for codebuild
resource "aws_iam_role" "uda_codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
    ]
  })
}


# Policy document to defines permission for codebuild
data "aws_iam_policy_document" "codebuild_policy_document" {
  statement {
    effect = "Allow"
    actions = [
           "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::codepipeline-us-east-1-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
           "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
    ]

    resources = [
      "arn:aws:codebuild:us-east-1:470769016866:report-group/uda_codebuild-*"
    ]

  }
}

# create policy from the policy document
resource "aws_iam_policy" "codebuild_policy" {
  name = "code_policy"
  policy = data.aws_iam_policy_document.codebuild_policy_document.json
}

### assign policy to role
resource "aws_iam_role_policy_attachment" "codebuild_policy_atachment" {
  role       = aws_iam_role.uda_codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn

}

# create a cloudwatch log group
resource "aws_cloudwatch_log_group" "codebuil_log_group"{
  name = "/aws/codebuild/uda_codebuild"
  retention_in_days = 14                            # Log retention period

}


# create a policy to access the cloudtach group
resource "aws_iam_policy" "cloudwatch_policy" {
  name = "cloudwatch-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"

        ],
        Resource = "arn:aws:logs:us-east-1:470769016866:log-group:/aws/codebuild/uda_codebuild"

      }

    ]
  })
}




### Attach policies  to codebuild roles


## permission to access cloudwatch
resource "aws_iam_role_policy_attachment" "codebuild_cloudwatch_attachment" {
  role       = aws_iam_role.uda_codebuild_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
  depends_on = [ aws_iam_policy.cloudwatch_policy ]
}


## permission to access ecr
resource "aws_iam_role_policy_attachment" "codebuild_ecr_attachment" {
  role       = aws_iam_role.uda_codebuild_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
  depends_on = [ aws_iam_policy.ecr_access_policy ]
}


## permissions to access bucket for artifact
resource "aws_iam_role_policy_attachment" "codebuild_bucket_attachment" {
  role       = aws_iam_role.uda_codebuild_role.name
  policy_arn = aws_iam_policy.codepipeline_bucket_policy.arn

}


## permission to access secret
resource "aws_iam_role_policy_attachment" "codebuild_secrets_access" {
  role       = aws_iam_role.uda_codebuild_role.name
  policy_arn = aws_iam_policy.secrets_policy.arn
  depends_on = [ aws_iam_policy.secrets_policy ]
}



## create ecr
resource "aws_ecr_repository" "ecr" {
  name                 = "uda-analytics"
  image_tag_mutability = "MUTABLE"
}


## ecr policy document
data "aws_iam_policy_document" "ecr_access_policy_document" {
  statement {
    effect = "Allow"
    sid    = "AllowPushPull"
    actions = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
    ]

    resources = [
      aws_ecr_repository.ecr.arn
    ]
  }

  statement {
    effect = "Allow"
    sid    = "AllowAuth"
    actions = [
          "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
}

## ecr policy
resource "aws_iam_policy" "ecr_access_policy" {
  name = "ecr_access_policy"
  policy = data.aws_iam_policy_document.ecr_access_policy_document.json
}


### not necessary if  role has permissions already
# data "aws_iam_policy_document" "uda_ecr_policy_document" {
#   statement {
#     effect = "Allow"
#     sid    = "AllowPushPull"
#     principals  {
#         type = "AWS"
#         identifiers = [aws_iam_role.uda_codebuild_role.arn]
#     }
#     actions = [
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:BatchGetImage",
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:PutImage",
#           "ecr:InitiateLayerUpload",
#           "ecr:UploadLayerPart",
#           "ecr:CompleteLayerUpload"
#     ]

#     resources = [
#       aws_ecr_repository.ecr.arn
#     ]
#   }

#   statement {
#     effect = "Allow"
#     sid    = "AllowAuth"
#     actions = [
#           "ecr:GetAuthorizationToken"
#     ]
#     resources = [
#       "*"
#     ]
#   }
# }


# resource "aws_ecr_repository_policy" "uda_ecr_policy" {
#   repository = aws_ecr_repository.ecr.name
#   policy = data.aws_iam_policy_document.uda_ecr_policy_document.json

# }
