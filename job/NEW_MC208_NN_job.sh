#!/bin/bash
#SBATCH -J NEW_MC208 # A single job name for the array
#SBATCH -c 1 # Number of cores
#SBATCH -p shared # Partition
#SBATCH --mem 4000 # Memory request (6Gb)
#SBATCH -t 0-3:00 # Maximum execution time (D-HH:MM)
#SBATCH -o NEW_MC208_%A_%a.out # Standard output
#SBATCH -e NEW_MC208_%A_%a.err # Standard error

echo "Initialising NEXUS environment" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
start=`date +%s`

# Set the configurable variables
Diff=0.30
JOBNAME="NEW_MC208"

# Create the directory
cd $SCRATCH/guenette_lab/Users/$USER/
mkdir -p $JOBNAME/$Diff/jobid_"${SLURM_ARRAY_TASK_ID}"
cd $JOBNAME/$Diff/jobid_"${SLURM_ARRAY_TASK_ID}"

# Copy the files over
cp ~/packages/NEWDiffusion/config/* .
cp ~/packages/nexus/macros/geometries/NEWDefaultVisibility.mac .

# Edit the file configs
sed -i "s#.*outputFile.*#/nexus/persistency/outputFile NEW_Tl208_ACTIVE.next#" NEW_MC208_NN.config.mac
sed -i "s#.*longitudinal_diffusion.*#                      longitudinal_diffusion = ${Diff} * mm / cm**0.5,#" detsim.conf

# Setup nexus and run
echo "Setting Up NEXUS" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
source ~/packages/nexus/setup_nexus.sh

# Also setup IC
source ~/packages/IC/setup_IC.sh

echo "Running NEXUS" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
for i in {1..2}; do

	# Replace the seed in the file	
	echo "The seed number is: $((1111111*${SLURM_ARRAY_TASK_ID}+$i))" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	sed -i "s#.*random_seed.*#/nexus/random_seed $((1111111*${SLURM_ARRAY_TASK_ID}+$i))#"  NEW_MC208_NN.config.mac
	sed -i "s#.*file_out.*#file_out = \"NEW_Tl208_ACTIVE_esmeralda_jobid_${SLURM_ARRAY_TASK_ID}_${i}_Diff${Diff}.next.h5\"#" esmeralda.conf
	
	# NEXUS
	nexus -n 10000 NEW_MC208_NN.init.mac 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

	# IC
	city detsim detsim.conf           2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city diomira diomira.conf         2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city irene irene.conf             2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city penthesilea penthesilea.conf 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city esmeralda esmeralda.conf     2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	echo; echo; echo;
done

# Cleaning up
rm -v *NEW_Tl208_ACTIVE*.next.h5 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
rm -v *detsim.next.h5* 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
rm -v *diomira.next.h5* 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
rm -v *irene.next.h5* 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
rm -v *penthesilea.next.h5* 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

echo "FINISHED....EXITING" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
end=`date +%s`
runtime=$((end-start))
echo "$runtime s" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt