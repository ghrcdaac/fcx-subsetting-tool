import boto3
import pandas as pd
import io, gzip, os

#---raw data bucket
AWSregion= os.environ.get('BUCKET_AWS_REGION')
bucket0 = os.environ.get('SOURCE_BUCKET_NAME')

client = boto3.client('s3', region_name=AWSregion)
s3 = boto3.resource('s3', region_name=AWSregion)

def get_LMA(file,header=None):
    """
    1. Read LMA data with header excluded
    2. reduce data amount by filtering out noise
    Note that
    nheader: header rows to skip (upon meeting w/ slabel)
    """
    srcbucket = bucket0
    if(not header):
        header=get_LMAheader(srcbucket,file,slabel='*** data ***')

    nheader = len(header)
    obj = client.get_object(Bucket=srcbucket, Key=file)
    DF=pd.read_csv(io.BytesIO(obj['Body'].read()), 
                   names=['Time','Lat','Lon','Alt','chi^2','dBW','mask'],
                   sep=r"\s+",index_col=None,skiprows=nheader,header=None,
                   compression='gzip')


    # Noise reduction: chi^2 < 2, remove some noise data
    DF=DF[(DF['chi^2']<2)]
    DF.index = range(len(DF))

    return DF, header


def get_LMAheader(bucket,file,slabel='*** data ***'):
    obj = s3.Object(bucket,file)
    with gzip.GzipFile(fileobj=obj.get()["Body"]) as gzipfile:
        content = gzipfile.read().decode("utf-8") #<--convert bytes to string
        lines=content.split('\n')

    n=1; nheader=0
    for line in lines:
        if(slabel in line): 
            nheader=n
            break
        n=n+1

    if(nheader==0):
        print("%%Can't find where data starts.",
             "\n%%GO Check start indicator! Is it '%s'?" %slabel)
        return -1
    
    return lines[0:n]

