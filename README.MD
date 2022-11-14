## How to deploy the lambda function (in the AWS lambda)
### It is supposed that the user has some prior knowledge about lambda.
1. clone the subsetting tool from github
2. run `build.sh`
3. inside the `/dist` dir, zips will be created for each subsetting type and the trigger.
4. For each zip files, create a lambda function.
5. upload each zip files into their appropriate lambdas.
6. The dependencies for the subsetting code is already available as layer.
   - add `XarrScipy` layer for the CRS type lambda
   - add `XarrS3fsH5ncf` layer for rest.
   - Note: that the `trigger_subsetting` doesnot need any dependency. So, do not add layer to it.
7. Each of the code (except trigger_subsetting) needs env variables (i.e. to state the region of the i/p, o/p bucket and the region of the bucket). So add them to each lambda. (Most possibly same env variables for all lambdas.)
   - `BUCKET_AWS_REGION`
   - `SOURCE_BUCKET_NAME`
8. Also, Each of the code (except trigger_subsetting), needs permission to read and write to S3.
   - Either create your own permission, Or add `sanjog-subsetting-fcx-role-ikmiflyf` permission to each lambda.
9. The `trigger_subsetting` should have an API gate way as an trigger, so add one.
10. For the expected POST API call, refer. postman collection attached `subsetting_postman`.


## To test the subsetting in lambda
1. Use the postman collection `subsetting_postman` as a reference to trigger the lambda.
2. The output will be in the `subDir` mentioned in the post request body.


## To test the subsetting script locally:
1. clone the subsetting tool from github
2. Create a env (using conda or pyenv) and then install dependencies using `requirements.txt`
3. Add `__init__.py` in each subsetting dir.
4. Import each subsetting inside the `lambda_function` of the `trigger_subsetting`, and invoke them (instead of lambda `client.invoke`)
5. Uncomment the `lambda_handler()` function call in the `lambda_function.py` for each subsetting.
6. Run `bash start.sh`
