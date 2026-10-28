---
name: codex
description: Start Codex's read-only review of an experiment's results, as AGENTS.md requires for Claude's results. Needs the codex CLI and a logged-in account.
---

# codex

Codex reviews read-only; Claude Code records the review, commits and merges.

Requires the codex CLI on `PATH` and a logged-in account (`codex login`); the
script stops with a message otherwise.

## Use

    /path/to/repo/.claude/skills/codex/run_codex.sh <experiment>

Run it in the background (it can take 5-60 min). It reviews
`experiments/<experiment>` in the main checkout with a fixed brief, written in
the script, that names only the experiment; do not add anything to it. A
re-review runs the same command.

Codex's final message goes to
`artifacts/<experiment>/codex_review/<YYYYMMDDTHHMMSS>.md` (printed as `out=`),
the full log to the same path plus `.log`. The sandbox is read-only with no
network. The model and reasoning effort are pinned at the top of the script;
`~/.codex/config.toml` does not change them.

## After the run

The script exits 3 when the output's first line is not exactly
`Verdict: pass` or `Verdict: fail`. On any nonzero exit, append nothing and
stop and ask the user; do not rerun.

- Append the output file verbatim to the end of the experiment README and
  commit it alone, the commit body naming the output file.
- "Verdict: pass": set the status to `reviewed`.
- "Verdict: fail": revise in a separate commit, then run the script again.
- Stop and ask the user in the cases AGENTS.md lists.
