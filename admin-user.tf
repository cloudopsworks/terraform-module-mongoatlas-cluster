##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

resource "mongodbatlas_database_user" "admin_user" {
  count              = try(var.settings.admin_user.enabled, false) ? 1 : 0
  auth_database_name = try(var.settings.admin_user.auth_database, "admin")
  project_id         = var.project_id != "" ? var.project_id : data.mongodbatlas_project.this[0].id
  username           = try(var.settings.admin_user.username, "${var.name != "" ? lower(var.name) : format("%s-%s", var.name_prefix, local.system_name_short)}-admin-user")
  password           = random_password.randompass[count.index].result

  roles {
    database_name = "admin"
    role_name     = "atlasAdmin"
  }

  scopes {
    name = mongodbatlas_advanced_cluster.this.name
    type = "CLUSTER"
  }

  labels {
    key   = "is-admin"
    value = "true"
  }

  dynamic "labels" {
    for_each = local.all_tags
    content {
      key   = labels.key
      value = replace(labels.value, "/[/$%&#]/", "+")
    }
  }
}