resource "aws_iam_role" "puppet-client-instance-role" {
  name = "${var.environment}-puppet-client-instance-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role" "puppet-master-instance-role" {
  name = "${var.environment}-puppet-master-instance-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role" "postgresdb-instance-role" {
  name = "${var.environment}-postgresdb-instance-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "describe-tags" {
  name        = "${var.environment}-describe-tags"
  path        = "/EC2/"
  description = "This policy allows an instance to describe tags"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [ "ec2:DescribeTags"],
      "Resource": ["*"]
    }
  ]
}
    EOF
}

resource "aws_iam_policy" "describe-instances" {
  name        = "${var.environment}-describe-instances"
  path        = "/EC2/"
  description = "This policy allows to describe instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [ "ec2:DescribeInstances"],
      "Resource": ["*"]
    }
  ]
}
    EOF
}

//  Attach the policies to the role.
resource "aws_iam_policy_attachment" "instance-describe-tags" {
  name       = "${var.environment}instance-describe-tags"
  roles      = [aws_iam_role.puppet-client-instance-role.name,
                aws_iam_role.postgresdb-instance-role.name,
              ]
  policy_arn = aws_iam_policy.describe-tags.arn
}

resource "aws_iam_policy_attachment" "instance-describe-instances" {
  name       = "${var.environment}instance-describe-instances"
  roles      = [aws_iam_role.puppet-master-instance-role.name]
  policy_arn = aws_iam_policy.describe-instances.arn
}

//  Create a instance profile for the role.
resource "aws_iam_instance_profile" "puppet-client-instance-profile" {
  name = "${var.environment}puppet-client-instance-profile"
  role = aws_iam_role.puppet-client-instance-role.name
}

resource "aws_iam_instance_profile" "puppet-master-instance-profile" {
  name = "${var.environment}puppet-master-instance-profile"
  role = aws_iam_role.puppet-master-instance-role.name
}

resource "aws_iam_instance_profile" "postgresdb-instance-profile" {
  name = "${var.environment}postgresdb-instance-profile"
  role = aws_iam_role.postgresdb-instance-role.name
}