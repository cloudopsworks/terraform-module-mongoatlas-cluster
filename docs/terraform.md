## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | ~> 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | ~> 2.10 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | cloudopsworks/tags/local | 1.0.9 |

## Resources

| Name | Type |
|------|------|
| [mongodbatlas_advanced_cluster.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/advanced_cluster) | resource |
| [mongodbatlas_cloud_backup_schedule.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cloud_backup_schedule) | resource |
| [mongodbatlas_cloud_backup_snapshot_export_bucket.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cloud_backup_snapshot_export_bucket) | resource |
| [mongodbatlas_database_user.admin_user](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user) | resource |
| [random_password.randompass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.randompass_rotated](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [time_rotating.randompass](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [mongodbatlas_project.this](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project) | data source |
| [mongodbatlas_project.this_id](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project) | data source |
| [mongodbatlas_roles_org_id.current](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/roles_org_id) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | Default cloud provider for Atlas backup export bucket and copy settings. Valid values: 'AWS', 'GCP', 'AZURE'. Can be overridden per-resource in settings. | `string` | `"AWS"` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Extra tags to add to the resources | `map(string)` | `{}` | no |
| <a name="input_is_hub"></a> [is\_hub](#input\_is\_hub) | Is this a hub or spoke configuration? | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the resource | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for the name of the resources | `string` | `""` | no |
| <a name="input_org"></a> [org](#input\_org) | Organization details | <pre>object({<br/>    organization_name = string<br/>    organization_unit = string<br/>    environment_type  = string<br/>    environment_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | (optional) The ID of the project where the cluster will be created | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | (optional) The name of the project where the cluster will be created | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Cloud provider region where the module is deployed. Used to compute the Atlas region name (e.g. 'us-east-1' → 'US\_EAST\_1'). Required when using backup copy settings or when no explicit region is set in settings.regions. | `string` | `""` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Settings for the module | `any` | `{}` | no |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | Spoke ID Number, must be a 3 digit number | `string` | `"001"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_admin_user"></a> [cluster\_admin\_user](#output\_cluster\_admin\_user) | n/a |
| <a name="output_cluster_connection_strings"></a> [cluster\_connection\_strings](#output\_cluster\_connection\_strings) | n/a |
| <a name="output_cluster_containers"></a> [cluster\_containers](#output\_cluster\_containers) | n/a |
| <a name="output_cluster_credentials"></a> [cluster\_credentials](#output\_cluster\_credentials) | Full credentials map including username, password, connection strings. Sensitive — consumed by cloud-specific wrapper modules to store in their secret store. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_cluster_server_type"></a> [cluster\_server\_type](#output\_cluster\_server\_type) | n/a |
| <a name="output_cluster_state"></a> [cluster\_state](#output\_cluster\_state) | n/a |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | n/a |
