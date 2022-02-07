#!/usr/bin/env bash
set -euo pipefail

kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80 &
ISTIO_PID=$!

echo "Started Istio port-forward, pid: $ISTIO_PID"
echo ISTIO_PID=$ISTIO_PID >> pids.env

sleep 1
