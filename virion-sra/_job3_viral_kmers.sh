#! /bin/bash
#SBATCH --account=def-tpoisot
#SBATCH --job-name=virion-3-viral-normalizing
#SBATCH --output=%x.out
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G

module load StdEnv/2020 julia/1.5.2

julia --project 03_merge_viral_kmers.jl

