#!/usr/bin/env bash

# Copyright 2021 The Kubeflow Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This shell script is used to setup Katib deployment.

set -o errexit
set -o nounset
set -o pipefail

echo "Creating Kubeflow namespace..."
#kubectl create namespace kubeflow

echo "Deploying all Kubeflow components..."
while ! kustomize build example --load_restrictor none | kubectl apply -f - --validate=false; do echo "Retrying to apply resources"; sleep 10; done

echo "---"
echo "Waiting for all Kubeflow components to become ready."
TIMEOUT=600s  # 10mins

echo "Waiting for istio-system/istiod to become ready..."
kubectl wait --timeout=${TIMEOUT} -n istio-system -l app=istiod --for=condition=Ready pod

echo "Waiting for istio-system/istio-ingressgateway to become ready..."
kubectl wait --timeout=${TIMEOUT} -n istio-system -l app=istio-ingressgateway --for=condition=Ready pod

echo "Waiting for kubeflow/ml-pipelines to become ready..."
kubectl wait --timeout=${TIMEOUT} -n kubeflow -l app=ml-pipeline --for=condition=Ready pod

echo "Waiting for kubeflow/kfserving to become ready..."
kubectl wait --timeout=${TIMEOUT} -n kubeflow -l app=kfserving --for=condition=Ready pod

echo "Waiting for kubeflow/katib to become ready..."
kubectl wait --timeout=${TIMEOUT} -n kubeflow -l katib.kubeflow.org/component=controller --for=condition=Ready pod

echo "Waiting for kubeflow/training-operator to become ready..."
kubectl wait --timeout=${TIMEOUT} -n kubeflow -l control-plane=kubeflow-training-operator --for=condition=Ready pod
