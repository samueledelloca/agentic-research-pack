---
name: agentic-research-pipeline
description: >-
  Execute a rigorous, multi-agent research investigation on a topic: turn a paper, dataset,
  or body of work into an executable tool-backed system, then reproduce its claims, generate
  and verify new findings, audit the literature, evaluate the system, and write it up. TRIGGER
  when the user wants to build an "autonomous AI scientist" or Paper2Agent, reproduce-and-extend
  a study, run an agentic research pipeline or a "verified discovery loop", deploy specialist +
  discovery + verification agents on a research question, or asks to "use the research companion
  to actually run/execute an investigation" (as opposed to only brainstorming directions). This
  is the EXECUTION counterpart to the `research-companion` ideation skill: research-companion
  decides WHAT to pursue; this runs the investigation end to end with built-in verification.
  Distilled from the IAISS C9orf72-Nature2Agent project (an AI-scientist built from a Nature study).
allowed-tools: Agent, Read, Glob, Grep, Bash, Write, Edit, WebSearch, WebFetch
argument-hint: [paper / dataset / research question to investigate]
---

# Agentic Research Pipeline

A reusable, **domain-independent** method for running a research investigation with AI agents so the
output is **verifiable, reproducible, and honestly scoped**, instead of a confident essay. The
architecture and the discipline are the product; the domain is a parameter. It happens to have been
distilled from a biology project, so the examples below mention biology agents, but those are one
instantiation. In another context the specialist agents are different (behavioural, systems, legal,
financial, whatever the topic needs) while the roles, the layering, and the verification are
unchanged. The skill is **self-contained**: it needs nothing beyond the base agent tools, and it uses
named services (Paper2Agent, scite, `research-companion`) only as optional adapters it can do without.

Read `references/architecture.md` for the full agent roster, repository skeleton, documentation
ledger, and reproducibility checklist. Read `references/evaluation.md` for the two-axis evaluation
and the concrete trust metrics (grounding, determinism, false-hypothesis-rejection, citation audit).

## The one idea that makes it trustworthy

**Tools, not prose.** Every factual claim the system makes is the return value of a real
computation (a stat test, a query, a lookup), not text a model generated. A "grounding" check then
confirms that every number reported equals the number the tool actually computed. A model may decide
*which* tool to call and how to interpret the result, but it never invents the result. This is what
lets the author stand behind the *process* even when they cannot personally judge the domain content.

Everything below serves that idea: expose the material as tools, drive findings through the tools,
and have a *different* agent independently recompute and attack each finding.

## Core architecture (the reusable invariant)

Two views of one design. These do **not** change between domains; everything else is instantiation.
The full roster, the primitive-to-layer mapping, and cross-domain example rosters are in
`references/architecture.md`.

**(A) Six primitives** — the minimal functional pieces every instance is built from. Each is a role;
swap the implementation freely.
- a **source adapter** (Paper2Agent pattern): turns source material into executable, callable tools;
- a **tool protocol** (MCP, or any function-call interface): how agents invoke those tools;
- **retrieval** (RAG over the source plus any external corpus): grounded recall;
- a **coding / reasoning agent**: builds the tools and drives the loop;
- a **quantitative-analysis agent**: computes the findings (the statistics, model, or metric are
  domain-dependent, the role is not);
- an **adversarial reviewer agent**: attacks every finding.

**(B) Five layers** — how the primitives compose:
1. **Knowledge base** (the source material, read-only ground truth);
2. **Tool server** (exposes layer 1 as validated tools; the only way agents touch the data);
3. **Specialist agents** (the layer you re-bind per domain: decompose *your* topic into sub-areas,
   one narrow agent + a restricted toolset each);
4. **Discovery agents** (domain-free: hypothesis generator, critic, evidence-checker, replication,
   contradiction, experiment-designer, falsification);
5. **Principal Investigator** (integrates; cannot override contradictory evidence).

Layer 3 is where the domain enters. A biology study used immunology / HLA / clinical agents; a
human-computer-interaction study would use behavioural-statistics / measurement / study-design agents;
a systems study, performance / security / reliability agents. The selection principle is identical;
only the labels and toolsets change.

