#the IAM custom policy configuration

resource "aws_iam_role_policy_attachment" "instance_ssm_core_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "instance_role" {
  name = format("role-%s-%s-instance", var.app, var.environment)
  path = "/"

  tags = {
    Terraform   = "true"
    Environment = var.environment
    APP         = var.app
  }

  assume_role_policy = data.aws_iam_policy_document.intance_assume_role.json
}

data "aws_iam_policy_document" "intance_assume_role" {
  version = "2012-10-17"

  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

