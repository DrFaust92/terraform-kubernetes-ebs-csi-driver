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

variable "ebs_csi_driver_version" {
  description = "The EBS CSI driver controller's image version"
  default     = ""
  type        = string
}

variable "ebs_csi_controller_image" {
  description = "The EBS CSI driver controller's image"
  default     = ""
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
  default     = []
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

variable "csi_provisioner_tag_version" {
  description = "The csi provisioner tag version"
  default     = "v3.2.1"
  type        = string
}