---
title: Development environments, Drupal and Blackfire
date: 2015-04-15
tags:
  - drupal
  - Drupal Planet
  - php
  - vagrant
  - sqlite
  - blackfire
tagline: Blackfire is a PHP performance profiler I learned about at Drupal Developer Days in Montpelliér.
---

I installed Blackfire in two different environments:

* local, light-weight environment (PHP 5.6, SQLite)
* Drupal VM (Vagrant, VirtualBox)

My motivation was to try out the Drupal VM (Ubuntu), and also try a very minimal local environment (Mac OS X), without the use of apps like MAMP or Acquia Dev Desktop.

Don’t get me wrong, both are excellent when you are new to using local development environments. After all, I started out my Drupal adventures with MAMP. Now I was ready to try a different direction.

## Local environment

My local environment is Mac OS X 10.10.3. To install packages, I use [Homebrew](http://brew.sh), "the missing package manager for OS X".

If you don’t have Homebrew installed, take 2 minutes to run the [installation command](http://brew.sh/#install) in Terminal.

My goal was a very minimal setup:

* PHP 5.6 built-in web server
* SQLite as database

I started out with making sure Homebrew was up to date:

~~~
brew doctor
brew update
~~~

### PHP 5.6

Next, I visited [PHP formulae repo for Homebrew](https://github.com/Homebrew/homebrew-php) on GitHub. I followed the [installation instructions](https://github.com/Homebrew/homebrew-php#installation) to install PHP 5.6:

~~~
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php
brew install php56
~~~
The first three commands take care of dependencies, the last installs PHP 5.6.

To start the built-in web server, run:

~~~
php -S localhost:8888
~~~

from any directory. You should see something like:

~~~
PHP 5.6.7 Development Server started at Wed Apr 15 17:49:52 2015
Listening on http://localhost:8888
Document root is /Users/alimac/drupal
Press Ctrl-C to quit.
~~~

The directory you run the command from will be treated as the root web directory.
You can visit http://localhost:8888 to view the site. If there is no `index.php` file, you will get an error:

> **Not Found**
>
> The requested resource / was not found on this server.

<img src="/images/2015-04-15-development-environments-drupal-and-blackfire/not-found.png">

No worries, it means the web server is up and running.

Restarting the web server is as easy as pressing `Ctrl + C` in the Terminal, and then running the `php -S localhost:8888` command again.

### SQLite

SQLite is provided with Mac OS X. The version I am using is 3.8.5.

There is a newer version (3.8.9) available via Homebrew, but I am not going to cover upgrading SQLite. If you want to take this detour, [this comment](https://github.com/Homebrew/homebrew-php/issues/702#issuecomment-23189223) has useful instructions.

### Composer

Composer is a dependency manager for PHP. It can manage PHP package dependencies on a *global* (user account-wide) or *local* (directory-wide) basis.

Some packages or tools that you will be managing with composer should be installed globally. Most packages are better installed locally in a specific project directory.

In my environment, composer itself is [installed globally](https://getcomposer.org/doc/00-intro.md#globally).

### Drush

Drush is a command-line shell and scripting tool for managing Drupal projects.

The installation method I used for Drush is [Composer - One Drush for all Projects](http://docs.drush.org/en/master/install/#composer-one-drush-for-all-projects). Drush 7.x (dev) works with Drupal 6, 7, and 8.

If there is a project I am working with that requires an older version of Drush, I can install it locally for that specific project.

### Drupal

With all the tools in place, it is time to install Drupal 8!

~~~
git clone --branch 8.0.x http://git.drupal.org/project/drupal
cd drupal
~~~

To install it in a specific directory, append a space and the directory name at the end of the `git` command.

Next, start the built-in PHP web server and confirm you can view drupal installation page in your browser.

I use `drush` to install and reinstall D8:

~~~
drush site-install -y --db-url=sqlite://Users/alimac/drupal/sites/all/files/.ht.sqlite
~~~

Let’s step through the parts of the `drush` command above:

1. [site-install](http://drushcommands.com/drush-7x/site-install/site-install) option is for installing (or reinstalling) a Drupal site
2. `-y` option automatically answers "yes" to any `y/n` questions
3. `--db-url` is a string whose value should be the database you want to use for your installation, in this case a SQLite file. Since it’s placed within the web root directory, it is prefixed with `.ht` which web servers like Apache should not make accessible to the world.

> **Caveat**: [Drush commands documentation](http://drushcommands.com/drush-7x/site-install/site-install) examples use a relative path. I got an error when using relative path, and I [reported it](ht.tps://github.com/drush-ops/drush/issues/1336) on GitHub. Using an absolute path worked for me.

When you run the `drush site-install` command, you will see something like:

~~~
You are about to CREATE the '/Users/alimac/drupal/d8/sites/all/files/.ht.sqlite' database. Do you want to continue? (y/n): y
Starting Drupal installation. This takes a while. Consider using the --notify global option.                                        [ok]
Installation complete.  User name: admin  User password: vvd6v2r756                                                                 [ok]
Congratulations, you installed Drupal!
~~~

You can use the same command to reinstall Drupal. The only difference in the will be in the first line of output:

~~~
You are about to DROP all tables in your '/Users/alimac/drupal/d8/sites/all/files/.ht.sqlite' database. Do you want to continue? (y/n): y
~~~

Check in your browser that your Drupal site has been installed.

### Blackfire

To use Blackfire, you must sign up for a free account on [blackfire.io](http://blackfire.io). Once you register, visit [Getting Started with Blackfire](https://blackfire.io/getting-started) and select the Mac OS X tab.

I recommend viewing the Getting Started doc while logged in. Why? Your server and client credentials will be inserted directly into the instructions. This makes it super easy to follow along the commands to install and configure Blackfire.

Since the steps are fairly straightforward, I am not going to repeat them here. Once you reach the bottom of the Getting Started page, the next step is to [install the browser extension](https://blackfire.io/doc/web-page) (Chrome-only).

To profile Drupal 8, click on the Blackfire icon, select an empty profile slot, and click the *Profile!* button. You will see a progress bar as the site is profiled by Blackfire:

TODO: screenshot

When profiling is finished, click on *View Profile* button to view the full profile.

## Drupal VM

As part of my [2014 talk at BADCamp](https://2014.badcamp.net/session/getting-started-vagrant), I created a [Vagrant-based project](https://github.com/alimac/vagrant-drupal) with the goal of provisioning a Drupal 8 development environment. To keep it simple, I used a shell provisioner. Since then I’ve been wanting to try more advanced provisioners like Chef or Ansible.

[Drupal VM](http://www.drupalvm.com) is a little more than a year old, but I found out about it fairly recently. The project "aims to make spinning up a simple local Drupal test/development environment incredibly quick and easy" and uses Vagrant and Ansible.

To get started with Drupal VM, clone the repository:

~~~
git clone git@github.com:geerlingguy/drupal-vm.git
~~~

Next, follow the [Quick Start Guide](https://github.com/geerlingguy/drupal-vm#quick-start-guide) to install dependencies, build the virtual machine and configure your host machine to access the VM.

What is nice about Drupal VM is that you can run `vagrant up` without configuring anything. Instead of copying the two YAML file, I just set up symbolic links:

~~~
ln -s example.config.yml config.yml
ln -s example.drupal.make.yml drupal.make.yml
~~~

By default, Drupal web root will be in `~/Sites/drupalvm`. Whether or not you change this default location, remember to delete its contents when you destroy the VM with `vagrant destroy`. Otherwise you will get errors loading your Drupal site the next time you run `vagrant up`.

You can map the default IP address of the VM: `192.168.88.88` to [drupaltest.dev](http://drupaltest.dev) hostname in your `/etc/hosts` file, or access your site using the IP address: [http://192.168.88.88](http://192.168.88.88).

Drupal VM comes with a lot out of the box:

* Apache 2.4.x
* PHP 5.5.x (configurable)
* MySQL 5.5.x
* Drush latest release (configurable)
* Drupal 6.x, 7.x, or 8.x.x (configurable)

As of this blog post, it does not come with Blackfire yet.

### Blackfire

To use Blackfire, you must sign up for a free account on [blackfire.io](http://blackfire.io). Once you register, visit [Getting Started with Blackfire](https://blackfire.io/getting-started) and select the Debian Ubuntu/Mint tab.

I recommend viewing the Getting Started doc while logged in. Why? Your server and client credentials will be inserted directly into the instructions. This makes it super easy to follow along the commands to install and configure Blackfire.

Since the steps are fairly straightforward, I am not going to repeat them here. Once you reach the bottom of the Getting Started page, the next step is to [install the browser extension](https://blackfire.io/doc/web-page) (Chrome-only).

To profile Drupal 8, click on the Blackfire icon, select an empty profile slot, and click the *Profile!* button. You will see a progress bar as the site is profiled by Blackfire:

<img src="/images/2015-04-15-development-environments-drupal-and-blackfire/blackfire-profiling.png">

When profiling is finished, click on *View Profile* button to view the full profile.

<img src="/images/2015-04-15-development-environments-drupal-and-blackfire/blackfire-profiled-drupal-site.png">
