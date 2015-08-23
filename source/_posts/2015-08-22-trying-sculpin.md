---
title: Trying Sculpin
date: 2015-08-22
header: /images/2015-08-22-trying-sculpin/sculpin.jpg
tags:
  - php
  - static site generator
  - sculpin
tagline: Goodbye, Middleman. Hello, Sculpin.
---

The first static site generator I worked with was [Middleman](http://www.middlemanapp.com).
I was inspired by Julie Pagano’s
[Site Redesign Using Middleman](http://juliepagano.com/blog/2013/11/10/site-redesign-using-middleman/).
I will always be grateful to Julie for making the repository public at the time.
It was a fantastic resource, and I ended up making my very first pull request.

I was first introduced to [Sculpin](http://sculpin.io) by Ashley Cyborski’s
[Fish Sticks: A Designer’s Adventure with Twig and Sculpin](http://2014.midcamp.org/session/fish-sticks-designers-adventure-twig-and-sculpin) session at the very first [MidCamp](http://midcamp.org) (Midwest Drupal Camp).
And recently I attended Karl Kedrovsky’s [Sculpin and Drupal](http://2015.drupalcorn.org/sessions/sculpin-and-drupal)
session at DrupalCorn.

Middleman has a robust ecosystem, good documentation and a number of useful
[extensions](https://directory.middlemanapp.com/#/extensions/all/).
When I first looked at Sculpin’s [documentation](https://sculpin.io/documentation/)
I did not feel very confident about migrating my site.

## Why switch?

My motivation was centered around three goals:

1. I want to learn Twig (which reminds me of [Template Toolkit](http://www.template-toolkit.org/))
1. I want to learn Symfony
1. I want to get more comfortable with object oriented PHP

And since I like to one-up my challenges, I also decided to switch from using
GitHub Pages to AWS S3 hosting.

<blockquote class="twitter-tweet" lang="en">
  <p lang="en" dir="ltr">
    did everything i could possibly do wrong when setting up my s3 bucket last
    night. but it works now</p>&mdash; alimac (@czaroxiejka)
  <a href="https://twitter.com/czaroxiejka/status/629271662270152704">
    August 6, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

After making a couple of missteps (created a bucket
in the wrong region, waiting for DNS changes to take effect is like watching
paint dry, `brew install s3cmd`) I finally got comfortable with publishing a
barebones Sculpin-generated site to S3.

## Learn by doing

Dissection is one of my favorite methods of learning. It is not the easiest
path to proficiency, but exploring site source and pairing it with documentation
is often the quickest way to orient oneself around a new technology.

My next step, then, was to find existing Sculpin sites and study them.
I chose Beau Simensen’s [beau.io](https://github.com/simensen/beau.io/) and
Gabriela D’Ávila’s [gabriela.io](https://github.com/gabidavila/gabriela.io)
as my dissection subjects.

The idea to use [Clean Blog](http://startbootstrap.com/template-overviews/clean-blog/)
theme came from Etiene Dalcol’s [etiene.net](http://etiene.net) site.

I created a very simple favicon image (letter _A_ in a red circle) and used
[Real Favicon Generator](http://realfavicongenerator.net/) to generate a spiffy
cross-platform favicon set.

**Tip**: If you are building a blog, the [Sculpin Blog Skeleton](https://github.com/sculpin/sculpin-blog-skeleton)
is a good template to reference. I first created my own content type, only to
run into problems later, when I tried to add tagging. Using the default _posts_
content type solved the tag index problem for me.

## To be continued...

There are still some mysteries for me to resolve:

1. **Markdown tables** [don’t render]({{site.url}}/writes/open-source-survival-guide-with-coraline-ada-ehmke/#open-source).
With Middleman, I used the `kramdown` gem to render Markdown tables.
1. **Tag paths**. How do I make tags like [Drupal Planet]({{site.url}}/tag/Drupal%20Planet.xml)
to use lowercase paths with dashes?
1. **Aliases**. `middleman-alias` gem allows you to create redirects. They are `meta-refresh` redirects, but still useful if you decide to change your site’s URL structure.
1. **[Generators](https://sculpin.io/documentation/generators/)**. How do I build my own?
1. **[Extending Sculpin](https://sculpin.io/documentation/extending-sculpin)**. What kind of bundle can I build?
