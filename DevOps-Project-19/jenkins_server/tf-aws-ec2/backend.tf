terraform {
  backend "s3" {
    bucket = "terraform-eks-cicd-7001-rm"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"
  }
}