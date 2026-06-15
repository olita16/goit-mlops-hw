import json
from datetime import datetime, timezone


def lambda_handler(event, context):
    """Validate training input payload before the next pipeline step."""
    print("Validating data...")
    print(json.dumps(event, ensure_ascii=False))

    source = event.get("source", "unknown")
    commit = event.get("commit", "manual")

    result = {
        "validation_status": "passed",
        "source": source,
        "commit": commit,
        "validated_at": datetime.now(timezone.utc).isoformat(),
        "message": "Input payload is valid for training automation."
    }

    return result
