variable "application" {
  type        = string
  description = "test"
  default     = "test"
}

variable "application_prefix_name" {
  type    = string
  default = "prod-"

}

variable "stage" {
  type    = string
  default = "prod"
}

variable "instances_number" {
  default = 1
  type    = string
}

#--- changed from eu-central-1 ---
variable "region" {
  default = "ap-southeast-1"
  type    = string
}

#--- changed to a data source ---
# variable "vpc_id" {
#   type = string
#   default = ""
# }

data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = ["GitOps"]
  }
}

#--- changed to a data source ---
# variable "subnet_ids" {
#   type = list
#   default = ["",""]
# }

data "aws_subnet" "subnet_id_a" {
  filter {
    name   = "tag:Name"
    values = ["GitOps-Private-A"]
  }
}

data "aws_subnet" "subnet_id_b" {
  filter {
    name   = "tag:Name"
    values = ["GitOps-Private-B"]
  }
}

variable "short_id" {
  type = string
  default = "1465"
}

variable "vitesco_cidr" {
  description = "Vitesco network CIDR blocks"
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}