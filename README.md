# Agentic Research Pack

A domain-independent Claude Code skill for running a **verification-first** research investigation.
Start from a paper, a dataset, or just an idea (for example a `research-companion` verdict, fetching
the sources as you go); expose the material as callable tools, reproduce what is known, generate and
*adversarially verify* new findings, audit the literature, and evaluate the whole system, so the
output survives scrutiny and reproduces, instead of reading like a confident essay.

Distilled from a biology project (an "autonomous AI scientist" built from a Nature study) and rebuilt
to be field-agnostic. It is the **execution** counterpart to the ideation skill
[`research-companion`](https://github.com/andrehuang/research-companion): research-companion decides
*what* to pursue; this pack runs the investigation end to end.

## The one idea

**Tools, not prose.** Every factual claim the system makes is the return value of a real computation,
not text a model generated. A grounding check then confirms that every reported number equals the
number a tool actually produced. That is what lets you stand behind the *process* even in a domain you
cannot personally judge. Every feature below serves that idea: expose the material as tools, drive
findings through the tools, and have a *different* agent independently recompute and attack each one.

## What it gives you

- **Guided intake that never guesses.** On trigger, the skill resolves the context (topic, claim,
  success criterion, source type, data modality, the domain's sub-areas, available tools, execution
  mode, constraints) from what it can see, then asks you a short, focused batch of questions for
  anything missing. It does not assume a default that would change the scientific meaning.
- **Two entry points.** From a **paper or dataset** (reproduce-and-extend) or from an **idea** (a
  primary study, often a `research-companion` PURSUE verdict). When you start from an idea, sources are
  fetched as the work proceeds.
- **A five-layer agent architecture** you re-bind to your field, with a fixed **discovery engine** of
  seven agents (generator, critic, evidence-checker, replication, contradiction, experiment-designer,
  falsification) and a principal-investigator agent that integrates but cannot override evidence.
- **Built-in verification.** Each finding is independently recomputed by a *different* agent, attacked
  by an adversarial critic, stress-tested for robustness (leave-one-out, multiple-comparison control,
  alternative models), and classified against the source. Only findings that are verified and survive
  the attack graduate.
- **Falsification, including a planted-null test.** Every surviving claim gets a stated falsifier and
  the most efficient experiment to try. The system also plants known nulls and must *reject* them, a
  direct check that it does not confirm what it should not.
- **Reference and citation checking.** Every citation is content-verified against the source text (not
  just topic-matched), metadata-verified against Crossref/DataCite, and checked for retractions, in a
  numeric citation style.
- **A two-axis evaluation** (the Common Evaluation Framework): the scientific result *and* the AI
  system are scored, every metric computed from real outputs.
- **Reproducibility by construction.** Fixed seeds, versioned data with checksums, recorded prompts,
  agent configs and model versions, per-run logs, pinned dependencies, executable workflows.
- **A documentation ledger.** Every hypothesis with the evidence for and against it, which were
  rejected, which were tested, and the prompts, configs, and code behind each, kept as
  machine-checkable files rather than buried in prose.
- **Honest scope by default.** The author verifies the process, not the domain's validity; speculative
  outputs stay labelled illustrative, and the work ships with a plain disclaimer.
- **Two execution modes.** Runs the same with or without an Anthropic API key: in-session reasoning,
  or a live API tool-use loop for headless and batched runs. Findings are tool-computed either way.
- **Self-contained, with optional adapters.** Needs nothing beyond base Claude Code. It uses
  `research-companion`, Paper2Agent/MCP, scite, and academic-writing-agents where present, and falls
  back cleanly where they are not.

## How it works: the pipeline

Stage 0 runs first, then stages 1 to 7. Stages 2 to 5 are the discovery loop and can iterate.

| Stage | What happens | What it produces |
|---|---|---|
| **0. Intake** | Resolve the context; ask you for every gap | a settled brief and the re-bound plan |
| **1. Ground** | Ingest and version sources; fix seeds; run the fail-fast test of the riskiest assumption first | provenance-stamped data; a go / no-go |
| **2. Expose as tools** | Wrap the material as validated callable tools (Paper2Agent pattern); give each agent a restricted subset | a tool server; the only path to the data |
| **3. Reproduce** | Re-derive known claims through the tools (or, for a primary study, reproduce the pilot and validate the apparatus) | a fidelity number; the license to extend |
| **4. Discover** | Specialist agents answer questions; an evidence-checker recomputes; a critic attacks; robustness and contradiction passes run | verified, attacked, classified findings |
| **5. Falsify** | State each claim's falsifier and the best experiment; plant nulls the system must reject | falsifiers, experiments, a rejection check |
| **6. Literature audit** | External support or contradiction; content-verify and metadata-verify every citation | a checked reference set |
| **7. Evaluate, test, report** | Score both axes; test all generated code; log every run; draft with an honest disclaimer | evaluation, tests, logs, the write-up |

The arc runs observation → mechanism → hypothesis → computational test → candidate → falsification.
Full detail is in [`SKILL.md`](skills/agentic-research-pipeline/SKILL.md).

## The architecture

Two views of one design. Only Layer 3 changes between domains.

**Six primitives** (each a role with a swappable implementation):

| Primitive | Role | Lives in |
|---|---|---|
| Source adapter (Paper2Agent) | turn source material into executable tools | Layer 2 |
| Tool protocol (MCP) | how agents call those tools | Layer 2 |
| Scientific RAG | grounded retrieval over source + corpus | Layers 1-2 |
| Coding / reasoning agent | builds the tools, drives the loop | cross-cutting |
| Statistical / quantitative-analysis agent | computes the findings | Layer 3 |
| Adversarial reviewer agent | attacks every finding | Layer 4 |

**Five layers:**

1. **Knowledge base** (the source material, read-only ground truth).
2. **Tool server** (exposes layer 1 as validated tools; the only way agents touch the data).
3. **Specialist agents** (re-bound per domain: one narrow agent plus a restricted toolset per
   sub-area). Biology uses immunology / HLA / clinical agents; HCI uses measurement / study-design /
   statistics agents; systems uses performance / security / reliability agents.
4. **Discovery agents** (domain-free): hypothesis generator, hypothesis critic, evidence checker,
   replication, contradiction, experiment designer, falsification.
5. **Principal Investigator** (integrates; cannot override contradictory evidence).

A coverage checklist of six required roles (generative, autonomous, literature, domain-analysis,
independent-verification, adversarial-review) maps onto these layers, so no essential role is missing.
Rosters for other fields, the repository skeleton, the documentation ledger, and the reproducibility
checklist are in [`architecture.md`](skills/agentic-research-pipeline/references/architecture.md).

## Verification and evaluation

**Verification design.** The agent that produces a finding and the agent that verifies it are
different, and the verifier recomputes from the raw tools. The critic is told to break the claim, not
to agree. A finding graduates only when the independent recompute matches, the critique is survived,
and robustness holds. The PI cannot argue away a failed check; contradictions, uncertainties, and
limitations ship with the result.

**The Common Evaluation Framework** scores two axes, every metric computed from real outputs:

- *Scientific:* reproducibility, statistical robustness, domain plausibility, external literature
  support, falsifiability, novelty, experimental tractability.
- *AI system:* grounding (hallucination rate), determinism and reproducibility, citation accuracy,
  tool-use accuracy, ability to detect its own errors, ability to reject false hypotheses, hypothesis
  novelty and diversity, computational cost and latency.

Details, including the planted-null test and the citation audit, are in
[`evaluation.md`](skills/agentic-research-pipeline/references/evaluation.md).

## Orchestration

The investigation is decomposed into independent, well-scoped work packages (data ingestion, the tool
server, the analysis library, the discovery loop, the literature audit, the writing review), each
handed to a focused subagent. Independent packages fan out in parallel; dependent ones are pipelined
so each reviewer starts as soon as its input is ready. Reviewers are briefed without being handed the
conclusion, so they recompute and attack rather than confirm. The same five-layer design can run as
live subagents or as a deterministic tool-driven loop; be explicit about which.

## How to use it

1. **Trigger it.** Ask to run or execute a research investigation, build an "AI scientist" or
   Paper2Agent, reproduce-and-extend a study, or hand over a `research-companion` idea. The skill also
   runs explicitly as `/agentic-research-pipeline:agentic-research-pipeline`.
2. **Answer the intake questions.** It will ask for whatever context it cannot infer. One good round
   here prevents a study built on a wrong assumption.
3. **Let it run the stages**, checking in at the fail-fast gate (Stage 1) and before the full build.
4. **Pick your execution mode.** In-session needs nothing; set an API key only if you want headless or
   batched live runs.

Starting from an idea, the handoff from `research-companion` is automatic: it reads the PURSUE verdict,
turns the riskiest assumption into the Stage-1 fail-fast test, and hands the idea back (PARK/KILL) on
the same record if that test fails.

## Install

Pick **one** path per machine (installing both the plugin and the symlink makes the skill load twice).

**As a plugin (recommended for sharing):**

```
/plugin marketplace add samueledelloca/agentic-research-pack
/plugin install agentic-research-pipeline@agentic-research
```

**As a symlinked pack (like researcher-pack):**

```
git clone https://github.com/samueledelloca/agentic-research-pack
cd agentic-research-pack
./setup.sh link      # symlinks skills/ into ~/.claude/skills/ ; `git pull` then updates in place
```

**Test locally before publishing:**

```
claude plugin validate .                        # checks manifest, marketplace, skill frontmatter
claude --plugin-dir ./agentic-research-pack     # load for one session without installing
```

## Works with (optional adapters, never required)

| Role in the pipeline | Preferred adapter | Fallback when absent |
|---|---|---|
| Ideation + idea triage | [research-companion](https://github.com/andrehuang/research-companion) | start from your framing; create a minimal eval record |
| Source → executable tools | [Paper2Agent](https://github.com/jmiao24/Paper2Agent) / an [MCP](https://modelcontextprotocol.io) tool server | a local module of functions the agents call |
| Literature audit | [scite](https://scite.ai) MCP | WebSearch + WebFetch + manual Crossref/DataCite checks |
| Drafting / writing review | [academic-writing-agents](https://github.com/andrehuang/academic-writing-agents) | run the same standards in a general subagent |
| Domain analysis / database | the field's own tool/model/database | code the analysis directly |

None of these is required. Each has a fallback, so the pipeline runs self-contained and gets better
where an adapter is present. How each one plugs in, and what flows across the seam, is in
[`integrations.md`](skills/agentic-research-pipeline/references/integrations.md).

## Repository layout

```
agentic-research-pack/
├── .claude-plugin/
│   ├── plugin.json           # plugin manifest
│   └── marketplace.json      # single-plugin marketplace (this repo)
├── skills/
│   └── agentic-research-pipeline/
│       ├── SKILL.md          # the method: core architecture, Stage 0 intake, execution modes, 7 stages
│       └── references/
│           ├── architecture.md      # primitives→layers, cross-domain rosters, repo skeleton, checklists
│           ├── evaluation.md        # the two-axis Common Evaluation Framework, verification, tests
│           ├── entry-from-paper.md  # worked example: start from a paper
│           ├── entry-from-idea.md   # worked example: start from an idea
│           └── integrations.md      # using it with external tools
├── setup.sh                  # link | unlink (symlink install)
├── LICENSE                   # MIT
└── README.md
```

## Credits

Inspired by [research-companion](https://github.com/andrehuang/research-companion) and
[researcher-pack](https://github.com/andrehuang/researcher-pack) (by `andrehuang`), the ideation
skill this pack executes against. The verification-first method is distilled from the IAISS
C9orf72-Nature2Agent course project, which was itself built on the
[Paper2Agent](https://github.com/jmiao24/Paper2Agent) idea.

## License

MIT. See [LICENSE](LICENSE). The method is distilled from a course project; the biology references are
illustrative, and any scientific reuse should cite the original studies.
