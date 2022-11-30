data "aws_iam_policy" "readonly_access" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "readonly_access" {
  user       = aws_iam_user.readonly_user.name
  policy_arn = data.aws_iam_policy.readonly_access.arn
}

resource "aws_iam_user" "readonly_user" {
  name = var.project_name # "uat"
}

resource "aws_iam_access_key" "readonly_user" {
  user = aws_iam_user.readonly_user.name
}