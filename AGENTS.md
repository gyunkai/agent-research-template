# Working instructions

Read `README.md` and `docs/agent_memory/MEMORY.md` in the main checkout (`/path/to/repo`) before substantive work. The README's hypotheses and candidate methods are revisable, not findings or a roadmap.

## Research practice

- Each experiment is a directory under `experiments/` with a `README.md`: specification first (question, data/split, inputs, readout, comparisons, success criterion), results last (same fields plus uncertainty; observations separate from interpretations). Status is `proposed`, `running`, `preliminary`, `reviewed`, or `abandoned`. The root `README.md` lists experiments by name, status, and link only.
- An experiment stays `proposed` until the user approves the specification; no code before that. Before running a variant on a benchmark, reproduce one published number (or match the official metric on released predictions) to validate loader and metric.
- Results stay `preliminary` until the other agent (Claude reviews Codex, Codex reviews Claude) has checked split, label alignment, and metric read-only and recorded the outcome in the experiment README.
- Claude starts Codex's review of its own results with the repository's `codex` skill and records Codex's output verbatim in the experiment README. The status follows Codex's verdict line alone. Claude stops and asks the user when it disagrees with a finding, when a finding needs a specification change or a new run, after three rounds without a pass, or when Codex fails.
- The direction sections of the root `README.md` change only with the user's agreement. Agents propose by creating a `proposed` directory holding a specification only.
- A prior result argues against a new proposal only if it tested the same hypothesis under the same conditions; state that, then the user decides.
- GPU work is never a design constraint. Extracting new features, rebuilding a cache, or running a new condition is an ordinary batch job the user submits. Design the experiment that answers the question, then write the Slurm script; do not pick a weaker design to stay on existing caches or CPU, and do not present GPU cost as a reason for a design choice.

## Implementation

- Benchmark loading, splits, and official metrics live once in `src/`; an experiment directory holds only its own code. No editable install: run `python -m experiments.<name>.<script>` from the worktree root, and `cd` to the worktree in Slurm scripts, so the imported `src/` is the worktree's.

## Collaboration

Several agents work here at once. The main checkout is never edited directly; every file-changing task runs in its own worktree and branch, named after the task:

```bash
MAIN=/path/to/repo
git -C $MAIN worktree add $MAIN-<task> -b <task> main   # next to the repository, never inside it
git commit -- <paths>                                     # inside the worktree, per finished unit
git rebase main                                           # when done, then the smallest check that the code runs
git -C $MAIN merge --ff-only <task>                       # if it aborts over uncommitted changes in main, stop and ask
git -C $MAIN worktree remove $MAIN-<task>
git -C $MAIN branch -d <task>
```

- Commit by path only, never `-a` or `add -A`; put `Agent: Claude` or `Agent: Codex` in the body. Agents do not push.
- Resolve mechanical conflicts yourself; stop and ask when two branches implement different designs of the same thing.
- Do not rebase or remove a worktree while a Slurm job launched from it is running. Job outputs go to `/path/to/repo/artifacts/` by absolute path; result summaries are committed in the experiment directory.
- Every run writes its commit SHA, command, config, seed, environment name, Slurm job ID, and whether the tree was clean to its output directory. A result entering an experiment README cites the tag `run/<experiment>/<n>` on the SHA it ran from.

## Memory

`docs/agent_memory/` holds one file per operational fact (cluster, tools, environments, data, links, the user's working rules), indexed one line each in `MEMORY.md`, under 30 lines. Never results, conclusions, or direction. Each file has frontmatter `name`, `description`, `metadata.type` (`feedback` or `reference`); an index line is `- [Title](file.md) — hook (YYYY-MM-DD)`. Memory edits and status-line changes are the only commits made directly on `main`: by path, subject prefix `memory:`, agent in the body.
