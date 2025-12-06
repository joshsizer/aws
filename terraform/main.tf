resource "flux_bootstrap_git" "this" {
  version = "v2.7.5"
  path    = "clusters/aws/dev/us-east-1/main"
}