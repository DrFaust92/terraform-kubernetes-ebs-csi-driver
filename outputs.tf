output "ebs_csi_driver_name" {
  description = "The Name of the EBS CSI driver"
  value       = kubernetes_csi_driver_v1.ebs.metadata[0].name
}

output "ebs_csi_driver_controller_role_arn" {
  description = "The Name of the EBS CSI driver controller IAM role ARN"
  value       = module.ebs_controller_role.iam_role_arn
}

output "ebs_csi_driver_controller_role_name" {
  description = "The Name of the EBS CSI driver controller IAM role name"
  value       = module.ebs_controller_role.iam_role_name
}

output "ebs_csi_driver_controller_role_policy_arn" {
  description = "The Name of the EBS CSI driver controller IAM role policy ARN"
  value       = aws_iam_policy.ebs_controller_policy.arn
}

output "ebs_csi_driver_controller_role_policy_name" {
  description = "The Name of the EBS CSI driver controller IAM role policy name"
  value       = aws_iam_policy.ebs_controller_policy.name
}
