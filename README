Terraform Module to provision an EC2 instance that is running Apache.

Not intended for prod use just to show case how to create a custom module on the terraform registry

```hcl

terraform {

}

provider "aws" {
  region = "us-east-1" #ap-southeast-1 = Singapore, southeast 2 is Sydney
}

module "apache" {
  source          = ".//terraform-aws-apache-example"
 public_key      = "ssh-rsa AAA"
  instance_type   = "t2.micro"
  server_name     = "Apache Example Server"
  my_ip_with_cidr = "MY_OWN_IP_ADDRESS/32"
  vpc_id          = "vpc-00000000"

}


output "public_ip" {
  value = module.apache.public_ip
}




``````