#!/bin/bash
# Sums the number events stored in the count event files
# The files input must be a file with a single number corresponding to the
# number of events that were simulated

# USAGE: source count_events.sh <file wildcard>

sum=0
for i in $*; do sum=$(($sum + $(cat $i))); done
echo $sum
