##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

output "cluster_name" {
  value = mongodbatlas_advanced_cluster.this.name
}

output "cluster_id" {
  value = mongodbatlas_advanced_cluster.this.cluster_id
}

output "cluster_version" {
  value = mongodbatlas_advanced_cluster.this.mongo_db_version
}

output "cluster_connection_strings" {
  value = mongodbatlas_advanced_cluster.this.connection_strings
}

output "cluster_state" {
  value = mongodbatlas_advanced_cluster.this.state_name
}

output "cluster_containers" {
  value = merge(mongodbatlas_advanced_cluster.this.replication_specs.*.container_id...)
}

output "cluster_server_type" {
  value = mongodbatlas_advanced_cluster.this.config_server_type
}

output "cluster_admin_user" {
  value = try(var.settings.admin_user.enabled, false) ? mongodbatlas_database_user.admin_user[0].username : ""
}

output "cluster_credentials" {
  description = "Full credentials map including username, password, connection strings. Sensitive — consumed by cloud-specific wrapper modules to store in their secret store."
  value       = local.cluster_credentials
  sensitive   = true
}