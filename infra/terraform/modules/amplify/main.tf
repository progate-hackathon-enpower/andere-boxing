resource "aws_amplify_app" "main" {
  name       = "${var.project_name}-${var.app_name}"
  repository = "https://github.com/${var.github_repository}"

  access_token = var.github_access_token

  platform = "WEB_COMPUTE"

  build_spec = var.build_spec

  environment_variables = var.environment_variables

  custom_rule {
    source = "/<*>"
    status = "404-200"
    target = "/index.html"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.app_name}-amplify"
    }
  )
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.main.id
  branch_name = var.branch_name

  framework = var.framework

  stage = var.stage

  environment_variables = var.branch_environment_variables

  enable_auto_build = var.enable_auto_build
}
