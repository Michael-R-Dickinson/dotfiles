---
disable-model-invocation: null
name: Arguments
description: Info on naming and organizing CLI Args
tags:
  - argument-parsing
  - scripting-conventions
  - cli-design
  - code-documentation
---
When writing scripts that interact with multiple different mostly separate models, prefix any arguments for these models with their name, ie orb-slam-config-path
Aim to give most arguments defaults, especially when they're obvious. Add docstrings that include both a minimal usage, with as few arguments as possible (just enough to specify the necessary things), and one that includes more arguments as examples.

If the number of CLI args exceeds 10, reorganize them into a separate argparse (or multiple) files. Argument groups to make them clear and make sure the --help has readable descriptions.