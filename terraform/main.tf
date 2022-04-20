### Create Developer Permission Set
# module "sso" {
#   source                  = "./sso"
#   sso_managed_policies    = var.sso_managed_policies
#   sso_permission_set_name = "Developer Role"
#   session_duration        = "PT4H"
# }

### Iterate through Repository List and create Code Commit resources
module "code" {
  source = "./code"
  # logic
  count = length(var.code_config)
  # iterate through repositories
  repo_name   = var.code_config[count.index].repo_name
  repo_branch = var.git.branch_main
  sns_email   = var.code_config[count.index].sns_email
  sns_kms_id  = "alias/aws/sns"
}

# output "test" {
#   value = var.code_config
# }

### Iterate through repository list and create pipeline resources

module "pipeline" {
  source = "./pipeline"

  count = length(var.code_config)
  ## IAM Variables ##
  iam_codebuild_path    = "/service-role/"
  iam_codebuild_name    = "${var.code_config[count.index].repo_name}-codebuild"
  iam_codepipeline_path = "/service-role/"
  iam_codepipeline_name = "${var.code_config[count.index].repo_name}-codepipeline"
  ## Pipeline Related Variables
  codepipeline_name                = "${var.code_config[count.index].repo_name}-pipeline"
  artifact_store_type              = "s3"
  source_git_branch                = var.git.branch_dev
  source_poll                      = false
  source_repo                      = var.code_config[count.index].repo_name
  build_projectname                = "build-${var.code_config[count.index].repo_name}"
  buildproject_init_name           = "build-${var.code_config[count.index].repo_name}-init"
  buildproject_init_description    = "Terraform Init Action"
  buildproject_init_encryption_key = "arn:aws:kms:${var.provider_variables.region}:${var.provider_variables.aws_account_id}:alias/aws/s3"
  buildproject_init_image          = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

