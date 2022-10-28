from datetime import datetime, timedelta
import numpy as np
import xarray as xr

def check_LIS(fileobj, fdate):
    """
    get LIS (lat,lon,time)
    Note that Secs is minisecond offset from the file time in the .nc file.
    *Using xarray, TAI is automatically converted to np.datetime64[ns].
    *Do not use xr.open_mfdataset. Dimensions in a LIS file are not fixed. 
    """
    ds= xr.open_dataset(fileobj, engine='h5netcdf')
    try:
        nflash=len(ds['flash_dim'].values)
    except KeyError:
        #print('%% %s has NO lightning data %%' %file.split('/')[-1])
        return [],None,None

    Lat = np.array(ds['lightning_area_lat'])
    Lon = np.array(ds['lightning_area_lon'])
    TAI = np.array(ds['lightning_area_TAI93_time']) #<--as datetime64[ns]
    Secs=(TAI - np.datetime64(fdate)).astype('timedelta64[s]').astype(int)
    Time = np.array([datetime.strptime(fdate,'%Y-%m-%d') + 
                     timedelta(seconds=int(s)) for s in Secs])
    ds.close()
    return Lat,Lon,Time