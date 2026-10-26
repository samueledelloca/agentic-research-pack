# Evaluation, verification, literature audit, and tests

This is the **Common Evaluation Framework**: every investigation evaluates two things, the
**scientific result** and the **AI system** that produced it. Score both. Compute every metric from
actual pipeline outputs, never assert it. The metric lists below are the full framework; keep the
ones that apply to your domain and drop those that do not (e.g. "domain plausibility" stands in for
"biological plausibility" outside biology).

## Axis 1 — Scientific evaluation

- **Reproducibility.** Can the source's own claims be re-derived from its own data? Report a fidelity
  number: reproduced value vs reported value (e.g. max absolute difference, and whether the
  significance call agrees).
- **Statistical robustness.** Does each finding survive leave-one-out (jackknife), family-wise
  correction (FDR), and alternative model choices? A finding that dies under FDR is a limitation, and
  saying so is part of the result.
- **Biological / domain plausibility.** Is the finding consistent with known mechanism? Label it as
  interpretation, not proof.
- **Independent literature support / external validation.** Does outside work support or contradict it?
- **Falsifiability.** Does every interpretive claim come with a stated falsifier?
- **Novelty.** How many findings are non-trivial and not already in the source? Set a success
  criterion up front (the source project required at least five verified novel observations).
- **Experimental tractability.** Could the proposed next experiment actually be run?

## Axis 2 — AI-system evaluation

- **Hallucination rate / grounding.** The key metric. Grounding = fraction of reported numbers that
  equal the number the tool actually computed. Target 1.0. This is the direct test that the system
  reports computations, not inventions.
- **Determinism / reproducibility.** Does the committed pipeline produce the same results on re-run,
  ideally with no credentials (deterministic backend)? Record whether live-model reasoning is on.
- **Replayability.** Fraction of reported numbers whose tool call, replayed from the ledger, returns
  the same output hash. Target 1.0; list every mismatch with its cause.
- **Citation accuracy.** Fraction of citations that actually support the specific claim they are
  attached to, with correct metadata (see the literature-audit section below).
- **Tool-use accuracy.** Did agents call permitted tools correctly and stay within their toolset?
- **Ability to detect its own errors.** Does the evidence checker catch planted mistakes?
- **Ability to reject false hypotheses.** Plant known nulls (a control comparison that should show no
  effect) and confirm the system *rejects* them instead of confirming them. This is the single most
  convincing AI-evaluation test; always include it.
- **Hypothesis novelty and diversity.** Are the questions varied and non-obvious, spread across sub-areas?
- **Computational cost and latency.** Record them.

## Verification design (how to make findings independent)

- The agent that **generates/answers** a finding and the agent that **verifies** it must be
  different, and the verifier recomputes from the raw tools rather than trusting the answer.
- The **adversarial critic** receives the claim and is tasked to break it, not to agree. Do not hand
  it your conclusion as a premise.
- A finding **graduates** only if: verified (independent recompute matches) AND it survives the
  critique AND it survives robustness. Attach surviving caveats to the finding; never drop them.
- The **PI cannot override** a failed check. Contradictions, uncertainties, and limitations get their
  own catalogue and ship with the result.

## Literature audit (citations that hold up)

Use a literature agent (scite MCP where available, else WebSearch + WebFetch). Then:

- **Content-verify, not topic-match.** Every citation must support the specific claim it is attached
  to: check numbers, direction of effect, population, and study type against the source itself
  (full text when available, abstract at minimum). Grouped citations hide misattribution, so re-check
  when splitting or moving one.
- **Metadata-verify against Crossref/DataCite.** Authors, year, venue, volume/issue/pages, DOI. Cite
  the published version over a preprint once it exists.
- **Check editorial notices** for retractions or corrections before citing.
- Follow the user's global citation rules: numeric style, cite punctually next to the claim, no
  repeated citation within a paragraph, no author names in running text except eponymous results.
- In the source project, auditing all references this way caught several over-attributions (a claim
  credited to the wrong paper in a group). Budget for this; it is where errors hide.

## Tests over AI-generated code

- Write automated tests for every module the agents wrote (data IO, stats, analyses, tools, the
  discovery loop, evaluation). The source project shipped ~35 tests. The point is that AI-generated
  code is inspected and tested, not trusted on sight.
- Test the properties that matter for trust: that `reproduce_claim` matches reported values, that
  robustness functions behave on known inputs, that the grounding check fails when a number is
  perturbed, and that the false-hypothesis test rejects a planted null.
- Keep per-run logs (`experiments/`) as evidence: each log holds the prompt, the tool calls, and the
  output for one agent run, so any result can be traced back to how it was produced. Keep the
  tool-call ledger alongside them, and add a test that replays a sample of logged calls and asserts
  matching output hashes, plus one that confirms an MCP call and an in-session call both reach the
  ledger.
