#!/bin/bash
#SBATCH -J NEW_MC208 # A single job name for the array
#SBATCH -c 8 # Number of cores
#SBATCH -p shared # Partition
#SBATCH --mem 4000 # Memory request (6Gb)
#SBATCH -t 0-6:00 # Maximum execution time (D-HH:MM)
#SBATCH -o NEW_MC208_%A_%a.out # Standard output
#SBATCH -e NEW_MC208_%A_%a.err # Standard error

echo "Initialising NEXUS environment" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
start=`date +%s`

# Set the configurable variables
ELDrift=2.5
JOBNAME="NEW_MC208"
FILES_PER_JOB=1
N_EVENTS=500
CONFIG=NEW_MC208_NN.config.mac 
INIT=NEW_MC208_NN.init.mac 
MODE="Tl208"

# Replace the particle if mode is set to electron
if [ "MODE" = "eminus" ]; then 
   sed -i "s#.*gamma.*#/Generator/SingleParticle/particle e-#" ${CONFIG}
fi

# Create the directory
cd $SCRATCH/guenette_lab/Users/$USER/
mkdir -p $JOBNAME/$ELDrift/$MODE/jobid_"${SLURM_ARRAY_TASK_ID}"
cd $JOBNAME/$ELDrift/$MODE/jobid_"${SLURM_ARRAY_TASK_ID}"

# Copy the files over
cp ~/packages/NEWDiffusion/config/* .
cp ~/packages/nexus/macros/geometries/NEWDefaultVisibility.mac .

# Edit the file configs
sed -i "s#.*execute.*#/control/execute NEWDefaultVisibility.mac#" ${CONFIG}
sed -i "s#.*outputFile.*#/nexus/persistency/outputFile NEW_Tl208_ACTIVE.next#" ${CONFIG}
sed -i "s#.*el_drift_velocity.*#                      el_drift_velocity      = ${ELDrift} * mm / mus)#" detsim.conf
sed -i "s#.*map_fname.*#  map_fname              = '/n/home05/$USER/packages/NEWDiffusion/database/TEST_kr_emap_xy_r_bndry_7746_st200819_band_zrms_alternate.h5',#" esmeralda.conf

# Setup nexus and run
echo "Setting Up NEXUS" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
source ~/packages/nexus/setup_nexus.sh

# Also setup IC
source ~/packages/IC/setup_IC.sh

for i in $(eval echo "{1..${FILES_PER_JOB}}"); do

	# Replace the seed in the file	
	SEED=$((${N_EVENTS}*${FILES_PER_JOB}*(${SLURM_ARRAY_TASK_ID} - 1) + ${N_EVENTS}*${i}))
	echo "The seed number is: ${SEED}" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	sed -i "s#.*random_seed.*#/nexus/random_seed ${SEED}#" ${CONFIG}
	sed -i "s#.*start_id.*#/nexus/persistency/start_id ${SEED}#" ${CONFIG}
	# sed -i "s#.*file_out.*#file_out = \"NEW_${MODE}_ACTIVE_esmeralda_jobid_${SLURM_ARRAY_TASK_ID}_${i}_ELDrift${ELDrift}.next.h5\"#" esmeralda.conf
	
	# NEXUS
	echo "Running NEXUS" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	nexus -n $N_EVENTS ${INIT} 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

	# IC
	echo "Running IC Detsim"  2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city detsim detsim.conf   2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	echo "Running IC Diomira" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city diomira diomira.conf 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	echo "Running IC Irene"   2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city irene irene.conf     2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	echo "Running IC Penthesilea"     2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city penthesilea penthesilea.conf 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	echo "Running IC Esmeralda"     2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city esmeralda esmeralda.conf 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

	# Rename files
	mv NEW_Tl208_ACTIVE_penthesilea.next.h5 NEW_${MODE}_ACTIVE_penthesilea_jobid_${SLURM_ARRAY_TASK_ID}_${i}_ELDrift${ELDrift}.next.h5
	mv NEW_Tl208_ACTIVE_esmeralda.next.h5 NEW_${MODE}_ACTIVE_esmeralda_jobid_${SLURM_ARRAY_TASK_ID}_${i}_ELDrift${ELDrift}.next.h5

	echo; echo; echo;
done

# Merge the files into one
mkdir temp_penthesilea 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
mv *penthesilea*.h5 temp_penthesilea 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
python ~/packages/NEWDiffusion/tools/merge_h5.py -i temp_penthesilea -o NEW_${MODE}_ACTIVE_penthesilea_jobid_${SLURM_ARRAY_TASK_ID}_merged_ELDrift${ELDrift}.next.h5 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

mkdir temp_esmeralda 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
mv *esmeralda*.h5 temp_esmeralda 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
python ~/packages/NEWDiffusion/tools/merge_h5.py -i temp_esmeralda -o NEW_${MODE}_ACTIVE_esmeralda_jobid_${SLURM_ARRAY_TASK_ID}_merged_ELDrift${ELDrift}.next.h5 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

# Count the events in the file and write to an output file
file="NEW_${MODE}_ACTIVE_penthesilea_jobid_${SLURM_ARRAY_TASK_ID}_merged_ELDrift${ELDrift}.next.h5"
echo "$(ptdump -d $file:/Run/events | sed 1,2d | wc -l | xargs)" > NumEvents.txt
echo "Total events generated: $(ptdump -d $file:/Run/events | sed 1,2d | wc -l | xargs)" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

# Cleaning up
rm -v NEW_Tl208_ACTIVE.next.h5 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
rm -v *detsim.next.h5* 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
rm -v *diomira.next.h5* 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
rm -v *irene.next.h5* 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
rm -v GammaEnergy.root 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
rm -v NEWDefaultVisibility.mac 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

# Remove the config files if not the first jobid
if [ ${SLURM_ARRAY_TASK_ID} -ne 1 ]; then
	rm -v *.conf 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	rm -v *.mac 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	rm -rv temp_penthesilea 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	rm -rv temp_esmeralda 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
fi

echo "FINISHED....EXITING" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
end=`date +%s`
runtime=$((end-start))
echo "$runtime s" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt