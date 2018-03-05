FROM ubuntu:artful

ARG HUGO

ARG WEB_DIR

# https://stackoverflow.com/questions/27273412/cannot-install-packages-inside-docker-ubuntu-image
RUN apt-get -qq update && apt-get -qq install curl

# hugo version available with apt-get is out of date
RUN curl -s -L https://github.com/gohugoio/hugo/releases/download/v${HUGO}/hugo_${HUGO}_Linux-64bit.deb -o hugo.deb

# install hugo
RUN dpkg -i hugo.deb

# create website dir
RUN mkdir -p $WEB_DIR

WORKDIR $WEB_DIR

# Why doesn't this work? 🤔
#CMD ["/usr/local/bin/hugo server --watch --bind 0.0.0.0"]
