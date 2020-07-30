locals {
  csi_volume_tags = join(",", [for key, value in var.tags : "${key}=${value}"])
  controller_name = "ebs-csi-controller"
  daemonset_name  = "ebs-csi-node"
  resizer_container = var.enable_volume_resizing ? [{}] : [{
    name  = "csi-resizer",
    image = "quay.io/k8scsi/csi-resizer:v0.3.0"
  }]

  snapshot_container = var.enable_volume_snapshot ? [{}] : [{
    name  = "csi-snapshotter",
    image = "quay.io/k8scsi/csi-snapshotter:2.1.1"
  }]
}