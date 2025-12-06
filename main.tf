data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["main"]
  }
}

data "aws_subnet" "use1a" {
  filter {
    name   = "tag:Name"
    values = ["main-private-us-east-1a"]
  }
}

data "aws_subnet" "use1b" {
  filter {
    name   = "tag:Name"
    values = ["main-private-us-east-1b"]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.1"

  name               = "main"
  kubernetes_version = "1.33"

  create_cloudwatch_log_group = false
  enabled_log_types           = null
  endpoint_public_access      = true
  enable_irsa                 = false

  # EKS Addons
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id     = data.aws_vpc.this.id
  subnet_ids = [data.aws_subnet.use1a.id, data.aws_subnet.use1b.id]

  eks_managed_node_groups = {
    worker = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["t3.medium"]
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size = 1
      max_size = 2
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 1
    }
  }

  access_entries = {
    # One access entry with a policy associated
    AdministratorAccess = {
      principal_arn = "arn:aws:iam::457253393941:role/AWSReservedSSO_AdministratorAccess_ff31aa0dd1ebddaa"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    "Environment" = "dev"
  }
}