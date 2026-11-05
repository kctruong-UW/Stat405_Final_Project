#!/bin/bash
echo "date,key,count" > all.csv
cat day_*.csv >> all.csv
Rscript analysis.R
