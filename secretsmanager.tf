##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  conn_str_arr         = split("//", try(mongodbatlas_advanced_cluster.this.connection_strings.0.standard, ""))
  conn_str_srv_arr     = split("//", try(mongodbatlas_advanced_cluster.this.connection_strings.0.standard_srv, ""))
  conn_str             = length(local.conn_str_arr) > 1 ? format("%s//%s:%s@%s", local.conn_str_arr[0], mongodbatlas_database_user.admin_user[0].username, random_password.randompass[0].result, local.conn_str_arr[1]) : ""
  conn_str_srv         = length(local.conn_str_srv_arr) > 1 ? format("%s//%s:%s@%s", local.conn_str_srv_arr[0], mongodbatlas_database_user.admin_user[0].username, random_password.randompass[0].result, local.conn_str_srv_arr[1]) : ""
  pvt_conn_str_arr     = length(mongodbatlas_advanced_cluster.this.connection_strings.0.private_endpoint) > 0 ? split("//", mongodbatlas_advanced_cluster.this.connection_strings.0.private_endpoint.0.connection_string) : []
  pvt_conn_str_srv_arr = length(mongodbatlas_advanced_cluster.this.connection_strings.0.private_endpoint) > 0 ? split("//", mongodbatlas_advanced_cluster.this.connection_strings.0.private_endpoint.0.srv_connection_string) : []
  pvt_conn_str         = length(local.pvt_conn_str_arr) > 1 ? format("%s//%s:%s@%s", local.pvt_conn_str_arr[0], mongodbatlas_database_user.admin_user[0].username, random_password.randompass[0].result, local.pvt_conn_str_arr[1]) : ""
  pvt_conn_str_srv     = length(local.pvt_conn_str_srv_arr) > 1 ? format("%s//%s:%s@%s", local.pvt_conn_str_srv_arr[0], mongodbatlas_database_user.admin_user[0].username, random_password.randompass[0].result, local.pvt_conn_str_srv_arr[1]) : ""
  mongodb_credentials = try(var.settings.admin_user.enabled, false) ? {
    username                       = mongodbatlas_database_user.admin_user[0].username
    password                       = random_password.randompass[0].result
    engine                         = "mongodbatlas"
    url                            = mongodbatlas_advanced_cluster.this.connection_strings.0.standard
    srv_url                        = mongodbatlas_advanced_cluster.this.connection_strings.0.standard_srv
    connection_string              = local.conn_str
    connection_string_srv          = local.conn_str_srv
    private_connection_strings     = local.pvt_conn_str
    private_connection_strings_srv = local.pvt_conn_str_srv
    cluster_name                   = mongodbatlas_advanced_cluster.this.name
  } : null
}

# Secrets saving
resource "aws_secretsmanager_secret" "atlas_cred" {
  count       = try(var.settings.admin_user.enabled, false) ? 1 : 0
  name        = "${local.secret_store_path}/mongodbatlas/${mongodbatlas_advanced_cluster.this.name}/admin-user-credentials"
  description = "Mongodbatlas Admin credentials - ${mongodbatlas_database_user.admin_user[0].username} - ${mongodbatlas_advanced_cluster.this.name}"
  tags        = local.all_tags
}

resource "aws_secretsmanager_secret_version" "atlas_cred" {
  count         = try(var.settings.admin_user.enabled, false) ? 1 : 0
  secret_id     = aws_secretsmanager_secret.atlas_cred[count.index].id
  secret_string = jsonencode(local.mongodb_credentials)
}

data "aws_lambda_function" "rotation_function" {
  count         = try(var.settings.admin_user.enabled, false) && try(var.settings.admin_user.rotation_lambda_name, "") != "" ? 1 : 0
  function_name = var.settings.admin_user.rotation_lambda_name
}

resource "aws_secretsmanager_secret_rotation" "user" {
  count               = try(var.settings.admin_user.enabled, false) && try(var.settings.admin_user.rotation_lambda_name, "") != "" ? 1 : 0
  secret_id           = aws_secretsmanager_secret.atlas_cred[0].id
  rotation_lambda_arn = data.aws_lambda_function.rotation_function[count.index].arn

  rotation_rules {
    automatically_after_days = try(var.settings.admin_user.rotation_period, 90)
    duration                 = try(var.settings.admin_user.rotation_duration, "1h")
  }
}
