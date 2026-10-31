# AIRR Open-Source Builder Pack

One entry point for the open-source projects I build on the UK AI Research
Resource (AIRR), mostly Isambard-AI Phase 2 (Arm64 GH200). Each project keeps
its own repository, history and README. This repo links them as git
submodules, so one clone gets all of them, and it also holds the shared HPC
setup they all use.

```bash
git clone --recurse-submodules https://github.com/Ryukijano/airr-open-source-builder-pack
# already cloned without submodules:
git submodule update --init --recursive
# pull the latest commit of every project:
git submodule update --remote --merge
```

## Projects

| Path | Project | What it is | Status |
|---|---|---|---|
| [`projects/world-model-rankability`](https://github.com/Ryukijano/world-model-rankability) | World-model rankability | Can a world model rank the robot actions it is choosing between? RoboJEPA 22M–8B on RoboCasa and DROID, failure analysis, LeWM counterfactual training, Ctrl-World probe | Benchmark and live demo shipped; training work ongoing |
| [`projects/openchange-uk`](https://github.com/Ryukijano/openchange-uk) | OpenChange-UK | Strict geographic and temporal transfer benchmark for UK coastal environmental change, plus a clean-JEPA Sentinel-1/2 track | Gate-1 runs done; split not yet accepted |
| [`projects/agentic-sfm`](https://github.com/Ryukijano/agentic-sfm) | Agentic SfM | A small VLM trained with RL (GRPO) to call geometric tools for hard structure-from-motion | Mixed results, blockers named in its README |
| [`upstream/le-wm`](https://github.com/Ryukijano/le-wm) | LeWorldModel (fork) | JEPA world model trained from pixels; the base model for the counterfactual experiments | Upstream fork |
| [`skills/agent-skills`](https://github.com/Ryukijano/agent-skills) | Agent skills | Devin/Cursor skills and workflows reused across the projects, including the deslop-writing and deslop-design skills | Maintained |

## Hugging Face

- Benchmark Space (leaderboard): https://huggingface.co/spaces/Ryukijano/world-model-rankability
- Live ZeroGPU Space with all eight RoboJEPA sizes: `Ryukijano/world-model-rankability-live` (private for now)

## Shared HPC setup

- [`hpc/CLIFTON_SETUP.md`](hpc/CLIFTON_SETUP.md): install `clifton`, authenticate (certificates last 12 hours) and write the SSH config.
- [`hpc/ISAMBARD_NOTES.md`](hpc/ISAMBARD_NOTES.md): project storage layout, the container, single-GPU job rules and known problems.
- [`hpc/templates/single_gpu.sbatch`](hpc/templates/single_gpu.sbatch): the job template every project starts from (one GH200, Apptainer `--nv`).
- [`AGENTS.md`](AGENTS.md): rules for coding agents.
- [`docs/CONTROL_MACHINE.md`](docs/CONTROL_MACHINE.md): the CPU-only Linux box that drives everything over SSH, and how to rebuild it somewhere else.

## Rules every project follows

- One GPU per job unless a run has earned a full node.
- Each step has a cheap smoke test and a kill rule before more compute is spent.
- Data and weights stay on Isambard project storage or Hugging Face. No data, weights or secrets go in git.
- Results are reported as measured, negative results included.

## Adding a project

```bash
git submodule add https://github.com/Ryukijano/<repo>.git projects/<repo>
# add a row to the table above, then commit
```
