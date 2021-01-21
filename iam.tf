data "aws_iam_policy_document" "ebs_controller_policy_doc" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ec2:AttachVolume",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteSnapshot",
      "ec2:DeleteTags",
      "ec2:DeleteVolume",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeVolumesModifications"
    ]
  }
}

resource "aws_iam_policy" "ebs_controller_policy" {
  name_prefix = var.ebs_csi_controller_role_policy_name_prefix
  policy      = data.aws_iam_policy_document.ebs_controller_policy_doc.json
}

module "ebs_controller_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.7.0"
  create_role                   = true
  role_description              = "EBS CSI Driver Role"
  role_name_prefix              = var.ebs_csi_controller_role_name
  provider_url                  = var.oidc_url
  role_policy_arns              = [aws_iam_policy.ebs_controller_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${local.controller_name}"]
  tags                          = var.tags
}