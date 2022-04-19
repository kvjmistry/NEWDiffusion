#!/bin/bash

# Declare an array of string with type, these are the EL drift vel values to run
declare -a StringArray=("1.25" "2.5" "3.75")

# Iterate the string array using for loop
for ELDrift in ${StringArray[@]}; do
   echo "Making jobscripts for EL Drift Vel value: $ELDrift"
   mkdir -p ELDrift_$ELDrift
   cd  ELDrift_$ELDrift
   cp ../NEW_MC208_NN_job.sh .
   sed -i "s#.*SBATCH -J.*#\#SBATCH -J NEW_MC208_${ELDrift}ELDrift \# A single job name for the array#" NEW_MC208_NN_job.sh
   sed -i "s#.*SBATCH -o.*#\#SBATCH -o NEW_MC208_${ELDrift}ELDrift_%A_%a.out \# Standard output#" NEW_MC208_NN_job.sh
   sed -i "s#.*SBATCH -e.*#\#SBATCH -e NEW_MC208_${ELDrift}ELDrift_%A_%a.err \# Standard error#" NEW_MC208_NN_job.sh
   sed -i "s#.*ELDrift=.*#ELDrift=${ELDrift}#" NEW_MC208_NN_job.sh
   sbatch --array=1-10 NEW_MC208_NN_job.sh
   # sbatch --array=1-500 NEW_MC208_NN_job.sh
   cd ..
done
