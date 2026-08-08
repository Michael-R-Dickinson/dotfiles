---
disable-model-invocation: true
name: SetupRepoWithDocker
tags:
  - docker-compose-config
  - cuda-environment
  - docker-configuration
  - environment-setup
---
### Instructions
Investigate the repo for setup instructions and environment info, and then create and iterate on a dockerfile and docker-compose to run the project.
- This includes setting up the correct cuda and python dependencies and moving in the required datasets (which should be available in this directory).
- You should test that the setup is correct by running through the processing steps in the readme: training the scene, creating the SAM masks and training the affinity features. 
### Guidelines:
**Docker**
- Avoid rebuilds as much as possible. Instead exec into the container and continue working on intsalation, apply fixes along the way etc. Then after making significant progress, edit the dockerfile and rebuild. The goal is to minimize the number of long rebuilds necessary and focus on finding solutions to problems early.
- Avoid training on many iterations if possible. Your task is to get things working quickly, so avoid waiting for longer optimizations than is necessary to confirm that things are working. 
- Aim to structure the docker compose to enable effective layer caching. When adding layers ensure that they are placed correctly such that they don't require rebuilding of heavy layers unnecessarily/frequently
- You may use the full suite of docker tools: running builds, docker exec into containers for debugging, etc.
- Use docker compose for running the container so it is easily repeatable
- You may already have a dockerfile to start with so begin with this as it has already made significant progress. 
- Be careful to not OOM - smaller/reasonable number of parallel jobs, etc. 

**Quality**
- Aim to use as much downsampling as possible (using the available args, we don't want to spend too much time or potentially introduce issues by adding our own downsampling)

**Errors**
- If you run into an out-of-memory error, ideally see if you can continue working through this and proceed to the next steps - we don't need a full successful training, but we do need confirmation that the environment and setup is correct. If its not possible to continue to the next step without fixing the memory error, raise to me.
- Raise to me if you're missing some data, datasets or important files. Its okay to end early and report back if you are blocked or hitting a dead end. Favor reporting back and evaluating other paths over digging yourself into a hole.

**General**
- Pipe outputs of processes likely to be long running to log files. Make sure to say where the log file will be *before* running the command so I know where to look for it. This should also make it easier for you to search the outputs of your commands.
- Use sub-agents to read full build outputs to avoid filling up your context window. Ideally minimize this too though, by running builds asynchronously as you continue working then dispatching sub-agents to simply read the logs after the build finishes.
- Commit frequently
