#!/bin/bash
# <What this job does, in one or two lines.>
# Sizing: <closest row in references/calibration.md, or the estimate and its assumption>
#   -> --time = expected elapsed x 1.5-2.
# Submit from the repository root; logs/ must already exist (Slurm does not create it).
# Array job: add --array=0-N, use %A_%a in place of %j, index with ${SLURM_ARRAY_TASK_ID}.
# GPU constraint: the GPU types the job can run on, e.g. "h100|h200|a100". CPU job: drop --gres and --constraint.

#SBATCH --job-name=<job-name>
#SBATCH --output=logs/slurm-%j.out
#SBATCH --error=logs/slurm-%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=<cpus>
#SBATCH --mem=<mem>
#SBATCH --time=<time>
#SBATCH --gres=gpu:1
#SBATCH --constraint="<gpu-types>"
#SBATCH --account=<account>
#SBATCH --mail-user=<email>
#SBATCH --mail-type=ALL

set -euo pipefail

cd "${SLURM_SUBMIT_DIR}"
source <conda-root>/etc/profile.d/conda.sh
conda activate <env>

python <path/to/script.py> <args>
