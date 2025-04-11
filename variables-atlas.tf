##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

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
#   cluster_type: "REPLICASET"
#   major_version: 7.0 (optional, default null)
#   termination_protection: true | false (optional, default null)
#   version_release: "LTS" | "GA" | "EA" (optional, default "LTS")
#   encryption_at_rest_enabled: true | false (optional, default false)
#   bi_connector:
#     enabled: true | false (optional, default false)
#     read_preference: "primary" | "secondary" | "primaryPreferred" | "secondaryPreferred" | "nearest" (optional, default "secondary")
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
#       frecuency_type: "HOURLY" | "DAILY" | "WEEKLY" | "MONTHLY" | "YEARLY" (optional, default daily)
#       bucket_name: string (required)
#       iam_role_id: string (required, IAM role ARN used for the bucket, assumed_role)
#     copy:
#       frequencies: []
#       region_name: "US_EAST_1" (optional, default region from deployment)
#       copy_oplogs: true | false (optional, default false)
#   global:
#     zone_name: "us-east-1" (optional, default null)
#     zone_id: "us-east-1a" (optional, default null)
#     regions:
#       backing_provider: "AWS" | "GCP" | "AZURE" (optional, default null)
#       provider: TENANT | SHARED | PUBLIC (optional, default TENANT)
#       region: "US_EAST_1" (optional, will use the region of the deployment)
#       priority: 1 (optional, default 7)
#       electable:
#         size: M10 (optional, default M2)
#         count: 3 (optional, default null)
#         iops: 1000 (optional, default null)
#         volume_type: "gp2" (optional, default null)
#         volume_size: 100 (optional, default null)
#       analythics:
#         size: M10 (optional, default M2)
#         count: 3 (optional, default null)
#         iops: 1000 (optional, default null)
#         volume_type: "gp2" (optional, default null)
#         volume_size: 100 (optional, default null)
#       read_only:
#         size: M10 (optional, default M2)
#         count: 3 (optional, default null)
#         iops: 1000 (optional, default null)
#         volume_type: "gp2" (optional, default null)
#         volume_size: 100 (optional, default null)
#       auto_scaling:
#         size: M10 (optional, default M2)
#         count: 3 (optional, default null)
#         iops: 1000 (optional, default null)
#         volume_type: "gp2" (optional, default null)
#         volume_size: 100 (optional, default null)
#         analythics:
#           size: M10 (optional, default M2)
#           count: 3 (optional, default null)
#           iops: 1000 (optional, default null)
#           volume_type: "gp2" (optional, default null)
#           volume_size: 100 (optional, default null)
#   hoop:
#     enabled: true | false
#     agent: hoop-agent-name
#     tags: ["tag1", "tag2"]
variable "settings" {
  description = "Settings for the module"
  type        = any
  default     = {}
}

variable "run_hoop" {
  description = "Run hoop with agent, be careful with this option, it will run the HOOP command in output in a null_resource"
  type        = bool
  default     = false
}