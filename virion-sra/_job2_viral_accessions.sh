#! /bin/bash
#SBATCH --account=def-tpoisot
#SBATCH --job-name=virion-2-viral-accessions
#SBATCH --array=1-28
#SBATCH --output=%x-%A-%a.out
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=40
#SBATCH --mem-per-cpu=2300M

module load StdEnv/2020 julia/1.5.2

julia --project -t 38 02_parallel_viral_kmers.jl

