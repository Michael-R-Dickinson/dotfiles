---
name: visualize-base
description: >-
  Shared output contract for visual-plan and visual-diff — not invoked
  directly. Defines the four-section document scaffold, the MDX component
  library, and the authoring rules both skills write against.
---

# visualize-base

This skill is never invoked on its own. `visual-plan` and `visual-diff` each
read this file plus its two reference docs before writing anything, so the
rules below live in one place instead of being duplicated and drifting.

Read, in order, before authoring a doc:

1. This file (the principles).
2. `references/output-structure.md` — the four-section scaffold and the
   graph-sizing rules.
3. `references/component-library.md` — the MDX component vocabulary, props,
   and the diff-status / `files` conventions.

## What these docs are for

A visual-plan or visual-diff doc answers **"what talks to what, and what
changed about that"** — never "how does this function work internally."
A reader opens the doc to build a mental model of the *shape* of a system or
a change to it. Implementation detail earns at most a collapsed code
snippet, and only when it clarifies something non-obvious about the
structure — never the main content.

If you find yourself explaining algorithm internals, control flow inside a
single function, or line-by-line logic, that content does not belong in the
doc at all — structural docs are not a substitute for reading the code.

## Core concepts

Full definitions are in `PROJECT.md` §1 of this tool's own repo; the
practical judgment calls are below.

- **Module** — a semi-independent section of code with a clear domain and a
  well-scoped set of concerns/data.
- **Interface** — how modules connect: a function/method call, an API call,
  or the read/write of an artifact.
- **Artifact** — a semi-permanent thing a module produces and saves (a file,
  a database row, a trained model, a rendered output) that a *different*
  read happens against later, not immediately in the same call.

**The judgment call that matters most is module boundaries.** There's no
formula for this — apply the underlying test: *would drawing the connection
between these two pieces of code be unambiguous?* If two files always change
together and share the same concern, they're one module, even if they're in
separate files (that's what `files` on a single `<Module>` is for — see the
component library doc). If a single file serves two distinct concerns that
other code depends on independently, it can be two modules that happen to
share a file.

Worked examples of the ambiguous cases:

- A validation function called synchronously from inside another module,
  with no independent callers and no state of its own — usually *not* its
  own module. Fold it into the caller's module, or represent the call
  informally in prose rather than adding a node for it.
- A "shared validation library" called from several unrelated modules,
  versioned and evolved independently — *is* its own module, because it has
  independent callers and its own boundary of concern (see `Scan Validator`
  in the worked examples in `visual-plan`/`visual-diff`).
- A row written to a table now and read by a completely different process
  later (e.g. a queue, a job, a different service) — an **artifact**, not an
  interface directly between the writer and reader. Model it as
  writer → artifact → reader (two edges through the artifact node), because
  that's what actually couples the two sides: the durable shape of the data,
  not a direct call.
- A row read back synchronously in the same request/transaction that wrote
  it (e.g. a DB write immediately followed by a read to confirm) is usually
  not worth modeling as a separate artifact node — it's internal to the
  module that owns the transaction.

When genuinely unsure whether something is a module or should just be prose
inside a neighboring module's description, prefer the simpler doc: don't add
a node unless it clarifies a connection a reader would otherwise miss.

## Doc size follows change size

A doc's size should track the size of what it describes, not a fixed
template. Fill in only the sections that earn their place:

- A one-interface change can be an Overview paragraph, one small `<Graph>`,
  and nothing else — no Key Changes bullets, no Implementation Details, no
  explicit definitions unless the interface itself is non-obvious. This
  should read like something you'd type directly into a chat message, just
  with the added richness of a diagram if one clarifies the change.
- A multi-subsystem change earns the full four-section scaffold, multiple
  graphs, and explicit definitions for anything a reader would otherwise
  have to go read the code to understand.

Never pad a small doc to make it look more thorough, and never compress a
genuinely multi-subsystem change into one crowded graph to keep the doc
short — see `references/output-structure.md` for how graphs split instead.
