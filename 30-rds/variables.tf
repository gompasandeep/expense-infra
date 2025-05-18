variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "expense"
        Environment = "dev"
        Terraform = "true"
    }
}

variable "zone_id" {
    default = "Z063704428FMXN0C1VQUF" #get it from route53
}

variable "domain_name" {
    default = "sancharlearning.xyz"
}