terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region used by this reference example."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "Non-overlapping CIDR allocated from the enterprise IP plan."
  type        = string
  default     = "10.40.0.0/16"
}

variable "environment" {
  description = "Environment label."
  type        = string
  default     = "reference"
}

locals {
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "HybridCloudReference"
  }
}

resource "aws_vpc" "hub" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, { Name = "hybrid-hub-vpc" })
}

resource "aws_subnet" "shared_a" {
  vpc_id            = aws_vpc.hub.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 10)
  availability_zone = "${var.region}a"

  tags = merge(local.tags, { Name = "shared-services-a" })
}

resource "aws_subnet" "shared_b" {
  vpc_id            = aws_vpc.hub.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 11)
  availability_zone = "${var.region}b"

  tags = merge(local.tags, { Name = "shared-services-b" })
}

resource "aws_cloudwatch_log_group" "network" {
  name              = "/reference/hybrid-cloud/network"
  retention_in_days = 30
  tags              = local.tags
}

output "vpc_id" {
  value       = aws_vpc.hub.id
  description = "Hub VPC identifier."
}

output "shared_subnet_ids" {
  value       = [aws_subnet.shared_a.id, aws_subnet.shared_b.id]
  description = "Shared-service subnet identifiers."
}
