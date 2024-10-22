# # Resource: IAM Policy for Cluster Autoscaler
resource "aws_iam_policy" "AmazonEKSClusterAutoscalerPolicy" {
  name   = "AmazonEKSClusterAutoscalerPolicyHarsh"
  policy = file("./iam_policy_autoscaler.json") # IAM Policy
}

# Trust Policy -> role -> OIDC -> service account -> node autoscaler controller pod of Cluster
data "aws_iam_policy_document" "cluster_autoscaler_iam_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.kubesystem_namespace}:${var.service_account_name_autoscaler}"] # Attach only to service account with name XYZ(autoscaler-controller) in kube-system namespace
    }
  }
}

resource "aws_iam_role" "AmazonEKSClusterAutoScalerrRole" {
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_iam_role.json # IAM ROLE Trust Policy
  name               = "AmazonEKSClusterAutoScalerrRoleHarsh"                             # IAM ROLE
}

# Attach IAM Policy to IAM ROLE
resource "aws_iam_role_policy_attachment" "aws_node_autoscaler_attach" {
  role       = aws_iam_role.AmazonEKSClusterAutoScalerrRole.name
  policy_arn = aws_iam_policy.AmazonEKSClusterAutoscalerPolicy.arn
}

resource "kubernetes_service_account" "service-account-cluster-autoscaler" {
  metadata {
    name      = var.service_account_name_autoscaler
    namespace = var.kubesystem_namespace
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app"   = var.service_account_name_autoscaler
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.AmazonEKSClusterAutoScalerrRole.arn
    }
  }
  depends_on = [
    aws_iam_role.AmazonEKSClusterAutoScalerrRole
  ]
}