## Dependencies and adapters (self-contained, fully compatible)

The skill requires nothing beyond the base agent tools (subagents, file access, a shell, web search).
It names specific services only as **optional adapters**, each with a fallback, so it runs in any
context and gets better where more is available. Never hard-depend on an adapter; if one is absent,
degrade gracefully and say so, do not block.

| Role in the pipeline | Preferred adapter | Fallback when absent |
|---|---|---|
| Source → executable tools | Paper2Agent / an MCP tool server | a plain local module of functions the agents call |
| Literature audit | scite MCP (Smart Citations, full text) | WebSearch + WebFetch + manual Crossref/DataCite checks |
| Ideation + idea triage | the `research-companion` skill | start from the user's framing; create a minimal eval record |
| Drafting / writing review | the `academic-writing-agents` plugin | run the same standards inside a general subagent |
| Domain analysis / database | the field's own tool, model, or database | code the analysis directly in the tool server |

## When to use / when not to

- **Use it** when the task is: reproduce and extend a study; interrogate a dataset for new,
  defensible findings; build a queryable agent over a paper or corpus; or any investigation where
  the output must survive scrutiny and be reproduced by someone else.
- **Adapt it** for qualitative or theoretical work: the "tools" become coded transcripts,
  a model, or a literature matrix, and "reproduce the claims" becomes "re-derive the coding / the
  proof". The verification, adversarial-critique, and documentation layers still apply. This
  adaptation is not guesswork: **Stage 0 resolves the source type and data modality with the user and
  re-binds the context-sensitive stages accordingly.**
- **Don't force it** on a quick lookup, a single analysis, or pure ideation. For choosing a
  direction in the first place, use the `research-companion` skill; this skill takes over once a
  direction is chosen and needs to be executed rigorously.

## Working with `research-companion` (handoff contract)

The two skills are two halves of one workflow. `research-companion` runs ideation and ends each idea
with a **Session Summary**: a verdict (PURSUE / PARK / KILL), a one-sentence **nugget**, the
**strength**, the **risk**, a **first step** (the single riskiest assumption to test, time-boxed to
1-2 weeks), and a watch list. It saves this as a research-evaluation page under
`wiki/research-evaluations/YYYY-MM-DD-<slug>.md`, or, with no wiki, under
`~/.claude/projects/<slug>/memory/research-evaluations/` (the user's shared PhD store uses a
`research-evaluations/` folder). This skill takes over from there.

**Forward handoff (ideation → execution).** When invoked on an idea that `research-companion` has
marked PURSUE (or when the user says "now run it"):

1. **Read the research-evaluation page first** and treat it as the brief. Do not re-litigate the
   verdict; it is settled input.
2. **Map its fields onto the pipeline:**
   - *nugget* → the central claim to ground and, eventually, the paper's conclusion-first target.
   - *risk* + *first step (riskiest assumption)* → **Stage 1's fail-fast test.** Run this BEFORE
     building the full apparatus. The pipeline's evidence-checker and falsification machinery are the
     right tools for it: make the riskiest assumption a planted hypothesis and try to break it cheaply.
   - *watch list / competition / scooping* → feed Stage 6 (literature audit); recheck for new
     preprints that would change the plan.
   - *timeline estimate* → scope the build; do not over-engineer past the first concrete result.
3. **Honor the fail-fast.** If the Stage-1 test of the riskiest assumption fails, stop and do the
   reverse handoff rather than pushing on. That is the whole point of running it first.

**Reverse handoff (execution → ideation).** When the fail-fast test, or a failed reproduction, kills
or weakens the idea, hand back to `research-companion` instead of forcing the study: append an
execution update to the **same** research-evaluation page (what was tested, what was learned, new
verdict PARK/KILL, and for PARK what would need to change), and append a line to the wiki log. This
keeps one record per idea across both skills rather than forking a second store. Then the user can
re-enter ideation on the salvage.

**Shared conventions.** Both skills read and write the same research-evaluation page and state. This
skill never starts a parallel evaluation store; it continues the one `research-companion` created.
When no `research-companion` page exists (the user came straight here), create a minimal one from the
user's framing so the record still exists and the reverse handoff has somewhere to land.

