import numpy as np
from helpers.s3_helper import S3list, s3FileObj
from .helpers.checker import check_LIS

def LISfiles(s3bucket,fdate, bigbox, tstart, tend, Verb=False):
    """
    Get LIS filename list within range [sec] starting from start to end on fdate
    and within the bigbox domain.
    Working:
    LIS files are hosted in s3. The files are separated according to date/time.
    So, when a subset is to be done, a check is done, to find, which of those files contains our date of interest.
    Returns a list of subset files.
    The files are later copied from source bucket to our destination bucket.
    """
    
    filesALL = S3list(s3bucket,fdate,'LIS')
    
    if len(filesALL)==0: return []
        
    files = [file for file in filesALL if file.split('.')[-1]=='nc']
    if(Verb): 
        print(' No. of all LIS .nc files: ',len(files))
        print(" Searching between {} and {}".format(tstart,tend))
    
    nf=0
    filesLIS = []
    lonW,latS,lonE,latN = bigbox
    
    for file in files:
        if(Verb): print("Check on ",file)

        fileobj = s3FileObj(s3bucket, file)
        
        lat,lon,Time = check_LIS(fileobj, fdate)
        # if(len(lat)==0): continue

        mask1=np.where((Time>=tstart) & (Time<tend))
        if(len(mask1[0])>0):
            # mask2=np.where((lon>lonW)&(lon<lonE) & (lat>latS)&(lat<latN) & (Time>=tstart)&(Time<tend))  
            # mask2=np.where((Time>=tstart)&(Time<tend))
            mask2 = mask1
            if(len(mask2[0])>0):
                if(Verb): print(" no. of flashes: ",len(mask2[0]))
                nf=nf+1
                filesLIS.append(file)
                if(Verb): print("{} within domain and range.".format(file))
        else:
            if(Verb): print("{}-{} not in bounds".format(Time[0],Time[-1]))
            if(nf>0): break   #<--if prev file in range and this one is not, later ones won't be

    print(" No. of LIS files found in domain/range: {}".format(len(filesLIS)))
    print(filesLIS)
    return filesLIS