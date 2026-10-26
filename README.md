# Agentic Research Pack

A domain-independent Claude Code skill for running a **verification-first** research investigation:
turn a paper or dataset into callable tools, reproduce its claims, generate and *adversarially verify*
new findings, audit the literature, and evaluate the system, so the output survives scrutiny and
reproduces, instead of reading like a confident essay.

Distilled from a biology project (an "autonomous AI scientist" built from a Nature study), rebuilt to
be field-agnostic. It is the **execution** counterpart to the ideation skill
[`research-companion`](https://github.com/andrehuang/research-companion): research-companion decides
*what* to pursue; this pack runs the investigation end to end.

## The one idea

**Tools, not prose.** Every factual claim the system makes is the return value of a real computation,
not text a model generated. A grounding check then confirms every reported number equals the number a
tool actually produced. That is what lets you stand behind the *process* even in a domain you cannot
personally judge. Everything else (specialist agents, discovery loop, literature audit, tests) serves
that idea.

## Architecture (the reusable invariant)

Two views of one design; only Layer 3 is re-bound per domain.

- **Six primitives:** source adapter (Paper2Agent), tool protocol (MCP), scientific RAG, coding agent,
  statistical-analysis agent, adversarial reviewer. Each is a role with a swappable implementation.
- **Five layers:** knowledge base → tool server → specialist agents (re-bound per domain) → discovery
  agents (generator, critic, evidence-checker, replication, contradiction, experiment-designer,
  falsification) → PI (integrates, cannot override contradictory evidence).

A biology study uses immunology / HLA / clinical agents; an HCI study uses measurement / study-design /
statistics agents; a systems study uses performance / security / reliability agents. Same principle,
different labels.

## Two entry points

- **From a paper** (reproduce-and-extend, Paper2Agent): wrap an existing paper/dataset as tools and
  reproduce its claims before extending. See
  [`entry-from-paper.md`](skills/agentic-research-pipeline/references/entry-from-paper.md).
- **From an idea** (a primary study, typically a `research-companion` PURSUE verdict): build tools
  around your own instrument; "reproduce" re-binds to reproducing the pilot. See
  [`entry-from-idea.md`](skills/agentic-research-pipeline/references/entry-from-idea.md).

When triggered, the skill first runs **Stage 0 intake**: it resolves the context (topic, source type,
data modality, domain roster, adapters, execution mode, constraints) from what it can see and **asks
you for anything missing. It never guesses a parameter that changes the scientific meaning.**

## Install

Pick **one** path per machine (installing both the plugin and the symlink makes the skill load twice).

**As a plugin (recommended for sharing):**

```
/plugin marketplace add samueledelloca/agentic-research-pack
/plugin install agentic-research-pipeline@agentic-research
```

The skill then triggers by description, or explicitly as `/agentic-research-pipeline:agentic-research-pipeline`.

**As a symlinked pack (like researcher-pack):**

```
git clone https://github.com/samueledelloca/agentic-research-pack
cd agentic-research-pack
./setup.sh link      # symlinks skills/ into ~/.claude/skills/ ; `git pull` then updates in place
```

**Test locally before publishing:**

```
claude plugin validate .                 # checks manifest, marketplace, and skill frontmatter
claude --plugin-dir ./agentic-research-pack   # load for one session without installing
```

Requires only base Claude Code. Everything below is optional.

## Works with (optional adapters, never required)

| Role in the pipeline | Preferred adapter | Fallback when absent |
|---|---|---|
| Ideation + idea triage | [research-companion](https://github.com/andrehuang/research-companion) | start from your framing; create a minimal eval record |
| Source → executable tools | [Paper2Agent](https://github.com/jmiao24/Paper2Agent) / an [MCP](https://modelcontextprotocol.io) tool server | a local module of functions the agents call |
| Literature audit | [scite](https://scite.ai) MCP | WebSearch + WebFetch + manual Crossref/DataCite checks |
| Drafting / writing review | [academic-writing-agents](https://github.com/andrehuang/academic-writing-agents) | run the same standards in a general subagent |
| Domain analysis / database | the field's own tool/model/database | code the analysis directly |

How each one plugs in, and what flows across the seam, is in
[`integrations.md`](skills/agentic-research-pipeline/references/integrations.md).

## Pairs well with

- [**research-companion**](https://github.com/andrehuang/research-companion) ⭐ the recommended
  pairing. Strategic ideation (brainstorm, evaluate, decide); hand its PURSUE verdict to this pack to
  execute. Ships inside [researcher-pack](https://github.com/andrehuang/researcher-pack).
- [**Paper2Agent**](https://github.com/jmiao24/Paper2Agent) turns a paper and its code into an
  [MCP](https://modelcontextprotocol.io) tool server. This is the Layer-2 "source to tools" adapter.
- [**scite**](https://scite.ai) provides Smart Citations and full-text search for the literature
  audit (Stage 6).
- [**academic-writing-agents**](https://github.com/andrehuang/academic-writing-agents) brings drafting,
  review, and bibliography agents for the Stage-7 write-up.

None of these is required. Each has a fallback (see the table above and `integrations.md`), so the
pipeline runs self-contained and gets better where an adapter is present.

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
[researcher-pack](https://github.com/andrehuang/researcher-pack) (by `andrehuang`), whose "pairs well
with" structure this README follows. The verification-first method is distilled from the IAISS
C9orf72-Nature2Agent course project, which was itself built on the
[Paper2Agent](https://github.com/jmiao24/Paper2Agent) idea.

## License

MIT. See [LICENSE](LICENSE). The method is distilled from a course project; the biology references are
illustrative, and any scientific reuse should cite the original studies.
