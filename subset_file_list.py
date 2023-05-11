import json
import boto3
import os

def lambda_handler(event, context):
    AWSregion= os.environ.get('BUCKET_AWS_REGION')
    srcbucket = os.environ.get('SOURCE_BUCKET_NAME')
    cloudfronturl = os.environ.get('CLOUD_FRONT_URL')

    if isinstance(event, str): event = json.loads(event)

    subsettoken = event["wsTokenId"]

    s3 = boto3.resource('s3', region_name=AWSregion)
    bucket = s3.Bucket(srcbucket)
    prefix = f"subsets/{subsettoken}"
    subset_files=[]
    for obj in bucket.objects.filter(Prefix=prefix):
            subset_files.append(f"{cloudfronturl}/{obj.key}")
    return {
        'statusCode': 200,
        'body': json.dumps({ "subsetfiles": subset_files })
    }