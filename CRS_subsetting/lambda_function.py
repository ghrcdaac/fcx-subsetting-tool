from datetime import datetime, timedelta
import json
import warnings
import os
warnings.filterwarnings("ignore")

from CRS.subset import subsetCRS
from helpers.s3_helper import moveToSubdir
from wsConnect import WSConnect

#---download script template in "output" bucket (not raw data bucket)
scriptTMP = 'subsets/download_template.py'

def lambda_handler(event, context):
    # 1. formulate the data, from the input lambda event
    print("Start request for FCX subset...")
    
    # when invoked by another lambda function, payload is recieved in string.
    if isinstance(event, str): event = json.loads(event)
    if(event): dcEvent = event
    # print('dcEvent',dcEvent)

    # create ws connection
    wsurl =  os.environ.get('WS_URL')
    wsTokenId = dcEvent["wsTokenId"]
    wscon = WSConnect(wsurl, wsTokenId)

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
    
        if('CRS' in dsets):
            subfile = subsetCRS(t0, tstart, tend, latRange, lonRange, fdate)
            if(subfile):
                moveToSubdir(subfile, subDir, destinationBucket)
                wscon.sendMessage({"wstokenid": wsTokenId, "message": "subsetting CRS done.", "crs": "true"})
            else:
                wscon.sendMessage({"wstokenid": wsTokenId, "message": "subsetting CRS failed.", "crs": "false"})
    else:
        print("%%%Error! Temp dir for subset cannot be created!!")
        wscon.sendMessage({"wstokenid": wsTokenId, "message": "subsetting time less than 10 seconds.", "crs": "false"})
    wscon.close()

# lambda_handler(1,2)