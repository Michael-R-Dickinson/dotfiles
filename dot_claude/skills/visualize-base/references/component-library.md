# Component library

The renderer supplies every component below. Write plain MDX and reach for
these — never invent new components or props. Every prop shown here is real;
if you need something not listed, that's a signal to simplify the doc rather
than to guess at a prop name.

## Structural diagram

### `<Graph>`

Container for a diagram. Pannable, zoomable, auto-laid-out — never pass x/y.
Holds any number of `<Module>` / `<Artifact>` children and `<Interface>`
edges. See `output-structure.md` for how many graphs a doc should have and
how big each one should be.

```mdx
<Graph>
  <Module id="Ingest Service">...</Module>
  <Artifact id="Raw Scans">...</Artifact>
  <Interface from="Ingest Service" to="Raw Scans" kind="write">...</Interface>
</Graph>
```

**Node identity across graphs.** The same `id` used in two different
`<Graph>`s renders as the same node — reuse an `id` only when it's genuinely
the same thing shown again for context (e.g. `Raw Scans` appearing in both
an ingestion graph and a reconstruction graph in the worked example: one
artifact, same file, same meaning in both places). Give **different `id`s**
to different things or different code paths, even when they live in the
same file or the same compiled module — e.g. two distinct classes in one
native extension (`Mapper (native)` / `Localizer (native)`, not one
`native module` node reused with different `files` in each graph). If an
id's `files`, description, or status would need to differ depending on
which graph you're looking at, that's a sign it's actually two things and
needs two ids.

### `<Module id="..." status? files? >`

Rectangular node. Children (or omit for no hover text) become the hover
description — what the module does *in context*, not a general doc comment.

### `<Artifact id="..." status? files? >`

Same shape as `<Module>`, styled distinctly (dashed border) so artifacts read
as "things," not "actors."

### `<Interface from="..." to="..." kind? status? def? files? >`

Directed edge, caller → callee (or writer → artifact → reader, modeled as
two edges through the artifact node). `kind` is a short label shown on the
edge — freeform text, chosen per-edge, not a fixed vocabulary.

**Name the actual method, function, or endpoint**, not a generic category.
`kind="validate_scan()"` or `kind="POST /scans/{id}/notify"` tells a reader
something `kind="call"` or `kind="API call"` doesn't — especially once a
module has more than one outgoing edge and the labels are the only thing
distinguishing them at a glance. Pull the name straight from the code you
read (the function being called, the route being hit), not a paraphrase.

For a writer → artifact → reader pair, there's often no specific method to
point to — `kind="write"` / `kind="read"` is a fine default there. But if a
more specific verb exists and is worth surfacing (the actual write method,
a named query, an event type), use that instead. This is a per-edge
judgment call, not a rule to apply uniformly across a doc.

`kind="entrypoint"` is the one reserved exception — use that exact string
(never a paraphrase) for the boundary edges described below, so they stay
recognizable across docs.

Keep any `kind` to one or two words. Children are the one-line hover
summary. If `def` matches an explicit-definition component's `id` elsewhere
in the doc, the edge becomes clickable and scrolls there.

### Entrypoints

An entrypoint is the boundary where something *outside* the system — a
person, a script, a scheduler — invokes a module: a CLI command, a flag, an
`npm` script, a build step, a server's listen call. Represent the invocation
itself as a `<Module>` node (its `id` is the actual command or flag a reader
would type or run, not a paraphrase), connected to the module it enters with
an `<Interface kind="entrypoint">` edge:

```mdx
<Module id="`myapp --dry-run`" status="added" />
<Module id="CLI" files={["cli.ts"]} />

<Interface from="`myapp --dry-run`" to="CLI" kind="entrypoint" status="added">
  New flag: runs the full pipeline without writing output.
</Interface>
```

Use `kind="entrypoint"` exactly (not a paraphrase like `"invokes"` or
`"runs"`) so entrypoint edges read consistently across docs. Don't add an
entrypoint node for an internal call that already has a caller module —
this is only for the outermost boundary.

### Diff status

`status` on `<Module>`, `<Artifact>`, and `<Interface>` — colored the way
`git diff` colors lines, so a reader's existing instincts transfer:

| `status`     | Color   |
|--------------|---------|
| `"added"`    | green   |
| `"removed"`  | red     |
| `"modified"` | blue    |
| *(unset)*    | neutral |

