resource "kubernetes_service_account" "service-account" {
  metadata {
    name      = var.service_account_name_alb
    namespace = var.kubesystem_namespace
    labels = {
      "app.kubernetes.io/name"      = var.service_account_name_alb
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.AmazonEKSLoadBalancerControllerRole.arn # ARN of IAM Role
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
      # "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
    }
  }
  depends_on = [
    module.eks.eks_managed_node_groups,                                 # Depends on EKS cluster node group
    aws_iam_role_policy_attachment.aws_load_balancer_controller_attach, #Depends on IAM Role for service account,
    # module.lb_role
  ]
}

