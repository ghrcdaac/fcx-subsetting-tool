## To test the subsetting script locally:
1. uncomment the lambda_handler function call in the lambda_function.py dir.
2. Run `bash start.sh`

## To deploy the subsetting script to the AWS lambda:
1. Run `bash create_zip.sh`
2. A zip file will be created in `../` dir.
3. upload the zip to the AWS lambda. (either using AWS lambda console, AWS CLI or AWS SDK)
4. Create the following ENV variables in the AWS lambda:
    BUCKET_AWS_REGION=xxxxx
    SOURCE_BUCKET_NAME=xxxxx
    DESTINATION_BUCKET_NAME=xxxxx
5. Add layers with the necessary dependencies.
6. Add API gate way trigger, to enable trigger through frontend.
