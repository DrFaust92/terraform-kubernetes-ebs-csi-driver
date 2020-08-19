locals {
  controller_name = "ebs-csi-controller"
  daemonset_name  = "ebs-csi-node"
  csi_volume_tags = join(",", [for key, value in var.tags : "${key}=${value}"])

  resizer_container = var.enable_volume_resizing ? [{
    name  = "csi-resizer",
    image = "quay.io/k8scsi/csi-resizer:v0.5.0"
  }] : []

  snapshot_container = var.enable_volume_snapshot ? [{
    name  = "csi-snapshotter",
    image = "quay.io/k8scsi/csi-snapshotter:v2.1.1"
  }] : []
}
