# NEWDiffusion
A repository for config and job script files for the NEW study of Z without S1  

# Usage  
Run the following command in the `~/packages/` directory on the harvard machine  
`git clone https://github.com/kvjmistry/NEWDiffusion.git`  

The job config folder contains the nexus and IC configuration files. You should
not need to edit these files. Preferably use these as templates and edit them
directly from the jon submission script.  

To launch jobs, go into the job folder. You will see the following files:  

```
NEW_MC208_NN_job.sh
launch_jobs.sh
cleanup_jobs.sh
```

The `NEW_MC208_NN_job.sh` is the template bash script which executes a set of
commands on each of the computers on each job.  

The `launch_jobs.sh` uses `NEW_MC208_NN_job.sh` as a template, it creates a 
separate log directory and replaces the diffusion value we want to simulate in
the file using the array: `declare -a StringArray=("0.1" "0.2" "0.3" "0.4" "0.5")`.
You can configure this array depending on the diffusion values you want to run.

To launch the jobs, you can do `source launch_jobs.sh`. The default number of jobs
are set to run 10 jobs 1 - 10 in the `sbatch` command at the end. You can increse
the number 10 to 100 if say you want to run 100 jobs etc. Each job generates 2 x 50000
events in nexus. You can also increase/decrease the number of events in each job
in the `NEW_MC208_NN_job.sh` to as you need. Note that by the time the events
get to esmeralda the final job output is about 50 events. 

The `cleanup_jobs.sh` can be sourced to clean up the everything if you want to 
start a fresh. Make sure the array configured is the same one as in `launch_jobs.sh`.