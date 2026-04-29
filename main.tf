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

  policies = {}

  tags = {
    "managed-by" = "terraform"
    Environment  = "dev"
  }
}
