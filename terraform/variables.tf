variable "provider_variables" {
  type = object({
    region         = string
    aws_account_id = string
  })
  description = "Terraform Provider Variables"
}

variable "standard_tags" {
  type = object({
    owner          = string
    classification = string
    solution       = string
    deployment     = string
    category       = string
  })
  description = "Standard Tags"
}

variable "sso_managed_policies" {
  type        = list(string)
  description = "List of AWS Managed Policies to be applied to Developer SSO Role"
}

# variable "repo_list" {
#   type        = list(string)
#   description = "List of repository names"
# }

variable "git" {
  type = object({
    branch_main = string
    branch_dev  = string
  })
}

### Map ###

variable "code_config" {
  description = "Sets repository name, email address value, and deployment targets"
  type = list(object({
    repo_name   = string
    sns_email   = string
    is_core     = bool
    is_dev_only = bool
    is_dev_prod = bool
  }))
}
