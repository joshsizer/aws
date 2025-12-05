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

  tags = {
    "Environment" = "dev"
  }
}