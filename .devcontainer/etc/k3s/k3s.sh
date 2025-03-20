#!/bin/bash
# https://github.com/k3s-io/k3s/tree/master?tab=readme-ov-file#quick-start---install-script

# load helper functions
source /app/.devcontainer/etc/util/functions.sh

function k3s-install() {
  # Determine CPU Architecture
  arch=$(lscpu | grep "Architecture" | awk '{print $NF}')
  if [[ $arch == x86_64* ]]; then
    ARCH="amd64"
  elif  [[ $arch == aarch64 ]]; then
    ARCH="arm64"
  fi

  printInfoSection "CPU is $ARCH"

  printInfoSection "Ensure Docker Daemon is running (Dependency)"
  
  if pgrep -x "dockerd" >/dev/null
  then
    printInfo "Docker is running"
  else
    printInfo "Ensure Docker is running.."
    sudo bash /app/.devcontainer/etc/docker/docker.sh
  fi

  printInfoSection "Deleting K3s"
  sudo bash /usr/local/bin/k3s-uninstall.sh || true

  
  printInfoSection "Installing K3s"
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --disable traefik" sh -

  # https://docs.k3s.io/cluster-access#accessing-the-cluster-from-outside-with-kubectl
  
  printInfoSection "Configure K3s Cluster access to user ubuntu"
  # Set kube config for root
  sudo mkdir -p /root/.kube
  sudo cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
  # Set kube config for user ubuntu
  mkdir -p /home/ubuntu/.kube
  sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
  sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube
  # Set kube config for external use in project_folder/.kube/config
  rm -rf /app/.kube
  mkdir -p /app/.kube
  sudo cp /etc/rancher/k3s/k3s.yaml /app/.kube/config
  sudo chmod 777 -R /app/.kube

  printInfoSection "Setting up NGINX Ingress"
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
  

  installHelm

  #installKubernetesDashboard

  #installHelmDashboard
   
  installK9s

  if [[ $CODESPACES == true ]]; then
    KUBERNETES_DASHBOARD_URL="https://${CODESPACE_NAME}-8001.app.github.dev"
    HELM_DASHBOARD_URL="https://${CODESPACE_NAME}-8002.app.github.dev"
  else
    KUBERNETES_DASHBOARD_URL="https://localhost:8001"
    HELM_DASHBOARD_URL="http://localhost:8002"
  fi

  printInfoSection "Kubernetes Dashboard: ${KUBERNETES_DASHBOARD_URL} using the token above"
  printInfoSection "Helm Dashboard: ${HELM_DASHBOARD_URL}"

  # printInfoSection "Debug"
  # k3s check-config
}

k3s-install