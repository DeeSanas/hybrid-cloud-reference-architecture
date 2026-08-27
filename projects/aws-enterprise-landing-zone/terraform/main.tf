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
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "landing-zone-lab"
}

resource "aws_vpc" "landing_zone" {
  cidr_block           = "10.40.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "lz-network"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.landing_zone.id
  cidr_block              = "10.40.10.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "public-a"
    Tier = "public"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.landing_zone.id
  cidr_block              = "10.40.11.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags = {
    Name = "public-b"
    Tier = "public"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.landing_zone.id
  cidr_block        = "10.40.20.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "private-a"
    Tier = "private"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.landing_zone.id
  cidr_block        = "10.40.21.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "private-b"
    Tier = "private"
  }
}

output "vpc_id" {
  value = aws_vpc.landing_zone.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}
