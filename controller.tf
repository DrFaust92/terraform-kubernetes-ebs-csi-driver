resource "kubernetes_deployment" "ebs_csi_controller" {
  metadata {
    name      = local.controller_name
    namespace = var.namespace
  }
  spec {
    replicas = var.csi_controller_replica_count

    selector {
      match_labels = {
        app = local.controller_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.controller_name
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
          image = "amazon/aws-ebs-csi-driver:v0.6.0"
          args = [
            "--endpoint=$(CSI_ENDPOINT)",
            "--logtostderr",
            "--v=5",
            "--extra-volume-tags=${local.csi_volume_tags}"
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
          image = "quay.io/k8scsi/csi-attacher:v2.2.0"
          args = [
            "--csi-address=$(ADDRESS)",
            "--v=5",
            "--leader-election=true",
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

        dynamic "container" {
          for_each = local.resizer_container

          content {
            name  = lookup(container.value, "name", null)
            image = lookup(container.value, "image", null)

            args = [
              "--csi-address=$(ADDRESS)",
              "--v=5"
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
        }

        dynamic "container" {
          for_each = local.snapshot_container

          content {
            name  = lookup(container.value, "name", null)
            image = lookup(container.value, "image", null)

            args = [
              "--csi-address=$(ADDRESS)",
              "--leader-election=true"
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
    kubernetes_cluster_role_binding.provisioner,
    kubernetes_csi_driver.ebs,
  ]
}
