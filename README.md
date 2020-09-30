# HSDP Temporal module
This module creates a Temporal server on a Container Host as well as a Cloud foundry instance of Temporal web. 
It also provisions a PostgreSQL database for use by the Temporal server. Future versions of this module
might utilize brokered Elasticsearch as well.

# Usage
Running Temporal on Container Host allows workers to be hosted on Cloud foundry,
Container Host and potentially even as Iron workers. If you do not requires workers on
Container Host then hosting Temporal fully on Cloud foundry is recommended.

```hcl
module "temporal" {
  source = "github.com/philips-labs/terraform-hsdp-temporal//src"

  bastion_host = var.bastion_host
  user         = var.cf_user
  private_key  = file(var.private_key_file)
  user_groups  = [var.cf_user]
  org_name     = var.cf_org
  app_domain   = data.cloudfoundry_domain.us_east.name
}
```

## Requirements

| Name | Version |
|------|---------|
| cloudfoundry | >= 0.12.4 |
| hsdp | >= 0.6.3 |

## Providers

| Name | Version |
|------|---------|
| cloudfoundry | >= 0.12.4 |
| hsdp | >= 0.6.3 |
| null | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_domain | The app domain to use | `string` | n/a | yes |
| bastion\_host | Bastion host to use for SSH connections | `string` | n/a | yes |
| instance\_type | The instance type to use | `string` | `"t2.medium"` | no |
| org\_name | Cloudfoundry ORG name to use for reverse proxy | `string` | n/a | yes |
| postgres\_plan | The HSDP-RDS PostgreSQL plan to use | `string` | `"postgres-medium-dev"` | no |
| private\_key | Private key for SSH access (should not have a passphrase) | `string` | n/a | yes |
| temporal\_image | The Temporal server image to use | `string` | `"temporalio/auto-setup:1.0.0"` | no |
| temporal\_web\_image | The Temporal web image to use | `string` | `"temporalio/web:1.0.0"` | no |
| user | LDAP user to use for connections | `string` | n/a | yes |
| user\_groups | User groups to assign to cluster | `list(string)` | n/a | yes |
| volume\_size | The volume size to use in GB | `number` | `50` | no |

## Outputs

| Name | Description |
|------|-------------|
| temporal\_id | Server ID of prometheus |
| temporal\_ip | Private IP address of Temporal server |
| temporal\_web\_url | The cloud foundry URL of Temporal web |

# Getting help / Contact
andy.lo-a-foe@philips.com

# License
License is MIT
