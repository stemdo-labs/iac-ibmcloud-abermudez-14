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

resource "ibm_is_security_group" "ssh_security_group" {
  name            = "ssh-security-group"
  vpc          =  ibm_is_vpc.vpc_abermudez.id  # Reemplaza con tu VPC
  resource_group  = var.resource_group          # Reemplaza con tu grupo de recursos
}

resource "ibm_is_security_group_rule" "ssh_rule" {
  group     = ibm_is_security_group.ssh_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
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
  target = ibm_is_instance.vm_abermudez.primary_network_interface[0].id
  resource_group = var.resource_group
  depends_on = [ibm_is_instance.vm_abermudez]

}

resource "ibm_is_ssh_key" "ssh_key_abermudez" {
  name       = "ssh-key-abermudez"
  public_key = <<-EOF
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCt9/RwJ2IaSKnCLvInZGYHbobdOND7ZdcKwpB2SgVnpF5oLleOngQ2qMQBBswBwtpyQjBv00RmCPhqCgmx4VkHk+36RJHtNUnjbKIiVSJpapNdg/GxRTGOHyvHPgDnDtBB8Ufsx2z0DF4DN2g9yjiTLre10GCed0zZcH0zORE8TJnvp8rYKrm9woj3un19WwgI9LJPbojuciAhmjadp1Cu6bdbQ1XDQOwQpjxDF9A0cTMSjM8KeoZiul3eNv0V+arvAF0B9v9wlRoWhjtymgKCDUHfBcczLYLA+CyFjplkOw47OiZRJj7Iv3NBxHEPVR2Irhg9UucHRBc+PlbOdwb0hdPtDx2crwfLoua/8J5UY5IUcOrBu6QNqYenkxis6s7Ukve8VLNzcQcMzT9eaIzn3Fffpr/rUyAtdDLoeS5s6+JABCD+zaCRnQs9wwvHoVf4hpDL0w+rkJ3JuEMvStXi+w7HlJUxnNB8Y0Cji48LUY3AK9bOZw3hAvvwhjCddPP7AFWLBn1v0JJqFcwxPl6ihjIfCIQ2odRo0PUN3H7abdHwy4NacH2ZgbrWfJG/gCP2r4C7jM0oTYjNehWMIHzzC+J/in2+KJJZMIppqMGfK7+XLg3OiV5B/PxSJAdJkXhNWXOootZU854es/eDzYkEUHMEPvdWojw5OguWH9F1QQ== IBM
  EOF
  resource_group = var.resource_group
}

# Virtual Server Instance (VM)
resource "ibm_is_instance" "vm_abermudez" {
  name              = "vm-abermudez"
  vpc               = ibm_is_vpc.vpc_abermudez.id
  profile           = "bx2-2x8" # Cambiar según tus necesidades
  zone              = "eu-gb-1"
  keys = [ibm_is_ssh_key.ssh_key_abermudez.id]  # Asignar la clave SSH a la VM
  image             = "r018-941eb02e-ceb9-44c8-895b-b31d241f43b5" # Reemplazar con el ID correcto
  resource_group = var.resource_group

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet_abermudez.id
    security_groups = [ibm_is_security_group.ssh_security_group.id]  # Asociar el Security Group a la instancia

  }
}

