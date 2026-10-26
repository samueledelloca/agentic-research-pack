# Architecture, scaffold, and ledgers

Domain-independent. Any specific names (biology, cytokines, HLA) are examples of one instantiation;
replace them with the sub-areas and tools your topic needs. The roles, the layering, and the
verification are the fixed part.

## The six primitives and how they map to the layers

The pasted "AI architecture" list is the set of functional primitives. Each is a role with a
swappable implementation, and each lives in one of the five layers:

| Primitive | Role | Lives in | Swap for |
|---|---|---|---|
| Source adapter (Paper2Agent) | turn source material into executable tools | Layer 2 | a local module of plain functions |
| Tool protocol (MCP) | how agents call those tools | Layer 2 | any function-call / tool interface |
| Scientific RAG | grounded retrieval over source + corpus | Layers 1-2 | embeddings + a vector index, or plain search |
| Coding / reasoning agent | builds the tools, drives the loop | cross-cutting | any capable coding agent |
| Statistical / quantitative-analysis agent | computes the findings | Layer 3 | the field's own analysis (model, metric, proof) |
| Adversarial reviewer agent | attacks every finding | Layer 4 | a critic subagent with the same brief |

Keep the roles; change the implementations. Nothing here is tied to a particular vendor or dataset.

## The five-layer agentic ecosystem

A research system is not one chat. It is layers, each with a job and a restricted toolset.

- **Layer 1 — Knowledge base.** The source material: the primary paper(s), supplementary
  information, raw and derived datasets, plus external corpora (literature index, domain databases).
  This is read-only ground truth.

- **Layer 2 — Tool server (Paper2Agent pattern).** A small server that exposes Layer 1 as validated,
  callable tools, so the material becomes *executable*, not just readable. A reusable core toolset:
  `list_datasets`, `describe_dataset`, `query_dataset`, `run_analysis`, `reproduce_claim`,
  `compare_groups`, `list_analyses`, plus domain queries (e.g. a lookup, a scorer, a search). Every
  tool returns real computed values. Agents may only act through these tools.

- **Layer 3 — Specialist agents (the layer you re-bind).** Narrow, topic-scoped interpreters. Each
  owns a slice of the problem and a subset of the tools, and interprets results within its slice
  (state effect sizes and sample sizes, label the evidence type, never overclaim). **Selection
  principle (domain-free):** decompose your topic into its natural sub-areas and give each one narrow
  agent plus a restricted toolset, including one agent for external literature and one for
  robustness/safety. The number and names are whatever your topic needs. Examples across domains:

  | Domain | Example Layer-3 roster |
  |---|---|
  | Biology (the source project) | literature, immunology, ALS, HLA, T-cell, drug-discovery, structural, single-cell, clinical, safety |
  | Human-computer interaction / behaviour | literature, measurement/psychometrics, study-design, statistics/modelling, qualitative-coding, ethics/validity, robustness |
  | ML / systems | literature, data-quality, baselines, evaluation-metrics, efficiency/cost, security, reproducibility |
  | Policy / social science | literature, data-sources, identification/causal-design, statistics, external-validity, stakeholder/ethics |

- **Layer 4 — Discovery agents (the engine).** Domain-independent; keep these names:
  - **Hypothesis generator** — proposes testable questions from the data.
  - **Hypothesis critic** — adversarially critiques each hypothesis and answer.
  - **Evidence checker** — independently recomputes and verifies each finding.
  - **Replication agent** — re-runs robustness checks (leave-one-out, FDR, alternative models).
  - **Contradiction agent** — classifies each finding vs the source (confirm / extend / contradict / caveat).
  - **Experiment designer** — designs the most efficient falsification experiment.
  - **Falsification agent** — states what observation would falsify each claim.

- **Layer 5 — Principal Investigator agent.** Integrates all outputs into the synthesis. Hard rule:
  **it cannot override contradictory evidence.** The PI selects findings that are verified, novel,
  and robust; it does not argue away a failed check.

## Optional adapters, and where they plug in

The architecture is self-contained. External tools attach at fixed points and each has a fallback, so
the system never hard-depends on them:

- **Layer 2 (source → tools):** Paper2Agent / an MCP server, else a local module of plain functions.
- **Layer 3 literature agent:** scite MCP (Smart Citations, full text), else WebSearch + WebFetch with
  a manual Crossref/DataCite metadata check.
- **Before the pipeline (ideation):** the `research-companion` skill produces the PURSUE brief; absent
  it, start from the user's framing and create a minimal evaluation record.
- **Stage 7 (drafting/review):** the `academic-writing-agents` plugin, else run its standards inside a
  general subagent.
- **Layer 3 domain analysis:** the field's own tool/model/database, else code the analysis directly.

If an adapter is present, use it; if not, use the fallback and say so. Compatibility is a bonus, never
a prerequisite.

## Six mandatory agent roles (coverage checklist)

Independent of the layering, the investigation must employ at least one of each. Use it as a
coverage check before you start:

1. a generative AI system (the coding/reasoning agent);
2. an autonomous or semi-autonomous agent (the discovery loop);
3. a scientific literature agent (scite MCP or equivalent);
4. a computational / domain-analysis agent (the tool server + analyses);
5. an independent verification agent (evidence checker + replication);
6. an adversarial / critical-review agent (hypothesis critic + falsification).

