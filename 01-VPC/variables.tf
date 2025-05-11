variable "public_subnet" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "database_subnet" {
  default = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "environment" {
  default = "dev"
}

variable "project_name" {
  default = "roboshop"
}
