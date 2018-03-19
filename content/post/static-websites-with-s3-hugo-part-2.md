---
title: Static Websites with S3 and Hugo, Part 2
date: 2018-03-18
categories:
  - Guides
tags:
  - aws
  - s3
  - hugo
  - docker
showSocial: false
comments: false
---

I don't often go to meetups, but when I do... I get inspired to practice Continuous Adventure (CA), this time with Makefile, Docker, and Hugo.
<!--more-->

In the first part of this series, I discussed how to [build a static website hosted on AWS Simple Storage Service (S3) with Terraform](static-websites-with-s3-hugo-part-1).
In this part, I will explain how I build and deploy my website, with a little help from Docker.

When I first started using Hugo, I installed it on my laptop with Homebrew:

```
brew install hugo
```

In between updates to the website, I would forget the exact syntax to start Hugo's built-in web server. Was it `hugo server` or `hugo --server`? I would also scratch my head and search through command history to locate the relevant AWS commands to deploy the updates to S3.

Fortunately, I was inspired by a [talk by Carolyn Van Slyck](http://carolynvanslyck.com/talk/docker/go/#/) about using Docker for Go projects. After studying https://github.com/carolynvs/carolynvanslyck.com/blob/source/Makefile I came up with a way to both document the build and deploy process, and then automate it down to two easy to remember commands.

## Prerequisites

1. Make :) sure you can run `make` on your computer. It's been a while since I have done this, but my understanding is that if you type `make` into the Terminal on a Mac, you will get prompted to [install Command Line Tools](http://railsapps.github.io/xcode-command-line-tools.html) if they aren't already installed.
2. [Install Docker](https://www.docker.com/community-edition).

That's it. You do not have to install Hugo at all. Hugo will be installed and run in a container.

Let's step through the two files needed for this, `Dockerfile` which defines the container image, and `Makefile` which abstracts all the commands needed to run a local Hugo site, and then to deploy updated files to S3.

## Dockerfile

A Dockerfile is a recipe for the container image. It defines what software I want installed and running in the container.

In [my Dockerfile](https://github.com/alimac/alimac.io/blob/master/Dockerfile), I specify that I want the image to be based on Ubuntu 17.10.1 (Artful Aardvark):

```
FROM ubuntu:artful
```

At image build time, Docker will expect two arguments to be provided: `HUGO`, with the value of Hugo version, and `WEB_DIR` with the value of the web directory where the static site project will be stored:
```
ARG HUGO

ARG WEB_DIR
```

I update the package cache and install `curl` so that I can download Hugo:
```
RUN apt-get -qq update && apt-get -qq install curl
```

Initially, I installed Hugo with `apt-get` but found that the package was a few versions behind. To get the latest version, I download the package directly:
```
RUN curl -s -L https://github.com/gohugoio/hugo/releases/download/v${HUGO}/hugo_${HUGO}_Linux-64bit.deb -o hugo.deb
```

The `-s` (or `--silent`) flag hides the `curl` command's download progress meter. The `-L` flag tells `curl` to follow any redirects that GitHub will throw at it, in other to download the file. With `-o` we set a nice short filename.

Install Hugo:
```
RUN dpkg -i hugo.deb
```

Create a web directory, and set the current directory to its path:
```
RUN mkdir -p $WEB_DIR

WORKDIR $WEB_DIR
```

That's it! Pretty straightforward. Let's inspect the Makefile to see how the Dockerfile gets used.

## Makefile

I used to use Makefiles a long time ago, but I forgot a lot of the syntax, so I needed a little refresher. [This tutorial](https://gist.github.com/isaacs/62a2d1825d04437c6f08) is a great way to get acquainted with Makefiles.

It is itself a Makefile that you can read and uncomment to try out the features as you learn the concepts. Super neat.

### Variables

In the first part of [my Makefile](https://github.com/alimac/alimac.io/blob/master/Makefile), I set  variables.

`WEBSITE` will dictate what the image and container name will be. It will also be used to form the web directory name:

```
WEBSITE=alimac.io
```

My S3 bucket name:

```
S3_BUCKET=$(WEBSITE)
```

After uploading new content, I will invalidate the CloudFront cache. For this, I need to look up the ID of the CloudFront distribution that corresponds to my website:

```
DISTRIBUTION_ID=$(shell aws cloudfront list-distributions \
  --query 'DistributionList.Items[].{id:Id,a:Aliases.Items}[?contains(a,`$(WEBSITE)`)].id' \
  --output text)
```

Let's look at this even closer. To get the ID, we run the AWS command line tool.

`aws cloudfront list-distributions` will list _all_ of my CloudFront distributions. I use a [JMESPath query](http://jmespath.org/) to narrow down the results.

The first part of the query filters the output to only include the distribution ID and the list of aliases associated with that distribution. I assign `id` and `a` so that I can refer to these attributes later:

```
DistributionList.Items[].{id:Id,a:Aliases.Items}
```

The second part of the query filters the list of results to only the distribution whose aliases contain `alimac.io`:

```
[?contains(a,`$(WEBSITE)`)].id
```

`--output text` renders the output in plain text instead of JSON, so that it can be assigned to `DISTRIBUTION_ID`.

I had previously used slightly [different query syntax](https://github.com/alimac/alimac.io/blob/78189ad6689d253144a7d21e348beb2479204463/Makefile#L11), which was buggy, but happened to yield the expected value since it was first in the list of results. I discovered and fixed this bug while writing this post :)

Why not hard-code your distribution ID and call it a day? I could do that, but this makes the Makefile more flexible (and I got to learn some new JMESPath tricks).

The last variable is the version of Hugo that I want to download and install. I want to get the latest and greatest *and* I want to get the version number dynamically:

```
HUGO_VERSION=$(shell curl -Is https://github.com/gohugoio/hugo/releases/latest \
	| grep -F Location \
	| sed -E 's/.*tag\/v(.*)/\1/g;')
```

On GitHub, `/releases/latest` for a project will redirect to the latest release. For example: `/releases/tag/v0.37.1` (the latest Hugo release at the time of this writing).

`curl -I` will return the HTTP response headers. When piping output to another command, `curl` will show a progress meter, so I use `-s` to supress it.

`grep` filters the output to only the header I am interested in: `Location`. `-F` flag makes the search faster (see: [grep --fixed-strings](https://www.safaribooksonline.com/library/view/grep-pocket-reference/9780596157005/ch01s07.html)).

`sed` (stream editor) is a useful tool that allows me to seek out only the final portion of the URL (`0.37.1`) with a regular expression. The expression looks for the pattern `tag/v`, and replaces the whole string with only the bits that comes after `tag/v`:
```
sed -E 's/.*tag\/v(.*)/\1/g;'
```

### Building the image

In addition to variables, Makefile has a list of targets, or actions to take. The first target, `build`, builds the image using `docker build` command, passing Hugo version and web directroy name as arguments:

```
build:
    docker build -t $(WEBSITE) . \
        --build-arg HUGO=$(HUGO_VERSION) \
        --build-arg WEB_DIR=/tmp/$(WEBSITE)
```

This is the same as running:

```
docker build -t alimac.io --build-arg HUGO=0.37.1 --build-arg WEB_DIR=/tmp/alimac.io
```

### Serving the site

Let's look at the next two targets, `default` and `serve`.

When running `make` without any arguments, the default target is to serve the site. This is the same as `make serve`.

`serve` depends on the `build` target, so it lists it as a dependency:

```
serve: build
```

The next command looks up the ID of any container (running or not) with the image tagged `alimac.io`, and disposes of it:

```
-docker ps --filter="name=$(WEBSITE)" -aq | xargs -n1 docker rm -f
```

In Makefile language, putting a dash in front of a command means that we want to ignore any error output. The first time I run `make` this command would error out because the container doesn't exist yet.

`-a` flag outputs _all_ containers, while `-q` (quiet) limits the output to container ID only.

The output is piped to `xargs` which passes the list of IDs one by one to `docker rm -f` to delete the container(s).

Try running `ls | xargs -n1 file` so see how this works.

The next command starts a new container to serve the site:

```
docker run -d \
    --volume `pwd`:/tmp/$(WEBSITE) \
    --publish 1313:1313 \
    --name $(WEBSITE) \
    $(WEBSITE) \
    hugo server --bind 0.0.0.0
```

With `-d` I tell Docker to run the container in daemon mode (rather than tying up the Terminal).

The next option `--volume` mounts the current directory on my computer (which contains website files) inside the container at `/tmp/alimac.io`.

My computer's port 1313 is mapped to the container's port 1313 (Hugo's default port).

The container is given a name that is the same as the image (`alimac.io`).

Finally, Hugo's built-in server is started and binds to `0.0.0.0`. This last bit is important! By default, Hugo binds to `127.0.0.1`, and the website will not work. I keep having to re-learn this ;)

### Editing content

This is an optional target.

```
edit:
    open http://localhost:1313
    code-insiders .
```

For convenience, running `make edit` will:

1. open http://localhost:1313 in the default browser
2. open the current directory in my usual editor, [Visual Studio Code Insiders
](https://code.visualstudio.com/insiders/)

At this point, there's nothing left to do but create and edit content.

### Deploying changes

When I am ready to deploy the website to S3, `make deploy` makes it easy.

First, I do a sweep of directories to find and delete any `.DS_Store` files. I also delete the `public` directory:

```
deploy:
    find . -name "*.DS_Store" -type f -delete
    rm -rf public/
```

A new container is started to run the `hugo` command. Running `hugo` rebuilds HTML files from their Markdown sources, and populates `public` directory:

```
docker run --rm -it --volume `pwd`:/tmp/$(WEBSITE) $(WEBSITE) hugo
```

`--rm` flag ensures that the container will be deleted after it finishes building the site.

Next, I upload the contents from `public/` to S3:

```
aws s3 sync --acl "public-read" --sse "AES256" public/ s3://$(S3_BUCKET) --delete
```

`--acl "public-read"` sets the permissions of each uploaded file (object) to be publicly accessible.

The files are encrypted at rest thanks to `--sse "AES256"`. It's free. Encrypt all the things!

`--delete` flag will delete any files stored in S3 that are not found in `public/`.

The last step is to invalidate the CloudFront cache, so that the updated content is served right away:

```
aws cloudfront create-invalidation --distribution-id $(DISTRIBUTION_ID) --paths '/*'
```

Hugo currently does not support incremental builds (that is, it will re-render all the files instead of only the ones that have been updated). There is a [GitHub issue](https://github.com/gohugoio/hugo/issues/1643) open regarding adding support for incremental builds.

This means that each deploy will upload *all* of the HTML files (since their timestamp gets changed, `aws s3 sync` considers them updated). This is not ideal.

If Hugo supported incremental builds, then only new or updated files would be uploaded. I could then parse the output of `aws s3 sync` to create a more specific list of paths to invalidate.

At a much larger scale, this would translate to bigger costs. Since my website is small and not updated often, this is not a deal breaker. Still, I would like to find a solution for this.

### Cleaning up

Running `make clean` will stop and remove the website container.

(I also have a `clean-all` target that does broader Docker housekeeping, which is not specific to the images and containers used to build and deploy my site.)

## Summary

Now when I want to make changes to my website, I only have to remember these two commands:

1. `make`
1. `make deploy`

Sweet. What would you improve about this design? Which parts could be explained in more detail? Did you find this post useful? Ping me on Twitter [@alimacio](https://twitter.com/alimacio) to let me know.
