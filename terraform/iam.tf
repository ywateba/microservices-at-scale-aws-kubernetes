
resource "aws_iam_policy" "secrets_policy" {
  name        = "secrets-policy"
  description = "Policy to allow  to access specific secrets in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Effect = "Allow",
        Resource = [
          "*"
        ]
      }
    ]
  })
}
