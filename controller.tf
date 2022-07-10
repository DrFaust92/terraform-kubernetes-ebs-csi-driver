resource "kubernetes_deployment" "ebs_csi_controller" {
  metadata {
    name      = local.controller_name
    namespace = var.namespace
    labels    = var.labels
    annotations = {
      "prometheus.io/port"   = "8080"
      "prometheus.io/scrape" = "false"
    }
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
        node_selector = merge({
          "kubernetes.io/os" : "linux",
        }, var.extra_node_selectors, var.controller_extra_node_selectors)

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
          image = "${var.ebs_csi_controller_image == "" ? "k8s.gcr.io/provider-aws/aws-ebs-csi-driver" : var.ebs_csi_controller_image}:${local.ebs_csi_driver_version}"
          args = compact(
            [
              "controller",
              "--endpoint=$(CSI_ENDPOINT)",
              "--http-endpoint=:8080",
              "--logtostderr",
              "--v=${tostring(var.log_level)}",
              length(local.csi_volume_tags) > 0 ? "--extra-tags=${local.csi_volume_tags}" : "",
              var.eks_cluster_id != "" ? "--k8s-tag-cluster-id=${var.eks_cluster_id}" : ""
            ]
          )

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:///var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          env {
            name = "CSI_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "AWS_EC2_ENDPOINT"
            value_from {
              config_map_key_ref {
                name     = "aws-meta"
                key      = "endpoint"
                optional = true
              }
            }
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
        }

        container {
          name  = "csi-provisioner"
          image = "k8s.gcr.io/sig-storage/csi-provisioner:${var.csi_provisioner_tag_version}"
          args = compact(
            [
              "--csi-address=$(ADDRESS)",
              "--v=${tostring(var.log_level)}",
              "--feature-gates=Topology=true",
              "--leader-election=true",
              var.extra_create_metadata ? "--extra-create-metadata" : "",
              var.enable_default_fstype ? "--default-fstype=${var.default_fstype}" : "",
            ]
          )

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
          image = "k8s.gcr.io/sig-storage/csi-attacher:v3.5.0"
          args = [
            "--csi-address=$(ADDRESS)",
            "--v=${tostring(var.log_level)}",
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
          image = "k8s.gcr.io/sig-storage/livenessprobe:${local.liveness_probe_version}"
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
              "--v=${tostring(var.log_level)}",
              var.enable_volume_resizing == true ? "--handle-volume-inuse-error=false" : "",
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
    kubernetes_csi_driver_v1.ebs,
  ]
}
