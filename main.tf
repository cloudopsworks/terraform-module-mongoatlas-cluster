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
  name                           = var.name != "" ? var.name : format("%s-%s", var.name_prefix, local.system_name_short)
  project_id                     = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
  cluster_type                   = try(var.settings.cluster_type, "REPLICASET")
  mongo_db_major_version         = var.settings.major_version
  termination_protection_enabled = var.settings.termination_protection
  version_release_system         = try(var.settings.version_release, "LTS")
  config_server_management_mode  = try(var.settings.config_server, "ATLAS_MANAGED")
  bi_connector_config {
    enabled         = try(var.settings.bi_connector.enabled, false)
    read_preference = try(var.settings.bi_connector.read_preference, "secondary")
  }
  advanced_configuration {
    default_write_concern                = try(var.settings.advanced.default_write_concern, "majority")
    javascript_enabled                   = try(var.settings.advanced.javascript, false)
    minimum_enabled_tls_protocol         = try(var.settings.advanced.tls_protocol, "TLS1_2")
    no_table_scan                        = try(var.settings.advanced.no_table_scan, false)
    oplog_size_mb                        = try(var.settings.advanced.oplog_size, null)
    oplog_min_retention_hours            = try(var.settings.advanced.oplog_retention, null)
    sample_size_bi_connector             = try(var.settings.advanced.bi.sample_size, null)
    sample_refresh_interval_bi_connector = try(var.settings.advanced.bi.refresh_interval, 300)
    transaction_lifetime_limit_seconds   = try(var.settings.advanced.transaction_lifetime, 60)
  }
  replication_specs {
    num_shards = try(var.settings.shards, null)
    zone_name  = try(var.settings.global.zone_name, null)
    zone_id    = try(var.settings.global.zone_id, null)
    dynamic "region_configs" {
      for_each = try(var.settings.regions, [])
      content {
        backing_provider_name = try(region_configs.value.backing_provider, "AWS")
        provider_name         = try(region_configs.value.provider, "TENANT")
        region_name           = upper(replace(try(region_configs.value.region, "us-east-1"), "-", "_"))
        priority              = try(region_configs.value.priority, 7)
        dynamic "electable_specs" {
          for_each = length(try(region_configs.value.electable, {})) > 0 ? [region_configs.value.electable] : []
          content {
            instance_size   = try(electable_specs.value.size, "M2")
            node_count      = try(electable_specs.value.count, 3)
            disk_iops       = try(electable_specs.value.iops, null)
            ebs_volume_type = try(electable_specs.value.volume_type, "STANDARD")
            disk_size_gb    = try(electable_specs.value.size_gb, null)
          }
        }
        dynamic "analytics_specs" {
          for_each = length(try(region_configs.value.analytics, {})) > 0 ? [region_configs.value.analytics] : []
          content {
            instance_size   = try(analytics_specs.value.size, "M2")
            node_count      = try(analytics_specs.value.count, 3)
            disk_iops       = try(analytics_specs.value.iops, null)
            ebs_volume_type = try(analytics_specs.value.volume_type, "STANDARD")
            disk_size_gb    = try(analytics_specs.value.size_gb, null)
          }
        }
        dynamic "read_only_specs" {
          for_each = length(try(region_configs.value.read_only, {})) > 0 ? [region_configs.value.read_only] : []
          content {
            instance_size   = try(read_only_specs.value.size, "M2")
            node_count      = try(read_only_specs.value.count, 3)
            disk_iops       = try(read_only_specs.value.iops, null)
            ebs_volume_type = try(read_only_specs.value.volume_type, "STANDARD")
            disk_size_gb    = try(read_only_specs.value.size_gb, null)
          }
        }
        auto_scaling {
          disk_gb_enabled = try(region_configs.value.auto_scaling.disk, false)
          compute_enabled = try(region_configs.value.auto_scaling.compute, false)
        }
        analytics_auto_scaling {
          disk_gb_enabled = try(region_configs.value.auto_scaling.analytics.disk, false)
          compute_enabled = try(region_configs.value.auto_scaling.analytics.compute, false)
        }
      }
    }
  }
  dynamic "tags" {
    for_each = local.all_tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}