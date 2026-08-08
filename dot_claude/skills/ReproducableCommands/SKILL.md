---
name: ReproducibleCommands
description: Guidelines for creating reproducible workflows after you finish prototyping
when_to_use: When you've finished scratchpad style experiments and you have a result I should be able to reproduce
tags:
  - reproducible-workflows
  - cli-design
  - bash-scripting
  - dev-workflow
---
Experiments may begin in notebooks, scratchpads, shell history, or temporary scripts. Once a valid result is found, convert it into a reproducible command-line workflow.

## Requirements

1. **Preserve the successful result**
    - Record the exact inputs, configuration, environment assumptions, and command sequence that produced it.
    - Avoid leaving required steps only in shell history, notebook state, or undocumented manual actions.
2. **Create a clear CLI**
    - Expose meaningful inputs as named arguments.
    - Use consistent, descriptive argument names.
    - Prefer explicit paths and options over hidden global state.
    - Validate inputs and provide useful error messages.
3. **Choose reproducible defaults**
    - Defaults should usually reproduce the validated result.
    - Do not use machine-specific paths, temporary files, or unstable values as defaults.
    - Clearly document any required arguments or environment variables.
4. **Document the workflow**
    - Ensure `--help` explains each argument, its default, and expected format.
    - Include at least one copy-pasteable command that reproduces the known result.
    - Document setup steps, dependencies, outputs, and important assumptions.
5. **Add Navi commands**
    - Add or update the appropriate `.cheat` files.
    - Include the canonical reproducibility command.
    - Provide Navi variables for commonly changed arguments so autocomplete is useful.
    - Keep Navi examples synchronized with the actual CLI and its defaults.
## Completion Criteria
A workflow is complete when a user can:
- discover it through Navi,
- understand it through `--help`,
- run it without reconstructing hidden context,
- and reproduce the validated result using the documented default command.