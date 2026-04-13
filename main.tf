##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  atlas_region = upper(replace(var.region, "-", "_"))
}

data "mongodbatlas_project" "this_id" {
  count      = var.project_id != "" ? 1 : 0
  project_id = var.project_id
}

data "mongodbatlas_project" "this" {
  count = var.project_name != "" ? 1 : 0
  name  = var.project_name
}

resource "mongodbatlas_advanced_cluster" "this" {
  name                           = var.name != "" ? var.name : format("%s-%s", var.name_prefix, local.system_name)
  project_id                     = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
  cluster_type                   = try(var.settings.cluster_type, "REPLICASET")
  mongo_db_major_version         = try(var.settings.major_version, null)
  termination_protection_enabled = try(var.settings.termination_protection, null)
  version_release_system         = try(var.settings.version_release, "LTS")
  config_server_management_mode  = try(var.settings.config_server, null)
  backup_enabled                 = try(var.settings.backup.enabled, null)
  encryption_at_rest_provider    = try(var.settings.encryption_at_rest_enabled, false) ? try(var.settings.encryption_at_rest_provider, "AWS") : null
  bi_connector_config = length(try(var.settings.bi_connector, {})) > 0 ? {
    enabled         = try(var.settings.bi_connector.enabled, false)
    read_preference = try(var.settings.bi_connector.read_preference, "secondary")
  } : null
  advanced_configuration = length(try(var.settings.advanced, {})) > 0 ? {
    default_write_concern                = try(var.settings.advanced.default_write_concern, null)
    javascript_enabled                   = try(var.settings.advanced.javascript, null)
    minimum_enabled_tls_protocol         = try(var.settings.advanced.tls_protocol, null)
    no_table_scan                        = try(var.settings.advanced.no_table_scan, null)
    oplog_size_mb                        = try(var.settings.advanced.oplog_size, null)
    oplog_min_retention_hours            = try(var.settings.advanced.oplog_retention, null)
    sample_size_bi_connector             = try(var.settings.advanced.bi.sample_size, null)
    sample_refresh_interval_bi_connector = try(var.settings.advanced.bi.refresh_interval, null)
    transaction_lifetime_limit_seconds   = try(var.settings.advanced.transaction_lifetime, null)
  } : null
  replication_specs = concat(
    # Primary replication spec (first shard / single-region clusters)
    [
      {
        zone_name = try(var.settings.global.zone_name, null)
        region_configs = [
          for rc in try(var.settings.regions, []) : {
            backing_provider_name = try(rc.backing_provider, null)
            provider_name         = try(rc.provider, "TENANT")
            region_name           = upper(replace(try(rc.region, local.atlas_region), "-", "_"))
            priority              = try(rc.priority, 7)
            electable_specs = length(try(rc.electable, {})) > 0 ? {
              instance_size   = try(rc.electable.size, "M2")
              node_count      = try(rc.electable.count, null)
              disk_iops       = try(rc.electable.iops, null)
              ebs_volume_type = try(rc.electable.volume_type, null)
              disk_size_gb    = try(rc.electable.disk_size, null)
            } : null
            analytics_specs = length(try(rc.analytics, {})) > 0 ? {
              instance_size   = try(rc.analytics.size, "M2")
              node_count      = try(rc.analytics.count, null)
              disk_iops       = try(rc.analytics.iops, null)
              ebs_volume_type = try(rc.analytics.volume_type, null)
              disk_size_gb    = try(rc.analytics.disk_size, null)
            } : null
            read_only_specs = length(try(rc.read_only, {})) > 0 ? {
              instance_size   = try(rc.read_only.size, "M2")
              node_count      = try(rc.read_only.count, null)
              disk_iops       = try(rc.read_only.iops, null)
              ebs_volume_type = try(rc.read_only.volume_type, null)
              disk_size_gb    = try(rc.read_only.disk_size, null)
            } : null
            auto_scaling = length(try(rc.auto_scaling, {})) > 0 ? {
              disk_gb_enabled            = try(rc.auto_scaling.disk, false)
              compute_max_instance_size  = try(rc.auto_scaling.max_size, null)
              compute_min_instance_size  = try(rc.auto_scaling.min_size, null)
              compute_scale_down_enabled = try(rc.auto_scaling.scale_down, false)
              compute_enabled            = try(rc.auto_scaling.compute, false)
            } : null
            analytics_auto_scaling = length(try(rc.auto_scaling.analytics, {})) > 0 ? {
              disk_gb_enabled            = try(rc.auto_scaling.analytics.disk, false)
              compute_max_instance_size  = try(rc.auto_scaling.analytics.max_size, null)
              compute_min_instance_size  = try(rc.auto_scaling.analytics.min_size, null)
              compute_scale_down_enabled = try(rc.auto_scaling.analytics.scale_down, false)
              compute_enabled            = try(rc.auto_scaling.analytics.compute, false)
            } : null
          }
        ]
      }
    ],
    # Additional shards for SHARDED / GEOSHARDED cluster types (one entry per shard)
    [
      for shard in try(var.settings.shards, []) : {
        zone_name = try(shard.zone_name, null)
        region_configs = [
          for rc in try(shard.regions, []) : {
            backing_provider_name = try(rc.backing_provider, null)
            provider_name         = try(rc.provider, "TENANT")
            region_name           = upper(replace(try(rc.region, local.atlas_region), "-", "_"))
            priority              = try(rc.priority, 7)
            electable_specs = length(try(rc.electable, {})) > 0 ? {
              instance_size   = try(rc.electable.size, "M2")
              node_count      = try(rc.electable.count, null)
              disk_iops       = try(rc.electable.iops, null)
              ebs_volume_type = try(rc.electable.volume_type, null)
              disk_size_gb    = try(rc.electable.disk_size, null)
            } : null
            analytics_specs = length(try(rc.analytics, {})) > 0 ? {
              instance_size   = try(rc.analytics.size, "M2")
              node_count      = try(rc.analytics.count, null)
              disk_iops       = try(rc.analytics.iops, null)
              ebs_volume_type = try(rc.analytics.volume_type, null)
              disk_size_gb    = try(rc.analytics.disk_size, null)
            } : null
            read_only_specs = length(try(rc.read_only, {})) > 0 ? {
              instance_size   = try(rc.read_only.size, "M2")
              node_count      = try(rc.read_only.count, null)
              disk_iops       = try(rc.read_only.iops, null)
              ebs_volume_type = try(rc.read_only.volume_type, null)
              disk_size_gb    = try(rc.read_only.disk_size, null)
            } : null
            auto_scaling = length(try(rc.auto_scaling, {})) > 0 ? {
              disk_gb_enabled            = try(rc.auto_scaling.disk, false)
              compute_max_instance_size  = try(rc.auto_scaling.max_size, null)
              compute_min_instance_size  = try(rc.auto_scaling.min_size, null)
              compute_scale_down_enabled = try(rc.auto_scaling.scale_down, false)
              compute_enabled            = try(rc.auto_scaling.compute, false)
            } : null
            analytics_auto_scaling = length(try(rc.auto_scaling.analytics, {})) > 0 ? {
              disk_gb_enabled            = try(rc.auto_scaling.analytics.disk, false)
              compute_max_instance_size  = try(rc.auto_scaling.analytics.max_size, null)
              compute_min_instance_size  = try(rc.auto_scaling.analytics.min_size, null)
              compute_scale_down_enabled = try(rc.auto_scaling.analytics.scale_down, false)
              compute_enabled            = try(rc.auto_scaling.analytics.compute, false)
            } : null
          }
        ]
      }
    ]
  )
  tags = { for k, v in local.all_tags : k => replace(v, "/[/$%&#]/", "+") }
}

