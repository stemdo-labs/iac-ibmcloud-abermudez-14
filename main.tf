terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = ">= 1.12.0"
    }
  }
}

# Configure the IBM Provider
provider "ibm" {
  region = "eu-gb"
  ibmcloud_api_key=var.api_key
}

resource "ibm_is_vpc" "vpc_abermudez" {
  name = "example-vpc-abermudez"
  resource_group = var.resource_group
}

resource "ibm_is_vpc_routing_table" "rtable_abermudez" {
  name = "example-routing-table"
  vpc  =  ibm_is_vpc.vpc_abermudez.id
}

resource "ibm_is_subnet" "subnet_abermudez" {
  name            = "example-subnet"
  vpc             = ibm_is_vpc.vpc_abermudez.id
  zone            = "eu-gb"
  ipv4_cidr_block = "10.0.1.0/16"
  routing_table   = ibm_is_vpc_routing_table.rtable_abermudez
  

}