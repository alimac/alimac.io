---
title: "XHProf and Drupal, in two flavors"
date: 2015-04-16
categories:
  - Drupal
  - Guides
tags:
  - drupal
  - Drupal Planet
  - xhprof
  - php
  - vagrant
aliases:
  - /writes/xhprof-and-drupal-in-two-flavors
showSocial: false
comments: false
---

After my recent brush with Blackfire at Drupal Dev Days in Montpelliér, I decided to also give another PHP profiling tool a try.
<!--more-->

**XHProf** is a "light-weight hierarchical and instrumentation based profiler" and the tool of choice used by sprinters in the [D8 Accelerate Performance](https://groups.drupal.org/node/464283) sprint.

## Environments

In [Development Environments, Drupal and Blackfire](/writes/development-environments-drupal-and-blackfire/) I described in detail the two environments I have been using:

1. **lightweight, local environment**: Mac OS X, PHP 5.6 and its built-in web server, SQLite
2. **isolated, virtual environment**: Vagrant-based [Drupal VM](http://drupalvm.com) (Ubuntu, PHP 5.5, Apache, MySQL) running on VirtualBox

Both have their merits, and I documented how to install and work with XHProf in each case.

## Local environment

Prerequisites:

* Homebrew
* PHP 5.6
* Composer
* Drush
* Drupal

For details about how I installed these prerequisites, check out [Development Environments, Drupal and Blackfire](/writes/development-environments-drupal-and-blackfire/#local-environment).


### Install XHProf

If you just run `brew install xhprof` the output will show PHP version-specific packages:

~~~
brew install xhprof
Error: No available formula for xhprof
Searching formulae...
php53-xhprof   php54-xhprof   php55-xhprof   php56-xhprof
~~~

In my case, the appropriate command was:

~~~
brew install php56-xhprof
~~~

The output will include helpful information how to test that XHProf was successfully installed. `php -i` command shows PHP configuration settings, so all you need to do is search for the "xhprof" string:

~~~
php -i | grep xhprof
/usr/local/etc/php/5.6/conf.d/ext-xhprof.ini
xhprof
xhprof => 0.9.2
~~~

### Configure XHProf

The only configuration needed is to set the output directory in the PHP configuration file for XHProf. Here is my `/usr/local/etc/php/5.6/conf.d/ext-xhprof.ini` file:

~~~
[xhprof]
extension="/usr/local/opt/php56-xhprof/xhprof.so"
xhprof.output_dir=/tmp
~~~

If your PHP built-in webserver is running, use `Ctrl + C` to stop it, and start it up again with `php -S localhost:8888`.

### XHProf Drupal module

There is a [Drupal XHProf module](https://www.drupal.org/project/xhprof) which provides a native Drupal UI for configuring and rendering profiling results.

I installed the module with `git` using instructions from [Version Control tab](https://www.drupal.org/project/xhprof/git-instructions) of the project page:

~~~
git clone --branch 8.x-1.x http://git.drupal.org/project/XHProf.git
~~~

Once downloaded, visit your Drupal site and navigate to Extend to enable the XHProf module.

#### Configure Drupal module

Visit Configuration > XHProf. Check the *Enable profiling of page views.* option. In the Profiling Settings, check:

* Cpu
* Memory
* Exclude PHP builtin functions
* Exclude indirect functions

Click *Save configuration* to finish.

#### Run profile

To run an XHProf profile, visit any page of your site and scroll down to the bottom. You should see a link titled **XHProf output**. Click on the link to access the XHProf report.

<img class="img-responsive" src="/images/2015-04-16-xhprof-and-drupal-in-two-flavors/xhprof-module-report.png">
<span class="caption text-muted">
XHProf module report within Drupal
</span>

### XHProf native output

XHProf also has a way to display output in its own pages. This view includes additional data that is not displayed in the Drupal module output.

Enabling native output is easy. First, locate the `xhprof_html` directory. Packages installed with Homebrew will typically be in `/usr/local/Cellar/`. In this case, the full path is:

~~~
/usr/local/Cellar/php56-xhprof/254eb24/xhprof_html/
~~~

You might see a different string in place of `254eb24`. You can also use the `locate` command. First, update the index. Then search for the directory:

~~~
sudo /usr/libexec/locate.updatedb
locate xhprof_html
~~~

`locate` should return a list of all the paths that include `xhprof_html`

Now, create a symbolic link in your Drupal root directory:

~~~
cd ~/druapl8/
ln -s /usr/local/Cellar/php56-xhprof/254eb24/xhprof_html
~~~

When you omit the second argument to `ln -s` the symbolic link will take the name of the inner-most directory.

With the symbolic link in place, now it’s time to visit: [http://localhost:8888/xhprof_html/]():

<img class="img-responsive" src="/images/2015-04-16-xhprof-and-drupal-in-two-flavors/xhprof-native-output.png">
<span class="caption text-muted">
XHProf native output
</span>

## Drupal VM

Drupal VM has an Ansible role for XHProf. XHProf is included by default. To start profiling, install the XHProf Drupal module.

### XHProf Drupal module

The [module](https://www.drupal.org/project/xhprof) provides a native Drupal UI for configuring and rendering profiling results.

I installed the module with `git` using instructions from [Version Control tab](https://www.drupal.org/project/xhprof/git-instructions) of the project page:

~~~
git clone --branch 8.x-1.x http://git.drupal.org/project/XHProf.git
~~~

Once downloaded, visit your Drupal site and navigate to Extend to enable the XHProf module.

#### Configure Drupal module

Visit Configuration > XHProf. Check the *Enable profiling of page views.* option.

> At this point I ran into an issue where the checkbox was disabled. I found a [workaround and reported the issue](https://github.com/geerlingguy/drupal-vm/issues/73) on GitHub. Jeff Geerling, the maintainer of Drupal VM resolved the problem within hours.

In the Profiling Settings, check:

* Cpu
* Memory
* Exclude PHP builtin functions
* Exclude indirect functions

Click *Save configuration* to finish.

#### Run profile

To run an XHProf profile, visit any page of your site and scroll down to the bottom. You should see a link titled **XHProf output**. Click on the link to access the XHProf report.

### XHProf native output

XHProf also has a way to display output in its own pages. This view includes additional data that is not displayed in the Drupal module output.

Viewing native output is even easier with Drupal VM. There is a setting in `config.yml` that configures Apache virtual host to serve XHProf output. All I needed to do is to map the hostname in my `/etc/hosts` file:

~~~
sudo vim /etc/hosts
~~~

Then add the following line:

~~~
192.168.88.88   local.xhprof.com
~~~

Now in the browser, visit: [local.xhprof.com](http://local.xhprof.com) to view the profiling results.
