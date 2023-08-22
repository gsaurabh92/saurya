variable "ami" {
    type = string
    
  
}

variable "instance_type" {
    type = string
  
}

variable "port" {
    type = list(string)
  
  
}


variable "availability_zone" {
    type = list(string)
   
  
}
 


variable "private-subnet_id" {
    type = string
  
}

variable "public-subnet_id" {
    type = string
}

variable "vpc_cidr_block" {
    type = string
  
}



variable "tags" {
    type = string
  
}