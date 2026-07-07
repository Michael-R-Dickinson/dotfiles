---
name: Docker
description: Instructions for working with docker in any way beyond simply running containers
---
- You may use the full suite of docker tools: running builds, docker exec into containers for debugging, etc.
- Avoid rebuilds as much as possible. Instead exec into containers and continue working/debugging + apply fixes along the way etc. Then after making significant progress, you may edit the dockerfile and rebuild - then make sure to test again in the fresh container. The goal is to minimize the number of long rebuilds necessary and focus on finding solutions to problems early.
- Avoid training on many iterations if possible unless instructed otherwise. Your task is to get things working quickly, so avoid waiting for longer optimizations than is necessary to confirm that things are working.
- Aim to structure the docker compose to enable effective layer caching. When adding layers ensure that they are placed correctly such that they don't require rebuilding of heavy layers unnecessarily/frequently
- Use docker compose for running/creating containers so it is easily repeatable