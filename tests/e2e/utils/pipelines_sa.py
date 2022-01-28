import os

from kubernetes import config

SERVICE_ACCOUNT_NAME = "kfp-external-client"
SERVICE_ACCOUNT_NAMESPACE = "kubeflow-user"

# The script is run outside the cluster always
config.load_kube_config()


def get_or_creaet_service_account(
