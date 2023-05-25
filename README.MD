## How to deploy the lambda function (in the AWS lambda)
### It is supposed that the user has some prior knowledge about lambda.

1. Place aws credentials inside `~/.aws/credentials`
2. Modify variables as neccessary in `tf-variables-*.tf`
3. Install terraform, then use:
   - terraform init
   - terrafrom plan
   - terraform apply

After terraform finishes building the Subsetting tool infrastructure, it outputs env varaibles that can be used in the frontend.
   - For `<sensitive>` as output value, use `terraform output <key_name>`


#
## Subsetting tool:

The subsetting tool has 3 parts:
1. <b>Core subsetting tool</b>: This part deals with subsetting the actual instrument values. It uses multiple subsetting lambda workers for different instruments. Raw data is pulled first from s3 SOURCE_BUCKET, processed and is finally stored in DESTINATION_BUCKET (SUBSET_OUTPUT_BUCKET)
2. <b>Progress bar</b>: This part deals with setting up two way communication between frontend and subset workers using Websockets. It uses Websocket IDs to differentiate connections uniquely in a serverless architecture. Dynamodb is used.
3. <b>Subsets direct download</b>: This part deals with exposing the privately stored subsets and making it directly downloadable using the CDN (Cloudfront).

The codebase is segregated based on the above mentioned parts.