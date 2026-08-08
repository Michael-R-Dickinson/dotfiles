---
disable-model-invocation:
name: LargeTask
description: For how to work through large tasks, or tasks where a lot of planning went into it
tags:
  - large-task-handling
  - progress-monitoring
  - context-management
  - agentic-workflow
---
**Context Management**
With your context is highly important as you need to manage the scope and progress of this task. In this case, delegate to sub-agents for everything rather than doing anything yourself - unless describing the task is equally easy to implementing (for example when we've already planned something very specific and you have written the code in the plan)
- This includes things like testing, running builds, debugging small errors - these should all be done by sub-agents
- Even exploring in the codebase and examining outputs should be done by sub-agents who can view the scope of outputs and synthesize the results compactly so you can spend an absolutely minimal amount of your context window for each step/iteration of the task. 
**Guidelines**
- You must be careful to not stall: 
	- sometime sub-agents will create monitors which never return
	- sometimes they will cause OOMs
	- You must be resilient to all of these over long periods of time - for example making sure that when dispatching sub agents you have something set to ping you after long enough that the agent should definitely have finished - so you can check on the progress in case its stalled
- If the tasks the agents are running are likely to take upwards of an hour: You should set up a system to ping you every hour to check on the running agent - just a quick peek to ensure it hasn't stalled is enough.
- If the subagents are running computationally expensive tasks: Make sure subagents keep an eye on system vitals and ensure we don't damage/overstress the system