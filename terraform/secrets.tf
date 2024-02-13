
## Fot rhisfile can contain sensitive values
## Decide carefully if to inclue it here or somewhere else

resource "aws_secretsmanager_secret" "dockerhub_username" {
  name        = "/tokens/dockerhub/username"
  description = "dockerhub username"


}

resource "aws_secretsmanager_secret" "dockerhub_password" {
  name        = "/tokens/dockerhub/password"
  description = "dockerhub password"

}

resource "aws_secretsmanager_secret_version" "dockerhub_username" {
  secret_id     = aws_secretsmanager_secret.dockerhub_username.id
  secret_string = "github_user_name"
}


resource "aws_secretsmanager_secret_version" "dockerhub_password" {
  secret_id     = aws_secretsmanager_secret.dockerhub_password.id
  secret_string = "github_password"
}


resource "aws_secretsmanager_secret" "github_token_classic" {
  name        = "/tokens/github/classic"
  description = "classic github token"

}

resource "aws_secretsmanager_secret_version" "github_token_classic" {
  secret_id     = aws_secretsmanager_secret.github_token_classic.id
  secret_string = "some_github_classic_secret"
}


resource "aws_secretsmanager_secret" "github_token_special" {
  name        = "/tokens/github/special"
  description = "fine grained github token"

}

resource "aws_secretsmanager_secret_version" "github_token_special" {
  secret_id     = aws_secretsmanager_secret.github_token_special.id
  secret_string = "some_github_fine_grained_secret"
}