## Repository skeleton

A predictable layout so the artifact is navigable and interoperable:

```
project/
├── agents/        agent specifications (registry: name, layer, role, allowed tools, system prompt)
├── model/         the tool server (Paper2Agent / MCP) and any trained model
├── data/          raw-data fetchers + provenance manifests (raw files usually not committed)
├── datasets/      machine-readable tidy tables + a schema file
├── literature/    RAG index, source text, curated external references, citation audit
├── notebooks/     exploratory analysis
├── training/      training scripts (if any model is trained)
├── evaluation/    scientific + AI-system evaluation outputs
├── experiments/   per-run logs (prompt, tool calls, output) for every agent run
├── configs/       config files (seeds, backend, model id)
├── results/       analyses, figures, discovery outputs
├── reports/       the written report (LaTeX or similar) + figures/tables
├── README.md  requirements.txt  environment.yml  run.sh
```

A single `run.sh` with stages (`setup | fetch | datasets | analyses | figures | discovery | evaluate | test | all`)
makes the whole thing executable end to end.

## Documentation ledger (what every investigation must record)

For each major hypothesis, keep a row with: (1) the hypothesis; (2) evidence supporting it;
(3) evidence against it; (4) whether it was rejected; (5) whether it was tested
(computationally/experimentally); (6) the prompts / agent specs needed to reproduce it; (7) the
AI-generated code that produced it. Store these as structured files (e.g. `questions.json`,
`observations.json`, `contradictions.json`) so they are machine-checkable, not prose buried in a report.

Each graduated finding and each reproduced claim also lists the ids of the tool calls that produced
its numbers (see the tool-call ledger below).

## Tool-call ledger

A run log says what an agent did. The tool-call ledger says what the tools computed, for every
caller. Write it from the registry's dispatch function (`call(tool, **args)`), never from one caller,
as one JSON line per call in `experiments/tool_calls/<run_id>.jsonl`:

| Field | Content |
|---|---|
| `call_id` | unique id, cited by findings and reproduced claims |
| `run_id`, `caller` | the run, and which path made the call (in-session, MCP, API loop, pipeline) |
| `tool`, `args` | tool name and arguments as canonical JSON (sorted keys) |
| `data_version` | checksums of the dataset files the tool read (reuse the provenance manifests) |
| `code_version` | git commit, flagged dirty if the tree has uncommitted changes |
| `seed` | when the tool samples, bootstraps or permutes |
| `replay` | the tool's replay class (`exact`, `seeded`, `tolerance`; see below) |
| `output_sha256` | hash of the canonical JSON output |
| `ts`, `duration_s` | timestamp and latency |

Canonicalise before hashing (sorted keys, floats rounded to a fixed precision, rows in a stable
order), or harmless formatting noise breaks the hash. Keep the full output only when it is small;
the hash plus a replay is enough to prove the rest.

The ledger buys three things. **Replay**, because a reviewer can re-run the exact call behind a
reported p value and compare hashes. **Disagreement tracing**, because when two agent runs or the
specialist and the evidence-checker disagree, a diff of their ledgers shows whether they called
different tools, passed different arguments, or read different data versions. **Grounding audits**,
because each reported number can be matched to the call that computed it, which is how the grounding
metric in `evaluation.md` gets computed. A hash mismatch on replay is a finding, never noise to be
silenced; it means the data, the code or the seed changed.

**Tools that cannot replay exactly.** Hash equality only holds for deterministic tools. Declare each
tool's replay class in the registry (`replay: exact | seeded | tolerance`) and log it in every record.

- *Exact.* Pure computations over versioned data. Replay must match the hash.
- *Seeded.* Sampling, bootstrap, permutation, or model fitting with a controllable seed. Record the
  seed and the library versions; replay with the same seed must match the hash. Where hardware still
  adds noise (multithreaded BLAS, GPU kernels), pin the thread count or move the tool to the next class.
- *Tolerance.* Anything irreducibly variable, such as a live model call, an external API or a web
  search, or data that changes over time. Store the full output (not just the hash), plus the model
  id, its parameters and, where possible, a snapshot of the external response. Declare up front what
  must agree on replay and how closely: a numeric tolerance on the reported quantity, the same label
  or decision, or a distribution check over k reruns with the spread reported. Fix the tolerance before
  replaying, never after seeing the result.

Keep stochasticity out of the computation tools where you can. Agents reason and tools compute, so a
live model belongs in the agent layer, while the tools it calls stay exact or seeded. Then every
reported number still replays exactly even when the reasoning that chose it does not.

## Reproducibility checklist

Fix random seeds. Version datasets (source id + per-file checksum). Record model versions, prompts,
and agent configurations. Log every experiment. Log every tool call at the registry with its data
version and output hash. Save intermediate results. Pin software dependencies.
Provide executable workflows. Provide independent verification. Inspect and test AI-generated code
rather than accepting it blind.

## The research arc

The point is not "an LLM can summarise a field". It is that a multi-agent system can move:

**observation → mechanism → hypothesis → computational test → candidate → falsification experiment.**

The recurring question the system should always be able to answer about its own next step: *what do
we test next, why, in which population/setting, against which target, and what experiment would most
efficiently falsify the current hypothesis?*
