#!/bin/bash

# WARNING : This file generate Rscripts that produce the genetic algorithm results 
# showed in the paper. The instructions to run this file are in the `README.md` file
# please refer to this file for further informations.

# Path to the folder containing other folder
directory_path="./"

for dir in "$directory_path"/*; do
  if [ -d "$dir" ]; then # Checks if it is a folder
    dir_name=$(basename "$dir")
    
    # Construct the path of the script based on the folder name
    script_path="${dir}/script_${dir_name}.sh"
    
    # Checks if the script exists
    if [ -f "$script_path" ]; then
      echo "Script launching : $script_path"
      # Run the scripts using sbatch a command to tell Slurm to run the file on the 
      # computing cluster
      sbatch "$script_path"
    else
      echo "This script does not exists : $script_path"
    fi
  fi
done
