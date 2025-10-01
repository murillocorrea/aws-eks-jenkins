terraform {
    backend "s3" {
      bucket = "cicd-terraform-eks-jenkins-teste"
      key = "eks/terraform.tfstate"
      region = "us-east-1"
    }
}