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
  region = "us-east-1"
}

locals {
  vpcs = {
    prod = {
      cidr = "10.40.0.0/16"
      az   = "us-east-1a"
    }
    nonprod = {
      cidr = "10.50.0.0/16"
      az   = "us-east-1b"
    }
  }
}

resource "aws_ec2_transit_gateway" "this" {
  description                     = "reference-enterprise-transit"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "tgw-enterprise-reference"
  }
}

resource "aws_vpc" "this" {
  for_each = local.vpcs

  cidr_block           = each.value.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "vpc-${each.key}"
    Environment = each.key
  }
}

resource "aws_subnet" "tgw" {
  for_each = local.vpcs

  vpc_id            = aws_vpc.this[each.key].id
  cidr_block        = cidrsubnet(each.value.cidr, 8, 1)
  availability_zone = each.value.az

  tags = {
    Name = "snet-${each.key}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = local.vpcs

  subnet_ids         = [aws_subnet.tgw[each.key].id]
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = aws_vpc.this[each.key].id

  tags = {
    Name = "attach-${each.key}"
  }
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = local.vpcs

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = {
    Name = "tgw-rt-${each.key}"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = local.vpcs

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.key].id
}

output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.this.id
}
