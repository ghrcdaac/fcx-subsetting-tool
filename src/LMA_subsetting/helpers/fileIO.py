
#====================================================
# For aircraft datasets (CRS, CPL, FEGS, LIP)
#   save subset data to a tmpfile in lambda's /tmp/.
#   before copying to the destined s3 bucket
#====================================================
def tmpFile(file, tstart, tend,instr,):
    """
    get a string pathname in temp.
    Useful to save the subset data in tmp,
    according to instrument name and
    Start End time.
    file: e.g. 'LMA/OKLMA/data/2017-05-17/goesr_plt_OKLMA_20170517_060000_0600.dat.gz'
    tstart: e.g. '2017-05-17 05:52:55 UTC'
    tend: e.g. '2017-05-17 06:00:55 UTC'
    instr: e.g. 'CRS, CPL, FEGS, LIP'
    """
    sdate = tstart.strftime('%Y%m%d')
    ts1 = tstart.strftime('%H%M%S')
    ts2 = tend.strftime('%H%M%S')
    
    fend = '.'+file.split('.')[-1]
    #tmpfile = '/tmp/'+file.split('/')[-1].split('.')[0]+'_'+ts1+'-'+ts2+fend
    tmpfile = '/tmp/subset'+instr+'_'+sdate+'_'+ts1+'-'+ts2+fend
    return tmpfile.split('.')[0]+'.dat'