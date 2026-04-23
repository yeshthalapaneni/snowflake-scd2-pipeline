"""
Upload Product Files to Amazon S3

This script uploads a CSV file to an S3 bucket. It can be used to send
both initial and changed product data to trigger downstream processing
in Snowflake and dbt.
"""

import os
import boto3
from datetime import datetime

# -----------------------------
# Configuration
# -----------------------------

S3_BUCKET = "your-bucket-name"
S3_PREFIX = "product_data/"
LOCAL_FILE_PATH = "../sample_data/product_changed.csv"

# -----------------------------
# S3 Client
# -----------------------------

s3_client = boto3.client("s3")

# -----------------------------
# Helper Functions
# -----------------------------

def generate_s3_key(prefix: str, file_name: str) -> str:
    timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    base_name = os.path.basename(file_name)
    return f"{prefix}{timestamp}_{base_name}"


def upload_file(local_path: str, bucket: str, key: str):
    if not os.path.exists(local_path):
        raise FileNotFoundError(f"File not found: {local_path}")

    print(f"Uploading {local_path} to s3://{bucket}/{key}")

    s3_client.upload_file(local_path, bucket, key)

    print("Upload completed")

# -----------------------------
# Main Execution
# -----------------------------

def main():
    try:
        s3_key = generate_s3_key(S3_PREFIX, LOCAL_FILE_PATH)
        upload_file(LOCAL_FILE_PATH, S3_BUCKET, s3_key)
    except Exception as e:
        print(f"Upload failed: {str(e)}")


if __name__ == "__main__":
    main()
