### Requirements
# + Create CodeCommit Repository
# + Assign SNS Topic with email
# + Create default branch main/master
# ? Can we create additional branches
# ? Limit access to main via IAM Policy to non Tech-Leads

## Create CodeCommit Repository
variable "repo_name" { type = string }
variable "repo_branch" { type = string }
resource "aws_codecommit_repository" "this" {
  repository_name = var.repo_name
  default_branch  = var.repo_branch
}

## Create SNS Notification Topic for Repository


variable "sns_kms_id" { type = string }
variable "sns_email" { type = string }

resource "aws_sns_topic" "this" {
  display_name      = var.repo_name
  name              = var.repo_name
  kms_master_key_id = var.sns_kms_id
}

resource "aws_sns_topic_policy" "this" {
  policy = jsonencode(
    {
      "Version" : "2008-10-17",
      "Statement" : [
        {
          "Sid" : "CodeNotification_publish",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "codestar-notifications.amazonaws.com"
          },
          "Action" : "SNS:Publish",
          "Resource" : "${aws_sns_topic.this.id}"
        }
      ]
    }
  )
  arn = aws_sns_topic.this.id
}

# Commented out for testing purposes to avoid spam
# resource "aws_sns_topic_subscription" "this" {
#   topic_arn = aws_sns_topic.this.arn
#   protocol  = "email"
#   endpoint  = var.sns_email
# }

output "aws_codecommit_repository" { value = aws_codecommit_repository.this }
output "aws_sns_topic" { value = aws_sns_topic.this }