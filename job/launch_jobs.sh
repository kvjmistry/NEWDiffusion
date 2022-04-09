#!/bin/bash

# Declare an array of string with type, these are the diffision values to run
declare -a StringArray=("0.1" "0.2" "0.3" "0.4" "0.5")

# Iterate the string array using for loop
for diff in ${StringArray[@]}; do
   echo "Making jobscripts for diffusion value: $diff"
   mkdir -p Diffusion_$diff
   cd  Diffusion_$diff
   cp ../NEW_MC208_NN_job.sh .
   sed -i "s#.*SBATCH -J.*#\#SBATCH -J NEW_MC208_${diff}diff \# A single job name for the array#" NEW_MC208_NN_job.sh
   sed -i "s#.*SBATCH -o.*#\#SBATCH -o NEW_MC208_${diff}diff_%A_%a.out \# Standard output#" NEW_MC208_NN_job.sh
   sed -i "s#.*SBATCH -e.*#\#SBATCH -e NEW_MC208_${diff}diff_%A_%a.err \# Standard error#" NEW_MC208_NN_job.sh
   sed -i "s#.*Diff=.*#Diff=${diff}#" NEW_MC208_NN_job.sh
   sbatch --array=1-10 NEW_MC208_NN_job.sh
   cd ..
done
