---
disable-model-invocation: true
name: MonsterPrompt
tags:
  - multi-agent-systems
  - task-delegation
  - agent-orchestration
  - debugging-workflow
---
## Task
Investigate and debug this issue by sending sub-agents with well described tasks, for both brainstorming fixes, applying them, and testing. Proceed until successful.
Make sure sub-agents prioritize applying and testing fixes quickly, which means, avoiding long running tasks if possible. 
## Guidelines
1. This is a large task, so you will be primarily an orchestrator - not making changes or testing on your own, but delegating to sub-agents. This is a hard rule: no doing things yourself. Your only job is to dispatch sub agents, and report things back to me. 
2. Take a cursory look and ask any questions you have before proceeding with debugging
3. You can instruct sub agents with full freedom. They may exec into the containers, run commands, rebuild, create and analyze visualizations, etc.
4. Avoid just tuning paramaters to the test datasets, instead step back and investigate the root causes for issues. Don't tunnel vision on tiny param changes, and instead look for holistic solutions that will generalize.
5. Aim to give sub-agents quick-ish tasks and record their progress incrementally in markdown docs so we can recover what they did if necessary. 
6. Sub-agents may test with scripts or any method you'd like, but the final outputs to evaluate on and present to me should come from a standardized consistent pipeline I can easily run - so not a modified copy of a docker container or a long stack of commands; it should be a clean and easily reproducible output. 
7. Feel free to send agents with a variety of tests to see how different solutions or approaches do.
8. Sometimes sub-agents will stall by failing to notice when a task has finished or various other reasons, when dispatching sub-agents, set a wakeup timer for you to check on the agent if it hasn't finished - the timer should give lots of headroom over how long the agent's task should likely take - this is just a guard so the whole process doesn't stall.