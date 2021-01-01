locals {
  ebs_csi_driver_version = "v0.8.0"
  liveness_probe_version = "v2.1.0"
  controller_name        = "ebs-csi-controller"
  daemonset_name         = "ebs-csi-node"
  csi_volume_tags        = join(",", [for key, value in var.tags : "${key}=${value}"])

  resizer_container = var.enable_volume_resizing ? [{
    name  = "csi-resizer",
    image = "quay.io/k8scsi/csi-resizer:v1.0.1"
  }] : []

  snapshot_container = var.enable_volume_snapshot ? [{
    name  = "csi-snapshotter",
    image = "quay.io/k8scsi/csi-snapshotter:v3.0.2"
  }] : []
}
