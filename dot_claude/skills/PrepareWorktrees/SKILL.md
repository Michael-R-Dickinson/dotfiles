---
disable-model-invocation: true
name: PrepareWorktrees
description: Write a script allowing us to develop in multiple worktrees simultaneously
tags:
  - git-worktrees
  - dev-environment-automation
  - bash-scripting
  - docker-compose-config
---
Write a bash or python script called init_worktree that can be run inside a worktree to set it up with everything necessary for development. 
This should copy/symlink over necessary files, install dependencies, etc.

You may modify docker composes such that they can run independently in different worktrees. If scripts reference specific containers, you may modify them to get the correct running container for the worktree. 

You'll want to ask me questions if there are ambiguities. Examples:
- whether to create separate docker containers, or images, etc
- whether to copy or symlink (only ask if theres a legitimate reason to copy over symlink)
- what dirs/files to link/copy if there are any ambiguities