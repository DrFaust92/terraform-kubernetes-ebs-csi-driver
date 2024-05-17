resource "kubernetes_daemonset" "node" {
  metadata {
    name      = local.daemonset_name
    namespace = var.namespace
    labels    = var.labels
    annotations = {
      "prometheus.io/port"   = "8080"
      "prometheus.io/scrape" = "false"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["field.cattle.io/publicEndpoints"],
    ]
  }

  spec {
    selector {
      match_labels = {
        app = local.daemonset_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.daemonset_name
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "eks.amazonaws.com/compute-type"
                  operator = "NotIn"
                  values   = ["fargate"]
                }
              }
            }
          }
        }

        node_selector = merge({
          "kubernetes.io/os" : "linux",
        }, var.extra_node_selectors, var.node_extra_node_selectors)

        host_network                    = true
        service_account_name            = kubernetes_service_account.node.metadata[0].name
        automount_service_account_token = true
        priority_class_name             = "system-node-critical"

        dynamic "toleration" {
          for_each = var.node_tolerations
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
          image = "${local.ebs_csi_controller_image}:${local.ebs_csi_driver_version}"
          args = flatten([
            "node",
            "--http-endpoint=:8080",
            "--endpoint=$(CSI_ENDPOINT)",
            "--logtostderr",
            "--v=${tostring(var.log_level)}",
            var.volume_attach_limit == -1 ? [] : ["--volume-attach-limit=${var.volume_attach_limit}"]
          ])

          dynamic "lifecycle" {
            for_each = var.ebs_csi_plugin_pre_stop_command != null ? [1] : []
            content {
              pre_stop {
                exec {
                  command = var.ebs_csi_plugin_pre_stop_command
                }
              }
            }
          }

          security_context {
            privileged = true
          }

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:/csi/csi.sock"
          }

          env {
            name = "CSI_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          volume_mount {
            mount_path        = "/var/lib/kubelet"
            name              = "kubelet-dir"
            mount_propagation = "Bidirectional"
          }

          volume_mount {
            mount_path = "/csi"
            name       = "plugin-dir"
          }

          volume_mount {
            name       = "device-dir"
            mount_path = "/dev"
          }

          port {
            name           = "healthz"
            container_port = 9808
            host_port      = 9808
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

          readiness_probe {
            http_get {
              path = "/healthz"
              port = "healthz"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 3
            period_seconds        = 10
            failure_threshold     = 5
          }

          resources {
            requests = var.node_ebs_plugin_resources.requests
            limits   = var.node_ebs_plugin_resources.limits
          }
        }

        container {
          name  = "node-driver-registrar"
          image = "${var.csi_node_driver_registrar_image}:${var.csi_node_driver_registrar_version}"
          args = [
            "--csi-address=$(ADDRESS)",
            "--kubelet-registration-path=$(DRIVER_REG_SOCK_PATH)",
            "--v=${tostring(var.log_level)}",
          ]

          dynamic "lifecycle" {
            for_each = var.ebs_csi_registrar_pre_stop_command != null ? [1] : []
            content {
              pre_stop {
                exec {
                  command = var.ebs_csi_registrar_pre_stop_command
                }
              }
            }
          }

          env {
            name  = "ADDRESS"
            value = "/csi/csi.sock"
          }

          env {
            name  = "DRIVER_REG_SOCK_PATH"
            value = "/var/lib/kubelet/plugins/ebs.csi.aws.com/csi.sock"
          }

          volume_mount {
            mount_path = "/csi"
            name       = "plugin-dir"
          }

          volume_mount {
            mount_path = "/registration"
            name       = "registration-dir"
          }

          resources {
            requests = var.node_driver_registrar_resources.requests
            limits   = var.node_driver_registrar_resources.limits
          }
        }

        container {
          name  = "liveness-probe"
          image = "${var.liveness_probe_image}:${var.liveness_probe_version}"
          args = [
            "--csi-address=/csi/csi.sock"
          ]

          volume_mount {
            mount_path = "/csi"
            name       = "plugin-dir"
          }

          resources {
            requests = var.node_liveness_probe_resources.requests
            limits   = var.node_liveness_probe_resources.limits
          }
        }

        volume {
          name = "kubelet-dir"

          host_path {
            path = "/var/lib/kubelet"
            type = "Directory"
          }
        }

        volume {
          name = "plugin-dir"

          host_path {
            path = "/var/lib/kubelet/plugins/ebs.csi.aws.com/"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "registration-dir"

          host_path {
            path = "/var/lib/kubelet/plugins_registry/"
            type = "Directory"
          }
        }

        volume {
          name = "device-dir"

          host_path {
            path = "/dev"
            type = "Directory"
          }
        }
      }
    }
  }
}