resource "mongodbatlas_cloud_backup_schedule" "this" {
  count                                    = try(var.settings.backup.enabled, false) ? 1 : 0
  cluster_name                             = mongodbatlas_advanced_cluster.this.name
  project_id                               = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
  reference_hour_of_day                    = try(var.settings.backup.hour_of_day, 0)
  reference_minute_of_hour                 = try(var.settings.backup.minute_of_hour, 0)
  restore_window_days                      = try(var.settings.backup.restore_window_days, 1)
  auto_export_enabled                      = try(var.settings.backup.auto_export, null)
  use_org_and_group_names_in_export_prefix = try(var.settings.backup.export_prefix, null)
  dynamic "policy_item_hourly" {
    for_each = length(try(var.settings.backup.hourly, {})) > 0 ? [var.settings.backup.hourly] : []
    content {
      frequency_interval = try(policy_item_hourly.value.interval, 1)
      retention_unit     = try(policy_item_hourly.value.retention_unit, "days")
      retention_value    = try(policy_item_hourly.value.retention_value, 1)
    }
  }
  dynamic "policy_item_daily" {
    for_each = length(try(var.settings.backup.daily, {})) > 0 ? [var.settings.backup.daily] : []
    content {
      frequency_interval = try(policy_item_daily.value.interval, 1)
      retention_unit     = try(policy_item_daily.value.retention_unit, "days")
      retention_value    = try(policy_item_daily.value.retention_value, 7)
    }
  }
  dynamic "policy_item_weekly" {
    for_each = length(try(var.settings.backup.weekly, {})) > 0 ? [var.settings.backup.weekly] : []
    content {
      frequency_interval = try(policy_item_weekly.value.interval, 1)
      retention_unit     = try(policy_item_weekly.value.retention_unit, "weeks")
      retention_value    = try(policy_item_weekly.value.retention_value, 4)
    }
  }
  dynamic "policy_item_monthly" {
    for_each = length(try(var.settings.backup.monthly, {})) > 0 ? [var.settings.backup.monthly] : []
    content {
      frequency_interval = try(policy_item_monthly.value.interval, 1)
      retention_unit     = try(policy_item_monthly.value.retention_unit, "months")
      retention_value    = try(policy_item_monthly.value.retention_value, 12)
    }
  }
  dynamic "policy_item_yearly" {
    for_each = length(try(var.settings.backup.yearly, {})) > 0 ? [var.settings.backup.yearly] : []
    content {
      frequency_interval = try(policy_item_yearly.value.interval, 1)
      retention_unit     = try(policy_item_yearly.value.retention_unit, "years")
      retention_value    = try(policy_item_yearly.value.retention_value, 2)
    }
  }
  dynamic "export" {
    for_each = length(try(var.settings.backup.export, {})) > 0 ? [var.settings.backup.export] : []
    content {
      export_bucket_id = mongodbatlas_cloud_backup_snapshot_export_bucket.this[0].id
      frequency_type   = try(export.value.frequency_type, "daily")
    }
  }
  dynamic "copy_settings" {
    for_each = length(try(var.settings.backup.copy, {})) > 0 ? [var.settings.backup.copy] : []
    content {
      cloud_provider     = try(copy_settings.value.cloud_provider, try(var.settings.cloud_provider, "AWS"))
      frequencies        = try(copy_settings.value.frequencies, [])
      region_name        = try(copy_settings.value.region_name, local.atlas_region)
      zone_id            = mongodbatlas_advanced_cluster.this.replication_specs[0].zone_id
      should_copy_oplogs = try(copy_settings.value.copy_oplogs, false)
    }
  }
}

resource "mongodbatlas_cloud_backup_snapshot_export_bucket" "this" {
  count          = length(try(var.settings.backup.export, {})) > 0 ? 1 : 0
  project_id     = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
  cloud_provider = try(var.settings.backup.export.cloud_provider, try(var.settings.cloud_provider, "AWS"))
  bucket_name    = var.settings.backup.export.bucket_name
  iam_role_id    = try(var.settings.backup.export.iam_role_id, null)
  service_url    = try(var.settings.backup.export.service_url, null)
  role_id        = try(var.settings.backup.export.role_id, null)
}
