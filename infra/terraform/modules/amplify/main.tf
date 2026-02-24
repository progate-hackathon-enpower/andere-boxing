resource "aws_amplify_app" "main" {
  name       = "${var.project_name}-${var.app_name}"
  repository = "https://github.com/${var.github_repository}"

  access_token = var.github_access_token

  platform = "WEB_COMPUTE"

  build_spec = var.build_spec

  environment_variables = var.environment_variables

  enable_branch_auto_build = true

  enable_auto_branch_creation   = var.enable_preview
  auto_branch_creation_patterns = var.enable_preview ? var.preview_branch_patterns : []

  dynamic "auto_branch_creation_config" {
    for_each = var.enable_preview ? [1] : []
    content {
      enable_auto_build = true
      framework         = var.framework
      stage             = "PULL_REQUEST"
    }
  }

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
