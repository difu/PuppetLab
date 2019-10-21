resource "aws_iam_role" "puppet-client-instance-role" {
  name = "puppet-client-instance-role"

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
  name        = "describe-tags"
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

//  Attach the policies to the role.
resource "aws_iam_policy_attachment" "instance-descibe-tags" {
  name       = "instance-descibe-tags"
  roles      = [aws_iam_role.puppet-client-instance-role.name]
  policy_arn = aws_iam_policy.describe-tags.arn
}

//  Create a instance profile for the role.
resource "aws_iam_instance_profile" "puppet-client-instance-profile" {
  name = "puppet-client-instance-profile"
  role = aws_iam_role.puppet-client-instance-role.name
}