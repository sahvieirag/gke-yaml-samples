# gke-yaml-samples

This repository contains a collection of YAML files for deploying applications and services on Google Kubernetes Engine (GKE). Each file is designed to demonstrate a specific feature or configuration of GKE, providing a practical reference for developers and operators.

## Files

- `deploy-best-effort.yaml`: YAML file for a "best-effort" deployment, ideal for non-critical workloads that can tolerate interruptions.
- `deploys-nap.yaml`: YAML file for deploying applications using Node Auto-Provisioning (NAP), which automatically manages node pools based on workload requirements.
- `deploys-vpa.yaml`: YAML file for a deployment with Vertical Pod Autoscaler (VPA) enabled, which automatically adjusts the CPU and memory requests of pods.
- `job-autopilot.yaml`: YAML file for running a batch job in a GKE Autopilot cluster, where the infrastructure is fully managed by Google.
- `job-nodepool.sh`: Bash script that creates a GKE cluster, a new node pool, and runs a job on that specific node pool.
- `job-standard.yaml`: YAML file for a standard batch job, suitable for workloads that need to run to completion.
- `vpa-deploys.yaml`: YAML file for a deployment with Vertical Pod Autoscaler (VPA) enabled, which automatically adjusts the CPU and memory requests of pods.

## How to Use

To use these files, you need a GKE cluster. You can apply them using the `kubectl apply -f <filename>.yaml` command. For the `job-nodepool.sh` script, you need to have the `gcloud` CLI installed and configured.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
