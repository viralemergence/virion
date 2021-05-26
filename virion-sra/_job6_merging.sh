#! /bin/bash
#SBATCH --account=def-tpoisot
#SBATCH --job-name=virion-6-merging
#SBATCH --output=%x.out
#SBATCH --time=5:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=186G

module load StdEnv/2020 julia/1.5.2

julia --project 06_process_data.jl
