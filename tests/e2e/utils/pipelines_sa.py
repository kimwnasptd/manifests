import base64

from kubernetes import client, config

SERVICE_ACCOUNT_NAME = "pipeline-runner"
SERVICE_ACCOUNT_NAMESPACE = "kubeflow-user-example-com"

# The script is run outside the cluster always
config.load_kube_config()


def get_sa_token(name=SERVICE_ACCOUNT_NAME,
                 namespace=SERVICE_ACCOUNT_NAMESPACE):
    k8s_client = client.CoreV1Api()
    sa = k8s_client.read_namespaced_service_account(name, namespace)

    if not sa.secrets:
        raise ValueError("No tokens exist for the specific ServiceAccount")

    secret_name = sa.secrets[0].name
    secret = client.CoreV1Api().read_namespaced_secret(secret_name,
                                                       sa.metadata.namespace)
    if secret.data.get("token") is None:
        msg = "The ServiceAccount secret is not populated with a token"
        raise RuntimeError(msg)

    return base64.b64decode(secret.data.get("token"))


print(get_sa_token())
