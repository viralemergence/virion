#! /bin/bash
#SBATCH --account=def-tpoisot
#SBATCH --job-name=virion-6-sparse
#SBATCH --output=%x.out
#SBATCH --time=5:00:00
#SBATCH --cpus-per-task=40
#SBATCH --mem-per-cpu=2300M

module load StdEnv/2020 julia/1.5.2

julia --project -t 38 06_sparse_matmult.jl

