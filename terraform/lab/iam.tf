#######################################
## Trust Policy
#######################################
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#######################################
## Instance Profile
#######################################
resource "aws_iam_instance_profile" "bastion_linux" {
  name = "${var.env_name}-BASTION-LINUX-1A-instance-profile"
  role = aws_iam_role.bastion_linux.name
}

#######################################
## IAM Role
#######################################
resource "aws_iam_role" "bastion_linux" {
  name               = "${var.env_name}-BASTION-LINUX-1A-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}
