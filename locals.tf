locals {
  ebs_csi_driver_version = var.ebs_csi_driver_version == "" ? "v0.8.1-amazonlinux" : var.ebs_csi_driver_version
  liveness_probe_version = "v2.2.0"
  controller_name        = "ebs-csi-controller"
  daemonset_name         = "ebs-csi-node"
  csi_volume_tags        = join(",", [for key, value in var.tags : "${key}=${value}"])

  resizer_container = var.enable_volume_resizing ? [{
    name  = "csi-resizer",
    image = "quay.io/k8scsi/csi-resizer:v1.1.0"
  }] : []

  snapshot_container = var.enable_volume_snapshot ? [{
    name  = "csi-snapshotter",
    image = "quay.io/k8scsi/csi-snapshotter:v4.0.0"
  }] : []
}
