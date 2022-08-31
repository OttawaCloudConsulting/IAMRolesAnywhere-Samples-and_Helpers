terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.28.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.2"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
  default_tags {
    tags = {
      deployment = "terraform"
      category   = "operations"
      source     = "github.com/OttawaCloudConsulting/IAMRolesAnywhere-Samples-and_Helpers"
    }
  }
}