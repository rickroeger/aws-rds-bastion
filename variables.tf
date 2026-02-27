#standard information
variable "profile" {
  type = string
}
variable "region" {
  type = string
}
variable "environment" {
  type = string
}
variable "app" {
  type = string
}


#network information
variable "cidr" {
  type = string
}

variable "azs" {
  type = list(any)
}

variable "vpc_private_subnets" {
  type = list(any)
}

variable "vpc_public_subnets" {
  type = list(any)
}

variable "vpc_database_subnets" {
  type = list(any)
}

variable "db_name" {
  type = string
}

variable "username" {
  type = string
}