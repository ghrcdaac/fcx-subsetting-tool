import numpy as np
import xarray as xr
from datetime import timedelta
from helpers.s3_helper import S3list, readObject as CRSaccess
from helpers.fileIO import tmpFile

def subsetCRS(t0, tstart, tend, latRange, lonRange, s3bucket, fdate):
    """
    Gets the original CRS file stored in s3.
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
    bucket0 = 'fcx-raw-data'
    file = S3list(bucket0,fdate,'CRS')[0]
    fileObj = CRSaccess(file,s3bucket) # (only works if file was made NOT using hdf5/netcdf engine, i.e. scipy or default)
    #print(' Obtained CRS object')
    
    with xr.open_dataset(fileObj, decode_cf=False) as ds:
        tt = ds['time'].values
        print(tt)
        xx = ds['lon'].values
        yy = ds['lat'].values
        arr=np.array([t0+timedelta(seconds=int(t*3600)) for t in tt])
        print(arr)
        #print('CRS len:',arr.shape)
        
        if(latRange != '-'):
            lons = lonRange.split(', ')
            lats = latRange.split(', ')
            lonW, lonE = float(lons[0]), float(lons[1])
            latS, latN = float(lats[0]), float(lats[1])
            index = (arr >= tstart) & (arr <= tend) \
                  & (xx>lonW) & (xx<lonE) \
                  & (yy>latS) & (yy<latN)
        else:
            index = (arr >= tstart) & (arr <= tend)
        
        print(' CRS points selected:',np.sum(index))
        
        tmpfile = None
        if(np.sum(index)>0):
            tmpfile = tmpFile(file, tstart, tend, 'CRS')
            tmpfile = "./data/subsets/" + tmpfile.split("/")[2] #TODO: remove later. only for local test
            # print(tmpfile)
            subds = ds.isel(time = index)
            subds.to_netcdf(tmpfile)
            
    print('{} created'.format(tmpfile))
    return tmpfile
