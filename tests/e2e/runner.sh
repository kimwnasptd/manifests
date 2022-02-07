#!/usr/bin/env bash
set -euo pipefail

function proxy-istio {
    kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
}

echo "Installing necessary RBAC."""
#kubectl apply -f yamls

echo "Setting up port-forward..."
./hack/proxy_istio.sh
./hack/proxy_pipelines.sh

echo "Running the tests."""
python3 mnist.py
