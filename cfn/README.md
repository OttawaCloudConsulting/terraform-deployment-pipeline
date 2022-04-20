# occ-lz-foundational-elements
Foundational Elements required for orchestration

## Overview

The purpose of this repository is manage the Infrastructure as Code foundational elements that are required to provision various Continuous Integration and Continuous Deployment frameworks.

## Elements

### Deployment Roles

Deployment Roles are deployed in pairs, with an 'Administration Role' that is typically assumed in the parent account, such as the organization master, and the remote 'Execution Role' that is present within the child account.

The parent role's permissions are restricted to limited Read and List permissions for typical code executions, such as captuing Organization ID, AccountId's etc., as well as assuming the remote exectuion roles.

The remote exectuion role's permissions are highly permissive within each account, but only trusted to the single parent account's Administration role.  

This combination reduces the ability to elevate to full Administrator Permissions to Infrastructure as Code deployments and authorized pipelines.

We further break out our deployment roles into two discrete sets.

#### Organization Wide Deployment Roles

This set of roles are provided full access within the Organization, and are not restricted to any regions, and can manage all resources.

#### Limited Deployment Role

This set of roles provide administrator access across the Organization, but follows the regular restrictions and follows the governance guidelines provisioned.  Administrative access is restricted to the permitted/authorized regions for deployment, and restrictions remain to protect the integrity of core infrastructure and governance resources.

### Default Service Roles

Many AWS Services, such as Systems Manager, include a one-click automated creation of service linked roles.  When we deploy with the API, either using CLI, SDK, or IaC such as Cloudformation or Terraform, we frequently depend on these to exist.  To reduce the potential for failures from missing dependencies, we will create these in advance.

