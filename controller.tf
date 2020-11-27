locals {
  provisioner_args = [
    "--csi-address=$(ADDRESS)",
    "--v=5",
    "--feature-gates=Topology=true",
    "--leader-election",
  ]
  provisioner_args_with_metadata = concat(provisioner_args, ["--extra-create-metadata"])
}

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
          image = "amazon/aws-ebs-csi-driver:${local.ebs_csi_driver_version}"
          args = [
            "--endpoint=$(CSI_ENDPOINT)",
            "--logtostderr",
            "--v=5",
            "--extra-tags=${local.csi_volume_tags}"
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
          image = "quay.io/k8scsi/csi-provisioner:v2.0.4"
          args  = var.extra_create_metadata ? local.provisioner_args_with_metadata : local.provisioner_args

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
          image = "quay.io/k8scsi/csi-attacher:v3.0.2"
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
          image = "quay.io/k8scsi/livenessprobe:${local.liveness_probe_version}"
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
