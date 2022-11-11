import subprocess

SUBSETTING_TYPES = ['CRS', 'FEGS', 'GLM', 'LIP', 'LIS', 'LMA']

def execsc(command):
    return subprocess.Popen(f"{command}", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

# create a dist dir. Inside the dist dir.
execsc("mkdir ./dist")
# for each subsetting type, create a new dir.
for subsetting_type in SUBSETTING_TYPES:
    newDir = f"{subsetting_type}_build"
    execsc(f"mkdir ./dist/{newDir}")
    # copy each subsetting type module into the new dir.
    execsc(f"cp -r ./{subsetting_type} ./dist/{newDir}")
    # copy helpers into the new dir.
    execsc(f"cp -r ./helpers ./dist/{newDir}")
    # also copy the lambda_function to the new dir.
    execsc(f"cp ./lambda_function.py ./dist/{newDir}")
    # also copy the zip to the new dir.
    execsc(f"cp ./create_zip.sh ./dist/{newDir}")

print("DONE")