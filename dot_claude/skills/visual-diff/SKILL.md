---
name: visual-diff
description: >-
  Turn a git commit range into a structural MDX doc — modules, interfaces,
  and artifacts added/removed/modified. Use when the user asks to visualize,
  diagram, or explain the structural shape of a code change, a branch, or a
  PR, as opposed to reading a raw line diff.
---

# visual-diff

Produces an MDX doc showing how a change's *structure* differs from before —
modules added/removed/reshaped, interfaces added/removed/redirected,
artifacts newly produced or consumed. Driven by `git diff` plus reading the
current file contents to interpret what the diff *means* structurally — this
is never a raw line diff dressed up in components.

## Before you write anything

Read, in this order:

1. `../visualize-base/SKILL.md`
2. `../visualize-base/references/output-structure.md`
3. `../visualize-base/references/component-library.md`

Those three define the doc scaffold, the graph-sizing rules, and the exact
component props. Do not author from memory of a previous run.

## Procedure

1. **Determine the git range.** Default: working tree vs. the merge-base
   with the main branch (covers staged, unstaged, and committed-on-this-
   branch changes together) — this matches what a reader means by "what did
   I change." If the user names an explicit range (two commits, a branch
   name, a PR), use that instead. **If the default range is empty** (clean
   working tree and current branch already at the merge-base — nothing to
   diff), don't produce an empty or fabricated doc: ask the user which range
   they meant.

2. **Look at what changed.** Run `git diff` (and `git diff --stat` for an
   overview) over the resolved range to see which files changed and how
   much.

3. **Read for structure, not lines.** Open the current contents of changed
   files — and any unchanged files they connect to — to understand what the
   diff *means*: a changed function signature is only interesting if it
   changes an interface; a new file is only a new module if it has its own
   boundary of concern (see the heuristic in `visualize-base/SKILL.md`).
   Line-level changes that don't affect structure (renames, formatting,
   internal refactors with the same external shape) don't belong in the doc
   at all.

4. **Map changes onto modules/interfaces/artifacts.** For each one, decide:
   - `status="added"` — didn't exist before this range.
   - `status="removed"` — existed before, doesn't after.
   - `status="modified"` — existed before and after, but its behavior or
     shape changed in a way a reader of the *structure* should know.
   - unset — unchanged, included only as context for a changed node/edge
     next to it.

5. **Decide the graph structure.** Follow `output-structure.md`'s sizing
   rules: one small graph if the diff is contained to one subsystem; one
   overview graph plus small per-subsystem graphs if it spans several.

6. **Set `files`** on every node/edge to the real filenames you read in
   step 3 (filename only, not the full path — see `component-library.md`).

7. **Write the doc** following the four-section scaffold, sized to the
   diff's actual scope (see "Doc size follows change size" in
   `visualize-base/SKILL.md`) — a one-interface change doesn't need Key
   Changes bullets or an Implementation Details section just to look
   complete.

8. **Save it** to `<target-repo>/.visual-docs/diffs/<slug>.mdx`, where
   `<slug>` is a short kebab-case name describing the change (branch name is
   a reasonable default if it's descriptive). Create the directory if it
   doesn't exist.

9. **Tell the user the file path** and that they can run
   `visualize <path-to-mdx>` (from the visual-diff tool's `renderer/`, or via
   the installed `visualize` bin) to view it as an interactive doc.

## Entrypoint changes

Only relevant if the diff changes how a module or the system is actually
run, built, or invoked — a new CLI flag, a new/changed `npm` script or build
command, a new way to start a service. Most diffs don't touch this at all;
if nothing about how something is invoked changed, skip this section
entirely — don't force an entrypoint node into a doc that doesn't need one.

When an entrypoint is added, removed, or changed:

- Represent it using the `<Interface kind="entrypoint">` convention in
  `component-library.md` — an incoming edge from a node for the invocation
  itself into the module it enters, so it's unmistakable at a glance that
  this edge is *how the system gets started*, not an ordinary call between
  two modules.
- Set `status` the same way as everything else: `"added"` for a new flag or
  command, `"removed"` for one that's gone, `"modified"` if an existing
  entrypoint's shape changed (e.g. a required arg became optional, a script
  now takes an extra parameter).
- Keep the invocation node's `id` literal — what a reader would actually
  type or run (`` `npm run build -- --watch` ``), not a paraphrase like
  "Build with watch mode."

## Common mistakes

- **Line-diff thinking.** A 200-line diff inside one function's internals is
  structurally nothing (`modified` on one module at most, probably not even
  worth a graph); a 5-line diff that redirects a call from one module to
  another is a real structural change. Weight the doc by structural impact,
  not diff size.
- **One crowded graph** instead of an overview + small per-subsystem graphs
  when the diff spans multiple areas — see the sizing rules.
- **Marking everything `modified`** because it's technically true (the file
  changed) — only mark a node/edge `modified` if a reader of the *structure*
  needs to know its behavior changed, not for every touched file.
- **Skipping `files`** — every node and edge should let the reader jump to
  the code.
- **A bare `<Graph>` with no caption.** Every graph needs a sentence or two
  above it saying what it shows — don't make the reader parse nodes and
  edges cold to figure out what they're even looking at.
