#!/bin/bash
# run_codex.sh -- run codex read-only (no network) to review one experiment.
#
# Usage: run_codex.sh <experiment>
# Reviews experiments/<experiment> in the main checkout with a fixed brief that names only the experiment.
# Model and reasoning effort are pinned below, not taken from ~/.codex/config.toml.
# Writes codex's final message to artifacts/<experiment>/codex_review/<YYYYMMDDTHHMMSS>.md
# and the full log to the same path plus .log. Exit code is codex's; if codex succeeds but the
# output's first line is not exactly "Verdict: pass" or "Verdict: fail", exits 3.
set -u
main=/path/to/repo
model=gpt-6.1-sol
effort=xhigh
exp=${1:?usage: run_codex.sh <experiment>}
[ -d "$main/experiments/$exp" ] || { echo "experiment missing: $main/experiments/$exp" >&2; exit 2; }
command -v codex >/dev/null || { echo "codex not found on PATH" >&2; exit 2; }
codex login status >/dev/null 2>&1 || { echo "codex has no logged-in account; run codex login" >&2; exit 2; }
outdir=$main/artifacts/$exp/codex_review
mkdir -p "$outdir"
out=$outdir/$(date +%Y%m%dT%H%M%S).md
brief="Review experiments/$exp, currently \`preliminary\`, read-only as AGENTS.md requires. You cannot modify files: output the full review section to be appended to the end of that experiment's README, with \"Verdict: pass\" or \"Verdict: fail\" as its first line."
echo "out=$out"
printf '%s\n' "$brief" | codex exec -C "$main" -o "$out" -s read-only -m "$model" -c model_reasoning_effort="$effort" > "$out.log" 2>&1
code=$?
echo "codex-exit=$code"
[ "$code" -eq 0 ] || exit $code
first=$(head -n 1 "$out")
[ "$first" = "Verdict: pass" ] || [ "$first" = "Verdict: fail" ] || { echo "first line of $out is not \"Verdict: pass\" or \"Verdict: fail\": $first" >&2; exit 3; }
echo "verdict=${first#Verdict: }"
