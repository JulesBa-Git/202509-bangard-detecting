#!/bin/bash

# WARNING : This file generate Rscripts that produce the genetic algorithm results 
# showed in the paper. The instructions to run this file are in the `README.md` file
# please refer to this file for further informations.

input_parameters="$1"
separator="$2"

# Check if the separator is provided; if not, default to a comma
if [ -z "$separator" ]; then
  separator=','
fi

# Split the string into an array using the specified separator
IFS="$separator" read -r -a parameter_values <<< "$input_parameters"

for value in "${parameter_values[@]}"; do
  dir_name="${value}_epochs"

  mkdir "$dir_name"

  file_name="${dir_name}/script_${dir_name}" 

  touch "${file_name}.R"

  cat > "$file_name.R" <<- EOM
library(emcAdr)
load("../datasets/simulated_dataset_2_3_med.RData")
set.seed(Sys.time())

# nb_individuals_set <- c(10,50,100,200,400,700,1000), This was the actual used line but
# empirical results show that smaller number have a small contribution to the 
# final results. We reduce the number of created files.

nb_individuals_set <- c(100,200,400,700,1000)

for(nb_individual in nb_individuals_set){
  hyperparam_test_genetic_algorithm($value, nb_individual, ATC_Tree_UpperBound_2014,simulPatient_2_3medic_realistic, 5,c(0.20) ,c(0),c(1.5), "./",24)
}
EOM

  touch "${file_name}.sh"

  cat > "${file_name}.sh" <<- EOM
#!/bin/bash
#SBATCH --job-name=genetique_${value}_epochs
#SBATCH --mail-user=jules.bangard@math.unistra.fr
#SBATCH --mail-type=END,FAIL,BEGIN
#SBATCH --cpus-per-task=25


Rscript ./$dir_name/script_$dir_name.R
EOM

done
