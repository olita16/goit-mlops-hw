import os
import shutil
import tempfile
from pathlib import Path

import mlflow
import mlflow.sklearn
import numpy as np
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway
from sklearn.datasets import load_iris
from sklearn.linear_model import SGDClassifier
from sklearn.metrics import accuracy_score, log_loss
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler


MLFLOW_TRACKING_URI = os.getenv("MLFLOW_TRACKING_URI", "http://localhost:5000")
PUSHGATEWAY_URL = os.getenv("PUSHGATEWAY_URL", "localhost:9091")

EXPERIMENT_NAME = "iris-mlflow-pushgateway"
BEST_MODEL_DIR = Path(__file__).resolve().parents[1] / "best_model"


def train_model(learning_rate: float, epochs: int):
    iris = load_iris()
    x_train, x_test, y_train, y_test = train_test_split(
        iris.data,
        iris.target,
        test_size=0.2,
        random_state=42,
        stratify=iris.target,
    )

    scaler = StandardScaler()
    x_train = scaler.fit_transform(x_train)
    x_test = scaler.transform(x_test)

    model = SGDClassifier(
        loss="log_loss",
        learning_rate="constant",
        eta0=learning_rate,
        max_iter=1,
        warm_start=True,
        random_state=42,
    )

    classes = np.unique(y_train)

    for _ in range(epochs):
        model.partial_fit(x_train, y_train, classes=classes)

    y_pred = model.predict(x_test)
    y_proba = model.predict_proba(x_test)

    accuracy = accuracy_score(y_test, y_pred)
    loss = log_loss(y_test, y_proba)

    return model, scaler, accuracy, loss


def push_metrics_to_gateway(run_id: str, accuracy: float, loss: float):
    registry = CollectorRegistry()

    accuracy_gauge = Gauge(
        "mlflow_accuracy",
        "MLflow model accuracy",
        ["run_id"],
        registry=registry,
    )
    loss_gauge = Gauge(
        "mlflow_loss",
        "MLflow model loss",
        ["run_id"],
        registry=registry,
    )

    accuracy_gauge.labels(run_id=run_id).set(accuracy)
    loss_gauge.labels(run_id=run_id).set(loss)

    push_to_gateway(
        PUSHGATEWAY_URL,
        job="mlflow_experiment",
        registry=registry,
    )


def main():
    mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
    mlflow.set_experiment(EXPERIMENT_NAME)

    param_grid = [
        {"learning_rate": 0.001, "epochs": 50},
        {"learning_rate": 0.005, "epochs": 50},
        {"learning_rate": 0.01, "epochs": 100},
        {"learning_rate": 0.05, "epochs": 100},
        {"learning_rate": 0.1, "epochs": 150},
    ]

    best_run = None

    for params in param_grid:
        with mlflow.start_run() as run:
            run_id = run.info.run_id

            model, scaler, accuracy, loss = train_model(
                learning_rate=params["learning_rate"],
                epochs=params["epochs"],
            )

            mlflow.log_params(params)
            mlflow.log_metric("accuracy", accuracy)
            mlflow.log_metric("loss", loss)

            with tempfile.TemporaryDirectory() as tmpdir:
                model_path = Path(tmpdir) / "model"
                mlflow.sklearn.save_model(model, model_path)
                mlflow.log_artifacts(str(model_path), artifact_path="model")

            push_metrics_to_gateway(run_id, accuracy, loss)

            print(
                f"run_id={run_id} "
                f"learning_rate={params['learning_rate']} "
                f"epochs={params['epochs']} "
                f"accuracy={accuracy:.4f} "
                f"loss={loss:.4f}"
            )

            if best_run is None or accuracy > best_run["accuracy"]:
                best_run = {
                    "run_id": run_id,
                    "accuracy": accuracy,
                    "loss": loss,
                    "params": params,
                    "model": model,
                }

    BEST_MODEL_DIR.mkdir(parents=True, exist_ok=True)

    for item in BEST_MODEL_DIR.iterdir():
        if item.is_dir():
            shutil.rmtree(item)
        else:
            item.unlink()

    mlflow.sklearn.save_model(best_run["model"], BEST_MODEL_DIR)

    print("\nBest model:")
    print(f"run_id={best_run['run_id']}")
    print(f"accuracy={best_run['accuracy']:.4f}")
    print(f"loss={best_run['loss']:.4f}")
    print(f"params={best_run['params']}")
    print(f"saved_to={BEST_MODEL_DIR}")


if __name__ == "__main__":
    main()
