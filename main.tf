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
  name = "vpc-abermudez"
  resource_group = var.resource_group
}

resource "ibm_is_subnet" "subnet_abermudez" {
  name = "subnet-abermudez"
  vpc = ibm_is_vpc.vpc_abermudez.id
  zone = "eu-gb-1"
  resource_group = var.resource_group
  ipv4_cidr_block= "10.242.1.0/24"
}

resource "ibm_is_vpc" "vpc_cluster_abermudez" {
  name = "vpc-cluster-abermudez"
  resource_group = var.resource_group

}


resource "ibm_is_subnet" "subnet_cluster_abermudez" {
  name = "subnet-cluster-abermudez"
  vpc = ibm_is_vpc.vpc_cluster_abermudez.id
  zone = "eu-gb-1"
  resource_group = var.resource_group
  ipv4_cidr_block= "10.242.2.0/24"
 
}

# Floating IP
resource "ibm_is_floating_ip" "public_ip" {
  name   = "public-ip-abermudez"
  zone   = "eu-gb-1"
  target = ibm_is_instance.vm_abermudez.primary_network_interface[0].id
  resource_group = var.resource_group  
}

# Virtual Server Instance (VM)
resource "ibm_is_instance" "vm_abermudez" {
  name              = "vm-abermudez"
  vpc               = ibm_is_vpc.vpc_abermudez.id
  profile           = "bx2-1x2" # Cambiar según tus necesidades
  zone              = "eu-gb-1"
  image             = "r006-21d636c2-eacf-4c31-9cc8-c7335966f4e3" # Reemplazar con el ID correcto
  keys              = [var.ssh_key]
  resource_group = var.resource_group

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet_abermudez.id
  }
}
  
