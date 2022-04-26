#!/bin/bash

# Declare an array of string with type, these are the EL drift vel values to run
declare -a StringArray=("gamma" "eminus")

# Iterate the string array using for loop
for SP in ${StringArray[@]}; do
   echo "Making jobscripts for particle value: $SP"
   mkdir -p $SP
   cd $SP
   cp ../NEW_MC208_NN_job.sh .
   sed -i "s#.*SBATCH -J.*#\#SBATCH -J NEW_MC208_${SP}SP \# A single job name for the array#" NEW_MC208_NN_job.sh
   sed -i "s#.*SBATCH -o.*#\#SBATCH -o NEW_MC208_${SP}SP_%A_%a.out \# Standard output#" NEW_MC208_NN_job.sh
   sed -i "s#.*SBATCH -e.*#\#SBATCH -e NEW_MC208_${SP}SP_%A_%a.err \# Standard error#" NEW_MC208_NN_job.sh
   sed -i "s#.*CONFIG=.*#CONFIG=NEW_MC208_NN_SP.config.mac#" NEW_MC208_NN_job.sh
   sed -i "s#.*INIT=.*#INIT=NEW_MC208_NN_SP.init.mac#" NEW_MC208_NN_job.sh
   sed -i "s#.*MODE=.*#MODE=${SP}#" NEW_MC208_NN_job.sh
   sbatch --array=1-50 NEW_MC208_NN_job.sh
   # sbatch --array=1-500 NEW_MC208_NN_job.sh
   cd ..
done
