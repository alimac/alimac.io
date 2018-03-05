# alimac.io

My personal website, built with [Hugo](https://gohugo.io/) and now, Docker.

## Requirements

[Install Docker](https://docs.docker.com/install/) and `make`.

## Usage

1. Clone the GitHub repo: `git clone git@github.com:alimac/alimac.io.git`
1. `cd alimac.io`
1. Run `make` to build and run the container.

The website (http://localhost:1313) will open in a new browser tab. When you make changes to the content, the change will automatically be reflected in the browser. Amazing!

## Caveats

The theme I use (https://themes.gohugo.io/hugo-tranquilpeak-theme/) is not included in this repository.

## FAQ

### Why not run `hugo` locally?

I sure can, but I wanted to try it with Docker. I learned some new things, and reinforced previous learnings while getting this to work with Docker.

I was inspired by a [talk by Carolyn Van Slyck](http://carolynvanslyck.com/talk/docker/go/#/) and https://github.com/carolynvs/carolynvanslyck.com/blob/source/Makefile.
