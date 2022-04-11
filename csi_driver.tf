resource "kubernetes_csi_driver_v1" "ebs" {
  metadata {
    name = "ebs.csi.aws.com"
  }

  spec {
    attach_required        = true
    pod_info_on_mount      = false
    volume_lifecycle_modes = ["Persistent"]
  }
}
