locals {
  snapshotter_name = "ebs-snapshot-controller"
}

resource "kubernetes_stateful_set" "snapshot" {
  count = var.enable_volume_snapshot ? 1 : 0

  metadata {
    name      = local.snapshotter_name
    namespace = var.namespace
  }

  spec {
    service_name = local.snapshotter_name
    replicas     = 1

    selector {
      match_labels = {
        app = local.snapshotter_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.snapshotter_name
        }
      }

      spec {
        service_account_name            = kubernetes_service_account.snapshotter[0].metadata[0].name
        automount_service_account_token = true

        container {
          name  = "snapshot-controller"
          image = "quay.io/k8scsi/snapshot-controller:v2.1.1"
          args = [
            "--v=5",
            "--leader-election=false"
          ]
        }
      }
    }
  }
}