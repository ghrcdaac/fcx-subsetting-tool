declare -a arr=("CRS_subsetting" "FEGS_subsetting" "GLM_subsetting" "LIP_subsetting" "LIS_subsetting" "LMA_subsetting" "trigger_subsetting")
mkdir ./dist
for i in "${arr[@]}"
do
   echo "zipping for $i started"
   zip -r ./dist/$i.zip ./$i
   echo "zipping for $i done."
done