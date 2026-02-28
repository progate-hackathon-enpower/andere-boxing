terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

# ArgoCD Helm Release
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = var.argocd_namespace
  create_namespace = true

  values = [yamlencode({
    # ClusterIP のみ (外部公開しない、port-forward でアクセス)
    server = {
      service = {
        type = "ClusterIP"
      }
      replicas = 1
    }

    # Insecure mode (TLS termination を ArgoCD 自体では行わない)
    configs = {
      params = {
        "server.insecure" = true
      }
    }

    # HA は不要 (ハッカソン / 小規模環境)
    redis-ha = {
      enabled = false
    }

    controller = {
      replicas = 1
    }

    repoServer = {
      replicas = 1
    }
  })]
}

# infra/argocd/static/applications.yaml を読み込んで適用
# kubectl_manifest はサーバー側スキーマ検証を行わないため、
# CRD が helm_release と同時に作られるケースでも動作する
data "kubectl_file_documents" "static" {
  content = file("${path.module}/../../../argocd/static/applications.yaml")
}

resource "kubectl_manifest" "static" {
  for_each  = data.kubectl_file_documents.static.manifests
  yaml_body = each.value

  depends_on = [helm_release.argocd]
}