## Stage 0 — Intake: resolve the context, ask for what is missing (never guess)

Run this the moment the skill is triggered, before building anything. The pipeline has a few
context-sensitive parameters, and resolving them is exactly what adapts the generic architecture to
the specific investigation. **Gather what is already known, then ask the user to fill every gap. Do
not guess a parameter, and do not fall back on a default that would change the scientific meaning.**

Parameters to resolve:
1. **Topic, claim, success criterion.** The research question, the central claim/nugget, and what
   counts here as a verified, non-trivial finding.
2. **Source type** (sets how Stages 2-3 bind):
   - *reproduce-and-extend* — a prior paper/dataset/corpus exists; wrap it as tools and reproduce its
     claims first;
   - *primary study* — no prior source; Stage 2 wraps your own instrument/data, and Stage 3
     "reproduce" re-binds to reproducing the pilot and validating the apparatus.
3. **Data modality** (sets what "tools" and "reproduce" mean): quantitative data, qualitative (coded
   transcripts, a coding scheme to re-derive), or theoretical (a model or proof to re-check). Mixed is
   allowed; name each.
4. **Domain sub-areas** (binds Layer 3): the specialist agents to instantiate. Propose a roster from
   the topic and confirm it; never inherit the biology roster by default.
5. **Available adapters** (from the Dependencies table): MCP/Paper2Agent tool server, a literature
   agent, a `research-companion` PURSUE brief, domain tools/databases. Use what exists, fall back
   otherwise.
6. **Execution mode**: API key for live agent reasoning, or in-session Claude only (see below). Either
   is fine; the choice affects how agents reason, not whether findings are tool-grounded.
7. **Constraints**: scope, timeline, ethics/data-access, target venue and its citation style.

Fill these from the trigger message, the `research-companion` research-evaluation page if one exists,
and the repository. For anything still missing or ambiguous, **ask the user a short, focused batch of
questions and wait for the answer.** One round of good questions beats a wrong assumption that
reshapes the study. Only once the context is specified do you proceed to Stage 1.

**Two entry points, worked examples.** This pipeline supports starting either from a **paper** (the
reproduce-and-extend / Paper2Agent entry: `references/entry-from-paper.md`, a biology case) or from an
**idea** (a primary study, typically a `research-companion` PURSUE verdict: `references/entry-from-idea.md`,
a human-robot case). For how to combine external tools (research-companion, Paper2Agent/MCP, scite,
academic-writing-agents) with their fallbacks, see `references/integrations.md`.

## Execution modes (API key or in-session Claude)

The pipeline runs the same way with or without an Anthropic API key. What changes is *where the agent
reasoning happens*; findings are tool-computed in every mode, so results reproduce.

- **In-session (no key).** This Claude session and its subagents are the reasoning agents: they choose
  which tools to call, read the outputs, and write conclusions inside the conversation. The committed
  pipeline that re-runs the analysis is deterministic code, so anyone reproduces the numbers without
  credentials. This is the default and needs nothing extra.
- **API key present.** Agents can additionally run a live tool-use loop programmatically (an
  Anthropic backend over the same tool registry), which suits headless, batched, or large runs outside
  a session. Keep the deterministic path as the reproducible artifact so results still reproduce with
  no key.
- **They coexist.** Build-time reasoning (in-session or via the API) chooses the questions and
  analyses; run-time execution recomputes and verifies them deterministically. Record which mode
  produced which output, plus the model id and seeds, so any run is traceable.

Design the tool layer so one registry can be called three ways without change: directly in-session,
through an MCP server, or through the API tool-use loop. One tool registry, three callers.

## The pipeline (seven stages)

Run these in order. Stages 2 to 5 form the discovery loop and can iterate. Each stage names the
agent role that owns it (roles defined in `references/architecture.md`).

1. **Ground.** Ingest the source material (paper, SI, datasets, code, prior literature). Build
   machine-readable tables with provenance: source id, version, checksum. Fix seeds, pin
   dependencies. Nothing enters the pipeline unversioned.

2. **Expose as tools (Paper2Agent pattern).** Wrap the material in a small server of validated,
   callable tools: list/describe/query a dataset, run a named analysis, reproduce a specific claim,
   plus domain-specific queries. The tools are the only way agents touch the data. Give each agent a
   *restricted* toolset and record the permissions.

