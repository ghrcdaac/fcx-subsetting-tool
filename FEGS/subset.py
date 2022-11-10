import pandas as pd
import os
from datetime import datetime, timedelta
from helpers.s3_helper import S3list
from helpers.fileIO import tmpFile

def subsetFEGS(t0, tstart, tend, latRange, lonRange, fdate):
    """
    Gets the original FEGS file stored in s3.
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
    file = S3list(fdate, 'FEGS')[0]
    s3path='s3://'+bucket0+'/'+file
    DF = pd.read_csv(s3path, sep=",",index_col=None,usecols=
                  ['FlashID', 'GPSstart','SUBstart','GPSend','SUBend', 
                   'lat','lon','alt','roll','peak','energy','meanBG','MaxPixNum',
                   'FOVlat1','FOVlon1','FOVlat2','FOVlon2',
                   'FOVlat3','FOVlon3','FOVlat4','FOVlon4'])
    # GPS time in 2012 is ahead of UTC by 18 seconds.
    GPSsec0517 = 1179014418  #<--GPSsec for 2017,05,17 00UTC
    t0517= datetime(2017,5,17)
    diff = (t0 - t0517).total_seconds()
    GPSsec0 = GPSsec0517+diff
    Secs = (DF['GPSstart']+DF['SUBstart']-GPSsec0).astype(int)
    DF['Time'] = [t0+timedelta(seconds=s) for s in Secs]
   
    DF = DF[ (DF.Time >=tstart) & (DF.Time< tend) ]
    
    if(latRange != '-'):
        lons = lonRange.split(', ')
        lats = latRange.split(', ')
        lonW, lonE = float(lons[0]), float(lons[1])
        latS, latN = float(lats[0]), float(lats[1])
        DF = DF[(DF.lon > lonW) & (DF.lon < lonE) & (DF.lat > latS) & (DF.lat < latN)]
        print('FEGS length:',len(DF))
    
    tmpfile = None
    if(len(DF)>0):
        tmpfile = tmpFile(file, tstart, tend, 'FEGS_Flash')
        # tmpfile = "./data/subsets/" + tmpfile.split("/")[2] #TODO: remove later. only for local test
        print(tmpfile)
        DF.reset_index(drop=True, inplace=True)
        DF = DF.drop('Time', 1)
        DF.to_csv(tmpfile, index=False)

    return tmpfile 
