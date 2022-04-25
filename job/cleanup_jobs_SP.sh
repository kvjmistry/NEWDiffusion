#!/bin/bash

# Declare an array of string with type
declare -a StringArray=("gamma" "eminus")

# Iterate the string array using for loop
for MODE in ${StringArray[@]}; do
    rm -rv ELDrift_${MODE}
    rm -rv $SCRATCH/guenette_lab/Users/$USER/NEW_MC208/2.5/$MODE
done