locals {
  controller_name = "ebs-csi-controller"
  daemonset_name  = "ebs-csi-node"
  csi_volume_tags = join(",", [for key, value in var.tags : "${key}=${value}"])

  resizer_container = var.enable_volume_resizing ? [{
    name  = "csi-resizer",
    image = "${var.csi_resizer_image}:${var.csi_resizer_version}"
  }] : []

  snapshot_container = var.enable_volume_snapshot ? [{
    name  = "csi-snapshotter",
    image = "${var.csi_snapshotter_image}:${var.csi_snapshotter_version}"
  }] : []

  # backwards compatibility: use default value when value is an empty string
  ebs_csi_driver_version   = var.ebs_csi_driver_version == "" ? "v1.6.2" : var.ebs_csi_driver_version
  ebs_csi_controller_image = var.ebs_csi_controller_image == "" ? "registry.k8s.io/provider-aws/aws-ebs-csi-driver" : var.ebs_csi_controller_image
}
