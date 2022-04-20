variable "iam_codebuild_path" {}
variable "iam_codebuild_name" {}

resource "aws_iam_role" "codebuild" {
  path = var.iam_codebuild_path 
  name = var.iam_codebuild_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  max_session_duration = 3600
}

variable "iam_codepipeline_path" {}
variable "iam_codepipeline_name" {}

resource "aws_iam_role" "codepipeline" {
  path = var.iam_codepipeline_path 
  name = var.iam_codepipeline_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  max_session_duration = 3600
}

## Create S3 Bucket for artifact_store
# Create if var.artifact_store_type = "s3"
resource "aws_s3_bucket" "this" {
  bucket_prefix = var.codepipeline_name
}

variable "codepipeline_name" {}   # "my-test-codepipeline"
variable "artifact_store_type" {} # "S3"
variable "source_git_branch" {}   # "main"
variable "source_poll" {}         # "false"
variable "source_repo" {}         # "jira"
variable "build_projectname" {}   # "my-test-codepipeline-build-stage"
# variable "" {}

resource "aws_codepipeline" "this" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline.arn
  artifact_store {
    location = aws_s3_bucket.this.id # < Output of S3 resource block
    type     = var.artifact_store_type
  }
  stage {
    name = "Source"
    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      configuration = {
        BranchName           = var.source_git_branch
        OutputArtifactFormat = "CODE_ZIP"
        PollForSourceChanges = var.source_poll
        RepositoryName       = var.source_repo
      }
      provider = "CodeCommit"
      version  = "1"
      output_artifacts = [
        "SourceArtifact"
      ]
      run_order = 1
    }
  }
  stage {
    name = "Build" # Terraform init, fmt, validate, checkov-output
    action {
      name     = "Init"
      category = "Build"
      owner    = "AWS"
      configuration = {
        ProjectName = "${var.build_projectname}-Init"
      }
      input_artifacts = [
        "SourceArtifact"
      ]
      provider = "CodeBuild"
      version  = "1"
      output_artifacts = [
        "BuildArtifactInit"
      ]
      run_order = 1
    }
    action {
      name     = "Format-Validate"
      category = "Build"
      owner    = "AWS"
      configuration = {
        ProjectName = "${var.build_projectname}-Init"
      }
      input_artifacts = [
        "SourceArtifact"
      ]
      provider = "CodeBuild"
      version  = "1"
      output_artifacts = [
        "BuildArtifactFormatValidate"
      ]
      run_order = 2
    }
  }
}


#### Build Stage from CFN

# variable "buildproject_init_name" {}
variable "buildproject_init_name" {}
variable "buildproject_init_description" {}
variable "buildproject_init_image" {}          # "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
variable "buildproject_init_encryption_key" {} # "arn:aws:kms:${AWS::Region}:${AWS::AccountId}:alias/aws/s3"

resource "aws_codebuild_project" "init" {
  name               = var.buildproject_init_name
  description        = var.buildproject_init_description
  build_timeout      = "60"
  service_role       = aws_iam_role.codebuild.arn
  encryption_key     = var.buildproject_init_encryption_key
  queued_timeout     = 60
  badge_enabled      = false
  project_visibility = "PRIVATE"

  artifacts {
    type                = "CODEPIPELINE"
    encryption_disabled = false
    name                = var.buildproject_init_name
    packaging           = "NONE"
  }

  cache {
    type = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.buildproject_init_image
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"

    #   environment_variable {
    #     name  = "SOME_KEY1"
    #     value = "SOME_VALUE1"
    #   }

    #   environment_variable {
    #     name  = "SOME_KEY2"
    #     value = "SOME_VALUE2"
    #     type  = "PARAMETER_STORE"
    #   }
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = var.codepipeline_name
      stream_name = var.buildproject_init_name
    }
    s3_logs {
      status = "DISABLED"
    }
  }

  source {
    type            = "CODEPIPELINE"
    insecure_ssl    = false
    buildspec       = data.local_file.buildspec_init.content
    git_clone_depth = 0
  }
}

data "local_file" "buildspec_init" {
  filename = "${path.module}/buildspec_init.yml"
}