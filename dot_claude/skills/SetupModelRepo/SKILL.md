---
disable-model-invocation: true
name: SetupModelRepo
description: Sets up a repo that involves a ML model and runs a smoke test
tags:
  - repository-setup
  - model-inference
  - machine-learning
  - environment-setup
---
Can you get this project up and running. Install dependencies and smoke test it, etc.

Guidelines
- If you need model weights, and they're linked in the readme, download them if possible
- Make sure you don't affect anything global on the system. Stay local - conda (with --prefix) or virtual envs, no changes to cuda etc. 
- You may not take up >50GB storage, so keep this in mind to avoid generating enormous mask directories or that sort of thing
- If the 50 series card raises issues, make a minimal attempt to get past this (update torch if the version increase is small and won't break things) etc.
	- If the minimal attempt is unsuccessful report back and we'll decide how to proceed
- Save the outputs of the model such as the videos to an outputs/ dir
- Be careful to not OOM - smaller/reasonable number of parallel jobs, etc. 

After a successful smoke test, run fully on the whole dataset and report back a few things:
- Artifacts from the model's inference in a format that is easy for me to interpret 
	- for image models, output images are great; for segmentations models - segmentations overlayed on images, etc. essentially some way for me to visually or easily validate the results
	- If the results are from a video - aim to output a video as well if possible (generally just the output images strung together into video form)
- Performance metrics:
	- fps (if its an image model) or equivalent for whatever the model's output format format
	- VRAM usage

Begin by checking if any datasets are available or linked in in the readme, and asking me if I have any data and displaying any data options you found.