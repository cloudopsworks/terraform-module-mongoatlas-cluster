##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  mongodb_credentials = try(var.settings.admin_user.enabled, false) ? {
    username                       = mongodbatlas_database_user.admin_user[0].username
    password                       = random_password.randompass[0].result
    engine                         = "mongodbatlas"
    connection_strings             = mongodbatlas_advanced_cluster.this.connection_strings.*.standard
    connection_strings_srv         = mongodbatlas_advanced_cluster.this.connection_strings.*.standard_srv
    private_connection_strings     = flatten(mongodbatlas_advanced_cluster.this.connection_strings.*.private_endpoint.0.connection_string)
    private_connection_strings_srv = flatten(mongodbatlas_advanced_cluster.this.connection_strings.*.private_endpoint.0.srv_connection_string)
    cluster_name                   = mongodbatlas_advanced_cluster.this.name
  } : {}
}

# Secrets saving
resource "aws_secretsmanager_secret" "dbuser" {
  count = try(var.settings.admin_user.enabled, false) ? 1 : 0
  name  = "${local.secret_store_path}/mongodbatlas/${mongodbatlas_advanced_cluster.this.name}/admin_user"
  tags  = local.all_tags
}

resource "aws_secretsmanager_secret_version" "dbuser" {
  count         = try(var.settings.admin_user.enabled, false) ? 1 : 0
  secret_id     = aws_secretsmanager_secret.dbuser[count.index].id
  secret_string = mongodbatlas_database_user.admin_user[count.index].username
}

resource "aws_secretsmanager_secret" "randompass" {
  count = try(var.settings.admin_user.enabled, false) ? 1 : 0
  name  = "${local.secret_store_path}/mongodbatlas/${mongodbatlas_advanced_cluster.this.name}/admin_user_password"
  tags  = local.all_tags
}

resource "aws_secretsmanager_secret_version" "randompass" {
  count         = try(var.settings.admin_user.enabled, false) ? 1 : 0
  secret_id     = aws_secretsmanager_secret.randompass[count.index].id
  secret_string = random_password.randompass[count.index].result
}

# Secrets saving
resource "aws_secretsmanager_secret" "atlas_cred" {
  count = try(var.settings.admin_user.enabled, false) ? 1 : 0
  name  = "${local.secret_store_path}/mongodbatlas/${mongodbatlas_advanced_cluster.this.name}/mongodbatlas-credentials"
  tags  = local.all_tags
}

resource "aws_secretsmanager_secret_version" "atlas_cred" {
  count         = try(var.settings.admin_user.enabled, false) ? 1 : 0
  secret_id     = aws_secretsmanager_secret.atlas_cred[count.index].id
  secret_string = jsonencode(local.mongodb_credentials)
}
