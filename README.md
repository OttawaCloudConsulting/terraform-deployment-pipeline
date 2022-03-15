# terraform-deployment-pipeline
AWS Pipeline to deploy Terraform projects

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