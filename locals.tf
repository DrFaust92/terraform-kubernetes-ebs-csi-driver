locals {
  ebs_csi_driver_version = var.ebs_csi_driver_version == "" ? "v1.6.2" : var.ebs_csi_driver_version
  liveness_probe_version = "v2.5.0"
  controller_name        = "ebs-csi-controller"
  daemonset_name         = "ebs-csi-node"
  csi_volume_tags        = join(",", [for key, value in var.tags : "${key}=${value}"])

  resizer_container = var.enable_volume_resizing ? [{
    name  = "csi-resizer",
    image = "k8s.gcr.io/sig-storage/csi-resizer:v1.4.0"
  }] : []

  snapshot_container = var.enable_volume_snapshot ? [{
    name  = "csi-snapshotter",
    image = "k8s.gcr.io/sig-storage/csi-snapshotter:v6.0.1"
  }] : []
}
