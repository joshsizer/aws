data "aws_eks_cluster" "upstream" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "upstream_auth" {
  name = var.cluster_name
}

provider "flux" {
  kubernetes = {
    host                   = data.aws_eks_cluster.upstream.endpoint
    token                  = data.aws_eks_cluster_auth.upstream_auth.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.upstream.certificate_authority[0].data)
  }
  git = {
    url          = "ssh://git@github.com/joshsizer/aws.git"
    author_email = var.author_email
    author_name  = "Josh Sizer"
    branch       = "flux"
    ssh = {
      username    = "git"
      private_key = var.private_key
    }
  }
}