variable "cluster_name" {
    type = string
}

variable "cluster_version" {
    default = "1.29"
}

variable "allowed_public_cidrs" {
    description = "Allowed IPs to access the EKS cluster: Local machine Public IP"
    type = list(string)
    # curl https://ifconfig.me
}

variable "system_node_instance_type" {
    type = list(string)
}

variable "vpc_id" {
    type = string
}

variable "subnet_ids" {
    type = list(string)
}

variable "control_plane_subnet_ids" {
    type = list(string)
}

variable "principal_arn" {
    type = string
}