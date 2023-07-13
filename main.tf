provider "aws" {
  region = "us-west-2"  # Update this based on your preferred region
}

resource "aws_security_group" "sagemaker_sg" {
  name        = "sagemaker_sg"
  description = "Allow all outbound and SageMaker-specific inbound rules"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy_document" "sagemaker_role_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_iam_role" "sagemaker_role" {
  name = "sagemaker_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "sagemaker.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "sagemaker_role_policy" {
  name = "sagemaker_role_policy"
  role = aws_iam_role.sagemaker_role.id

  policy = data.aws_iam_policy_document.sagemaker_role_policy.json
}

resource "aws_sagemaker_notebook_instance" "sagemaker_notebook" {
  name          = "rj-notebook-instance"
  role_arn      = "arn:aws:iam::155029645081:role/service-role/AmazonSageMakerServiceCatalogProductsExecutionRole"
  instance_type = "ml.t2.medium"

  security_groups = [aws_security_group.sagemaker_sg.id]
  subnet_id       = "subnet-0e82c477"  # Replace with your subnet ID

  tags = {
    Name = "sagemaker-notebook"
  }
}
