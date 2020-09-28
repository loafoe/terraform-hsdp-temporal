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

# Getting help / Contact
andy.lo-a-foe@philips.com

# License
License is MIT