- **A removed module left disconnected.** Don't just drop a
  `status="removed"` node with no edges — include the `<Interface>`(s) it
  had before removal, also `status="removed"`, so the graph shows what it
  was replaced by, not just that it's gone.
- **Writing implementation detail as if it were structural** — an
  interesting algorithm change belongs in Implementation Details (or is
  entirely out of scope), never as the reason a module gets its own graph
  node.
- **Generic `kind` labels.** `kind="call"` or `kind="API call"` on every
  edge tells a reader nothing once a module has more than one outgoing
  edge. Name the actual function or endpoint (`kind="validate_scan()"`,
  `kind="POST /notify"`) — see `component-library.md`.

## Worked example

A diff spanning two subsystems (ingestion, and reconstruction+notification)
— big enough to earn one overview graph plus two small per-subsystem graphs,
per the sizing rules. Trimmed for brevity; a real doc would also include
`files` on every node/edge (omitted here only to keep the example short) and
explicit definitions for the two new interfaces marked `def`.

````mdx
export const frontmatter = {
  title: "Scan pipeline: split ingestion, async reconstruction notifications",
  kind: "structural diff",
};

## Overview

Splits the ingest path from reconstruction so a bad scan never reaches the
trainer, and replaces the frontend's poll loop with a push notification once
a point cloud finishes reconstructing.

## Key changes

- Introduced `Raw Scans` as a durable intermediate artifact instead of
  streaming ingested data straight into reconstruction.
- Added `Scan Validator` so malformed scans are rejected before they're
  persisted.
- Removed `Legacy Uploader` — every client now goes through `Ingest Service`.
- Replaced the frontend's poll loop with a push notification from the new
  `Notification Service`.

## Structural changes

Two subsystems changed, so this starts with one overview graph showing both,
followed by a small graph zoomed into each.

<Graph>
  <Module id="Ingest Service" />
  <Module id="Legacy Uploader" status="removed" />
  <Module id="Scan Validator" status="added" />
  <Artifact id="Raw Scans" status="added" />
  <Module id="Reconstruction Worker" status="modified" />
  <Module id="Notification Service" status="added" />
  <Module id="Web Frontend" />

  <Interface from="Ingest Service" to="Scan Validator" kind="validate_scan()" status="added" />
  <Interface from="Ingest Service" to="Raw Scans" kind="write" status="added" />
  <Interface from="Reconstruction Worker" to="Raw Scans" kind="read" status="added" />
  <Interface from="Reconstruction Worker" to="Notification Service" kind="POST /notify" status="added" />
  <Interface from="Notification Service" to="Web Frontend" kind="push" status="added" />
</Graph>

### Ingestion

Zooms into the ingest path: the new validation step and the durable
`Raw Scans` artifact it now writes to, plus the legacy upload path they
fully replace.

<Graph>
  <Module id="Ingest Service" files={["service.ts"]}>
    Pulls raw sensor scans and hands them to validation before persisting.
  </Module>
  <Module id="Scan Validator" status="added" files={["validate.ts"]}>
    New: rejects malformed or low-quality scans before they're persisted.
  </Module>
  <Artifact id="Raw Scans" status="added">
    New intermediate artifact — validated scans land here.
  </Artifact>
  <Module id="Legacy Uploader" status="removed">
    Removed: the old direct-to-store upload path.
  </Module>
  <Module id="Client">
    Any caller submitting a scan — now always goes through `Ingest Service`.
  </Module>

  <Interface from="Ingest Service" to="Scan Validator" kind="validate_scan()" status="added" def="def-validate-scan">
    Calls `validate_scan()` before persisting.
  </Interface>
  <Interface from="Ingest Service" to="Raw Scans" kind="write" status="added">
    Writes each accepted scan.
  </Interface>
  <Interface from="Client" to="Legacy Uploader" kind="POST /upload" status="removed">
    Used to upload straight to storage, with no validation step.
  </Interface>
</Graph>

### Reconstruction & notification

Zooms into what changed downstream: the worker now reacts to new `Raw Scans`
entries instead of being called directly, and pushes a completion event
instead of the frontend polling for one.

<Graph>
  <Artifact id="Raw Scans" status="added">
    Validated raw scans, read by the reconstruction worker.
  </Artifact>
  <Module id="Reconstruction Worker" status="modified" files={["worker.ts"]}>
    Now triggered by new `Raw Scans` entries instead of a direct call, and
    notifies on completion instead of the frontend polling for it.
  </Module>
  <Module id="Notification Service" status="added">
    New: fans out a push notification when reconstruction finishes.
  </Module>
  <Module id="Web Frontend">
    Browser client that renders the point cloud viewer.
  </Module>

  <Interface from="Reconstruction Worker" to="Raw Scans" kind="read" status="added">
    Reads new entries instead of receiving scans directly.
  </Interface>
  <Interface from="Reconstruction Worker" to="Notification Service" kind="POST /notify" status="added" def="def-notify">
    Posts a completion event once training finishes.
  </Interface>
  <Interface from="Notification Service" to="Web Frontend" kind="push" status="added">
    Pushes the completion event to any subscribed client.
  </Interface>
</Graph>
````

Note the overview graph's nodes have no children (no hover description) —
that detail lives on the same nodes repeated in the per-subsystem graphs
below, where it's actually useful.
