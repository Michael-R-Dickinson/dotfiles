---
name: visual-plan
description: >-
  Turn a plan for work not yet built into a structural MDX doc — modules,
  interfaces, and artifacts as they will exist, before any code is written.
  Use when the user describes a direction, pastes a text/code plan, or asks
  to visualize a proposed change before implementing it.
---

# visual-plan

Produces an MDX doc showing the intended module/interface/artifact shape of
work that hasn't been built yet. Read-only with respect to source: this
skill describes a direction, it never implements it or edits target-repo
code.

## Before you write anything

Read, in this order:

1. `../visualize-base/SKILL.md`
2. `../visualize-base/references/output-structure.md`
3. `../visualize-base/references/component-library.md`

Those three define the doc scaffold, the graph-sizing rules, and the exact
component props. Do not author from memory of a previous run.

## Procedure

1. **Gather the plan.** Take it from the user's description, or from an
   existing text/code plan they paste or point you at. If the plan builds on
   top of existing code, read that code in the target repo — name real
   modules and files the plan connects to, don't invent them. Only the *new*
   pieces the plan introduces can lack a `files` path (see below).

2. **Identify modules/interfaces/artifacts.** Apply the boundary heuristic
   from `visualize-base`. A plan usually introduces a small number of new
   pieces connecting into a larger existing system — include enough existing
   context nodes (status unset) that the new pieces make sense, but no more.

3. **Decide the graph structure.** Follow `output-structure.md`'s sizing
   rules. Most plans describe one cohesive change and need exactly one small
   graph. Reach for the overview-graph pattern only if the plan genuinely
   spans multiple distinct subsystems.

4. **Set `status`.** A plan has no "before" to diff against, so default to
   leaving `status` unset on everything. Marking new pieces `"added"` is
   fine when it helps a reader immediately see what's proposed vs. what
   already exists — use it consistently across the whole doc if you use it
   at all, not on some nodes and not others.

5. **Set `files`.** For pieces that extend or call into existing code, use
   the real filename, not the full path (see `component-library.md`). For
   genuinely new modules/artifacts with no file yet, either state the
   intended filename if the plan has already decided one, or omit `files` —
   never guess.

6. **Write the doc** following the four-section scaffold in
   `output-structure.md`, sized to the plan (see "Doc size follows change
   size" in `visualize-base/SKILL.md`).

7. **Save it** to `<target-repo>/.visual-docs/plans/<slug>.mdx`, where
   `<slug>` is a short kebab-case name for the plan's topic (e.g.
   `decouple-ingestion.mdx`). Create the directory if it doesn't exist.

8. **Tell the user the file path** and that they can run
   `visualize <path-to-mdx>` (from the visual-diff tool's `renderer/`, or via
   the installed `visualize` bin) to view it as an interactive doc.

## Common mistakes

- Treating "plan" as license to skip reading the codebase — a plan that
  connects to existing code still needs real module names and `files`
  filenames for the existing side of every interface.
- Marking everything `"added"` including unchanged context nodes you only
  included for orientation — leave those unset.
- Writing a large Implementation Details section for a plan — implementation
  hasn't happened yet, so this section is usually empty or very short (a
  design decision worth flagging, not code).
- One crowded graph instead of splitting, or an overview graph for a plan
  that only touches one subsystem.
- **Generic `kind` labels.** `kind="call"` on every edge tells a reader
  nothing once a module has more than one outgoing edge. Name the actual
  function or endpoint the plan proposes (`kind="validate_scan()"`,
  `kind="POST /notify"`) — see `component-library.md`.

## Worked example

A plan to decouple ingestion from reconstruction, before any code exists for
it. One subsystem, one small graph, no overview graph needed, no
Implementation Details section since nothing is built yet.

````mdx
export const frontmatter = {
  title: "Plan: decouple scan ingestion from reconstruction",
  kind: "structural plan",
};

## Overview

Introduces a durable intermediate artifact between ingestion and
reconstruction, with a dedicated validation step, so a malformed scan is
rejected before a reconstruction run is wasted on it.

## Key changes

- Add `Scan Validator` as a new shared validation module, called from
  `Ingest Service` before anything is persisted.
- Add `Raw Scans` as a new durable artifact — validated scans land here
  instead of `Ingest Service` calling the reconstruction path directly.
- `Reconstruction Worker` (existing) starts reading from `Raw Scans` instead
  of being called directly by `Ingest Service`.

## Structural changes

One subsystem, so this is the only graph — no overview needed. It shows the
new validation step and durable artifact sitting between the existing
ingest and reconstruction modules.

<Graph>
  <Module id="Ingest Service" files={["service.ts"]}>
    Existing: pulls raw sensor scans from field devices.
  </Module>
  <Module id="Scan Validator" status="added">
    New: shared validation library. Rejects malformed or low-quality scans
    before they're persisted.
  </Module>
  <Artifact id="Raw Scans" status="added">
    New intermediate artifact. Validated scans land here instead of
    streaming straight into reconstruction.
  </Artifact>
  <Module id="Reconstruction Worker" status="modified" files={["worker.ts"]}>
    Existing, behavior changes: triggered by new `Raw Scans` entries instead
    of a direct call from `Ingest Service`.
  </Module>

  <Interface from="Ingest Service" to="Scan Validator" kind="validate_scan()" status="added" def="def-validate-scan">
    Calls `validate_scan()` before persisting.
  </Interface>
  <Interface from="Ingest Service" to="Raw Scans" kind="write" status="added">
    Writes each accepted scan.
  </Interface>
  <Interface from="Reconstruction Worker" to="Raw Scans" kind="read" status="added">
    Reads new entries instead of receiving scans directly.
  </Interface>
</Graph>

### Explicit definitions

<FunctionDef id="def-validate-scan" from="Ingest Service" to="Scan Validator" signature="function validate_scan(scan: RawScan): ValidationResult">
  <Param name="scan">The raw scan payload, before it's persisted.</Param>
  <Returns>A `ValidationResult` describing whether the scan passed.</Returns>
</FunctionDef>
````
