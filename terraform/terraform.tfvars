vpc_cidr = "10.0.0.0/16"

public_subnet = {
  "public_subnet_1" = {
    "cidr" = "10.0.1.0/24"
    "az"   = "us-east-1a"
  }

  "public_subnet_2" = {
    "cidr" = "10.0.2.0/24"
    "az"   = "us-east-1b"
  }
}

private_subnet = {
  "private_subnet_1" = {
    "cidr" = "10.0.3.0/24"
    "az"   = "us-east-1a"
  }

  "private_subnet_2" = {
    "cidr" = "10.0.4.0/24"
    "az"   = "us-east-1b"
  }
}