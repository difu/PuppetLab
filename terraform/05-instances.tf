data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}


module "puppet-testlab-asgroup" {
  source = "github.com/terraform-aws-modules/terraform-aws-autoscaling"

  name = "puppet-nodes-group-a"

  lc_name = "puppet-nodes-lc"

  image_id                     = data.aws_ami.amazon_linux.id
  instance_type                = "t2.micro"
  security_groups              = [aws_security_group.puppet-public-ssh.id, aws_security_group.puppet-public-ssl.id, aws_security_group.puppet-public-puppet.id]
  associate_public_ip_address  = true
  recreate_asg_when_lc_changes = true
  key_name                     = var.key_name

//  ebs_block_device = [
//    {
//      device_name           = "/dev/xvdz"
//      volume_type           = "gp2"
//      volume_size           = "50"
//      delete_on_termination = true
//    },
//  ]
//
//  root_block_device = [
//    {
//      volume_size           = "50"
//      volume_type           = "gp2"
//      delete_on_termination = true
//    },
//  ]

  # Auto scaling group
  asg_name                  = "puppet-nodes-asg"
  vpc_zone_identifier       = [aws_subnet.public-a.id,aws_subnet.public-b.id,aws_subnet.public-c.id]
  health_check_type         = "EC2"
  min_size                  = var.group_a_min_servers
  max_size                  = var.group_a_max_servers
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Project"
      value               = var.project
      propagate_at_launch = true
    },
  ]

  tags_as_map = {
    instance_role = "webserver"
    environment = "dev"
  }
}

data "template_file" "puppet_master_init" {
    template = file("user_data/puppet_master.sh")
  template = file("user_data/puppet_master.sh")
  vars = {
    internal_domain = var.dns_zone_name
  }
}

resource "aws_instance" "puppetmaster" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = aws_subnet.public-a.id
  vpc_security_group_ids = [
    aws_security_group.puppet-public-ssh.id,
    aws_security_group.puppet-public-puppet.id]
  user_data = base64encode(data.template_file.puppet_master_init.rendered)
  key_name = var.key_name
  tags = {
    Name = "Puppet master"
  }
}