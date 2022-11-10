import pandas as pd
import os
from datetime import datetime as dt
from helpers.s3_helper import S3list
from helpers.fileIO import tmpFile

def subsetLIP(tstart, tend, latRange, lonRange, fdate):
    """
    Gets the original LIP file stored in s3.
    Generates the subsets and stores it inside a temp file.
    returns the string list of file names, that are stored inside temp dir.
    Later expected to upload to s3.

    Args:
        t0 (datetime): date object %Y-%m-%d
        tstart (datetime): start date time object %Y-%m-%d %H:%M:%S UTC
        tend (datetime): end date time object %Y-%m-%d %H:%M:%S UTC
        latRange (string): _description_
        lonRange (string): _description_
        s3bucket (string): _s3 bucket where the raw file is stored in.
        fdate (string): string flight date.

    Returns:
        _type_: string dir of subset file in tmp.
    """    
    bucket0 = os.environ.get('SOURCE_BUCKET_NAME')
    file = S3list(fdate,'LIP')[0]
    s3path='s3://'+bucket0+'/'+file
    df=pd.read_csv(s3path, sep=",",header=None)
    df.columns = ['Date/Time', 'Ex', 'Ey', 'Ez', 'Eq', 
                  'lat', 'lon', 'alt','v8','v9','v10']

    df['Time'] = [dt.strptime((a.split('.')[0]), '%Y-%m-%d %H:%M:%S') for a in df['Date/Time']]

    df = df[ (df.Time >=tstart) & (df.Time< tend) ]
    
    if(latRange != '-'):
        lons = lonRange.split(', ')
        lats = latRange.split(', ')
        lonW, lonE = float(lons[0]), float(lons[1])
        latS, latN = float(lats[0]), float(lats[1])
        df = df[(df.lon > lonW) & (df.lon < lonE) & (df.lat > latS) & (df.lat < latN)]
    
    tmpfile = None
    if(len(df)>0):
        tmpfile = tmpFile(file, tstart, tend, 'LIP')
        # tmpfile = "./data/subsets/" + tmpfile.split("/")[2] #TODO: remove later. only for local test
        df.reset_index(drop=True, inplace=True)
        df = df.drop('Time', 1)
        df.to_csv(tmpfile, index=False, header=False)

    return tmpfile 
