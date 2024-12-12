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
  ibmcloud_api_key="03fU7W2VX2zH2oC9JW7Asj7DV96j9jUG56MaMI0r8PTx"
}

resource "ibm_is_vpc" "EJEMPLOVPC" {
  name = "example-vpc-abermudez"
  resource_group = "4364ced224cf420fa07d8bf70a8d70df"
}