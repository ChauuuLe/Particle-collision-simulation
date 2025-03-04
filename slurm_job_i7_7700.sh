#!/bin/bash

## This is an example Slurm template job script for A1 that just runs the script and arguments you pass in via `srun`.

#SBATCH --job-name=test
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=4gb
#SBATCH --partition=i7-7700
#SBATCH --time=00:30:00
#SBATCH --output=%x_%j.slurmlog
#SBATCH --error=%x_%j.slurmlog

echo "We are running on $(hostname)"
echo "Job started at $(date)"

# Define test cases
declare -a tests=("tests/large/100k_density_0.7_fixed.in"
                  "tests/large/100k_density_0.8_fixed.in"
                  "tests/large/100k_density_0.9_fixed.in"
                  "tests/standard/10k_density_0.7.in"
                  "tests/standard/10k_density_0.9.in")

# Define thread counts
declare -a threads=(8 9 10 11 16 17 20 21)

make

# Run perf stat for each test case with each thread count
for test in "${tests[@]}"; do
    for t in "${threads[@]}"; do
        echo "Running perf stat on $test with $t threads"
        srun --partition=i7-7700 perf stat -r 5 -e task-clock,cycles,instructions,cache-misses,cache-references -- ./sim.perf "$test" "$t"
    done
done

echo "Job ended at $(date)"
