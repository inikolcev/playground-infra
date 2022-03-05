provider "aws" {
  region = "eu-central-1"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
