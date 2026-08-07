# Output structure

Every doc follows the same four-section scaffold, in order. Within a
section, write ordinary MDX — prose, headings, lists, and components from
`component-library.md` — in whatever order and quantity fits the specific
change. Nothing below the section level is fixed. Skip a section entirely
if it has nothing to say (see "Doc size follows change size" in
`../SKILL.md`).

## 1. Overview

What this plan/diff is, in a few sentences. State the outcome, not a list of
files touched.

## 2. Key changes

A prose/bullet summary of the notable decisions or changes, above the level
of any single interface. This is where you explain *why*, not just *what* —
the graphs in the next section show what changed structurally; this section
explains the decisions behind it.

## 3. Structural changes

The modules/interfaces/artifacts involved, as one or more graphs. **This is
the section readers spend the most time in** — get the graph-splitting,
captions, and removals right before anything else in the doc.

### Caption every graph

Never drop a bare `<Graph>` into the doc. Every graph gets a short prose
caption — one or two sentences right above it — stating what it shows:
which subsystem or slice of the change it's zoomed into, whether it's the
overview or a detail view, and the overall shape of what changed. This is
in addition to, not instead of, brief prose per notable change within the
graph. A reader should know what they're about to look at before they start
parsing nodes and edges, not have to reverse-engineer it from the diagram.

### Graph sizing

- **There is no node-count limit on any graph, small or large.** A small
  graph zooms into one subsystem or one piece of the change — a handful of
  nodes (2-4 is typical) is normal, but that's a description of what a
  focused graph tends to look like, not a floor to pad toward or a ceiling
  to trim toward. Include exactly the nodes the piece you're articulating
  needs. A small graph's job is to show *that* pipeline or subsystem
  clearly, never the whole system for completeness's sake — it's fine, and
  expected, for most of the codebase to be absent from it. Don't drop a
  node that's part of the real structural seam just to hit a target count,
  and don't add unrelated nodes just to look thorough. Including a node
  that didn't change (status unset) is fine when it gives a reader context
  they need to place the change — e.g. showing the existing module a new
  one now calls into.
- **One overview graph at most, and only when it earns its place.** If the
  change touches multiple distinct subsystems or areas that each deserve
  their own zoomed-in graph, add exactly one overview graph *first*,
  before the per-subsystem graphs. Like the small graphs, it has no
  node-count limit — it's showing the whole shape of the change, sized to
  however many subsystems that actually spans — and its nodes don't need
  full hover descriptions since the per-subsystem graphs below cover that
  detail. If the change only touches one subsystem, skip the overview
  entirely: go straight to the one small graph.
- **Never more than one "big" graph per doc.** If you're tempted to add a
  second large graph, that's a sign the doc should split into more small
  per-subsystem graphs instead.

Decide the split by asking: *would a reader need to scroll/pan a lot to see
the whole thing, or hold more than ~4 nodes' relationships in their head at
once?* If yes, split it into more, smaller graphs — don't trim nodes to
force a smaller graph to fit a count. A graph earns its size from what it's
explaining, not from hitting a target number.

### Removed modules keep their old edges

When a `<Module>` or `<Artifact>` is marked `status="removed"`, also include
the `<Interface>` edges it had before removal (also `status="removed"`)
rather than leaving it floating with no connections. A disconnected removed
node only tells a reader "this went away"; a removed node with its old edges
still attached shows *what it was wired into* — which is almost always the
more useful fact, especially when a new node/edge elsewhere now fills that
role. This is what makes it clear what's being replaced, not just what's
gone. Only applies to `visual-diff` — `visual-plan` has no "before" to show
removals against.

### Status and files

Set `status` on every `<Module>`, `<Artifact>`, and `<Interface>` that
changed between the two sides (unset = unchanged/context-only). Set `files`
on every `<Module>`, `<Artifact>`, and `<Interface>` so a reader knows which
file(s) it lives in — filename only, not the full path; never invent one,
only use files you've actually read or confirmed exist. Full syntax in
`component-library.md`.

## 4. Implementation details

Important *low-level* pieces worth calling out — not structural, and
intentionally secondary. Use prose, LaTeX where math clarifies something,
and collapsed-by-default code panels for small snippets. This section
exists for the reader who wants to go one level deeper, not as the doc's
main content. Most small docs should skip this section entirely.
