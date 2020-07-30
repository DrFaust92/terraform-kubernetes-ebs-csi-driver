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
  type        = map(string)
  default     = {}
}

variable "csi_controller_tolerations" {
  description = "CSI driver controller tolerations"
  type        = map(string)
  default     = {}
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