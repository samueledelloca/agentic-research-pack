# Entry point B — start from an idea (research-companion handoff)

Use this when there is no prior paper to wrap, only a chosen research direction, typically the PURSUE
output of the `research-companion` ideation skill. This is a *primary study*: you build tools around
your own instrument and data, and "reproduce" re-binds to reproducing the pilot and validating the
apparatus. The worked case below is a human-robot / human-computer study; the shape is domain-free and
the specific numbers are placeholders the user fills at Stage 0.

## The handoff

`research-companion` ends a PURSUE idea with a Session Summary: a nugget, a strength, a risk, and a
**first step** (the single riskiest assumption, time-boxed to 1-2 weeks), saved to a
research-evaluation page. This skill reads that page as its brief (see the SKILL.md handoff contract)
and turns the "first step" into its Stage-1 fail-fast test. If no research-companion page exists, Stage
0 gathers the same fields by asking the user.

## Illustrative case: a skill-atrophy HRI study

Nugget (example): "Delegating a judgement task to a robot that enacts the outcome atrophies the
operator's own judgement skill, visible as trial-level response lag even when the robot's advice is
correct." Risk: the effect is too small to detect at a feasible N, or it is confounded by proximity to
the robot. First step: a cheap Wizard-of-Oz micro-pilot that tests whether lag separates the two
conditions at all.

### How the stages bind here

- **Stage 0 (intake).** Source type = *primary study*. Data modality = quantitative behavioural logs
  (and optionally qualitative debrief). Layer-3 roster = measurement, study-design, statistics/modelling,
  qualitative-coding, validity/ethics, robustness. Confirm the primary DV, the planted-error rate, and
  the success criterion with the user; do not assume them.
- **Stage 1 (ground + fail-fast).** Run the micro-pilot first. Version the pilot logs, fix seeds. If
  the riskiest assumption fails (no separation), stop and do the reverse handoff to research-companion
  (append PARK + what was learned to the same page) instead of building the full study.
- **Stage 2 (tools).** The tool server wraps the instrument and coding scheme, not a paper:
  `load_trials`, `score_response` (vs ground truth), `trial_lag`, `switch_rate`, `weight_of_advice`,
  `fit_model`. Every reported number comes from these.
- **Stage 3 (reproduce, re-bound).** With no prior paper, reproduce the *pilot* and validate the
  *apparatus* before the main run: re-derive the pilot numbers from raw logs through the tools and
  confirm the manipulation behaves as specified.
- **Stage 4 (discover).** The confirmatory primary is answered by the analysis agent; an independent
  evidence-checker recomputes the model from raw logs; the critic attacks (proximity confound, small
  strata, multiple DVs); robustness runs leave-one-participant-out and alternative model specs; the
  contradiction agent checks exploratory reads against the primary.
- **Stage 5 (falsify + plant-a-null).** State what observation would falsify the effect. Plant a
  condition where no effect should exist (e.g. correct-advice trials with identical enactment) and
  confirm the pipeline reports null, not a false positive.
- **Stage 6 (literature).** External support via a literature agent; content- and metadata-verify every
  citation; recheck the research-companion watch list (scooping) for new preprints.
- **Stage 7 (evaluate/test/report).** Two-axis evaluation; tests over the scoring and modelling code;
  write-up in the venue's citation style.

### Scale note

The full seven-stage pipeline is sized for a substantial study. For a short-format paper (a late-breaking
report or an extended abstract), run a *light* version: fail-fast + tool-backed primary + plant-a-null +
citation audit, skipping the heavy apparatus-reproduction and the full specialist layer. Stage 0 should
surface the venue and scope so this choice is explicit.
