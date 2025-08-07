#!/bin/bash

# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Define o nome do cluster e a região
CLUSTER_NAME="cluster-name"
REGION="us-central1"

# Cria o cluster GKE
gcloud container clusters create-auto $CLUSTER_NAME --region=$REGION

# Define o nome do pool de nós e o tipo de máquina
NODE_POOL_NAME="pool-2"
MACHINE_TYPE="e2-standard-4"

# Cria o novo pool de nós
gcloud container node-pools create $NODE_POOL_NAME \
    --cluster=$CLUSTER_NAME \
    --machine-type=$MACHINE_TYPE \
    --region=$REGION

# Define o nome do job e o pool de nós de destino
JOB_NAME="sudoku-solver-job"
TARGET_NODE_POOL=$NODE_POOL_NAME

# Aplica o job ao cluster, direcionando para o pool de nós criado
kubectl apply -f job-standard.yaml
kubectl patch job $JOB_NAME -p '{"spec":{"template":{"spec":{"nodeSelector":{"cloud.google.com/gke-nodepool":"'$TARGET_NODE_POOL'"}}}}}'