3. **Reproduce.** Re-derive the source's own headline claims from its own data, through the tools.
   Report a fidelity number (reproduced value vs the source's reported value). Reproduction that
   matches is the license to go further; reproduction that fails is itself a finding.

4. **Discover.** For each question: a specialist agent answers it via tools; an **independent
   evidence-checker** recomputes it from scratch; an **adversarial critic** attacks it (sample size,
   confounds, multiple testing); a **replication/robustness** pass stresses it (leave-one-out, FDR,
   alternative models); a **contradiction** agent classifies it against the source (confirms /
   extends / contradicts / caveats). Only findings that are verified AND survive the attack graduate.

5. **Falsify.** For every surviving claim, state the observation that would falsify it and design
   the most efficient experiment to try. Plant known nulls and confirm the system *rejects* them.

6. **Audit the literature.** Use a literature agent (scite MCP where available, else WebSearch and
   WebFetch) for external support or contradiction. Verify each citation against the source
   **content**, not just topic match, and verify metadata against Crossref/DataCite. Check for
   retractions. See `references/evaluation.md` and the user's global citation rules.

7. **Evaluate, test, report.** Score both the science and the AI system on the two-axis framework.
   Write automated tests over all AI-generated code and run them. Log every agent run (prompt, tool
   calls, output). Then draft the report with numeric citations and the user's style rules, and
   archive datasets + results with a DOI. End with an honest disclaimer: the author verified the
   process, not necessarily the domain validity.

## Orchestration: how to actually run it with subagents

The project was built by **decomposing it into independent, well-scoped work packages and handing
each to a focused subagent**, rather than doing everything in one thread. Reproduce that:

- **Decompose into independent packages.** Typical packages: data ingestion + provenance; the tool
  server; the analysis library; the discovery loop; the literature + citation audit; the
  writing/bibliography review; the logic/consistency/technical review. Each has a clear input,
  output, and the files it needs.
- **Fan out what is independent, pipeline what is dependent.** Launch independent packages as
  parallel subagents (one message, several `Agent` calls). Chain a package on the output of another
  only when it truly depends on it (e.g. the citation audit needs the draft; robustness needs the
  findings). Prefer a pipeline so each reviewer starts as soon as its input is ready.
- **Brief each subagent like a peer.** State the goal, the files to read, what is already settled,
  and the exact artifact to return. Its brief is its only context, so keep scope narrow and explicit.
- **Keep reviewers independent of the conclusion.** The evidence-checker and the adversarial critic
  must recompute and attack without being handed the answer to confirm. An agent given a hypothesis
  tends to return it confirmed; design against that.
- **Two realisations of the same architecture.** The five-layer agent design can be run as (a) real
  Claude subagents reasoning live, or (b) a deterministic tool-driven loop in code (the committed
  default in the source project, so results reproduce with no API key). Be explicit about which you
  are using. Live reasoning is better for open-ended generation; the deterministic loop is better for
  a reproducible, credential-free artifact. They can coexist: build-time reasoning picks the
  questions, run-time code executes and verifies them.
- **Optional assets, never required.** The `Agent` tool runs the work packages above in any context.
  Where they exist, use the adapters from the Dependencies table (Paper2Agent/MCP for tools, scite for
  literature, `research-companion` for ideation, `academic-writing-agents` for drafting). If a
  plugin's agents are not invokable as `subagent_type`, run their standards as instructions inside a
  general subagent. If an adapter is missing entirely, use its fallback and continue.

## Honest-scope guardrails (do not skip these)

These are what separated a defensible deliverable from an impressive-looking one:

- Lead with the **grounding and verification** contribution, not the flashiest hypothesis. State
  limitations (e.g. a fixed question bank, small strata) plainly.
- Keep speculative outputs (a therapeutic proposal, a strong causal claim) labelled as
  **illustrative** until the evidence earns more.
- The author remains responsible for every AI output and must be able to explain every component.
  Inspect and test AI-generated code; never accept it blind.
- Record enough to reproduce: prompts, agent configs, model versions, seeds, data versions, logs.
