terraform {
  required_providers {
    qingcloud = {
      source = "shaowenchen/qingcloud"
      version = "1.2.6"
    }
  }
}

variable "access_key" {
  default = "yourID"
}

variable "secret_key" {
  default = "yourSecret"
}

variable "zone" {
  default = "ap2a"
}

provider "qingcloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  zone = "${var.zone}"
}