#!/bin/bash
# Single-GH200 job template for Isambard-AI Phase 2.
# Copy it, set JOB/PROJECT_ROOT/CMD, then: sbatch single_gpu.sbatch
#SBATCH --job-name=CHANGE_ME
#SBATCH --nodes=1
#SBATCH --gpus=1
#SBATCH --cpus-per-task=16
#SBATCH --time=02:00:00
#SBATCH --output=%x-%j.out
set -euo pipefail

PROJ=${PROJ:-/projects/$SLURM_JOB_ACCOUNT}              # e.g. /projects/u6xn
SIF=${SIF:-$PROJ/sif-images/pytorch_26.09-py3.sif}      # NGC PyTorch, pulled once
VENV=${VENV:-$PROJ/venvs/default}                       # venv created inside the container

apptainer exec --nv --bind "$PROJ:$PROJ" "$SIF" bash -c "
  set -euo pipefail
  [ -d $VENV ] || python -m venv --system-site-packages $VENV
  source $VENV/bin/activate
  nvidia-smi --query-gpu=name,memory.total --format=csv
  python -c 'import torch, platform; print(platform.machine(), torch.__version__, torch.cuda.get_device_name(0))'
  # your command here, e.g.:
  # python train.py ++trainer.max_epochs=1
"