`visual-diff` sets `status` on anything that changed between the two sides
of the diff and leaves it unset on anything unchanged that's shown only for
context. `visual-plan` has no "before" to diff against — leave `status`
unset by default, or mark everything `"added"` if that framing helps.

### `files` — always set on real code

`files` accepts a string array and renders as a small violet, monospace
badge — visually distinct from the green/red/blue status colors so it never
reads as a diff indicator. It's how a reader finds the code:

```mdx
<Module id="Scan Validator" status="added" files={["validate.ts", "rules.ts"]}>
  New: shared validation library...
</Module>

<Interface from="Ingest Service" to="Scan Validator" kind="validate_scan()" files={["service.ts"]}>
  Calls `validate_scan()` before persisting.
</Interface>
```

Rules:

- **Filename only, not the full path** — `validate.ts`, not
  `src/ingest/validate.ts`. The badge is for orientation, not a
  copy-pasteable path, and the directory adds noise most readers don't need.
  The one exception is `<Artifact>` nodes whose location is dynamic (a
  per-run output path, a templated table/object key — anything that isn't a
  single fixed file on disk): show whatever actually identifies it there,
  since a bare filename would be misleading or incomplete.
- If two files in the set share a name in different directories,
  disambiguate with the minimum path needed to tell them apart (e.g.
  `ingest/validate.ts` vs. `export/validate.ts`) rather than reverting to
  full paths everywhere.
- **Never invent a filename.** Only cite files you've actually opened or
  confirmed exist in the target repo. For `visual-plan`, where the module
  may not exist yet, either name the file it will live in if that's already
  decided, or omit `files` entirely rather than guess.
- Note the MDX syntax: `files={[...]}` — a JS array literal in curly braces,
  same pattern as `status={200}` on `<Response>` below. A bare string
  (`files="a.ts"`) will not work.
- One file or several are both fine; the badge truncates and shows the full
  list on hover.

## Explicit definitions

Placed near the `<Interface>` that points at them via `def`, or wherever in
the doc makes sense — not a required subsection.

### `<FunctionDef id="..." signature="..." from? to? lang? >`

Codeblock-style call signature (Shiki-highlighted, `lang` defaults to
`"ts"`). `from`/`to` render a small caller → callee label above the
signature if both are given.

```mdx
<FunctionDef id="def-validate-scan" from="Ingest Service" to="Scan Validator" signature="function validate_scan(scan: RawScan): ValidationResult">
  <Param name="scan">The raw scan payload as received from the device.</Param>
  <Returns>A `ValidationResult` describing whether the scan passed.</Returns>
</FunctionDef>
```

`<Param name="..." type? in? required?>` and `<Returns type?>` are
descriptor-only children (they render nothing themselves) — `in` is one of
`"path" | "query" | "body" | "header"`, relevant for `ApiDef` params more
than `FunctionDef` params.

### `<ApiDef id="..." method="..." path="..." from? to? >`

Swagger/OpenAPI-style panel.

```mdx
<ApiDef id="def-viewer-api" from="Web Frontend" to="Viewer API" method="GET" path="/scans/{id}/pointcloud">
  <Param name="id" in="path" type="string" required>The scan's identifier.</Param>
  <Response status={200} ok>Returns a `url`, `format`, and `pointCount`.</Response>
  <Response status={404}>The scan doesn't exist yet.</Response>
</ApiDef>
```

`<Response status={number} ok?>` — `status` must be a numeric literal in
braces, not a string. `ok` colors the status code green; omit it for error
responses (colored red).

Artifact read/write interfaces don't get a separate definition component —
what's read/written and when belongs directly on the `<Interface>` edge's
hover summary.

## Code & math

### `<CodePanel lang="..." title?>`

Collapsible, **collapsed by default**, Shiki-highlighted. Children are the
raw code as a template string. Used for small internal snippets, mainly in
Implementation Details — never as the primary content of a section.

```mdx
<CodePanel lang="python" title="validate_scan.py">{`def validate_scan(scan: RawScan) -> ValidationResult:
    ...
`}</CodePanel>
```

### LaTeX

Not a component — Obsidian-style markdown syntax, works anywhere in prose:
`$inline$` for inline math, `$$block$$` on its own line for display math. No
import, no tag needed.
