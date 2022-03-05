resource "helm_release" "argo-cd" {
  name       = "argo-cd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.35.0"
  namespace = "argocd"
  create_namespace = "true"

  depends_on = [aws_eks_cluster.eks-cluster,
                aws_eks_node_group.private-nodes]
}
