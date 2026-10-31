# Isambard-AI notes

## Access

- Log in with `clifton auth`, then `ssh <project>.aip2.isambard`. See `CLIFTON_SETUP.md`.
- Certificates expire after 12 hours. Rerun `clifton auth` and approve the device code.

## Storage layout (project u6xn)

```
/projects/u6xn/
  sif-images/pytorch_26.09-py3.sif   # shared container image
  lewm/                              # world-model work
    src/{le-wm,stable-worldmodel,Ctrl-World}
    venv/  venvs/ctrl-world/
    data/{droid_train.h5,droid_holdout.h5,shards/,split.json}
    ckpt/{Ctrl-World,svd,clip}/
    cf/{src,slurm,logs,runs,results}/  # counterfactual experiments
    slurm/  logs/
  rankability/                       # RoboJEPA benchmark code and results
```

Keep one directory per project with `src/`, `data/`, `ckpt/`, `runs/`,
`results/`, `logs/` and `slurm/`, and send Slurm logs to `logs/%x-%j.out`.

## Jobs

- The nodes are Arm64 (`aarch64`) GH200s. Run everything inside the NGC
  PyTorch Apptainer image with `--nv`; there are no system PyTorch modules.
- Start from `templates/single_gpu.sbatch`. One GPU = one GH200; a full node is 4.
- Hydra configs: use `++key=value` for keys that already exist.

## Known problems and fixes

| Problem | Fix |
|---|---|
| `decord` / `eva-decord` have no aarch64 wheels | A small `decord.py` shim backed by PyAV (`pip install av`) |
| `diffusers==0.34.0`: `NameError: logger` in `quantizers/torchao/torchao_quantizer.py` | Move `logger = logging.get_logger(__name__)` above the `_update_torch_safe_globals()` call, or use another diffusers version |
| `/local/$USER` is not writable | Read HDF5 straight from `/projects` |
| Host-RAM OOM kill with 24 dataloader workers | 8–12 workers per GPU |
| LeWM predictor uses BatchNorm | Score all candidate actions in one batched call, not one call each |
