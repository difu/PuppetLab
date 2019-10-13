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

  name = "example-with-ec2"

  lc_name = "puppet-nodes-lc"

  image_id                     = data.aws_ami.amazon_linux.id
  instance_type                = "t2.micro"
  security_groups              = [aws_security_group.puppet-public-ssh.id, aws_security_group.puppet-public-ssl.id]
  associate_public_ip_address  = true
  recreate_asg_when_lc_changes = true
  key_name                     = var.key_name

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size           = "50"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name                  = "puppet-nodes-asg"
  vpc_zone_identifier       = [aws_subnet.public-a.id,aws_subnet.public-b.id,aws_subnet.public-c.id]
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 3
  desired_capacity          = 3
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Project"
      value               = var.project
      propagate_at_launch = true
    },
  ]

  tags_as_map = {
    extra_tag1 = "extra_value1"
    extra_tag2 = "extra_value2"
  }
}

resource "aws_instance" "puppetmaster" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = aws_subnet.public-a.id
  vpc_security_group_ids = [
    aws_security_group.puppet-public-ssh.id]
  key_name = var.key_name
  tags = {
    Name = "Puppet master"
  }
}