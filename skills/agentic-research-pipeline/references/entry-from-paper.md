# Entry point A — start from a paper (reproduce-and-extend, Paper2Agent)

Use this when a prior paper, dataset, or corpus already exists and the goal is to turn it into an
executable agent, reproduce its claims, and extend it with verified new findings. This is the
"Paper2Agent" entry. The worked case below is a biology study; the shape is domain-free.

## Illustrative case: an immunology Nature study

Source: a published study with a manuscript, supplementary tables, and deposited raw data (flow
cytometry, peptide/HLA tables, survival data). Goal: an agent that explains the design, reproduces the
statistics and figures, interrogates the peptide/HLA data, tests alternative assumptions, and
generates verified observations the paper does not state.

### How the stages bind here

- **Stage 0 (intake).** Source type = *reproduce-and-extend*. Data modality = quantitative. Layer-3
  roster = immunology, HLA, T-cell, clinical, structural, safety (the paper's sub-areas). Confirm the
  success criterion with the user, e.g. "at least five verified non-trivial observations not in the paper".
- **Stage 1 (ground).** Fetch the deposited data with checksums; build tidy machine-readable tables;
  pin dependencies; fix seeds.
- **Stage 2 (tools).** A tool server exposes: `list_datasets`, `describe_dataset`, `query_dataset`,
  `run_analysis`, `reproduce_claim`, `compare_groups`, plus domain tools (`hla_typing`,
  `most_immunogenic_epitopes`, `protein_sequence`). Every number the agents report comes from these.
- **Stage 3 (reproduce).** Re-derive each headline claim from the paper's own data; report fidelity
  (reproduced p vs reported p). Matching reproduction licenses extension.
- **Stage 4 (discover).** Specialist agents ask and answer sub-area questions; an independent
  evidence-checker recomputes; the critic attacks (small strata, multiple testing); robustness runs
  leave-one-donor-out and FDR; the contradiction agent classifies each finding vs the paper.
- **Stage 5 (falsify).** For a proposed mechanism/therapeutic direction, state the falsifier and the
  most efficient experiment. Plant a known null (a control antigen that should not differ) and confirm
  the system rejects it.
- **Stage 6 (literature).** External support/contradiction via a literature agent; content-verify and
  metadata-verify every citation.
- **Stage 7 (evaluate/test/report).** Two-axis evaluation; tests over all generated code; honest
  disclaimer that the author verified the process, not the domain validity.

### Why this entry suits reproduce-and-extend

The paper gives you a ground truth to reproduce (Stage 3), which is the cleanest possible check that
the tool layer is faithful before you trust it on new questions. If reproduction fails, that failure
is itself a reportable finding and a reason to stop and recheck the tooling.
