provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

data "tls_certificate" "cert" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

//resource "aws_iam_openid_connect_provider" "openid_connect" {
//  client_id_list  = ["sts.amazonaws.com"]
//  thumbprint_list = [data.tls_certificate.cert.certificates.0.sha1_fingerprint]
//  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
//}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

module "ebs_csi_driver_controller" {
  source = "../.."

  oidc_url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}