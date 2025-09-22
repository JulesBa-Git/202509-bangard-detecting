library(emcAdr)
load("../datasets/simulated_dataset_2_3_med.RData")

file_list <- list.files(path=".", pattern="*.txt", full.names=TRUE, recursive=FALSE)

repetitions <- 5

# Output a file named `solutions.csv`
print_csv(file_list, simulPatient_2_3medic_realistic, repetitions, ATC_Tree_UpperBound_2014)