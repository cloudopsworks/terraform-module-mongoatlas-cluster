##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

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
  value = merge(mongodbatlas_advanced_cluster.this.replication_specs.*.container_id)
}

output "cluster_server_type" {
  value = mongodbatlas_advanced_cluster.this.config_server_type
}