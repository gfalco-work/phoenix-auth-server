# ########################################################################################################################
# ## Container registry for the service's Docker image
# ########################################################################################################################

resource "aws_ecr_repository" "ecr" {
  name                 = lower(var.namespace)
  force_delete         = true
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }
  lifecycle {

  }
  tags = {
    Scenario = var.scenario
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.ecr.repository_url
}