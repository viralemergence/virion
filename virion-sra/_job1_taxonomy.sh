#! /bin/bash
#SBATCH --account=def-tpoisot
#SBATCH --job-name=virion-1-taxonomy
#SBATCH --output=%x.out
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=80G

module load StdEnv/2020 julia/1.5.2

julia --project 01_read_taxonomy.jl

