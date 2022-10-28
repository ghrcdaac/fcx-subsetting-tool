##############################################################################
# Requires 1) boto3 library pre-installed for python 3.5 and later (pathlib) #
#          2) AWS account & a AWS credential file set up in .aws/credentials #
##############################################################################
import os
import boto3
from pathlib import Path 

s3bucket = 'ghrc-fcx-viz-output'
AWSregion= 'us-east-1' 
s3 = boto3.resource('s3', region_name=AWSregion)
bucket = s3.Bucket(s3bucket)

subDir = 'subsets/RHPeR8073622/'
subset = subDir.split('subsets/')[1]

localDir = 'tmp/'+subset #<--suset to be saved under local tmp/
Path(localDir).mkdir(parents=True, exist_ok=True)

for obj in bucket.objects.filter(Prefix=subDir):
    
    s3path, filename = os.path.split(obj.key)

    if(s3path+'/' != subDir):
        Dir = s3path.split('/')[-1]
        Path(localDir+Dir).mkdir(parents=True, exist_ok=True)
        print('*Downloading '+os.path.join(subset,Dir,filename)+'....')
        
        bucket.download_file(obj.key, os.path.join(localDir,Dir,filename))
    
    elif(obj.key != subDir):
        print('*Downloading '+os.path.join(subset,filename)+'....')
        bucket.download_file(obj.key, os.path.join(localDir,filename))

