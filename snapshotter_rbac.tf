resource "kubernetes_service_account" "snapshotter" {
  count = var.enable_volume_snapshot ? 1 : 0

  metadata {
    name      = local.snapshotter_name
    namespace = var.namespace
  }
}

resource "kubernetes_role" "snapshotter_leader_election" {
  count = var.enable_volume_snapshot ? 1 : 0

  metadata {
    name      = "ebs-snapshot-controller-leaderelection"
    namespace = var.namespace
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["get", "watch", "list", "delete", "update", "create"]
  }
}

resource "kubernetes_role_binding" "snapshotter_leader_election" {
  count = var.enable_volume_snapshot ? 1 : 0

  metadata {
    name      = "snapshot-controller-leaderelection"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.snapshotter_leader_election[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.snapshotter[0].metadata[0].name
    namespace = kubernetes_service_account.snapshotter[0].metadata[0].namespace
  }
}