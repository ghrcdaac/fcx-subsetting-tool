import boto3, s3fs
import os
from datetime import datetime

#---raw data bucket

# AWSregion= 'us-east-1'
# bucket0 = 'fcx-raw-data'
AWSregion= os.environ.get('AWS_REGION')
bucket0 = os.environ.get('SOURCE_BUCKET_NAME')

#---initiate s3, both low level and high level APIs
s3 = boto3.resource('s3', region_name=AWSregion)
client = boto3.client('s3', region_name=AWSregion)

def S3list(date,instrm,network='OKLMA'):
    """
    get list of files in a s3 bucket for a specific fdate and instrument (prefix)
    fdate: e.g. '2017-05-17'
    instrm: e.g. 'GLM'
    """
    prefix={'GLM':'GLM/data/L2/'+fdate+'/OR_GLM-L2-LCFA_G16_s',
            'ABI':'ABI/data/'+fdate+'/C13/OR_ABI-L1b-RadC-M3C13_G16',
            'LIS':'ISS_LIS/data/'+fdate+'/ISS_LIS_SC_V1.0_',
            'FEGS':'FEGS/data/goesr_plt_FEGS_'+fdate.replace('-','')+'_Flash',
            'CRS':'CRS/data/GOESR_CRS_L1B_'+fdate.replace('-',''),
            'NAV':'NAV_ER2/data/goesrplt_naver2_IWG1_'+fdate.replace('-',''),
            'LMA':'LMA/'+network+'/data/'+fdate+'/goesr_plt_'+network+'_'+fdate.replace('-',''),
            'LIP':'LIP/data/goesr_plt_lip_'+fdate.replace('-','')}
    
    srcbucket = bucket0
    bucket = s3.Bucket(srcbucket)
    # print("S3list searching for ",prefix[instrm])
    
    keys=[]
    if(instrm=='GLM'):
        yyyyjjj   = datetime.strptime(fdate,'%Y-%m-%d').strftime('%Y%j')
        prefx = prefix[instrm] + yyyyjjj #+ str(i).zfill(2)
        for obj in bucket.objects.filter(Prefix=prefx):
            keys.append(obj.key)
            
    else:
        for obj in bucket.objects.filter(Prefix=prefix[instrm]):
            keys.append(obj.key)

    return keys

def moveToSubdir(tmpfile, subDir, desbucket):
    '''
    Upload file in tempfile dir to one S3 Bucket to another s3 Bucket
    tmpfile: dir of temp file
    subDir: dir in s3, to store file
    destbucket: bucket in s3, to store the file
    '''
    subfile = tmpfile.split('/')[-1]
    fileKey = subDir + subfile

    s3.Bucket(desbucket).upload_file(tmpfile, fileKey)
    print('*{} uploaded to {}:{} \n'.format(subfile,desbucket, fileKey))    

def copyToSubdir(files, tempKey, desbucket, instr=''):
    '''
    Copy from one S3 Bucket to another s3 Bucket
    files: list of file names
    tempKey: key to make file unique in s3
    destbucket: destination bucket name
    instr: instrument name
    '''
    if(len(files)==0): return
    
    srcbucket = bucket0 # bucket0 = fcx-raw-data

    for file in files:
        print(file)
        fileKey = tempKey + instr + file.split('/')[-1]
        try:
            s3.Object(srcbucket, file).load()
        except: 
            print(file,' DOES NOT exists!')

        source= { 'Bucket' : srcbucket, 'Key': file}
        s3.Bucket(desbucket).copy(source, fileKey)
        #s3.Object(desbucket, fileKey).copy_from(CopySource = source)
    print('*{} subset copied to S3 temp \n'.format(instr.split('/')[0]))
    
def makesubDir(desbucket, subDir,scriptTMP):
    """
    Create an s3 sub-folder for the data subset (probably unnecessary)
    Make a python downloadcript and place it in this subfolder
    destbucket: bucket in s3, to store the file
    subDir: dir in s3, to store file
    """

    #---check if dir exists
    result = client.list_objects(Bucket = desbucket, Prefix = subDir )
    exists = False
    print(subDir,'exists?',result)

    if('Contents' not in result):
        client.put_object(Bucket=desbucket, Key=subDir)
        mkDLscript(scriptTMP, desbucket, subDir)
        
        print(subDir,' Dir created for current subset with download script ready\n')

def s3FileObj(s3bucket,fname):
    """
    Return S3 file object to be accessed using xarray or hdf5/netcdf4.
    """
    file = s3bucket+'/'+fname
    fs = s3fs.S3FileSystem()  #(anon=False)
    fileObj = fs.open(file,'rb')

    return fileObj

def readObject(fname, s3bucket):
    """    
    Access the object file (eg. CRS)
    reads the data
    Return data in file object

    Args:
        fname (_type_): name of the onject file
        s3bucket (_type_): bucket where the object file resides

    Returns:
        _type_: bytes
    """
    fileobj = client.get_object(Bucket=s3bucket, Key=fname) 
    fileCRS = fileobj['Body'].read()
    return fileCRS
    

# helpers

def mkDLscript(scriptTMP, desbucket, subDir):
    """
    Open the download template script file (also in the desbucket)
    Replace the lines indicating the subset's location for download in 
    the download script template file
    """
    #lines = open(scriptTMP, 'r').readlines()
    obj = s3.Object(desbucket, scriptTMP)
    lines = obj.get()['Body'].read().decode('utf-8').split('\n')
    lines = [ s+'\n' for s in lines]
    
    text1 = "s3bucket = '"+desbucket+"'\n"
    text2 = "subDir = '"+subDir+"'\n"
    no1 = 8
    no2 =13
    lines[no1] = text1
    lines[no2] = text2
    out = open('/tmp/downloadScript.py', 'w')
    out.writelines(lines)
    out.close()
    
    moveToSubdir('/tmp/downloadScript.py', subDir, desbucket)
