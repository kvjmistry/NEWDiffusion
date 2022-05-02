#!/bin/bash
#SBATCH -J Esmeralda # A single job name for the array
#SBATCH -c 8 # Number of cores
#SBATCH -p shared # Partition
#SBATCH --mem 4000 # Memory request (6Gb)
#SBATCH -t 0-6:00 # Maximum execution time (D-HH:MM)
#SBATCH -o Esmeralda_%A_%a.out # Standard output
#SBATCH -e Esmeralda_%A_%a.err # Standard error

echo "Initialising environment" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
start=`date +%s`

# Set the configurable variables
KrMap=""
MODE="match"
JOBNAME="Esmeralda"
FILES_PER_JOB=10
PROCESS=$((${SLURM_ARRAY_TASK_ID} - 1))

# Create the directory
cd $SCRATCH/guenette_lab/Users/$USER/
mkdir -p $JOBNAME/$MODE/jobid_"${SLURM_ARRAY_TASK_ID}"
cd $JOBNAME/$MODE/jobid_"${SLURM_ARRAY_TASK_ID}"

# Copy the files over
cp ~/packages/NEWDiffusion/config/esmeralda.conf .
cp ~/packages/NEWDiffusion/config/filelist.txt .

# Edit the file configs
sed -i "s#.*map_fname.*#  map_fname              = '/n/home05/$USER/packages/NEWDiffusion/database/${KrMap}',#" esmeralda.conf

# Setup IC
source ~/packages/IC/setup_IC.sh

echo
echo "======== Split the FILELIST ========"

# Now get cut the file list up into the relavent chunk
LINE1=$((${PROCESS}*${FILES_PER_JOB} + 1))
LINE2=$((${PROCESS}*${FILES_PER_JOB} + ${FILES_PER_JOB}))

echo
echo "LINE1: ${LINE1}, LINE2: ${LINE2}" | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

# Create the subfiles list
sed -n "${LINE1},${LINE2}p" < filelist.txt | tee subfiles.list

echo
echo "======== Now copying over the files: ========"
# Now copy the files over to the local directory
for f in $(cat subfiles.list)
do
	echo $f
	cp -v $f . | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
done;

echo
echo "======== DOING AN LS  ========"
ls -ltrh

i=0
for f in $(cat subfiles.list); do

	echo "RUNNING OVER FILE: $(basename ${f})" | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	echo "INDEX IS: $i" | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

	# Replace the filename	
	sed -i "s#.*files_in.*#files_in = \"$(basename ${f})\"#" esmeralda.conf
	sed -i "s#.*file_out.*#file_out = \"hdst_3689_7746_trigger2_v1.2.0_20191122_bg_${MODE}_esmeralda_jobid_${SLURM_ARRAY_TASK_ID}_${i}.h5\"#" esmeralda.conf
	
	# IC
	echo "Running IC Esmeralda"     2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city esmeralda esmeralda.conf 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

	i=$(($i+1))
	rm ./$(basename ${f}) | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

	echo; echo; echo;
done

# Merge the files into one
mkdir temp_esmeralda 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
mv *esmeralda*.h5 temp_esmeralda 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
python ~/packages/NEWDiffusion/tools/merge_h5.py -i temp_esmeralda -o hdst_3689_7746_trigger2_v1.2.0_20191122_bg_${MODE}_esmeralda_merged_jobid_${SLURM_ARRAY_TASK_ID}.h5 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

# Count the events in the file and write to an output file
file=$(ls | grep merged)
echo "$(ptdump -d $file:/Run/events | sed 1,2d | wc -l | xargs)" > NumEvents.txt
echo "Total events generated: $(ptdump -d $file:/Run/events | sed 1,2d | wc -l | xargs)" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

# Cleaning up

# Remove the config files if not the first jobid
if [ ${SLURM_ARRAY_TASK_ID} -ne 1 ]; then
	rm -v *.conf 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	rm -v *.mac 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	rm -rv temp_esmeralda 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
fi

echo "FINISHED....EXITING" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
end=`date +%s`
runtime=$((end-start))
echo "$runtime s" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt