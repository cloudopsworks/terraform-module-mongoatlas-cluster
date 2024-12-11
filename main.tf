##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

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
  dynamic "bi_connector_config" {
    for_each = length(try(var.settings.bi_connector, {})) > 0 ? [var.settings.bi_connector] : []
    content {
      enabled         = try(bi_connector_config.value.enabled, false)
      read_preference = try(bi_connector_config.value.read_preference, "secondary")
    }
  }
  dynamic "advanced_configuration" {
    for_each = length(try(var.settings.advanced, {})) > 0 ? [var.settings.advanced] : []
    content {
      default_write_concern                = try(advanced_configuration.value.default_write_concern, null)
      javascript_enabled                   = try(advanced_configuration.value.javascript, null)
      minimum_enabled_tls_protocol         = try(advanced_configuration.value.tls_protocol, null)
      no_table_scan                        = try(advanced_configuration.value.no_table_scan, null)
      oplog_size_mb                        = try(advanced_configuration.value.oplog_size, null)
      oplog_min_retention_hours            = try(advanced_configuration.value.oplog_retention, null)
      sample_size_bi_connector             = try(advanced_configuration.value.bi.sample_size, null)
      sample_refresh_interval_bi_connector = try(advanced_configuration.value.bi.refresh_interval, null)
      transaction_lifetime_limit_seconds   = try(advanced_configuration.value.transaction_lifetime, null)
    }
  }
  replication_specs {
    num_shards = try(var.settings.shards, null)
    zone_name  = try(var.settings.global.zone_name, null)
    zone_id    = try(var.settings.global.zone_id, null)
    dynamic "region_configs" {
      for_each = try(var.settings.regions, [])
      content {
        backing_provider_name = try(region_configs.value.backing_provider, null)
        provider_name         = try(region_configs.value.provider, "TENANT")
        region_name           = upper(replace(try(region_configs.value.region, "us-east-1"), "-", "_"))
        priority              = try(region_configs.value.priority, 7)
        dynamic "electable_specs" {
          for_each = length(try(region_configs.value.electable, {})) > 0 ? [region_configs.value.electable] : []
          content {
            instance_size   = try(electable_specs.value.size, "M2")
            node_count      = try(electable_specs.value.count, null)
            disk_iops       = try(electable_specs.value.iops, null)
            ebs_volume_type = try(electable_specs.value.volume_type, null)
            disk_size_gb    = try(electable_specs.value.disk_size, null)
          }
        }
        dynamic "analytics_specs" {
          for_each = length(try(region_configs.value.analytics, {})) > 0 ? [region_configs.value.analytics] : []
          content {
            instance_size   = try(analytics_specs.value.size, "M2")
            node_count      = try(analytics_specs.value.count, null)
            disk_iops       = try(analytics_specs.value.iops, null)
            ebs_volume_type = try(analytics_specs.value.volume_type, null)
            disk_size_gb    = try(analytics_specs.value.disk_size, null)
          }
        }
        dynamic "read_only_specs" {
          for_each = length(try(region_configs.value.read_only, {})) > 0 ? [region_configs.value.read_only] : []
          content {
            instance_size   = try(read_only_specs.value.size, "M2")
            node_count      = try(read_only_specs.value.count, null)
            disk_iops       = try(read_only_specs.value.iops, null)
            ebs_volume_type = try(read_only_specs.value.volume_type, null)
            disk_size_gb    = try(read_only_specs.value.disk_size, null)
          }
        }

        dynamic "auto_scaling" {
          for_each = length(try(region_configs.value.auto_scaling, {})) > 0 ? [region_configs.value.auto_scaling] : []
          content {
            disk_gb_enabled            = try(auto_scaling.value.disk, false)
            compute_max_instance_size  = try(auto_scaling.value.max_size, null)
            compute_min_instance_size  = try(auto_scaling.value.min_size, null)
            compute_scale_down_enabled = try(auto_scaling.value.scale_down, false)
            compute_enabled            = try(auto_scaling.value.compute, false)
          }
        }

        dynamic "analytics_auto_scaling" {
          for_each = length(try(region_configs.value.auto_scaling.analytics, {})) > 0 ? [region_configs.value.auto_scaling.analytics] : []
          content {
            disk_gb_enabled            = try(analytics_auto_scaling.value.disk, false)
            compute_max_instance_size  = try(analytics_auto_scaling.value.max_size, null)
            compute_min_instance_size  = try(analytics_auto_scaling.value.min_size, null)
            compute_scale_down_enabled = try(analytics_auto_scaling.value.scale_down, false)
            compute_enabled            = try(analytics_auto_scaling.value.compute, false)
          }
        }
      }
    }
  }
  dynamic "tags" {
    for_each = local.all_tags
    content {
      key   = tags.key
      value = replace(tags.value, "/[/$%&#]/", "+")
    }
  }
}