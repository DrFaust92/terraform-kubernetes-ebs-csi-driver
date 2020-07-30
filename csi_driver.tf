resource "kubernetes_csi_driver" "ebs" {
  metadata {
    name = "ebs.csi.aws.com"
  }

  spec {
    attach_required   = true
    pod_info_on_mount = false
  }
}