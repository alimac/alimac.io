---
title: "Adventures with Errbot, Part 1"
date: 2015-11-06
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
  - /writes/adventures-with-errbot-part-1
showSocial: false
comments: false
---

On Friday nights, I install bots and blog about it.
<!--more-->

I use Jabber for chat at work. It is not as slick as some of the other options
chat services available, but it has its advantages:

* most of my coworkers are already using it
* free and open source

I wanted add an interactive bot to our group chatroom. Out of
[three open source options given in this article](https://www.pagerduty.com/blog/what-is-chatops/)
I decided to try [Errbot](http://errbot.net/), a Python-based bot.

## Why this guide?

The start was a bit rocky... some of the instructions in the
[User Guide](http://errbot.net/user_guide/setup.html) were confusing.
For example, [Starting the daemon](http://errbot.net/user_guide/setup.html#starting-the-daemon)
refers to a non-existent `scripts/` directory.

And (emphasis mine):

> After installing Err, you must **create a data directory somewhere on your
system** where config and data may be stored. Find the installation directory
of Err, then **copy the file config-template.py to your data directory as
config.py**.

For a beginner like me, "somewhere on your system" is too vague. At this point
I was not sure how `errbot` was supposed to know where the configuration file
and the data directory were located if I just put them "somewhere".

<div class="alert alert-info">
<i class="fa fa-info-circle fa-2x"></i>
You can pass a <code>-c</code> parameter to <code>errbot</code>
with the path to the configuration file, as I found out much later.
</div>

Thus, this is my own guide to installing Errbot, along with the adventures I
came across. If you find it useful,
[<i class="fa fa-twitter"></i>let me know](https://twitter.com/alimacio).


## Install

First we need to install `pip`:

``` bash
sudo yum -y install python-pip
```
Now let’s install Errbot:

``` bash
sudo pip install err
```

And, per recommendations, let’s install
[extra dependencies](http://errbot.net/user_guide/setup.html#extra-dependencies)
needed to talk to our Jabber server:

``` bash
sudo pip install sleekxmpp pyasn1 pyasn1-modules
```

Even though the guide lists `dnspython3` as an extra dependency, I found that
it would cause the bot to stop working. Fortunately, I learned this because
I accidentally did not install it to begin with, and only added it at a point
when I had a working bot.

<div class="alert alert-danger">
<i class="fa fa-exclamation-circle fa-2x"></i> If you are using Python 2.7 (run
<code>python -v</code> to find out) don’t install <code>dnspython3</code>.
</div>

## Configure

So where is Errbot installed exactly? We can use the `locate` command, but
first let’s make sure that its database is up to date:

``` bash
sudo updatedb
locate errbot
```

`locate errbot` will return a long list of paths:

``` bash
/usr/bin/errbot
/usr/lib/python2.7/site-packages/errbot
/usr/lib/python2.7/site-packages/errbot/__init__.py
...
```

`/usr/lib/python2.7/site-packages/errbot` is the one we are interested in,
because that’s where we can find the configuration file template
`config-template.py`. Copy the template to `config.py`:

``` bash
cd /usr/lib/python2.7/site-packages/errbot
cp config-template.py config.py
```

Next, open `config.py` in your favorite editor (I use `vim`). Here are
the changes I made to the configuration file:

Uncomment the `BACKEND` variable, and set the logging level to DEBUG just in
case we run into any problems:

``` bash
BACKEND = 'XMPP'
BOT_LOG_LEVEL = logging.DEBUG
```

Enter the credentials for the Jabber ID in the `BOT_IDENTITY` section.
In the examples that follow, change `jabberserver.tld` to the hostname of your
Jabber server:

``` python
  # XMPP (Jabber) mode
  'username': 'foo@jabberserver.tld', # The JID of the user you have created for the bot
  'password': 'Temp1234', # The corresponding password for this user
```

List the users who can configure the bot:

``` python
BOT_ADMINS = ('alimac@jabberserver.tld',)
```

Join our group chat:

``` python
CHATROOM_PRESENCE = ('dev@jabbberserver.tld',)
```

And finally, give the bot a name. I asked for advice, and named it **Bender**,
in honor of [Bender Bending Rodriguez](https://en.wikipedia.org/wiki/Bender_(Futurama))
from Futurama:

``` python
CHATROOM_FN = 'Bender'
```

<img class="img-responsive" src="/images/2015-11-06-adventures-with-errbot-part-1/stephen-hanafin-bender.jpg">
<span class="caption text-muted">
Photo CC-BY-SA [Stephen Hanafin](https://flic.kr/p/5ttZUs)
</span>

## Run

Now that the configuration part is behind us, let’s run Errbot!

``` bash
alimac@centos7> errbot
Traceback (most recent call last):
  File "/bin/errbot", line 5, in <module>
    from pkg_resources import load_entry_point
  File "/usr/lib/python2.7/site-packages/pkg_resources.py", line 3011, in <module>
    parse_requirements(__requires__), Environment()
  File "/usr/lib/python2.7/site-packages/pkg_resources.py", line 626, in resolve
    raise DistributionNotFound(req)
pkg_resources.DistributionNotFound: six>=1.7
```

Uh oh, it looks like we have a dependency that needs to be updated. The very
last line mentions that `six` must be at version 1.7 or above. To upgrade:

``` bash
pip install --upgrade six
```

Let’s try again:

``` bash
alimac@centos7> errbot
18:49:04 INFO     errbot.err                Config check passed...
18:49:04 INFO     errbot.err                Selected backend 'XMPP'.
18:49:04 INFO     errbot.err                Checking for '/var/lib/err'...
Traceback (most recent call last):
  File "/bin/errbot", line 9, in <module>
    load_entry_point('err==3.1.2', 'console_scripts', 'errbot')()
  File "/usr/lib/python2.7/site-packages/errbot/err.py", line 227, in main
    raise Exception(u"The data directory '%s' for the bot does not exist" % config.BOT_DATA_DIR)
Exception: The data directory '/var/lib/err' for the bot does not exist
```

Fair enough, let’s create it (and make sure that the user we are running `errbot`
as can write to this directory):

``` bash
mkdir /var/lib/err
```

And again:

``` bash
IOError: [Errno 2] No such file or directory: '/var/log/err/err.log'
```

Let’s create the log directory and file, too:

``` bash
mkdir /var/log/err/
touch /var/log/err/err.log
```

.. and try one more time!

It looked like things were going to work, but...

``` bash
18:50:23 ERROR    sleekxmpp.xmlstream.xmlst Socket Error #185090050: _ssl.c:340:
error:0B084002:x509 certificate routines:X509_load_cert_crl_file:system lib
```

Researching this error led to me to a [post on GitHub](https://github.com/gbin/err/issues/427)
which suggested uncommenting `XMPP_CA_CERT_FILE` and setting setting it to:

``` bash
XMPP_CA_CERT_FILE = None
```

And then finally...

``` bash
...
19:00:07 DEBUG    errbot.plugins.ChatRoom   Try to join room 'dev@jabberserver.tld'
19:00:07 INFO     errbot.plugins.ChatRoom   Joining room dev@jabberserver.tld with username Bender
```

... Bender joined the chat.

## Success

Yes. Now we can run commands like `!help` and `!help Plugins` to interact with
the bot.

That’s it for now. In [Part II](/writes/adventures-with-errbot-part-2), I
will explore installing plugins, and later maybe write my own plugin.

Was this guide useful? Did you notice any mistakes?
[<i class="fa fa-twitter"></i>Tell me](https://twitter.com/alimacio).
