from datetime import datetime
from tkinter import ALL
from helpers.s3_helper import S3list

def GOESfiles(srcbucket,fdate,tstart,tend,instr='GLM'):
    """
    get GLM or ABI file list between tstart and tend
    Note that GOES-R M3/CONUS scan for ABI was about every 5min
    Note that GLM files are every 20 sec for most flights,
         BUT irregular for flights on/before April 22, 2017 (corrupt files?)
         
    GLM files are hosted in s3. The files are separated according to date/time.
    So, when a subset is to be done, a check is done, to find, which of those files contains our date of interest.
    Returns a list of subset files.
    The files are later copied from source bucket to our destination bucket.
    """
    
    ALLfiles = S3list(srcbucket,fdate,instr)
    # print('Files:',ALLfiles)

    files = []
    for file in ALLfiles:
        ftstr = file.split('G16_s')[-1].split('_e')[0]
        ftbeg = datetime.strptime(ftstr[0:-1],'%Y%j%H%M%S')
        if(ftbeg >= tstart) & (ftbeg < tend): 
            files.append(file)
        else:
            if(len(files)>0): break
    
    print(" No. of {} files found: {}".format(instr, len(files)))
    return files