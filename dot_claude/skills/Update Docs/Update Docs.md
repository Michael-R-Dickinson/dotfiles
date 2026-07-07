---
name: Update Docs/Claude.md
description: How to update docs/claude.md files
when_to_use: Whenever updating or proposing to update the docs/claude md files
---
## Scope: 
- With directory specific info, create a CLAUDE.md in that directory with the specific knowledge for working in it - AND if warranted, update the root CLAUDE.md with very brief information about the module so it knows when to investigate in that directory and read the more specific file
- If you're doing a scoped investigation of an issue or bug - this is not the time to update the CLAUDE.md. progress information about debugging or fixes should be written in separate, task specific, markdown docs. 
## Guidelines
- Focus on recording the most reusable pieces of information you, or sub-agents discover.
- Focus intently on keeping CLAUDE.md files minimal so they only contain information that is relevant to anyone working in that directory.
	- CLAUDE.md files should always be < 200 lines long - not a hard rule but a strong guideline
	- We want CLAUDE.md files to consist of very relevant, high-level information about a module AND additionally serve as an index to other more detailed docs for specific things. 
	- You may always when updating docs: 
		- Clean up the CLAUDE.md files by making things more concise
		- Move information to docs inside the appropriate docs/ dir and link to these docs inside the CLAUDE.md
		- Clean up docs in the docs/ dir - deleting old docs or references to old stuff is okay
- Docs should always be concise and brief whether in the CLAUDE.md files or in docs/ dirs
- Docs should always contain up to date information - we want to avoid information about old versions of the system or history of how it got there - unless its directly relevant to maintaining it
	- you may delete and trim docs to be most relevant - always aim for high-signal