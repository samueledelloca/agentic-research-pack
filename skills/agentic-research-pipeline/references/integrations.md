# Integrations — using this skill with external tools

The skill is self-contained: it needs none of the tools below. Each is an **optional adapter** that
plugs in at a fixed point and has a fallback, so the pipeline runs anywhere and gets better where more
is available. This file shows how each one connects and what flows across the seam.

## research-companion (ideation → execution)

- **What it is.** A strategic-ideation skill (Seed → Diverge → Evaluate → Deepen → Frame → Decide)
  that ends with a PURSUE / PARK / KILL verdict and a research-evaluation page.
- **How it connects.** Forward: this skill reads the PURSUE page and maps nugget → central claim,
  risk + first-step → Stage-1 fail-fast test, watch list → literature audit, timeline → scope.
  Reverse: a failed fail-fast or reproduction appends a PARK/KILL update to the *same* page. One record
  per idea across both skills.
- **Data across the seam.** The research-evaluation page (wiki `research-evaluations/<date>-<slug>.md`,
  or the memory fallback). Do not fork a second store.
- **Fallback (absent).** Start from the user's framing at Stage 0 and create a minimal evaluation
  record so the reverse handoff still has somewhere to land.
- **Typical flow.** `/research-companion` to pick a direction, then this skill to execute it.

## Paper2Agent / an MCP tool server (source → tools)

- **What it is.** A pattern (and tooling) that turns a paper, its supplementary material, datasets and
  workflows into executable, callable tools instead of documents.
- **How it connects.** It *is* Layer 2 of the architecture. Expose the source as a tool server; give
  each agent a restricted subset. Every finding is a tool return value.
- **Fallback (absent).** A plain local module of functions the agents call in-session. The discipline
  (tools, not prose) matters more than the transport; MCP just makes the same tools reusable across
  clients and across the live/deterministic/API callers.

## scite MCP (literature audit)

- **What it is.** A literature MCP with Smart Citations and full-text search.
- **How it connects.** It is the Stage-6 literature agent and a Layer-3 literature specialist. Use it
  to find external support/contradiction, to content-verify each citation against the source text, and
  to check for retractions. Verify metadata against Crossref/DataCite.
- **Fallback (absent).** WebSearch + WebFetch for discovery, with a manual Crossref/DataCite metadata
  check. Slower and less precise, but the audit still runs.

## academic-writing-agents (Stage 7 drafting / review)

- **What it is.** A plugin of writing and review agents (section drafting, prose polishing, writing
  review, bibliography checks).
- **How it connects.** Stage 7 drafts the report with it, applying the venue's citation style and the
  user's style rules. Its review agents double as a writing/bibliography audit pass.
- **Fallback (absent).** Run the same standards as instructions inside a general subagent (draft →
  tighten → review → bib-check). No capability is lost, only the packaging.

## Combining them end to end

A full run with everything installed:

1. `/research-companion` → PURSUE verdict + research-evaluation page.
2. This skill, Stage 0 reads that page and asks for any gaps.
3. Stage 2 builds a Paper2Agent/MCP tool server (or a local module).
4. Stages 3-5 reproduce, discover, and verify through the tools; scite backs the literature checks.
5. Stage 7 drafts with academic-writing-agents and archives the result.

With none installed, the same five steps run with in-session tools, WebSearch, and a general drafting
subagent. The output is the same shape; only the leverage differs. Never block on a missing adapter.
