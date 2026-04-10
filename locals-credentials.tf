##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  admin_password   = try(var.settings.admin_user.enabled, false) ? (
    try(var.settings.admin_user.rotation_lambda_name, "") == "" ? random_password.randompass[0].result : random_password.randompass_rotated[0].result
  ) : null
  conn_str_arr     = split("//", try(mongodbatlas_advanced_cluster.this.connection_strings.0.standard, ""))
  conn_str_srv_arr = split("//", try(mongodbatlas_advanced_cluster.this.connection_strings.0.standard_srv, ""))
  conn_str = try(var.settings.admin_user.enabled, false) ? (
    length(local.conn_str_arr) > 1 ?
    format("%s//%s:%s@%s", local.conn_str_arr[0], mongodbatlas_database_user.admin_user[0].username, local.admin_password, local.conn_str_arr[1])
    : ""
  ) : ""
  conn_str_srv = try(var.settings.admin_user.enabled, false) ? (
    length(local.conn_str_srv_arr) > 1 ?
    format("%s//%s:%s@%s", local.conn_str_srv_arr[0], mongodbatlas_database_user.admin_user[0].username, local.admin_password, local.conn_str_srv_arr[1])
    : ""
  ) : ""
  pvt_conn_str_arr     = length(mongodbatlas_advanced_cluster.this.connection_strings.0.private_endpoint) > 0 ? split("//", mongodbatlas_advanced_cluster.this.connection_strings.0.private_endpoint.0.connection_string) : []
  pvt_conn_str_srv_arr = length(mongodbatlas_advanced_cluster.this.connection_strings.0.private_endpoint) > 0 ? split("//", mongodbatlas_advanced_cluster.this.connection_strings.0.private_endpoint.0.srv_connection_string) : []
  pvt_conn_str = try(var.settings.admin_user.enabled, false) ? (
    length(local.pvt_conn_str_arr) > 1 ?
    format("%s//%s:%s@%s", local.pvt_conn_str_arr[0], mongodbatlas_database_user.admin_user[0].username, local.admin_password, local.pvt_conn_str_arr[1])
    : ""
  ) : ""
  pvt_conn_str_srv = try(var.settings.admin_user.enabled, false) ? (
    length(local.pvt_conn_str_srv_arr) > 1 ?
    format("%s//%s:%s@%s", local.pvt_conn_str_srv_arr[0], mongodbatlas_database_user.admin_user[0].username, local.admin_password, local.pvt_conn_str_srv_arr[1])
    : ""
  ) : ""
  cluster_credentials = try(var.settings.admin_user.enabled, false) ? {
    username                        = mongodbatlas_database_user.admin_user[0].username
    password                        = local.admin_password
    project_name                    = var.project_name != "" ? var.project_name : data.mongodbatlas_project.this_id[0].name
    project_id                      = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
    auth_database                   = try(var.settings.admin_user.auth_database, "admin")
    engine                          = "mongodbatlas"
    url                             = mongodbatlas_advanced_cluster.this.connection_strings.0.standard
    srv_url                         = mongodbatlas_advanced_cluster.this.connection_strings.0.standard_srv
    connection_string               = local.conn_str
    connection_string_srv           = local.conn_str_srv
    private_connection_string       = local.pvt_conn_str
    private_connection_string_srv   = local.pvt_conn_str_srv
    cluster_name                    = mongodbatlas_advanced_cluster.this.name
  } : null
}
