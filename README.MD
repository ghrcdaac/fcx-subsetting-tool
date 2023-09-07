# Steps to deploy the Subsetting Tool

It is supposed that the user has some prior knowledge about aws.

## Pre-requisites


- [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
- [Setup AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
  - `aws configure` Preferred. This deployment will assume that aws configure is used.
  - Need ```aws_access_key_id and aws_secret_access_key``` key values; inside `~/.aws/credentials`

## Deployement Details

1. Export env variables for keys mentioned in .env.example into shell session.
     - example: `export TF_VAR_aws_region="**********" TF_VAR_accountId="**********"`
2. Deploy using `bash deploy.sh`. The bash script does the following things:
      - terraform init
      - terrafrom plan
      - terraform apply
3. Use the `subsettingTool.postman_collection.json` postman collection to test.

After terraform finishes building the Subsetting tool infrastructure, it outputs env varaibles that can be used in the frontend.

   - For `<sensitive>` as output value, use `terraform output <key_name>`

### To remove the Subsetting Tool

- Use `terraform destroy`

### Details on Subsetting tool

The subsetting tool has 3 parts:

1. <b>Core subsetting tool</b>: This part deals with subsetting the actual instrument values. It uses multiple subsetting lambda workers for different instruments. Raw data is pulled first from s3 SOURCE_BUCKET, processed and is finally stored in DESTINATION_BUCKET (SUBSET_OUTPUT_BUCKET)

2. <b>Progress bar</b>: This part deals with setting up two way communication between frontend and subset workers using Websockets. It uses Websocket IDs to differentiate connections uniquely in a serverless architecture. Dynamodb is used.

3. <b>Subsets direct download</b>: This part deals with exposing the privately stored subsets and making it directly downloadable using the CDN (Cloudfront).

The codebase is segregated based on the above mentioned parts.
