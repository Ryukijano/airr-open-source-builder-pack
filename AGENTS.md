# AGENTS.md

Instructions for coding agents (Cursor, Devin, Codex) working in this repo.

- Clone with submodules: `git submodule update --init --recursive`. Each project in `projects/` has its own README and AGENTS rules. Read them before editing, and commit inside the submodule, not here.
- Shared HPC setup: `hpc/`. Isambard-AI is Arm64 GH200: run everything in the NGC PyTorch Apptainer image with `--nv`, one GPU per job, starting from `hpc/templates/single_gpu.sbatch`.
- Rebuilding the control box: `docs/CONTROL_MACHINE.md`.
- Private agent context (project state, memory, subagent history) is in the private `Ryukijano/lab-infra` repo under `docs/cursor-context/`. Read `PROJECT_STATE.md` there before any research work.
- Rules: report measured results only; no data, weights or secrets in git; push, deploy or change visibility only when the owner asks; never merge without approval; write in plain language.
