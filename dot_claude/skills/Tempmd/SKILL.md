---
disable-model-invocation: true
name: tempmd
description: output to a temp.md file
---
Give an extremely brief summary of your response in the chat. Then write your full response to a `<repo_root>/temp.md` file
- It should not be any longer than your normal response simply because you're writing to a file. Its only purpose is better readability for the user. 
- Make sure that this file is not tracked. Add it to `.git/info/exclude` if its not already