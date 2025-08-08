##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

resource "random_password" "randompass" {
  count            = try(var.settings.admin_user.enabled, false) && try(var.settings.admin_user.rotation_lambda_name, "") == "" ? 1 : 0
  length           = 20
  special          = false
  override_special = "=_-"
  min_upper        = 2
  min_special      = 0
  min_numeric      = 2
  min_lower        = 2

  lifecycle {
    replace_triggered_by = [
      time_rotating.randompass[0].rotation_rfc3339
    ]
  }
}

resource "random_password" "randompass_rotated" {
  count            = try(var.settings.admin_user.enabled, false) && try(var.settings.admin_user.rotation_lambda_name, "") != "" ? 1 : 0
  length           = 20
  special          = false
  override_special = "=_-"
  min_upper        = 2
  min_special      = 0
  min_numeric      = 2
  min_lower        = 2

  lifecycle {
    replace_triggered_by = [
      time_rotating.randompass[0].rotation_rfc3339
    ]
  }
}

resource "time_rotating" "randompass" {
  count         = try(var.settings.admin_user.enabled, false) ? 1 : 0
  rotation_days = try(var.settings.admin_user.password_rotation_period, 90)
}
