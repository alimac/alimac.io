# alimac.io

My personal website, built with [Hugo](https://gohugo.io/) and now, Docker.

## Requirements

[Install Docker](https://docs.docker.com/install/) and `make`.

## Usage

1. Clone the GitHub repo: `git clone git@github.com:alimac/alimac.io.git`
1. `cd alimac.io`
1. Run `make` to build and run the container.

The website (http://localhost:1313) will open in a new browser tab. When you make changes to the content, the change will automatically be reflected in the browser. Amazing!

## Theme

The theme I use (https://themes.gohugo.io/hugo-tranquilpeak-theme/) is not included in this repository.

To install the theme:

1. `mkdir themes` (inside the cloned repo)
1. `git clone git@github.com:kakawait/hugo-tranquilpeak-theme.git`

## Acknowledgements

I was inspired by a [talk by Carolyn Van Slyck](http://carolynvanslyck.com/talk/docker/go/#/) and https://github.com/carolynvs/carolynvanslyck.com/blob/source/Makefile.
