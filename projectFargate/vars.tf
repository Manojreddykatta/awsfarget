variable "subnet_cidrs_public" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  type = list
}
variable "subnet_cidrs_private" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
  type = list
}
variable "availability_zones" {
  default = ["ap-south-1a", "ap-south-1b"]
  type = list
}

