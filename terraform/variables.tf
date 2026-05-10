variable "vpc_cidr" {
  type = string
}

variable "public_subnet" {
  type = map(map(string))
}

variable "private_subnet" {
  type = map(map(string))
}