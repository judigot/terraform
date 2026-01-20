#!/bin/sh
set -eu

BUCKET="$1"
KEY="$2"
REGION="$3"
EXPIRES_IN="${4:-604800}" # 7 days

URL="$(aws --profile admin --region "$REGION" s3 presign "s3://$BUCKET/$KEY" --expires-in "$EXPIRES_IN")"

# Terraform external data source needs JSON
python3 - <<PY
import json
print(json.dumps({"url": """$URL"""}))
PY
