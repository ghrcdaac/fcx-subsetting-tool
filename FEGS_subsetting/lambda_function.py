from datetime import datetime, timedelta
import json
import warnings
warnings.filterwarnings("ignore")

from FEGS.subset import subsetFEGS
from helpers.s3_helper import moveToSubdir

#---download script template in "output" bucket (not raw data bucket)
scriptTMP = 'subsets/download_template.py'

def lambda_handler(event, context):
    # 1. formulate the data, from the input lambda event
    print("Start request for FCX subset...")
    
    # when invoked by another lambda function, payload is recieved in string.
    if isinstance(event, str): event = json.loads(event)

    dcEvent = {
        "subDir": "https://szg-ghrc-fcx-viz-output.s3.amazonaws.com/subsets/subset_test00/",
        "date": "2017-05-17",
        # "Start": "2017-05-17 05:52:55 UTC",
        # "End": "2017-05-17 06:00:02 UTC",
        "Start": "2017-05-17 07:00:55 UTC",
        "End": "2017-05-17 07:16:02 UTC",
        "latRange": "-",
        "lonRange": "-",
        "DataSets": [
            {
                "id": "1",
                "cat_id": "CRS",
                "state": 1
            },
            {
                "id": "2",
                "cat_id": "LIP",
                "state": 1
            },
            {
                "id": "3",
                "cat_id": "FEGS",
                "state": 1
            },
            {
                "id": "4",
                "cat_id": "LMA",
                "state": 1
            },
            {
                "id": "5",
                "cat_id": "LIS",
                "state": 1
            },
            {
                "id": "6",
                "cat_id": "GLM",
                "state": 1
            },
            {
                "id": "7",
                "cat_id": "ABI",
                "state": 1
            }
        ]
    }
    

    if (event['body']): dcEvent = event['body']
    # print('dcEvent',dcEvent)
    
    subsetDir = dcEvent['subDir']
    # output bucket and the dir inside output bucket
    destinationBucket = subsetDir.split('://')[-1].split('.s3.')[0]
    subDir = subsetDir.split('s3.amazonaws.com/')[-1]
    
    fdate = dcEvent['date']
    Tstart = dcEvent['Start']
    Tend = dcEvent['End']
    latRange = dcEvent['latRange']
    lonRange = dcEvent['lonRange']
    datasets = dcEvent['DataSets']
    nsets = len(datasets)

    # 2. collect the cat ids (LIS, LIP, FEGS, ABI, etc.)
    dsets=[]
    for ds in datasets:
        dsets.append(ds['cat_id'])
    
    # print('Received fdate,Tend,subDir=',fdate,Tend,subDir)
    # print('No. of datasets:',len(dsets))

    # 3. To check if the subsetting is actually possible.
    tstart = datetime.strptime(Tstart,'%Y-%m-%d %H:%M:%S UTC')
    tend   = datetime.strptime(Tend,  '%Y-%m-%d %H:%M:%S UTC')
    t0 = datetime.strptime(fdate,'%Y-%m-%d')
    dt = (tend - tstart)
    if dt>timedelta(seconds=10):
        # --make subDir and download script

        # 4. create the buckets, dirs, tmps needed for the script, in later time.
        # makesubDir(destinationBucket, subDir, scriptTMP)
    
        if('FEGS' in dsets):
            subfile = subsetFEGS(t0, tstart, tend, latRange, lonRange, fdate)
            # print('{} created for FEGS subset'.format(subfile))
            if(subfile): moveToSubdir(subfile, subDir, destinationBucket)

    else:
        print("%%%Error! Temp dir for subset cannot be created!!")

# lambda_handler(1,2)