variable "ebs_csi_controller_role_name" {
  description = "The name of the EBS CSI driver IAM role"
  default     = "ebs-csi-driver-controller"
  type        = string
}

variable "ebs_csi_controller_role_policy_name_prefix" {
  description = "The prefix of the EBS CSI driver IAM policy"
  default     = "ebs-csi-driver-policy"
  type        = string
}

# for backwards compatibility see locals.tf
variable "ebs_csi_driver_version" {
  description = "The EBS CSI driver controller's image version"
  default     = "v1.6.2"
  type        = string
}

# for backwards compatibility see locals.tf
variable "ebs_csi_controller_image" {
  description = "The EBS CSI driver controller's image"
  default     = "registry.k8s.io/provider-aws/aws-ebs-csi-driver"
  type        = string
}

variable "ebs_csi_plugin_pre_stop_command" {
  type = list(string)
  default = ["/bin/aws-ebs-csi-driver", "pre-stop-hook"]
  description = "The pre-stop command for the EBS CSI driver plugin container"
}

variable "csi_node_driver_registrar_version" {
  description = "The CSI node driver registrar image version"
  default     = "v2.9.0"
  type        = string
}

variable "csi_node_driver_registrar_image" {
  description = "The CSI node driver registrar image"
  default     = "registry.k8s.io/sig-storage/csi-node-driver-registrar"
  type        = string
}

variable "ebs_csi_registrar_pre_stop_command" {
  type = list(string)
  default = null
  description = "The pre-stop command for the EBS CSI driver registrar container"
}

variable "csi_attacher_version" {
  description = "The CSI attacher image version"
  default     = "v3.5.1"
  type        = string
}

variable "csi_attacher_image" {
  description = "The CSI attacher image"
  default     = "registry.k8s.io/sig-storage/csi-attacher"
  type        = string
}

variable "csi_provisioner_tag_version" {
  description = "The csi provisioner tag version"
  default     = "v3.2.1"
  type        = string
}

variable "csi_provisioner_image" {
  description = "The CSI provisioner image"
  default     = "registry.k8s.io/sig-storage/csi-provisioner"
  type        = string
}

variable "csi_resizer_version" {
  description = "The CSI resizer image version"
  default     = "v1.4.0"
  type        = string
}

variable "csi_resizer_image" {
  description = "The CSI resizer image"
  default     = "registry.k8s.io/sig-storage/csi-resizer"
  type        = string
}

variable "csi_snapshotter_version" {
  description = "The CSI snapshotter image version"
  default     = "v6.0.1"
  type        = string
}

variable "csi_snapshotter_image" {
  description = "The CSI snapshotter image"
  default     = "registry.k8s.io/sig-storage/csi-snapshotter"
  type        = string
}

variable "liveness_probe_version" {
  description = "The liveness probe image version"
  default     = "v2.5.0"
  type        = string
}

variable "liveness_probe_image" {
  description = "The liveness probes image"
  default     = "registry.k8s.io/sig-storage/livenessprobe"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
  type        = map(string)
}

variable "namespace" {
  description = "The K8s namespace for all EBS CSI driver resources"
  type        = string
  default     = "kube-system"
}

variable "oidc_url" {
  description = "EKS OIDC provider URL, to allow pod to assume role using IRSA"
  type        = string
}

variable "node_tolerations" {
  description = "CSI driver node tolerations"
  type        = list(map(string))
  default     = [{ operator = "Exists" }]
}

variable "csi_controller_tolerations" {
  description = "CSI driver controller tolerations"
  type        = list(map(string))
  default     = []
}

variable "csi_controller_replica_count" {
  description = "Number of EBS CSI driver controller pods"
  type        = number
  default     = 2
}

variable "enable_volume_resizing" {
  description = "Whether to enable volume resizing"
  type        = bool
  default     = false
}

variable "enable_volume_snapshot" {
  description = "Whether to enable volume snapshotting"
  type        = bool
  default     = false
}

variable "extra_create_metadata" {
  description = "If set, add pv/pvc metadata to plugin create requests as parameters."
  type        = bool
  default     = false
}

variable "eks_cluster_id" {
  description = "ID of the Kubernetes cluster used for tagging provisioned EBS volumes"
  type        = string
  default     = ""
}

variable "extra_node_selectors" {
  description = "A map of extra node selectors for all components"
  default     = {}
  type        = map(string)
}

variable "controller_extra_node_selectors" {
  description = "A map of extra node selectors for controller pods"
  default     = {}
  type        = map(string)
}

variable "node_extra_node_selectors" {
  description = "A map of extra node selectors for node pods"
  default     = {}
  type        = map(string)
}

variable "labels" {
  description = "A map of extra labels for all resources"
  default     = {}
  type        = map(string)
}

variable "log_level" {
  description = "The log level for the CSI Driver controller"
  default     = 5
  type        = number
}

variable "volume_attach_limit" {
  description = "Configure maximum volume attachments per node. -1 means use default configuration"
  default     = -1
  type        = number
}

variable "additional_iam_policies_arns" {
  description = "The EBS CSI driver controller's additional policies to allow more actions (kms, etc)"
  default     = []
  type        = list(string)
}

variable "enable_default_fstype" {
  description = "Wheter to enable default Filesystem type"
  default     = false
  type        = bool
}

variable "default_fstype" {
  description = "The default Filesystem type"
  default     = "ext4"
  type        = string
}

variable "controller_csi_attacher_resources" {
  description = "The controller csi attacher resources"
  default = {
    requests = {}
    limits   = {}
  }
  type = object({
    requests = map(string)
    limits   = map(string)
  })
}

variable "controller_csi_provisioner_resources" {
  description = "The controller csi provisioner resources"
  default = {
    requests = {}
    limits   = {}
  }
  type = object({
    requests = map(string)
    limits   = map(string)
  })
}

variable "controller_csi_resizer_resources" {
  description = "The controller csi resizer resources"
  default = {
    requests = {}
    limits   = {}
  }
  type = object({
    requests = map(string)
    limits   = map(string)
  })
}

variable "controller_csi_snapshotter_resources" {
  description = "The controller csi snapshotter resources"
  default = {
    requests = {}
    limits   = {}
  }
  type = object({
    requests = map(string)
    limits   = map(string)
  })
}

variable "arn_format" {
  type        = string
  default     = "aws"
  description = "ARNs identifier, usefull for GovCloud begin with `aws-us-gov`"
}

variable "controller_ebs_plugin_resources" {
  description = "The controller ebs plugin resources"
  default = {
    requests = {}
    limits   = {}
  }
  type = object({
    requests = map(string)
    limits   = map(string)
  })
}

variable "node_driver_registrar_resources" {
  description = "The node driver registrar resources"
  default = {
    requests = {}
    limits   = {}
  }
  type = object({
    requests = map(string)
    limits   = map(string)
  })
}

variable "node_ebs_plugin_resources" {
  description = "The node ebs plugin resources"
  default = {
    requests = {}
    limits   = {}
  }
  type = object({
    requests = map(string)
    limits   = map(string)
  })
}

variable "node_liveness_probe_resources" {
  description = "The node liveness probe resources"
  default = {
    requests = {}
    limits   = {}
  }
  type = object({
    requests = map(string)
    limits   = map(string)
  })
}
