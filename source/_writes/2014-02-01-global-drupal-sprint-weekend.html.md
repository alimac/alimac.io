---
title: Global Drupal Sprint Weekend
date: 2014-02-01
tags:
  - drupal
  - Drupal Planet
---

On January 26 I participated in [Drupal Global Sprint Weekend][].
This was my second time participating in a sprint during the Global Sprint
Days (check out this [podcast with Cathy Theys][] to find out how it all got
started).

There are a few things that helped make this sprint experience even better this
year:

1. I had a specific goal.
2. I had local environment ready.
3. I read [A Helpful Guide to Your First Drupal Sprint][].

My goal was to learn more about configuration management in Drupal 8. I actually
didn't get to exploring configuration management, but I learned about using
[drush][] for automating installation and tear-down of a Drupal site.

[Drupal Global Sprint Weekend]: https://groups.drupal.org/node/332998
[podcast with Cathy Theys]: https://www.lullabot.com/blog/podcasts/global-sprint-days
[A Helpful Guide to Your First Drupal Sprint]: http://www.genuineinteractive.com/blog-posts/web/helpful-guide-first-sprint/
[drush]: https://github.com/drush-ops/drush

## Local environment

I had a laptop running OS X 10.8.5 and [MAMP][] 2.1.2. You will also need
[git][] to be installed to run the `git clone` commands. My notes will be
helpful to someone who has gone through installing Drupal via browser, but
wants to speed up or automate the process on the command line.

[MAMP]: http://www.mamp.info/en/index.html
[git]: http://git-scm.com

## Set up drush

I had a previous version of drush installed (6.0-dev) but I wanted to use 7.0.
I used `pear` to install, so to uninstall the existing drush I used:

~~~ shell
sudo pear uninstall drush/drush
~~~

Instead of using a package manager, I wanted to run drush directly from a local
git repository. This would allow me to use different versions of drush easily,
just by switching to a different branch.

First, create a `~/bin/` directory. Next, clone the drush repository within
`~/bin/`:

~~~ shell
git clone https://github.com/drush-ops/drush.git
~~~

Finally, update `.bash_login` (or `.profile` or `.bash_profile`) to add the
following two lines:

~~~ shell
export PATH="~/bin:$PATH"
alias drush="~/bin/drush/drush"
~~~

The first allows me to execute scripts located in my `~/bin/` directory.
The second adds an alias to the drush executable. I reloaded my shell:

~~~shell
. ~/.bash_login
~~~

and now I was ready to use drush:

~~~ shell
drush --version
 Drush Version   :  7.0-dev
~~~

There are just two [additional configuration steps][] to make drush work with
MAMP. Specify which version of PHP will be used by drush. I added the following
to `.bash_login`:

~~~ shell
export PATH="/Applications/MAMP/Library/bin:/Applications/MAMP/bin/php5.4/bin:$PATH"
~~~

Create a symbolic link to MAMP's MySQL socket file:

~~~ shell
sudo mkdir /var/mysql
sudo ln -s /Applications/MAMP/tmp/mysql/mysql.sock /var/mysql/mysql.sock
~~~

[additional configuration steps]: https://github.com/drush-ops/drush#additional-configurations-for-mamp

## Site install with drush

Get a copy of Drupal 8:

~~~ shell
git clone --branch 8.x http://git.drupal.org/project/drupal.git
~~~

To install Drupal, use `drush site-install` or the shorthand `drush si`.
First I tried it with an existing (but empty) MySQL database and user (both
named `drupal`):

~~~ shell
drush si --account-pass=admin --db-url=mysql://drupal:drupal@localhost/drupal -y
~~~

Afterward I opened <http://localhost/drupal> in the browser to confirm that
the installation was successful.

Next, I tried it with root MySQL credentials and created a database on the fly:

~~~ shell
drush si --account-pass=admin --db-url=mysql://root:root@localhost/mydb -y
~~~

One thing I wanted to do is to use root MySQL credentials to create the new
database, but also create a MySQL user that is granted rights only to that
database. The reason why I would like to do this is to keep the sites isolated,
each with its own MySQL user and database. It does not look like this can be
done with drush, though.

## Clean up

Cleaning up, or "resetting" the site involves more than one command. First,
remove existing database:

~~~ shell
drush sql-drop -y
~~~

Next, remove existing installation:

~~~ shell
sudo rm -rf sites/default
~~~

Finally, restore the sites/default/default.settings.php file:

~~~ shell
sudo git checkout -- sites/default
~~~

## Script it all up

After running the individual commands, it's time to take it easy and script
all of these tasks. The following two scripts make install and clean-up easy.
Copy and save each in the `~/bin/` directory, as `drupal-install` and
`drupal-clean`.

Then, add the following to your shell profile:

~~~ shell
source ~/bin/drupal-install
source ~/bin/drupal-clean
~~~

### drupal-install

~~~ shell
function drupal-install() {
	# If you run this command with an argument, it will be the name of the DB
	if [ $1 ] ; then
		drush si --account-pass=admin --db-url=mysql://root:root@localhost/$1 -y
	else
		drush si --account-pass=admin --db-url=mysql://root:root@localhost/d8 -y
	fi
}
~~~

### drupal-clean

~~~ shell
function drupal-clean() {
	# Remove existing database
	drush sql-drop -y;
	# Remove existing install
	sudo rm -rf sites/default;
	# Restore the sites/default/default.settings.php file
	sudo git checkout -- sites/default;
	# Temporarily make the sites/default writable by anyone
	sudo chmod -R 777 sites/default;
	# Ensure the owner is the current user, not root user
	sudo chown -R `whoami` sites/default;
	# Now that we own it and can write, change the permissions back to how drupal expects them
	sudo git checkout -- sites/default;
	# But still ensure that we own the folder
	sudo chown -R `whoami` sites/default;
}
~~~

## Other things I learned

Even if you have more than two versions of PHP only two will be shown in MAMP
preferences. To choose a version that isn't displayed in MAMP preferences,
temporarily rename or move the other versions out of the
`/Applications/MAMP/bin/php/` directory.

I think MAMP is a great tool to start with when setting up a local development
environment. In the future I will be exploring setting up a [Vagrant][] box as
a local environment for Drupal, so that I can more closely approximate a
production environment.

[Vagrant]: http://www.vagrantup.com

