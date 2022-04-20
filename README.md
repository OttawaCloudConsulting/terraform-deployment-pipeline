# terraform-deployment-pipeline
AWS Pipeline to deploy Terraform projects

## Design Summary

### Master Pipeline

1. Developer SSO Role
2. Developer IAM Permissions
3. Cloud9 Instance
4. Generic Encryption Key

### Terraform Code Pipelines

1. AWS CodeCommit Repository
   1. Master/Main Branch # Cannot be coded
   2. Develpoment Branch # Cannot be coded
2. Add Inline Policy to Developer Role
3. Check Pipeline for structural changes
4. CodePipeline Role
   1. Source Stage - CodeCommit Repository 'main' branch
5. CloudWatch Log Group
   1. Log Stream
6. Build Stage
   1. Code scan
7. Test Stage
   1. Unit Tests
8. Deploy To Development
   1. Validate Variables
   2. Terraform Plan
   3. Approval
   4. Terrform Apply
   5. Smoke Test
9. Deploy to Production
   1. Validate Variables
   2. Terraform Plan
   3. Approval
   4. Terraform Apply
   5. Smoke Tests
10. Removal from Development
   6. Terraform Destroy
   7. Notification / Confirmation

## Cross-Account Deployment Roles
A set of cross-account deployment roles are included as CloudFormation templates that can be deployed using CloudFormation Stacksets to the entire organization

+ orgwide-admin-all-regions
+ orgwide-admin-core-regions

+ remote-exec-all-regions
+ remote-exec-core-regions

A Cross-Account Deployment Role is used within the Deployment Account to assume a role within the target account.  

An Admin Role is created within the Deployment Account, that maintains read access to be able to perform actions such as querying AWS Organizations, or retrieving Parameter Store parameters.  This Admin Role has trusts to the Remote Execution Role that can be assumed in the target account for deployment actions.
An Admin Role is created for 'All Regions' and a secondary one is created for 'Core Regions' to limit scope of permissions.  

A Remote Execution Role is created within every Account across the organiztion that can be assumed to perform deployment related actions.  This Remote Execution Role is highly permissive.

A Remote Execution Role is created for 'All Regions' and a secondary one is created for 'Core Regions' to limiit scope of permissions.  The 'Core Regions' Remote Execution Role includes access to the US-EAST-1 region, to ensure access to 'global' services, such as IAM.
