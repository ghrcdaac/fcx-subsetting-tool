export BUCKET_AWS_REGION=us-east-1
export SOURCE_BUCKET_NAME=fcx-raw-data

python3 ./trigger_subsetting/lambda_function.py
