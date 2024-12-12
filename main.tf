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

resource "ibm_is_vpc" "EJEMPLOVPC" {
  name = "example-vpc-abermudez"
  resource_group = var.resource_group
}