resource "kubernetes_service_account" "csi_driver" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.ebs_controller_role.this_iam_role_arn
    }
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "provisioner" {
  metadata {
    name = "ebs-external-provisioner-role"
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
    verbs      = ["get", "list", "watch", "update"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["list", "watch", "create", "update", "patch"]
  }

  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshots"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["csinodes"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["get", "watch", "list", "delete", "update", "create"]
  }
}

resource "kubernetes_cluster_role_binding" "provisioner" {
  metadata {
    name = "ebs-csi-provisioner-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.provisioner.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.csi_driver.metadata[0].name
    namespace = kubernetes_service_account.csi_driver.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role" "attacher" {
  metadata {
    name = "ebs-external-attacher-role"
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["csi.storage.k8s.io"]
    resources  = ["csinodeinfos"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments"]
    verbs      = ["get", "list", "watch", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "attacher" {
  metadata {
    name = "ebs-csi-attacher-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.attacher.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.csi_driver.metadata[0].name
    namespace = kubernetes_service_account.csi_driver.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role" "resizer" {
  count = var.enable_volume_resizing ? 1 : 0

  metadata {
    name = "ebs-external-resizer-role"
  }

  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents"]
    verbs      = ["create", "get", "list", "watch", "update", "delete"]
  }

  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["list", "watch", "create", "update", "patch"]
  }
}

resource "kubernetes_cluster_role_binding" "resizer" {
  count = var.enable_volume_resizing ? 1 : 0

  metadata {
    name = "ebs-csi-resizer-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.resizer[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.csi_driver.metadata[0].name
    namespace = kubernetes_service_account.csi_driver.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role" "snapshotter" {
  count = var.enable_volume_snapshot ? 1 : 0

  metadata {
    name = "ebs-external-snapshotter-role"
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "update", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims/status"]
    verbs      = ["update", "patch"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["list", "watch", "create", "update", "patch"]
  }
}

resource "kubernetes_cluster_role_binding" "snapshotter" {
  count = var.enable_volume_snapshot ? 1 : 0

  metadata {
    name = "ebs-csi-snapshotter-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.snapshotter[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.csi_driver.metadata[0].name
    namespace = kubernetes_service_account.csi_driver.metadata[0].namespace
  }
}