terraform {
  required_providers {
    conformity = {
      version = "0.3.1"
      source  = "trendmicro.com/cloudone/conformity"
    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
      aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "conformity" {
  region = var.region
  apikey = var.apikey
}

provider "aws" {
  region = var.region
  profile = var.profile
}