"""Provenance record required by AGENTS.md for every run output directory."""

import json
import os
from pathlib import Path
import platform
import shlex
import subprocess
import sys


def write_run_info(out_dir, config, seed):
    repository = Path(__file__).resolve().parents[1]
    info = {
        "commit": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=repository, text=True).strip(),
        "tree_clean": not subprocess.check_output(["git", "status", "--porcelain"], cwd=repository, text=True).strip(),
        "worktree": str(repository),
        "command": shlex.join(sys.orig_argv),
        "config": config,
        "seed": seed,
        "environment": Path(sys.prefix).name,
        "python_version": platform.python_version(),
        "slurm_job_id": os.environ.get("SLURM_JOB_ID"),
        "slurm_array_task_id": os.environ.get("SLURM_ARRAY_TASK_ID"),
        "hostname": platform.node(),
    }
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "run_info.json").write_text(json.dumps(info, indent=2) + "\n")
    subprocess.run([sys.executable, "-m", "pip", "freeze"], check=True, text=True,
                   stdout=open(out_dir / "pip_freeze.txt", "w"))
    return info
