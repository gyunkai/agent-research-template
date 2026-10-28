---
name: slurm-rules
description: MUST be used before writing or editing any Slurm batch script (*.slurm / sbatch --wrap), and when sizing a job (time/mem/cpu/GPU), choosing an account, or diagnosing a job that was CANCELLED, timed out, or OOM-killed. Resource defaults by workload class, account selection for the shortest queue, and GPU-utilization rules.
---

# Slurm script rules

## Hard rules
- The user submits jobs themselves. Never run `sbatch` unless explicitly asked; deliver the script.
- No model inference on CPU nodes/partitions, even tiny models.
- Every script must work from a fresh shell: activate the environment explicitly (e.g. `source <conda-root>/etc/profile.d/conda.sh && conda activate <env>`).
- `--time` = expected elapsed × 1.5–2. Never tight-fit.
- Set `#SBATCH --account=` explicitly; pick it with "Choosing the account" below.
- GPU jobs must keep the GPU fed. Many clusters cancel GPU jobs with low utilization, sometimes with no message in the log (e.g. `CANCELLED by 0`). Follow the policy recorded under "Cluster facts"; if none is recorded, keep average utilization above 60%.
  - Decode-bound pipelines: request ≥16 CPUs and enough dataloader workers; decode only what the encoder consumes. Real case: an embedding job with 8 CPUs was cancelled for low utilization at 2h22; the same job with 16 CPUs completed in 53 min.
  - Decode-bound array jobs: keep each task ≤1.5 h, or split one long input across workers.

## Script template
Start every script from `assets/sample.slurm`: fill the `<...>` placeholders, keep the header order and the one-line sizing comment.

## Resource defaults by workload class
Before sizing any job, read `references/calibration.md` (measured elapsed / mem / cpus per workload class) and start from the closest row.

## New workload types
- No matching row → give an estimate, state the sizing assumption in one line when handing over the script; the user confirms before submitting. Do not probe the cluster to size resources.
- Backfill `references/calibration.md` only when a completed run changes sizing: a new workload class, measured elapsed or memory more than 2× off the matching row, or a TIMEOUT / OOM / utilization cancel. Skip debug runs, bug failures, and runs that fit an existing row. Same row format, no job IDs. Source: `sacct -j <jobid> --format=JobName,Partition,AllocTRES,Elapsed,Timelimit,MaxRSS,State`.

## Choosing the account
Check when writing the script:
- Accounts: `sacctmgr show assoc user=$USER format=Account,Partition,QOS`. FairShare: `sshare -U -u $USER -o Account%32,FairShare`.
- Use only accounts that reach the partition or GPU type the job needs (see "Cluster facts"); among them, pick the highest FairShare.
- When the job can run on several GPU types, request them together (`--constraint`, as in the template) so it starts on whichever type frees first, and pick the highest FairShare among the accounts that reach them.

## Cluster facts
Fill in once per cluster.
- Accounts and the partitions / GPU types each reaches: `<...>`
- Accounts never to use for GPU jobs: `<...>`
- GPU utilization policy (threshold, window, action): `<...>`
- Compute nodes have internet access: `<yes / no>`

## Per-project overrides
If the current project defines its own resource table (project CLAUDE.md / AGENTS.md or docs), that table wins over this one.
