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
  load_config_file       = false
  version                = "~> 1.11.4"
}

module "ebs_csi_driver_controller" {
  source = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "<VERSION>"

  ebs_csi_controller_role_name               = "ebs-csi-driver-controller"
  ebs_csi_controller_role_policy_name_prefix = "ebs-csi-driver-policy"
  oidc_url                                   = aws_iam_openid_connect_provider.openid_connect.url
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.6, < 0.14 |
| kubernetes | >= 1.11.4 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| kubernetes | >= 1.11.4 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| csi\_controller\_replica\_count | Number of EBS CSI driver controller pods | `number` | `2` | no |
| csi\_controller\_tolerations | CSI driver controller tolerations | `list(map(string))` | `[]` | no |
| ebs\_csi\_controller\_role\_name | The name of the EBS CSI driver IAM role | `string` | `"ebs-csi-driver-controller"` | no |
| ebs\_csi\_controller\_role\_policy\_name\_prefix | The prefix of the EBS CSI driver IAM policy | `string` | `"ebs-csi-driver-policy"` | no |
| eks\_cluster\_id | ID of the Kubernetes cluster used for tagging provisioned EBS volumes | `string` | `""` | no |
| enable\_volume\_resizing | Whether to enable volume resizing | `bool` | `false` | no |
| enable\_volume\_snapshot | Whether to enable volume snapshotting | `bool` | `false` | no |
| extra\_create\_metadata | If set, add pv/pvc metadata to plugin create requests as parameters. | `bool` | `false` | no |
| namespace | The K8s namespace for all EBS CSI driver resources | `string` | `"kube-system"` | no |
| node\_tolerations | CSI driver node tolerations | `list(map(string))` | `[]` | no |
| oidc\_url | EKS OIDC provider URL, to allow pod to assume role using IRSA | `string` | n/a | yes |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| ebs\_csi\_driver\_controller\_role\_arn | The Name of the EBS CSI driver controller IAM role ARN |
| ebs\_csi\_driver\_controller\_role\_name | The Name of the EBS CSI driver controller IAM role name |
| ebs\_csi\_driver\_controller\_role\_policy\_arn | The Name of the EBS CSI driver controller IAM role policy ARN |
| ebs\_csi\_driver\_controller\_role\_policy\_name | The Name of the EBS CSI driver controller IAM role policy name |
| ebs\_csi\_driver\_name | The Name of the EBS CSI driver |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
