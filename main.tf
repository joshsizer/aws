module "iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name_prefix = "TestPolicy-"
  description = "My example policy"

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "ec2:Describe*"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    }
  EOF

  tags = {
    "managed-by" = "terraform"
    Environment  = "test"
  }
}

module "iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role"

  name = "TestRole"

  permissions_boundary = "arn:aws:iam::457253393941:policy/AppRuntimeBoundary"

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole",
      ]
      principals = [{
        type = "AWS"
        identifiers = [
          "arn:aws:iam::457253393941:root",
        ]
      }]
    }
  }

  policies = {
    ExamplePolicy = module.iam_policy.arn
  }

  tags = {
    "managed-by" = "terraform"
  }
}
