# ########################################################################################################################
# ## Creates IAM Role which is assumed by the Container Instances (aka EC2 Instances)
# ########################################################################################################################
#
# resource "aws_iam_role" "ec2_instance_role" {
#   name               = "${var.namespace}_EC2_InstanceRole_${var.environment}"
#   assume_role_policy = data.aws_iam_policy_document.ec2_instance_role_policy.json
#
#   tags = {
#     Scenario = var.scenario
#   }
# }
#
# resource "aws_iam_role_policy_attachment" "ec2_instance_role_policy" {
#   role       = aws_iam_role.ec2_instance_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
# }
#
# resource "aws_iam_instance_profile" "ec2_instance_role_profile" {
#   name = "${var.namespace}_EC2_InstanceRoleProfile_${var.environment}"
#   role = aws_iam_role.ec2_instance_role.id
#
#   tags = {
#     Scenario = var.scenario
#   }
# }
#
# data "aws_iam_policy_document" "ec2_instance_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     effect  = "Allow"
#
#     principals {
#       type        = "Service"
#       identifiers = [
#         "ec2.amazonaws.com",
#         "ecs.amazonaws.com"
#       ]
#     }
#   }
# }
#
# ########################################################################################################################
# ## Create service-linked role used by the ECS Service to manage the ECS Cluster
# ########################################################################################################################
#
# resource "aws_iam_role" "ecs_service_role" {
#   name               = "${var.namespace}_ECS_ServiceRole_${var.environment}"
#   assume_role_policy = data.aws_iam_policy_document.ecs_service_policy.json
#
#   tags = {
#     Scenario = var.scenario
#   }
# }
#
# data "aws_iam_policy_document" "ecs_service_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     effect  = "Allow"
#
#     principals {
#       type        = "Service"
#       identifiers = ["ecs.amazonaws.com",]
#     }
#   }
# }
#
# resource "aws_iam_role_policy" "ecs_service_role_policy" {
#   name   = "${var.namespace}_ECS_ServiceRolePolicy_${var.environment}"
#   policy = data.aws_iam_policy_document.ecs_service_role_policy.json
#   role   = aws_iam_role.ecs_service_role.id
# }
#
# data "aws_iam_policy_document" "ecs_service_role_policy" {
#   statement {
#     effect  = "Allow"
#     actions = [
#       "ec2:AuthorizeSecurityGroupIngress",
#       "ec2:Describe*",
#       "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
#       "elasticloadbalancing:DeregisterTargets",
#       "elasticloadbalancing:Describe*",
#       "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
#       "elasticloadbalancing:RegisterTargets",
#       "ec2:DescribeTags",
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:DescribeLogStreams",
#       "logs:PutSubscriptionFilter",
#       "logs:PutLogEvents"
#     ]
#     resources = ["*"]
#   }
# }
#
# ########################################################################################################################
# ## IAM Role for ECS Task execution
# ########################################################################################################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.namespace}_ECS_TaskExecutionRole_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json

  tags = {
    Scenario = var.scenario
  }
}

data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ########################################################################################################################
# ## IAM Role for ECS Task
# ########################################################################################################################

resource "aws_iam_role" "ecs_task_iam_role" {
  name               = "${var.namespace}_ECS_TaskIAMRole_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json

  tags = {
    Scenario = var.scenario
  }
}

# ########################################################################################################################
# ## IAM Role for Role to be created GitHubAction-AssumeRoleWithAction
# ########################################################################################################################
resource "aws_iam_openid_connect_provider" "githubOidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
}

data "aws_iam_policy_document" "oidc_github_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.githubOidc.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:gfalco77/*:ref:refs/heads/main"]
    }
  }
}

data "aws_iam_policy_document" "ecr-ecs-publisher" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:*"]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition"
    ]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices"
    ]
    resources = ["arn:aws:ecs:eu-west-2::${var.account_id}:service/${var.namespace}_ECSCluster_${var.environment}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${var.account_id}:role/${var.namespace}_ECS_TaskExecutionRole_${var.environment}",
      "arn:aws:iam::${var.account_id}:role/${var.namespace}_ECS_TaskIAMRole_${var.environment}"
    ]
  }
}

resource "aws_iam_role" "github_role" {
  name               = "GithubActionsRole"
  assume_role_policy = data.aws_iam_policy_document.oidc_github_policy.json
  inline_policy {
    name   = "github_actions_policy"
    policy = data.aws_iam_policy_document.ecr-ecs-publisher.json
  }
}
