#!/bin/bash
# Job name:
#SBATCH --job-name=consumption_scar_solve_array
#
# Account:
#SBATCH --account=
#
# Partition:
#SBATCH --partition=
#
# Request one node:
#SBATCH --nodes=1
#
# Wall clock limit:
#SBATCH --time=3-00:00:00
#
#SBATCH --array=1-101
#
## Command(s) to run :
module purge
module load julia/1.0.0

julia -p $SLURM_CPUS_ON_NODE solve.jl
