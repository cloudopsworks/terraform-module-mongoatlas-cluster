##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

variable "region" {
  description = "Cloud provider region where the module is deployed. Used to compute the Atlas region name (e.g. 'us-east-1' → 'US_EAST_1'). Required when using backup copy settings or when no explicit region is set in settings.regions."
  type        = string
  default     = ""
}

variable "cloud_provider" {
  description = "Default cloud provider for Atlas backup export bucket and copy settings. Valid values: 'AWS', 'GCP', 'AZURE'. Can be overridden per-resource in settings."
  type        = string
  default     = "AWS"
}

variable "name_prefix" {
  description = "Prefix for the name of the resources"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name of the resource"
  type        = string
  default     = ""
}

variable "project_id" {
  description = "(optional) The ID of the project where the cluster will be created"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "(optional) The name of the project where the cluster will be created"
  type        = string
  default     = ""
}

##
# Variable entries as YAML
# settings:
#   cluster_type: "REPLICASET"         # (Optional) Cluster type: REPLICASET | SHARDED | GEOSHARDED. Default: "REPLICASET"
#   major_version: 7.0                 # (Optional) MongoDB major version. Default: null (uses Atlas default)
#   termination_protection: true       # (Optional) Enable termination protection. Default: null
#   version_release: "LTS"             # (Optional) Release cadence: LTS | CONTINUOUS. Default: "LTS"
#   encryption_at_rest_enabled: false  # (Optional) Enable encryption at rest. Default: false
#   encryption_at_rest_provider: "AWS" # (Optional) Provider for encryption at rest: AWS | GCP | AZURE. Default: "AWS"
#   cloud_provider: "AWS"              # (Optional) Default cloud provider for backup export/copy: AWS | GCP | AZURE. Default: "AWS"
#   bi_connector:
#     enabled: true | false (optional, default false)
#     read_preference: "primary" | "secondary" | "primaryPreferred" | "secondaryPreferred" | "nearest" (optional, default "secondary")
#   admin_user:
#     enabled: true | false            # (Optional) Create an Atlas admin user. Default: false
#     username: "my-admin"             # (Optional) Username for the admin user. Default: auto-generated from name
#     auth_database: "admin"           # (Optional) Authentication database. Default: "admin"
#     use_external_rotation: false     # (Optional) When true, an external rotation manager handles the password. Default: false
#     rotation_lambda_name: ""         # (Optional) External rotator identifier (e.g. Lambda name for AWS). Required when use_external_rotation is true.
#     rotation_period: 90              # (Optional) Password rotation period in days. Default: 90
#     rotation_duration: "1h"          # (Optional) Duration for external rotator execution. Default: "1h"
#     password_rotation_period: 90     # (Optional) time_rotating period in days for Terraform-managed rotation. Default: 90
#   advanced:
#     default_write_concern: "majority" | "majorityAndTagSet" | "majorityAndTagSetAny" | "majorityAndTagSetAnyRemote" | "majorityAndTagSetAnyLocal" | "majorityAndTagSetAnyRemoteLocal" (optional, default null)
#     javascript: true | false (optional, default false)
#     tls_protocol: "TLS1_0" | "TLS1_1" | "TLS1_2" | "TLS1_3" (optional, default null)
#     no_table_scan: true | false (optional, default null)
#     oplog_size: 50 (in MB optional, default null)
#     oplog_retention: 30 (in hours optional, default null)
#     bi:
#       sample_size: 1000 (optional, default null)
#       refresh_interval: 60 (in seconds optional, default null)
#     transaction_lifetime: 30 (in minutes optional, default null)
#   backup:
#     enabled: true | false (optional, default false)
#     hour_of_day: 0-23 (optional, default 0)
#     minute_of_hour: 0-59 (optional, default 0)
#     restore_window_days: 1 (optional, default 1)
#     auto_export: true | false (optional, default false)
#     export_prefix: string (optional, default null)
#     hourly:
#       interval: number (default: 1)
#       retention_unit: string (default: "days")
#       retention_value: number (default: 1)
#     daily:
#       interval: number (default: 1)
#       retention_unit: string (default: "days")
#       retention_value: number (default: 7)
#     weekly:
#       interval: number (default: 1)
#       retention_unit: string (default: "weeks")
#       retention_value: number (default: 4)
#     monthly:
#       interval: number (default: 1)
#       retention_unit: string (default: "months")
#       retention_value: number (default: 12)
#     yearly:
#       interval: number (default: 1)
#       retention_unit: string (default: "years")
#       retention_value: number (default: 2)
#     export:
#       cloud_provider: "AWS" | "GCP" | "AZURE"  # (Optional) Override cloud provider for this export bucket. Default: settings.cloud_provider
#       frecuency_type: "HOURLY" | "DAILY" | "WEEKLY" | "MONTHLY" | "YEARLY" (optional, default daily)
#       bucket_name: string              # (Required for AWS) S3 bucket name
#       iam_role_id: string              # (Required for AWS) IAM role ID (assumed role) for bucket access
#       service_url: string              # (Required for GCP/AZURE) Service URL for the export bucket
#       role_id: string                  # (Required for GCP/AZURE) Role ID for bucket access
#     copy:
#       cloud_provider: "AWS" | "GCP" | "AZURE"  # (Optional) Override cloud provider for copy settings. Default: settings.cloud_provider
#       frequencies: []
#       region_name: "US_EAST_1" (optional, default region from deployment)
#       copy_oplogs: true | false (optional, default false)
#   global:
#     zone_name: "zone-1"          # (Optional) Zone name for the primary replication spec (used in GEOSHARDED clusters). Default: null
#   regions:                        # (Optional) List of region_configs for the primary replication spec (first shard).
#     - backing_provider: "AWS"    # (Optional) Backing cloud provider for TENANT clusters: AWS | GCP | AZURE. Default: null
#       provider: "TENANT"         # (Optional) Atlas provider type: TENANT | AWS | GCP | AZURE. Default: TENANT
#       region: "US_EAST_1"        # (Optional) Atlas region name. Defaults to the deployment region converted to Atlas format.
#       priority: 7                # (Optional) Election priority (1-7, 7 = primary). Default: 7
#       electable:
#         size: "M10"              # (Optional) Instance size for electable nodes. Default: M2
#         count: 3                 # (Optional) Number of electable nodes. Default: null
#         iops: 1000               # (Optional) Provisioned IOPS (AWS only). Default: null
#         volume_type: "gp3"       # (Optional) EBS volume type (AWS only). Default: null
#         disk_size: 10            # (Optional) Disk size in GB, set at spec level (required by provider v2.0+). Default: null
#       analytics:
#         size: "M10"              # (Optional) Instance size for analytics nodes. Default: M2
#         count: 1                 # (Optional) Number of analytics nodes. Default: null
#         iops: 1000               # (Optional) Provisioned IOPS (AWS only). Default: null
#         volume_type: "gp3"       # (Optional) EBS volume type (AWS only). Default: null
#         disk_size: 10            # (Optional) Disk size in GB, set at spec level. Default: null
#       read_only:
#         size: "M10"              # (Optional) Instance size for read-only nodes. Default: M2
#         count: 1                 # (Optional) Number of read-only nodes. Default: null
#         iops: 1000               # (Optional) Provisioned IOPS (AWS only). Default: null
#         volume_type: "gp3"       # (Optional) EBS volume type (AWS only). Default: null
#         disk_size: 10            # (Optional) Disk size in GB, set at spec level. Default: null
#       auto_scaling:
#         disk: true               # (Optional) Enable disk auto-scaling. Default: false
#         compute: true            # (Optional) Enable compute auto-scaling. Default: false
#         max_size: "M40"          # (Optional) Maximum instance size for compute auto-scaling. Default: null
#         min_size: "M10"          # (Optional) Minimum instance size for compute auto-scaling. Default: null
#         scale_down: true         # (Optional) Allow scale-down of compute. Default: false
#         analytics:
#           disk: true             # (Optional) Enable disk auto-scaling for analytics nodes. Default: false
#           compute: true          # (Optional) Enable compute auto-scaling for analytics nodes. Default: false
#           max_size: "M40"        # (Optional) Maximum instance size for analytics auto-scaling. Default: null
#           min_size: "M10"        # (Optional) Minimum instance size for analytics auto-scaling. Default: null
#           scale_down: true       # (Optional) Allow scale-down for analytics. Default: false
#   shards:                         # (Optional) Additional shards for SHARDED / GEOSHARDED clusters. Each entry creates one replication_specs element (provider v2.0 independent shard scaling). Default: []
#     - zone_name: "zone-1"        # (Optional) Zone name for this shard (required for GEOSHARDED). Default: null
#       regions:                   # (Optional) List of region_configs for this shard. Same structure as settings.regions above.
#         - provider: "AWS"
#           region: "EU_WEST_1"
#           priority: 7
#           electable:
#             size: "M30"
#             count: 3
#             disk_size: 10
#   hoop:
#     enabled: true | false
#     agent: hoop-agent-name
#     tags: ["tag1", "tag2"]
variable "settings" {
  description = "Settings for the module"
  type        = any
  default     = {}
}
