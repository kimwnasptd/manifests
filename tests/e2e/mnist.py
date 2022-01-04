"""E2E Kubeflow test that tesst Pipelines, Katib, TFJobs and KFServing.

Requires:
pip install kfp==1.8.4
pip install kubeflow-katib==0.12.0
"""
import kfp
import kfp.dsl as dsl

from utils.katib import create_katib_experiment_task
from utils.tfjob import create_tfjob_task
from utils.kfserving import create_kfserving_task

NAME = "mnist-e2e"
NAMESPACE = "kubeflow-user-example-com"
TRAINING_STEPS = "200"


@dsl.pipeline(
    name="End to End Pipeline",
    description="An end to end mnist example including hyperparameter tuning, "
                "train and inference",
)
def mnist_pipeline(name=NAME, namespace=NAMESPACE,
                   training_steps=TRAINING_STEPS):
    # Run the hyperparameter tuning with Katib.
    katib_op = create_katib_experiment_task(name, namespace, training_steps)

    # Create volume to train and serve the model.
    model_volume_op = dsl.VolumeOp(
        name="model-volume",
        resource_name="model-volume",
        size="1Gi",
        modes=dsl.VOLUME_MODE_RWO,
    )

    # Run the distributive training with TFJob.
    tfjob_op = create_tfjob_task(name, namespace, training_steps, katib_op,
                                 model_volume_op)

    # Create the KFServing inference.
    create_kfserving_task(name, namespace, tfjob_op, model_volume_op)


# Run the Kubeflow Pipeline in the user's namespace.
kfp_client = kfp.Client()
run_id = kfp_client.create_run_from_pipeline_func(
    mnist_pipeline,
    namespace=NAMESPACE,
    arguments={},
).run_id
print("Run ID: ", run_id)
