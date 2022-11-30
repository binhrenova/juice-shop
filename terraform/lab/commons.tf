terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.2"
    }
  }
}

locals {
  project_name = "snyk-juice-shop"

  tags = {
    project     = var.project_name
    environment = var.env_name
  }
}

provider "aws" {
  region = var.region
}
