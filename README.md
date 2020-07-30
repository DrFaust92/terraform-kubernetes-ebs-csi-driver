<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.6, < 0.14 |
| kubernetes | ~> 1.11.4 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| kubernetes | ~> 1.11.4 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ebs\_csi\_controller\_role\_name | The name of the EBS CSI driver IAM role | `string` | `"ebs-csi-driver-controller"` | no |
| ebs\_csi\_controller\_role\_policy\_name\_prefix | The prefix of the EBS CSI driver IAM policy | `string` | `"ebs-csi-driver-policy"` | no |
| enable\_volume\_resizing | Whether to enable volume resizing | `bool` | `false` | no |
| enable\_volume\_snapshot | Whether to enable volume snapshotting | `bool` | `false` | no |
| namespace | The K8s namespace for all EBS CSI driver resources | `string` | `"kube-system"` | no |
| node\_tolerations | CSI driver node tolerations | `map(string)` | `{}` | no |
| oidc\_url | EKS OIDC provider URL, to allow pod to assume role using IRSA | `string` | n/a | yes |
| replica\_count | Number of EBS CSI driver controller pods | `number` | `2` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| tolerations | CSI driver controller tolerations | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| ebs\_csi\_driver\_controller\_role\_arn | The Name of the EBS CSI driver controller IAM role ARN |
| ebs\_csi\_driver\_controller\_role\_name | The Name of the EBS CSI driver controller IAM role name |
| ebs\_csi\_driver\_controller\_role\_policy\_arn | The Name of the EBS CSI driver controller IAM role policy ARN |
| ebs\_csi\_driver\_controller\_role\_policy\_name | The Name of the EBS CSI driver controller IAM role policy name |
| ebs\_csi\_driver\_name | The Name of the EBS CSI driver |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->