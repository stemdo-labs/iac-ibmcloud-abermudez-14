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
  vpc          =  ibm_is_vpc.vpc_abermudez.id
  resource_group  = var.resource_group  
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

resource "ibm_is_security_group_rule" "IP_rule" {
  group     = ibm_is_security_group.ssh_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"

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
 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQYePYr1IxSOGxJ6+lKuD4onsLK8jxU93BvYAB2lxTgomteXCpdHnKK3jix8hxadmANkG/k9kEjxWwKQR7ZVyw8eQul3aLCfMnHGqplVQH3JSsz5bKMaCNx8r2P5SYGLeTmbixZUmjlFxeacEQ7/8RPvVESZ5IvrOpNtsW0kF3IsxXZndLhZlC+a69xIw2UTDVYRjwSFcB4BLl2Z3YPIwcFNWyDQdThmSWJkfdXxOmunaVRVK+OFhEAJmIf8TJ6JVBbsBf1RU2khD8M3zGpxTKF6W0rb9seEkfHERhJbYpv8NmyWST8vgyCYRElKQK+IWmT4qMua+q6eXcrUtalyZa1m8rIytze10sa4kBsN/fdr/rtACDo+hx/e1lU5GnwodPscFaVHHH5nIOF1iq4llRevoPsTvSwViAE9Se1BrLZC1MrpyxF8l7LTDqCYbRuWoTXP5w5ElbqKIEbaBvv3xhd8V7jW0VYvg/vSbD9ZApAmb7QRnzzjGLCKS9k5/rOvhtcT/FP7XXxivnc+tRp7Q+FRjHAPgmhd9unk/LTUjXhaD9+M30nDol39jT+jwBZ8JOW1rFEFQJkGM7wfqSzbJRQutH5VMCX3XSk1+qv2hz5Sza1IJJPfeleetFRT9b1AbU/TCRpOg7ZwrcvMd9xyWFacHTqaUR2/oXF2c6FzT6FQ== abermudez@stemdo
  EOF
  resource_group = var.resource_group
  
}
resource "ibm_is_public_gateway" "public_gateway_abermudez" {
  name = "vpc-abermudez"
  vpc  = ibm_is_vpc.vpc_abermudez.id
  zone = "eu-gb-1"
  resource_group = var.resource_group
}

resource "ibm_is_public_gateway" "public_gateway_cluster_abermudez" {
  name = "vpc-cluster-abermudez"
  vpc  = ibm_is_vpc.vpc_cluster_abermudez.id
  zone = "eu-gb-1"
  resource_group = var.resource_group
}

# Virtual Server Instance (VM)
resource "ibm_is_instance" "vm_abermudez" {
  name              = "vm-abermudez"
  vpc               = ibm_is_vpc.vpc_abermudez.id
  profile           = "bx2-2x8"
  zone              = "eu-gb-1"
  keys = [ibm_is_ssh_key.ssh_key_abermudez.id]  
  image             = "r018-941eb02e-ceb9-44c8-895b-b31d241f43b5"
  resource_group = var.resource_group

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet_abermudez.id
    security_groups = [ibm_is_security_group.ssh_security_group.id]

  }
}


resource "ibm_cr_namespace" "abermudez_cr_namespace" {
  name              = "abermudez-cr-namespace"
  resource_group_id = var.resource_group
}



resource "ibm_resource_instance" "cos_instance_abermudez" {
  name              = "abermudez-cos-instance"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = var.resource_group
}
 
resource "ibm_container_vpc_cluster" "cluster_abermudez" {
  name              = "abermudez-vpc-cluster"
  vpc_id            = ibm_is_vpc.vpc_cluster_abermudez.id
  kube_version      = "4.16.23_openshift"
  flavor            = "bx2.4x16"
  worker_count      = "2"
  cos_instance_crn  = ibm_resource_instance.cos_instance_abermudez.id
  resource_group_id = var.resource_group
  zones {
    subnet_id = ibm_is_subnet.subnet_cluster_abermudez.id
    name      = "eu-gb-1"
  }
}

