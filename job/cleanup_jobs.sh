#!/bin/bash

# Declare an array of string with type
declare -a StringArray=("0.1" "0.2" "0.3" "0.4" "0.5")

# Iterate the string array using for loop
for diff in ${StringArray[@]}; do
    rm -rv Diffusion_${diff}
    rm -rv $SCRATCH/guenette_lab/Users/$USER/NEW_MC208/$diff
done