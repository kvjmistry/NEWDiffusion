#!/bin/bash

# Declare an array of string with type
declare -a StringArray=("1.25" "2.5" "3.75")

# Iterate the string array using for loop
for ELDrift in ${StringArray[@]}; do
    rm -rv ELDrift_${ELDrift}
    rm -rv $SCRATCH/guenette_lab/Users/$USER/NEW_MC208/$ELDrift/Tl208
done