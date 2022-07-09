# Kubernetes EBS CSI driver Terraform module

Terraform module which creates Kubernetes EBS CSI controller resources on AWS EKS.

Based on the original repo for the [EBS CSI driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)

## Usage

```hcl
data "aws_eks_cluster" "cluster" {
  name = "my-eks-cluster"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "my-eks-cluster"
}

data "tls_certificate" "cert" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "openid_connect" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates.0.sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "ebs_csi_driver_controller" {
  source = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "<VERSION>"

  ebs_csi_controller_image                   = ""
  ebs_csi_controller_role_name               = "ebs-csi-driver-controller"
  ebs_csi_controller_role_policy_name_prefix = "ebs-csi-driver-policy"
  oidc_url                                   = aws_iam_openid_connect_provider.openid_connect.url
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.40.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 1.11.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.22.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.12.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_controller_role"></a> [ebs\_controller\_role](#module\_ebs\_controller\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 4.24.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ebs_controller_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [kubernetes_cluster_role.attacher](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.node](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.provisioner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.resizer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.snapshotter](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.attacher](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.node](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.provisioner](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.resizer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.snapshotter](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_csi_driver_v1.ebs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/csi_driver_v1) | resource |
| [kubernetes_daemonset.node](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/daemonset) | resource |
| [kubernetes_deployment.ebs_csi_controller](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_service_account.csi_driver](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.node](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_iam_policies_arns"></a> [additional\_iam\_policies\_arns](#input\_additional\_iam\_policies\_arns) | The EBS CSI driver controller's additional policies to allow more actions (kms, etc) | `list(string)` | `[]` | no |
| <a name="input_controller_extra_node_selectors"></a> [controller\_extra\_node\_selectors](#input\_controller\_extra\_node\_selectors) | A map of extra node selectors for controller pods | `map(string)` | `{}` | no |
| <a name="input_csi_controller_replica_count"></a> [csi\_controller\_replica\_count](#input\_csi\_controller\_replica\_count) | Number of EBS CSI driver controller pods | `number` | `2` | no |
| <a name="input_csi_controller_tolerations"></a> [csi\_controller\_tolerations](#input\_csi\_controller\_tolerations) | CSI driver controller tolerations | `list(map(string))` | `[]` | no |
| <a name="input_csi_provisioner_tag_version"></a> [csi\_provisioner\_tag\_version](#input\_csi\_provisioner\_tag\_version) | The csi provisioner tag version | `string` | `"v3.2.1"` | no |
| <a name="input_default_fstype"></a> [default\_fstype](#input\_default\_fstype) | The default Filesystem type | `string` | `"ext4"` | no |
| <a name="input_ebs_csi_controller_image"></a> [ebs\_csi\_controller\_image](#input\_ebs\_csi\_controller\_image) | The EBS CSI driver controller's image | `string` | `""` | no |
| <a name="input_ebs_csi_controller_role_name"></a> [ebs\_csi\_controller\_role\_name](#input\_ebs\_csi\_controller\_role\_name) | The name of the EBS CSI driver IAM role | `string` | `"ebs-csi-driver-controller"` | no |
| <a name="input_ebs_csi_controller_role_policy_name_prefix"></a> [ebs\_csi\_controller\_role\_policy\_name\_prefix](#input\_ebs\_csi\_controller\_role\_policy\_name\_prefix) | The prefix of the EBS CSI driver IAM policy | `string` | `"ebs-csi-driver-policy"` | no |
| <a name="input_ebs_csi_driver_version"></a> [ebs\_csi\_driver\_version](#input\_ebs\_csi\_driver\_version) | The EBS CSI driver controller's image version | `string` | `""` | no |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | ID of the Kubernetes cluster used for tagging provisioned EBS volumes | `string` | `""` | no |
| <a name="input_enable_default_fstype"></a> [enable\_default\_fstype](#input\_enable\_default\_fstype) | Wheter to enable default Filesystem type | `bool` | `false` | no |
| <a name="input_enable_volume_resizing"></a> [enable\_volume\_resizing](#input\_enable\_volume\_resizing) | Whether to enable volume resizing | `bool` | `false` | no |
| <a name="input_enable_volume_snapshot"></a> [enable\_volume\_snapshot](#input\_enable\_volume\_snapshot) | Whether to enable volume snapshotting | `bool` | `false` | no |
| <a name="input_extra_create_metadata"></a> [extra\_create\_metadata](#input\_extra\_create\_metadata) | If set, add pv/pvc metadata to plugin create requests as parameters. | `bool` | `false` | no |
| <a name="input_extra_node_selectors"></a> [extra\_node\_selectors](#input\_extra\_node\_selectors) | A map of extra node selectors for all components | `map(string)` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of extra labels for all resources | `map(string)` | `{}` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | The log level for the CSI Driver controller | `number` | `5` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The K8s namespace for all EBS CSI driver resources | `string` | `"kube-system"` | no |
| <a name="input_node_extra_node_selectors"></a> [node\_extra\_node\_selectors](#input\_node\_extra\_node\_selectors) | A map of extra node selectors for node pods | `map(string)` | `{}` | no |
| <a name="input_node_tolerations"></a> [node\_tolerations](#input\_node\_tolerations) | CSI driver node tolerations | `list(map(string))` | `[]` | no |
| <a name="input_oidc_url"></a> [oidc\_url](#input\_oidc\_url) | EKS OIDC provider URL, to allow pod to assume role using IRSA | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_volume_attach_limit"></a> [volume\_attach\_limit](#input\_volume\_attach\_limit) | Configure maximum volume attachments per node. -1 means use default configuration | `number` | `-1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ebs_csi_driver_controller_role_arn"></a> [ebs\_csi\_driver\_controller\_role\_arn](#output\_ebs\_csi\_driver\_controller\_role\_arn) | The Name of the EBS CSI driver controller IAM role ARN |
| <a name="output_ebs_csi_driver_controller_role_name"></a> [ebs\_csi\_driver\_controller\_role\_name](#output\_ebs\_csi\_driver\_controller\_role\_name) | The Name of the EBS CSI driver controller IAM role name |
| <a name="output_ebs_csi_driver_controller_role_policy_arn"></a> [ebs\_csi\_driver\_controller\_role\_policy\_arn](#output\_ebs\_csi\_driver\_controller\_role\_policy\_arn) | The Name of the EBS CSI driver controller IAM role policy ARN |
| <a name="output_ebs_csi_driver_controller_role_policy_name"></a> [ebs\_csi\_driver\_controller\_role\_policy\_name](#output\_ebs\_csi\_driver\_controller\_role\_policy\_name) | The Name of the EBS CSI driver controller IAM role policy name |
| <a name="output_ebs_csi_driver_name"></a> [ebs\_csi\_driver\_name](#output\_ebs\_csi\_driver\_name) | The Name of the EBS CSI driver |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
