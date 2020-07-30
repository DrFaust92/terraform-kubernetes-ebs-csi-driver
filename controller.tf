locals {
  tags = join(",", [for key, value in var.tags : "${key}=${value}"])
  name = "ebs-csi-controller"
}

resource "kubernetes_deployment" "ebs_csi_controller" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }
  spec {
    replicas = var.csi_controller_replica_count
    selector {
      match_labels = {
        app = local.name
      }
    }
    template {
      metadata {
        labels = {
          app = local.name
        }
      }
      spec {
        node_selector = {
          "beta.kubernetes.io/os" : "linux",
          "kubernetes.io/arch" : "amd64"
        }

        service_account_name            = kubernetes_service_account.csi_driver.metadata[0].name
        automount_service_account_token = true
        priority_class_name             = "system-cluster-critical"

        toleration {
          operator = "Exists"
        }

        dynamic "toleration" {
          for_each = var.csi_controller_tolerations
          content {
            key                = lookup(toleration.value, "key", null)
            operator           = lookup(toleration.value, "operator", null)
            effect             = lookup(toleration.value, "effect", null)
            value              = lookup(toleration.value, "value", null)
            toleration_seconds = lookup(toleration.value, "toleration_seconds", null)
          }
        }

        container {
          name  = "ebs-plugin"
          image = "amazon/aws-ebs-csi-driver:v0.5.0"
          args = [
            "--endpoint=$(CSI_ENDPOINT)",
            "--logtostderr",
            "--v=5",
            "--extra-volume-tags=${local.tags}"
          ]
          env {
            name  = "CSI_ENDPOINT"
            value = "unix:///var/lib/csi/sockets/pluginproxy/csi.sock"
          }
          volume_mount {
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
            name       = "socket-dir"
          }
          port {
            name           = "healthz"
            container_port = 9808
            protocol       = "TCP"
          }
          liveness_probe {
            http_get {
              path = "/healthz"
              port = "healthz"
            }
            initial_delay_seconds = 10
            timeout_seconds       = 3
            period_seconds        = 10
            failure_threshold     = 5
          }
        }

        container {
          name  = "csi-provisioner"
          image = "quay.io/k8scsi/csi-provisioner:v1.6.0"
          args = [
            "--csi-address=$(ADDRESS)",
            "--v=5",
            "--feature-gates=Topology=true",
            "--enable-leader-election",
            "--leader-election-type=leases"
          ]
          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }
          volume_mount {
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
            name       = "socket-dir"
          }
        }

        container {
          name  = "csi-attacher"
          image = "quay.io/k8scsi/csi-attacher:v1.2.0"
          args = [
            "--csi-address=$(ADDRESS)",
            "--v=5",
            "--leader-election=true",
            "--leader-election-type=leases"
          ]
          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }
          volume_mount {
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
            name       = "socket-dir"
          }
        }

        container {
          name  = "liveness-probe"
          image = "quay.io/k8scsi/livenessprobe:v2.0.0"
          args = [
            "--csi-address=/csi/csi.sock"
          ]
          volume_mount {
            mount_path = "/csi"
            name       = "socket-dir"
          }
        }

        volume {
          name = "socket-dir"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [
    kubernetes_cluster_role_binding.attacher,
    kubernetes_cluster_role_binding.provisioner
  ]
}