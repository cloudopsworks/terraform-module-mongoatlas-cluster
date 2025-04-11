##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  hoop_tags = length(try(var.settings.hoop.tags, [])) > 0 ? join(" ", [for v in var.settings.hoop.tags : "--tags \"${v}\""]) : ""
  hoop_connection = try(var.settings.hoop.enabled, false) ? (<<EOT
hoop admin create connection ${lower(mongodbatlas_advanced_cluster.this.name)}-ow \
  --agent ${var.settings.hoop.agent} \
  --type database/mongodb \
  -e "CONNECTION_STRING=_aws:${aws_secretsmanager_secret.atlas_cred[0].name}:connection_string" \
  --overwrite \
  ${local.hoop_tags}
EOT
  ) : null
}

resource "null_resource" "hoop_connection" {
  count = local.hoop_connection != null && var.run_hoop ? 1 : 0
  provisioner "local-exec" {
    command     = local.hoop_connection
    interpreter = ["bash", "-c"]
  }
}

output "hoop_connection" {
  value = local.hoop_connection
}
