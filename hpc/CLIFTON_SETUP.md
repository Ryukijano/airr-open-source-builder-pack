# Clifton on your Linux machine (Isambard-AI Phase 2, project u6xn)

Run these on your own computer, not on the Devin VM. Source: https://docs.isambard.ac.uk/user-documentation/guides/login/ (checked 2026-10-07).

## 0. Before you start

- Set your UNIX short name on the Isambard portal (https://account.isambard.ac.uk). Without it, `clifton auth` fails with "User short name is empty".
- Have an Ed25519 key, or an RSA key of 3072 bits or more. If you don't have one:

```bash
ls ~/.ssh/id_ed25519 || ssh-keygen -t ed25519 -C "gyanateet@googlemail.com"
```

## 1. Install

`uname -m` prints `x86_64` or `aarch64`, which match the release file names.

```bash
mkdir -p ~/.local/bin
curl --location "https://github.com/isambard-sc/clifton/releases/latest/download/clifton-linux-musl-$(uname -m)" \
     --output ~/.local/bin/clifton
chmod u+x ~/.local/bin/clifton
if ! command -v clifton >/dev/null; then echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc; export PATH="$HOME/.local/bin:$PATH"; fi
clifton --version            # 0.3.0 at the time of writing
```

## 2. Authenticate (every 12 hours)

```bash
clifton auth                 # opens your browser; or add --identity ~/.ssh/<key> for a non-standard key path
```

You should see "Successfully authenticated as ... downloaded SSH certificate for projects: - u6xn". The certificate is written next to your key, e.g. `~/.ssh/id_ed25519-cert.pub`, and is valid for 12 hours.

## 3. Write the SSH config (first time, and after you join a new project)

```bash
clifton ssh-config write     # writes ~/.ssh/config_clifton and includes it from ~/.ssh/config
```

Don't edit `~/.ssh/config_clifton` by hand; put any extra settings in `~/.ssh/config`.

## 4. Connect and check

```bash
ssh u6xn.aip2.isambard hostname
```

On first connection, accept only if the Isambard-AI Phase 2 host key is one of:

| Type | Fingerprint |
|---|---|
| ED25519 | SHA256:jLwRcG3g1kDJwTHBqc3JdgZA99UQ5baO6ALIaNMZTyA |
| ECDSA | SHA256:asi1gSKS17jZs0WaX3P6FhMCzEjRH52EidZTQ/Qh9+g |
| RSA | SHA256:rPLDdQhhWXbIp5ezSTK07isq78QKK8eb9Q5gfwFeRXY |

If you get a host-key prompt for a different host, check it against the "Host fingerprints" table on the login guide page.

## If something fails

- "Could not get certificate" or "Claim projects not present": sign out at https://account.isambard.ac.uk (menu, top right), then rerun `clifton auth`.
- `clifton: command not found`: `~/.local/bin` is not on your PATH (see step 1).
- Status and known issues: https://status.isambard.ac.uk. Helpdesk: https://support.isambard.ac.uk.

## Rules on the login node

- Login nodes have no GPUs. Each session is limited to 1 CPU core, 4 GiB of memory and 500 tasks.
- Don't leave tmux, screen, agents or long-running processes on the login node. Bash also closes the session after 24 hours with no input.
- Don't run AI agents on Isambard, and don't give an agent your key, certificate or a persistent connection.

## Next: OpenChange-UK smoke test

Once `ssh u6xn.aip2.isambard hostname` works, follow docs/WORKFLOW.md in https://github.com/Ryukijano/openchange-uk/pull/1. It covers: pull the NGC PyTorch 25.05 image to `$PROJECTDIR/sif-images` on the login node, run `make check-sbatch`, then `sbatch slurm/00_smoke.sbatch` (1 node, 1 GPU, 10 minutes). Paste me the log and I'll go through it.
