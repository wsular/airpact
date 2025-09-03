#!/usr/bin/bash

d=$(date +%Y%m%d)

cd /home/vonw/work/software/airpact/GIS

/home/vonw/anaconda3/envs/work/bin/python create-airpact-gis.py

aws s3 cp ${d}_PM25.gpkg s3://airpact-gis/airpact_PM25_${d}.gpkg --acl public-read-write
aws s3 cp ${d}_O3.gpkg s3://airpact-gis/airpact_O3_${d}.gpkg --acl public-read-write

rm ${d}_PM25.gpkg
rm ${d}_O3.gpkg

