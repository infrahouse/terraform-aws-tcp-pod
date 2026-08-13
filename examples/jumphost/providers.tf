provider "aws" {
  region = var.region
  default_tags {
    tags = {
      created_by : "infrahouse/terraform-aws-tcp-pod" # GitHub repository that created a resource
    }
  }
}
