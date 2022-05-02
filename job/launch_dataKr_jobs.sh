#!/bin/bash

# Declare an array of string with type, these are the EL drift vel values to run
declare -a MapArray=("match" "zrms" "zs1" "alternate")
declare -a FileArray=("kr_emap_xy_r_7746_st200819_band_match.h5" "kr_emap_xy_r_7746_st200819_band_zrms.h5" "kr_emap_xy_r_7746_st200819_band_zs1.h5" "kr_emap_xy_r_bndry_7746_st200819_band_zrms_alternate.h5")

# Iterate the string array using for loop
for i in ${!MapArray[@]}; do
   MAP=${MapArray[$i]}
   echo "Making jobscripts for Kr Map: $MAP"
   mkdir -p KrMAP_$MAP
   cd  KrMAP_$MAP
   cp ../Esmeralda_KrMaps.sh .
   sed -i "s#.*SBATCH -J.*#\#SBATCH -J KrMap_${MAP} \# A single job name for the array#" Esmeralda_KrMaps.sh
   sed -i "s#.*SBATCH -o.*#\#SBATCH -o KrMap_${MAP}_%A_%a.out \# Standard output#" Esmeralda_KrMaps.sh
   sed -i "s#.*SBATCH -e.*#\#SBATCH -e KrMap_${MAP}_%A_%a.err \# Standard error#" Esmeralda_KrMaps.sh
   sed -i "s#.*KrMap=.*#KrMap=${FileArray[$i]}#" Esmeralda_KrMaps.sh
   sed -i "s#.*MODE=.*#MODE=${MAP}#" Esmeralda_KrMaps.sh
   sbatch --array=1-148 Esmeralda_KrMaps.sh
   cd ..
done
