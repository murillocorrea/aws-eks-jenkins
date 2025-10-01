terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-jenkins-teste"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"
  }
}