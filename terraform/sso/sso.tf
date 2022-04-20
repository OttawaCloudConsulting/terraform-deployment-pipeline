### Requirements
# + Create Developer Role
# + Assign Managed Policies to Developer Role
# + Assign Developer Role access to user & accountid

### Get existing SSO Instance
data "aws_ssoadmin_instances" "this" {}

### Create Developer Permission Set
variable "sso_permission_set_name" {
  type = string
}
variable "session_duration" {
  type = string
}

resource "aws_ssoadmin_permission_set" "this" {
  name             = var.sso_permission_set_name
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  session_duration = var.session_duration
}

### Attach Policies from list
variable "sso_managed_policies" {
  type = list(string)
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = toset(var.sso_managed_policies)

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = each.key
  permission_set_arn = aws_ssoadmin_permission_set.example.arn
}

### Outputs

output "sso_permission_set" {
  value = aws_ssoadmin_permission_set.this
}