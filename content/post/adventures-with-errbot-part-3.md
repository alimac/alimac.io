---
title: Adventures with Errbot, Part 3
date: 2015-11-20
categories:
  - Guides
tags:
  - python
  - jabber
  - xmpp
  - open source
thumbnailImage: /images/errbot.png
thumbnailImagePosition: left
aliases:
  - /writes/adventures-with-errbot-part-3
showSocial: false
comments: false
---

In Part 1, we
[installed and configured Errbot](/adventures-with-errbot-part-1), a
Python-based chat bot. In Part 2, we
[added and configured plugins for Errbot](/adventures-with-errbot-part-2).
Now it’s time to create our own plugin for Errbot.
<!--more-->

<div class="alert alert-success">
<i class="fa fa-leaf fa-2x"></i>
This guide is intended for beginners who are comfortable with the command line
and have some programming experience, but may be new to Python (like me) or
continuous integration (CI).
</div>

## Errbot documentation

Errbot [User Guide](http://errbot.io/index.html#user-guide) has a
[plugin development](http://errbot.io/user_guide/plugin_development/) section.
It has examples of things you might want your plugin to do. I found it helpful
to read a bit of the documentation, implement a feature, and then return later
when I was implementing another part of the project.

I based this part of the series around two topics in the plugin development
section:

- [3. Hello, world!](http://errbot.io/user_guide/plugin_development/basics.html#hello-world)
and
- [11. Testing your plugins](http://errbot.io/user_guide/plugin_development/testing.html#testing-your-plugins)

The goal is to write a simple plugin from scratch, test it first using Errbot’s
interactive text mode, then the Python test tool `py.test`, and finally connect
the project to a continuous integration service, Travis CI.

## Development environment

How do we get started? If you don’t have a development environment yet, no
worries. While working on this guide, I built a simple, shareable
[development environment for Errbot plugins](https://github.com/alimac/errbot-dev),
which:

- uses [Vagrant](http://vagrantup.com) and [VirtualBox](http://www.virtualbox.org/wiki/Downloads)
to set up a virtual machine runnning Ubuntu 14.04
- installs `pip`, `err` (and other dependencies mentioned in Part I) on the
virtual machine
- installs `coverage` and `pep8` (used for testing)
- sets up a minimal configuration for Err
- creates `err-data/` and `err-plugins/` directories

To use this development environment, install Vagrant and VirtualBox first. You
will also need [Git](https://git-scm.com/downloads) to be installed on your
computer.

I recommend installing the `vagrant-vbguest` plugin, to keep VirtualBox Guest
Additions up to date. On the command line, run:

``` bash
vagrant plugin install vagrant-vbguest
```

Now it’s time to download the `errbot-dev` project. You can either clone it
with `git`:

``` bash
git clone https://github.com/alimac/errbot-dev.git
```

Or [download the .zip file](https://github.com/alimac/errbot-dev/archive/master.zip).

Inside the project, there are two files:

- `Vagrantfile` - contains the virtual server configuration and shell commands
that will install Err
- `config.py` - a minimal configuration of Err

Once downloaded (and unpacked), use the terminal to go to the `errbot-dev`
directory and start the virtual server:

``` bash
cd errbot-dev/
vagrant up
```

The first time you run `vagrant up`, it will take a while. Especially if Vagrant
has to download the (Ubuntu 14.04) base box.

Once the virtual server is ready, use `vagrant ssh` to connect to it. Then,
go to the `/vagrant` directory.  You should be able to start Errbot with
the `-T` flag:

``` bash
cd /vagrant
errbot -T
```

The `-T` flag means that Errbot will not try to connect to a backend. Instead,
it will give you an interactive prompt where you can type bot commands, (as if
you were connected to an XMPP backend and in a chat. Try `!status`, `!help` or
another command. If you type:

``` bash
!whoami
```

You will find out that you are `gbin@localhost`. [gbin](https://github.com/gbin)
is Guillaume Binet, the maintainer of Errbot.

To exit the Errbot shell, use `Ctrl + c`.

I find it useful to have two simultaneous sessions, one in which I run
`errbot -T`, and another in which I use `vim` to make changes to a plugin’s
code. You can also use a local code editor, on your desktop.

## Our first plugin

Let’s create a basic plugin for Errbot. A plugin will consist of at least three
files:

- `pluginname.py` - the plugin itself
- `pluginname.plug` - a metadata file
- `test_pluginname.py` - tests for the plugin

<div class="alert alert-warning">
<i class="fa fa-cogs fa-2x"></i>
It’s good idea to get into the habit of adding tests early in the project.
Having tests reduces the chance that you will introduce bugs later, and it
helps make sure that your plugin can be reliably built over and over again.
</div>

To start, we will build a simple plugin that replies whenever someone in the
chat says “hello”.

In `/vagrant/errbot-plugins/` create a `HelloBot` directory where we will store
the plugin files.

### <i class="fa fa-file-code-o"></i> hello.plug

The first file - `hello.plug` - will contain basic information about the plugin.
The *Name* refers to the class name we will use. The *module* refers to
the `.py` filename.

Our plugin will work with Python 2 or above, and we will include a short
description of the plugin in the Documentation section.

``` ini
[Core]
Name = HelloBot
Module = hello

[Python]
Version = 2+

[Documentation]
Description = Plugin for Errbot that responds to hello’s.
```

### <i class="fa fa-file-code-o"></i> hello.py

Our `.py` file is where the plugin’s logic will be. This example is similar to
the example given in section [3. Hello, World](http://errbot.io/user_guide/plugin_development/basics.html)
of the Errbot plugin development guide. Take a look at it first. Then continue
reading below.

``` python
from errbot import BotPlugin, botcmd


class HelloBot(BotPlugin):
    """'Hello!' plugin for Errbot"""

    @botcmd
    def hello(self, msg, args):
        """Say hello to someone"""
        return "Hello, " + format(msg.frm)
```

1. The first line lists the packages we are importing that will be used by
the plugin.
1. Then, we define our class, `HelloBot`, along with a documentation comment
wrapped in three double quotes.
1. `def` is how we start our function. This function takes three parameters:
`self` (our plugin), `msg` (the message that the bot is responding to), and
`args` (anything that follows the `!hello` command).
1. Above it, is `@botcmd`, a *decorator*. It means that `hello` is a command
that we can give to the bot.
1. Inside the function, we have another documentation comment. This one will be
shown when you call for help with `!help HelloBot`.
1. The last line is the bot’s response. `msg.frm` is the identifier of the user
who types the `!hello` command in the chat.

Whew! That’s a lot to take in. If you want to test it out, run:

``` bash
errbot -T -c /vagrant/config.py
```
and once Errbot loads, say `!hello` and see what happens.

### <i class="fa fa-file-code-o"></i> test_hello.py

In `test_hello.py` we will add a test to make sure that if someone says
`!hello`, the bot does respond with what we expect.

Remember how we used `!whoami` to find out that in the interactive text mode
our username is `gbin@localhost`? We can use this in our tests:

``` python
import os
import hello
from errbot.backends.test import testbot


class TestHelloBot(object):
    extra_plugin_dir = '.'

    def test_hello(self, testbot):
        testbot.push_message('!hello')
        assert 'Hello, gbin@localhost' in testbot.pop_message()
```

1. As in `hello.py` we import a few packages:
  - `os` - a “[portable way of using operating system dependent functionality](https://docs.python.org/2/library/os.html)”
(useful for testing)
  - `hello` - our plugin
  - `testbot` - a test instance of Errbot, to which we will pass commands and
check if the output matches our expectations
1. We define a class in which we will define the test functions. Each function
is considered to be an independent test.
1. Within our test class, we have a `test_hello` function that uses the testbot
to pass a command - `!hello` - and checks that the response matches with
the expected reply, `Hello, gbin@localhost`.

## Test with py.test

It’s time to run our test. We will use `py.test`, a [Python testing tool](http://pytest.org).
In `/vagrant/err-plugins/HelloBot/` directory, run the following command:

``` bash
py.test -sv
```

The `-v` flag means that we will see verbose output of each test (rather than
a `.` for successful test and an `F` for each failed test). The `-s` flag will
conveniently display the errors at the end, so that we don’t have to scroll
through all of the output capture to find them.

If all goes well, you will see something like:

``` bash
===================== test session starts =============================
platform linux2 -- Python 2.7.6, pytest-2.8.2, py-1.4.30, pluggy-0.3.1
rootdir: /vagrant/err-plugins/HelloBot, inifile:
plugins: pep8-1.0.6, xdist-1.13.1
collected 1 items

test_hello.py::TestHelloBot::test_hello PASSED

=================== 1 passed in 0.79 seconds ==========================
```

If any of the tests do not pass, you might see:

``` bash
=========================== FAILURES ==================================
_____________________TestHelloBot.test_hello __________________________

self = <test_hello.TestHelloBot object at 0x7fe22149af90>
testbot = <errbot.backends.test.TestBot object at 0x7fe220ae01d0>

    def test_hello(self, testbot):
        testbot.push_message('!hello')
>       assert 'Hello, alimac@localhost' in testbot.pop_message()
E       assert 'Hello, alimac@localhost' in 'Hello, gbin@localhost'
E        +  where 'Hello, gbin@localhost' = <bound method TestBot.pop_message of <errbot.backends.test.TestBot object at 0x7fe220ae01d0>>()
E        +    where <bound method TestBot.pop_message of <errbot.backends.test.TestBot object at 0x7fe220ae01d0>> = <errbot.backends.test.TestBot object at 0x7fe220ae01d0>.pop_message

test_hello.py:11: AssertionError
==================== 1 failed in 0.88 seconds =========================
```

What happened? In the example above, the test failed because the expected
response (`Hello, alimac@localhost`) did not match the response the Errbot
gave (`Hello, gbin@localhost`).

### Code style

[PEP 8](https://www.python.org/dev/peps/pep-0008/) is style guide for Python
code, and `pep8` is a [tool to check your Python code](http://pep8.readthedocs.org/en/latest/intro.html)
against some of the style conventions in PEP 8.

It will check that your line lengths are at most 79 characters, that you use
the right kind of indentation, etc. The goal here is consistency.

To perform PEP 8 checks, run `py.test` with the `--pep8` flag. Here is
an example of what you might see in the output:


``` bash
_________________________ PEP8-check ________________________________
/vagrant/err-plugins/HelloBot/hello.py:3:1: E302 expected 2 blank lines, found 1
class HelloBot(BotPlugin):
^
/vagrant/err-plugins/HelloBot/hello.py:4:80: E501 line too long (89 > 79 characters)
    """Example 'Hello!' plugin for Errbot that replies to hello's to chat participants"""
                                                                               ^

================= 1 failed, 2 passed in 0.90 seconds ================
```

As a newcomer to Python, I found these consistency checks very helpful.


### Test coverage

How do we know what tests to write? `coverage` is a tool that measures code
coverage during test execution. We can use it to pinpoint code that is not
covered by tests.

To use `coverage`, we have to modify the command we use to run tests:

``` bash
coverage run --source hello -m py.test --pep8
```

To check the results, run `coverage report`. You might see the following
output:

``` bash
Name       Stmts   Miss  Cover
------------------------------
hello.py       4      0   100%
```

When coverage is less than 100%, we would like to see exactly where we are
missing tests. Run the `coverage html` command. It will create a directory,
`htmlcov`, containing web pages showing where the tests are missing.

Navigate to the `errbot-dev/err-plugins/HelloBot/htmlcov` directory on your
computer (instead of the virtual machine) and view the contents in a browser.

You should see a page like this:

<img class="img-responsive" alt="HTML output of `coverage` command"
  src="/images/2015-11-20-adventures-with-errbot-part-3/htmlcov.png">
<span class="caption text-muted">
HTML output of `coverage`.
</span>

You can click on each filename to see detailed results. For example, if we
remove the `test_hello` function, we would see which statements need a test
highlighed in red:

<img class="img-responsive" alt="Coverage results highlight statements that
  need to be tested"
  src="/images/2015-11-20-adventures-with-errbot-part-3/htmlcov-file.png">
<span class="caption text-muted">
Coverage results highlight statements that need to be tested.
</span>

Great! We now have style guide checks, tests, and a measurement of test
coverage. What’s next?

## Continous integration

> Continuous Integration (CI) is a development practice that requires
> developers to integrate code into a shared repository several times a day.
> Each check-in is then verified by an automated build, allowing teams to
> detect problems early.

In final step of this guide we are going to set up an automated build of our
project.

By testing our plugin in a disposable environment, we will make sure
that there are no unexpected dependencies and that we can reliably build and
test our plugin using different Python versions.

We are going to need three things:

1. a public **git repository** of our project hosted on [GitHub](http://github.com)
1. a free [Travis CI](https://travis-ci.org) account, set up to build our project
1. a configuration file for Travis CI in the repository

### Git repository

Let’s intialize our git repository by running the `git init` command in
the `HelloBot/` directory on our computer (instead of the virtual machine).

`git status` should show us all of the untracked files:

``` bash
  .cache/
  .coverage
  __pycache__/
  hello.plug
  hello.py
  hello.pyc
  htmlcov/
  test_hello.py
```

Some of these files are directories are _artifacts_, or byproducts of testing
and Python byte code compilation. We can ask git to ignore them by creating a
`.gitignore` file with the following contents:

``` bash
.cache/
.coverage
__pycache__/
*.pyc
htmlcov/
```

Now we can add the files we care about to the repository and make our first
commit:

``` bash
git add .gitignore hello.plug hello.py test_hello.py
git commit -m "Initial commit"
```

Next, create a [GitHub repository](http://github.com) and add it as a
**remote** to your local repository. Then, push the project to the remote
repository (substitute the URL for your own):

``` bash
git remote add origin git@github.com:alimac/err-hello.git
git push -u origin master
```

### Travis account

[Open a Travis CI account](http://docs.travis-ci.com/user/getting-started/)
with your GitHub credentials (steps 1 and 2).

Make sure that the repositories have synced, and flip the switch on our
`err-hello` repository to a green checkmark:

<img class="img-responsive" alt="View of repositories on Travis CI"
  src="/images/2015-11-20-adventures-with-errbot-part-3/travis-repos.png">
<span class="caption text-muted">
View of repositories on Travis CI
</span>

The next step is to add a `.travis.yml` configuration file to the repo.

### Travis configuration file

In your local repo, create a file named `.travis.yml` and add the following
contents:

``` ini
language: python
python:
  - 2.7
  - 3.3
  - 3.4
  - 3.5
install:
  - pip install -q err pytest pytest-pep8 --use-wheel
  - pip install -q coverage --use-wheel
script:
  - coverage run --source hello -m py.test --pep8
notifications:
  email: false
```

The configuration file is where we specify the language of our project, which
versions of Python we want to test, and how we run the test. We also include
any packages that need to be installed.

Travis builds are triggered whenever you push to the remote repository on
GitHub. Add `.travis.yml` to your local repository, commit it, and push to
start the Travis build.

You should see it in action (refresh [travis-ci.org](http://travis-ci.org) page
if you don’t see the build):

<img class="img-responsive" alt="View of repositories on Travis CI"
  src="/images/2015-11-20-adventures-with-errbot-part-3/travis-build-jobs.png">
<span class="caption text-muted">
Build jobs will be marked as green if they run successfully
</span>

Click on a build job to view its log:

<img class="img-responsive" alt="View of repositories on Travis CI"
  src="/images/2015-11-20-adventures-with-errbot-part-3/travis-log.png">
<span class="caption text-muted">
Travis CI build job log
</span>

Now every time we push code to the GitHub repository it will automatically start
four build jobs (one for each version of Python).

## What’s next?

Our project is missing a `README.md` file, but I will leave this part up to you.

Consider adding a [build status badge](http://docs.travis-ci.com/user/status-images/)
to the README file to show that your build is passing.

You can also [integrate your project with Coveralls](http://errbot.io/user_guide/plugin_development/testing.html#travis-and-coveralls),
an online service that will show test coverage results.
Like Travis CI, you can add a test coverage badge to the README indicate how
well do your tests cover your codebase.

And that’s all for now. In later parts of this series, I will tackle more
advanced plugin functionality by taking a look at the
[err-factoid](https://github.com/alimac/err-factoid) and
[err-request-tracker](https://github.com/alimac/err-request-tracker) plugins
I built while learning about Errbot.

Was this guide useful? Did you notice any mistakes?
[<i class="fa fa-twitter"></i>Tell me](https://twitter.com/alimacio).
