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
kubectl create namespace kubeflow

echo "Deploying all Kubeflow components..."
while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

echo "Waiting for all Kubeflow components to become ready..."
TIMEOUT=600s  # 10mins
kubectl wait --timeout=${TIMEOUT} --all --all-namespaces --for=condition=Ready pod
