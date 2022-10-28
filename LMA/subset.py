import pandas as pd
from datetime import datetime
from helpers.s3_helper import S3list
from helpers.fileIO import tmpFile
from .helpers.LMA_getter import get_LMA

# from stRangesLMA import stRangesLMA
###########################################
# functions
###########################################

def LMAfiles(srcbucket,fdate,tstart,tend,latRange,lonRange,network='OKLMA'):
    """
    get LMA filename list within Trange [sec] starting from tstart on fdate
    Note that LMA files are every 10min/5min
    """
    files = S3list(srcbucket,fdate,'LMA',network=network)

    if(len(files)==0): return []
    
    filesLMA = []
    for file in files:
        tstr = file.split(fdate.replace('-','')+'_')[-1]
        hrtime = ' '+tstr.split('_')[0]
        if(network=='NALMA'): 
            ftbeg = datetime.strptime(fdate+hrtime,'%Y-%m-%d %H')
        else:
            ftbeg = datetime.strptime(fdate+hrtime,'%Y-%m-%d %H%M%S')

        if(ftbeg >= tstart) & (ftbeg < tend): 
            filesLMA.append(file)
        else:
            if(len(filesLMA)>0): break
    print("No. of LMA found for selected period: ",len(filesLMA))

    
    # if lon-lat avail, first subset for latitue, else skip it
    # the subset for date time

    header= None
    DF = pd.DataFrame()
    print(filesLMA)
    for file in filesLMA:
        df, header = get_LMA(srcbucket,file,header)
        DF = pd.concat([DF, df])
                
    # # skipped lon lat subsetting for now.
    # #-- get spatial subset
    # if(latRange != '-'):
    #     lons = lonRange.split(', ')
    #     lats = latRange.split(', ')
    #     lonW, lonE = float(lons[0]), float(lons[1])
    #     latS, latN = float(lats[0]), float(lats[1])
    #     DF = DF[(DF.Lon > lonW) & (DF.Lon < lonE) & (DF.Lat > latS) & (DF.Lat < latN)] 
                
    #-- get temporal subset
    t0 = datetime.strptime(fdate,'%Y-%m-%d')
    t1 = (tstart - t0).total_seconds()
    t2 = (tend   - t0).total_seconds()
    DF = DF[(DF.Time>=t1) & (DF.Time<=t2)]
    #-- string dir: to save subset to a file in lambda's /tmp/ dir
    # tmpfile = tmpFile(file, tstart, tend, network).split('.')[0]+'.dat'
    tmpfile = tmpFile(file, tstart, tend, network)
    tmpfile = "./data/subsets/" + tmpfile.split("/")[2] # TODO: remove later, only for local testing 

    #-------------------------
    #--keep original header (may take ~30s for a 10min subset of DF.to_string() and write(line))
    #-------------------------
    header[-2] = 'Number of events: '+str(len(DF))
    header = '\n'.join([line for line in header] )
    header +='\n'
    data = DF.to_string(header=False,
                       index=False) #.split('\n')
    with open(tmpfile, 'w') as ict:
       for line in header: ict.write(line)
       if(len(DF)>0):
           for line in data: ict.write(line) 
       filesLMA = [tmpfile]
       print('LMA subset:',tmpfile)
    
    #-------------------------
    #-- no original header
    #-------------------------

    # DF = DF.rename({'Time': 'Data: time (UT sec of day)', 
    #                 'Lat':'lat', 'Lon':'lon', 'Alt':'alt(m)',
    #                 'chi^2':'reduced chi^2', 'dBW':'P(dBW)'}, axis=1)
    # if(len(DF)>0): 
    #     DF.to_csv(tmpfile, index=False)
    #     filesLMA = [tmpfile]
    #     print('LMA subset:',tmpfile)
    # else: 
    #     filesLMA = []
    #-------------------------

    return filesLMA