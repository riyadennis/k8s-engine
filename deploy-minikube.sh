#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -n "${DOCKER_USERNAME:-}" && -n "${DOCKER_PASSWORD:-}" ]]; then
  echo "Logging in to Docker registry..."
  # For Docker Hub, leave DOCKER_REGISTRY empty or set to 'https://index.docker.io/v1/'
  docker login "${DOCKER_REGISTRY:-}" -u "${DOCKER_USERNAME}" --password-stdin <<< "${DOCKER_PASSWORD}"
else
  echo "Skipping docker login (DOCKER_USERNAME/DOCKER_PASSWORD not set)."
fi

echo "Starting Minikube (if not already running)..."
minikube start

echo "Setting kubectl context to Minikube..."
kubectl config use-context minikube

echo "Using kube-context: $(kubectl config current-context)"
echo "Make sure this is your Minikube cluster (should be 'minikube')."

echo "Applying MySQL, identity, and ingestion manifests..."
kubectl apply -f "$SCRIPT_DIR/mysql.yaml"
kubectl apply -f "$SCRIPT_DIR/identity.yaml"
kubectl apply -f "$SCRIPT_DIR/identity-gql.yaml"
kubectl apply -f "$SCRIPT_DIR/ingestion.yaml"

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=Available deployment/mysql --timeout=120s || true
kubectl wait --for=condition=Ready pod -l name=identity-server --timeout=120s || true
kubectl wait --for=condition=Available deployment/ingestion-rest-service --timeout=120s || true

echo "Current pods:"
kubectl get pods -o wide

echo "Current services:"
kubectl get svc

echo "Done. To access a service via Minikube, you can run e.g.:"
echo "  minikube service ingestion-rest-service"

