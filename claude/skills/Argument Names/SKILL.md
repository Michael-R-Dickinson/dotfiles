---
disable-model-invocation:
name: Argument Names
description: Info on naming CLI Args
---
When writing scripts that interact with multiple different mostly separate models, prefix any arguments for these models with their name, ie orb-slam-config-path
Aim to give most arguments defaults, especially when they're obvious. Add docstrings that include both a minimal usage, with as few arguments as possible (just enough to specify the necessary things), and one that includes more arguments as examples.