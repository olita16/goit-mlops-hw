import json
from datetime import datetime, timezone


def lambda_handler(event, context):
    """Log simple training metrics after validation."""
    print("Logging training metrics...")
    print(json.dumps(event, ensure_ascii=False))

    metrics = {
        "metric_name": "training_pipeline_started",
        "metric_value": 1,
        "validation_status": event.get("validation_status", "unknown"),
        "commit": event.get("commit", "manual"),
        "logged_at": datetime.now(timezone.utc).isoformat()
    }

    print(json.dumps(metrics, ensure_ascii=False))

    return {
        "logging_status": "completed",
        "metrics": metrics,
        "input": event
    }
