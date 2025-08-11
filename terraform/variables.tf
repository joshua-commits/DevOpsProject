//variables.tf

variable "example_variable" {

	type 	    = string # Can be string, number, bool, etc.
	description = "Helps a reader figure out what this block is for."
	default	    = "This is the value if nothing else is provided."
	nullable    = false # a.k.a, can this varibale be a null value?

}

variable "location" {

	description = "The Azure region where the resources will be deployed"
	type	    = string
	default	    = "UK South"
}

variable "environment" {

	description = "The environment where the resources will be deployed"
	type	    = string
	default	    = "dev"
}

variable "docker_username" {
	description = "The username for the docker registry"
	type	    = string
	sensitive   = true
}

variable "docker_password" {
	description = "The password for the docker registry"
	type	    = string
	sensitive   = true
}