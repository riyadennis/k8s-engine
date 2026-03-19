#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting kubectl context to Minikube..."
kubectl config use-context minikube

echo "Using kube-context: $(kubectl config current-context)"
echo "Make sure this is your Minikube cluster (should be 'minikube')."

echo "Deleting ingestion, identity, and MySQL manifests..."
kubectl delete -f "$SCRIPT_DIR/ingestion.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/identity.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/identity-gql.yaml" --ignore-not-found
kubectl delete -f "$SCRIPT_DIR/mysql.yaml" --ignore-not-found

echo "Current pods after teardown:"
kubectl get pods -o wide || true

echo "Current services after teardown:"
kubectl get svc || true

echo "If you also want to stop the Minikube VM, run:"
echo "  minikube stop"

