#!/bin/bash
# Sums the number events stored in the count event files

sum=0
for i in $*; do sum=$(($sum + $(cat $i))); done
echo $sum
