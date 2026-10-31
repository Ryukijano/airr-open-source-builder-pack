# This machine — full setup guide (so you can reproduce it elsewhere)

## What this box actually is

A **Devin session VM** (AWS): `devin-box`, Ubuntu 22.04.5 LTS, x86_64,
8 vCPU, 31 GB RAM, 124 GB disk, **no GPU**. GPU work happens on Isambard
over SSH — this box is the control node. A Devin VM is disposable; anything
you want to keep lives on GitHub / Hugging Face / Isambard project storage.

## Desktop

- KDE Plasma on X11 (`DISPLAY=:0`), viewable live via the webapp "Computer" tab (VNC).
- Chrome for Testing with CDP on `localhost:29229` for browser automation.
- Konsole is the terminal (`konsole`); there's also a `x-terminal-emulator` alias.
- Desktop shortcuts: `~/Desktop` (e.g. `~/Desktop/sepiq`).

## Toolchain (already installed)

| Tool | Path / version |
|---|---|
| python3 (system) | 3.10.12 |
| pyenv | `~/.pyenv` (init in .bashrc) |
| nvm + node | `~/.nvm` |
| uv | `~/.local/bin/uv` 0.12.23 |
| cargo/rust | `~/.cargo` |
| homebrew | `/home/linuxbrew/.linuxbrew` |
| docker | 29.7.2 |
| git, wmctrl, xdotool, ripgrep, expect | system |
| hf CLI | `~/.local/bin/hf` (authenticated via `HF_TOKEN` env) |
| grok CLI | `~/.local/bin/grok`, completions in `~/.grok` |
| devin CLI | `~/.local/bin/devin` |
| clifton | `~/.local/bin/clifton` + `~/clifton-bin` |

.bashrc also sources `/opt/.devin/package/user_bashrc` (sets `DISPLAY=:0`,
git author identity).

## Environment / secrets

Injected as env vars into each new shell — never written to files:
`HF_TOKEN`, `GITHUB_TOKEN_RYUKIJANO` (fine-grained, repo-scoped),
plus Devin org/session secrets referenceable as `secret:org:NAME` /
`secret:session:NAME`. To reproduce: export your own HF + GitHub tokens.

## Isambard access (the important part)

SSH via **clifton** — it mints short-lived SSH certificates instead of keys:

- `~/.ssh/config` → `Include ~/.ssh/config_clifton` (clifton-managed).
- `config_clifton` defines `jump.*` ProxyJump hosts for aip1 / aip2 /
  macs3 / isambard3 and `*.bc5.digital-labs`.
- Login host: `u6xn.aip2.isambard` → user `ryukijano.u6xn`, cert at
  `~/.cache/clifton/u6xn.aip2.isambard-cert.pub`.
- Base key: `~/.ssh/id_ed25519` (clifton signs it).
- **Cert expires every 12 hours** → rerun `clifton` and complete the device
  login URL it prints (keycloak.isambard.ac.uk device code).
- To reproduce elsewhere: `ssh-keygen -t ed25519`, install clifton,
  run it once to generate `config_clifton` + cert.

On Isambard (`/projects/u6xn/`):
- `lewm/` — LeWM workspace: `src/le-wm`, `src/stable-worldmodel`,
  `src/Ctrl-World`, `venv`, `venvs/ctrl-world`, `data/droid_train.h5`
  (~235 GB), `data/droid_holdout.h5`, `data/shards`, `ckpt/` (Ctrl-World,
  SVD, CLIP), `cf/` counterfactual experiment root, `slurm/`, `logs/`.
- `sif-images/pytorch_26.09-py3.sif` — the apptainer image all jobs run in.
- `rankability/` — probe + eval scripts.
- Run everything as `sbatch` single-GPU jobs (`--gpus=1`, workq);
  apptainer exec with `--nv --bind /projects/u6xn:/projects/u6xn`.
- Gotchas found: no `decord` for aarch64 (use the av shim in
  `slurm/run_ctrl_world_scale.sh`); diffusers 0.34.0 has a `logger`
  NameError (patched in `venvs/ctrl-world/.../torchao_quantizer.py`);
  `/local/$USER` not writable — read HDF5 from shared FS; 24 dataloader
  workers can OOM-kill host RAM.

## Repo layout (`~/repos`)

`AntiConjugate-Devin`, `agent-skills`, `agentic-sfm`, `anthropic-skills`,
`hf-skills`, `isambard-skills`, `le-wm`, `nvidia-skills`, `openchange-jepa`,
`openchange-uk`, `stable-worldmodel` (+ logs/patches in repo root).

Main project working dir: **`~/rankability/`** — `probe/`, `breakage/`,
`cf/` (src, slurm, logs, results, sweep, findings), `hf/`, `demo/` code for
the Spaces, `docs/BLOG*.md` lives in the GitHub repo
`Ryukijano/world-model-rankability`.

`~/memory/gyanateet_848779` — Devin's persistent memory checkout (git).
`~/sepiq`, `~/Desktop/sepiq` — SEPIQ challenge prediction CSVs.
`~/dino-swap`, `~/natcf`, `~/isaac-sim-job`, `~/papers` etc. are older
project dirs; `~/memory_old` is stale — don't use it.

## Devin-specific pieces (won't exist on a plain box)

- `/opt/.devin/package/` — VM bootstrap (desktop, chrome, vscode-server,
  user_bashrc). Skipping it just loses the agent tooling.
- MCP plugins loaded this session: DeepWiki, Gmail, Google Drive,
  Hugging Face, plus skill packs (isambard, nvidia, anthropic, hf,
  ryukijano custom). To reuse the custom skills elsewhere, they're just
  SKILL.md files — copy them into `.devin/skills/` or equivalent.
- Session URL: app.devin.ai/sessions/<id>; secrets via `secret:...` refs.

## Minimal reproduce-elsewhere recipe

1. Ubuntu 22.04+, install: `git ripgrep wmctrl xdotool expect uv docker`
   (+ `nvm`, `pyenv`, `brew` if wanted).
2. `ssh-keygen -t ed25519`; install clifton; run once for isambard cert.
3. `pipx/pip install huggingface_hub[cli]`; `hf auth login`.
4. Clone `Ryukijano/world-model-rankability` for code; data/weights stay on
   Isambard `/projects/u6xn` or HF.
5. For a GUI: KDE + `DISPLAY=:0` + konsole + Chrome with
   `--remote-debugging-port=29229`.
