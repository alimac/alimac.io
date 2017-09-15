---
title: Adventures with Errbot, Part 2
date: 2015-11-13
categories:
  - Guides
tags:
  - python
  - jabber
  - xmpp
  - open source
aliases:
  - /writes/adventures-with-errbot-part-2
showSocial: false
comments: false
---

In [Part 1](/adventures-with-errbot-part-1), I wrote about installing and
configuring [Errbot](http://errbot.net) to use with a Jabber server.
Now let’s look at installing plugins for Errbot.
<!--more-->

There is [a list of over 200 plugins](https://github.com/gbin/err/wiki) for
Errbot. You can ask the bot about available plugins with `!repos` command.
The command may take a few moments to run, but the list it generates is much
shorter. From that list, I picked ` err-time`, so that my bot (Bender), could
tell me what time it is in different cities around the world.

## Install a plugin

The command to install a plugin is `!repos install plugin-source`, where
`plugin-source` can be the plugin name (like `err-time`) or a git repository
(`https://github.com/gbin/err-time`). For plugins listed with the `!repos`
command, you can use the plugin name.

Plugins can only be installed by opening a direct chat to the bot. If you try
to install a plugin in a group chat the bot will tell you as much:

<img class="img-responsive" alt="You cannot administer the bot from a chatroom"
  src="/images/2015-11-13-adventures-with-errbot-part-2/message-bot-directly.png">
<span class="caption text-muted">
Bender: "You cannot administer the bot from a chatroom, message the bot directly."
</span>

Got it. I opened a chat with Bender, and tried the install command again.
Bender replied:

``` bash
This command requires bot-admin privileges.
```

Hm, but I did list my username (`alimac@jabberserver.tld`) as an admin in
the configuration file. I tried a few other variations with no success.

Finally, I found the `!whoami` bot command and asked Bender who I was:

``` bash
┏━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━┓
┃ key      ┃ value                ┃
┡━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━┩
│ person   │ dev@jabberserver.tld │
├──────────┼──────────────────────│
│ nick     │ dev                  │
├──────────┼──────────────────────│
│ fullname │ None                 │
├──────────┼──────────────────────│
│ client   │ alimac               │
└──────────┴──────────────────────┘
• string representation is 'dev@jabberserver.tld/alimac'
• class is 'XMPPMUCOccupant'
```

Well, this is strange. The bot thinks I am the room. I updated the configuration
file:

``` python
BOT_ADMINS = ('dev@jabberserver.tld',)
```

and now I was able to give admin commands to the bot in private chat.

I happened to use a chat client on another computer later, where the `!whoami`
command returned `alimac@jabberserver.tld`. I added both to `BOT_ADMINS`.

<div class="alert alert-info">
<i class="fa fa-info-circle fa-2x"></i>
The reason for these differences is caused by how you initiate a chat with
the bot. If you start the private chat by clicking on the bot’s name in a group
chat, your identity is set to <code>room@jabberserver.tld</code>. If, on the
other hand, you add the bot to your contact list and start the chat by clicking
on the contact list entry, your identity is set to
<code>username@jabberserver.tld</code>.
</div>

### Plugin dependencies

I ran `!repos install err-time` again:

``` bash
Some plugins are generating errors:
You need those dependencies for /var/lib/err/plugins/err-gitbot: pytz
Plugins reloaded without any error.
```

On the server where I installed Errbot, I ran `sudo pip install pytz`. Back
in the chat room, I could now ask Bender what time it was in various places
with `!time city-name`:

<img class="img-responsive" alt="Asking bot what time it is"
  src="/images/2015-11-13-adventures-with-errbot-part-2/err-time.png">
<span class="caption text-muted">
Testing the <code>err-time</code> plugin.
</span>

## Installed plugins

You can find out which plugins are installed by asking `!status plugins`:

``` bash
Plugins

┏━━━━━━━━┳━━━━━━━━━━━━━━━━┓
┃ Status ┃ Name           ┃
┡━━━━━━━━╇━━━━━━━━━━━━━━━━┩
│ A      │ ACLs           │
├────────┼────────────────┤
│ A      │ Backup         │
├────────┼────────────────┤
│ A      │ ChatRoom       │
├────────┼────────────────┤
│ A      │ DnsUtils       │
├────────┼────────────────┤
│ A      │ Health         │
├────────┼────────────────┤
│ A      │ Help           │
├────────┼────────────────┤
│ A      │ Kudos          │
├────────┼────────────────┤
│ A      │ Plugins        │
├────────┼────────────────┤
│ A      │ TimeBot        │
├────────┼────────────────┤
│ A      │ Utils          │
├────────┼────────────────┤
│ A      │ VersionChecker │
├────────┼────────────────┤
│ A      │ WeatherBot     │
├────────┼────────────────┤
│ C      │ Webserver      │
└────────┴────────────────┘
 A = Activated, D = Deactivated, B = Blacklisted, C = Needs to be configured
```

As you can see, I installed a few other plugins.

### WeatherBot

This plugin allows me to ask the bot about the weather in various places with
`!weather location`, where `location` can be a city or country.

After installing the plugin (`!repos install err-weather`), it needs to be
configured with [an API key from OpenWeatherMap](http://openweathermap.org/appid)
and optionally, the temperature units (Celsius or Fahrenheit).

Once you get an API key, configure WeatherBot using the following command:

``` bash
!plugin config WeatherBot
{'api_key': '1ba5cf124541ba5cf12454', 'units': 'imperial'}
```

Then, ask about the current weather in say, Fairbanks, Alaska:

``` bash
!weather fairbanks
Found it! it looks like the forecast is 'overcast clouds'
Here’s some more info:
Location: Fairbanks, US at 2015-11-07 16:10:20
Temperature: 23.61F [ low: 23.61F \ high: 23.61F]
Humidity: 92%
Wind: 268.5 5.44 m/s
Pressure: 989.64hP
```


### Kudos

Another nice plugin to have is one that gives virtual thanks or praise to
others. But, what are kudos?

> In the 19th century, **kudos** entered English as a singular noun,
> a transliteration of a Greek singular noun kŷdos meaning “praise or renown.”
- [Dictionary.com](http://dictionary.reference.com/browse/kudos)

To install this plugin all you need is `!repos install https://github.com/sijis/err-kudos.git`.

Once installed, you can give kudos with `username++`:

```
Bender++
```

And check "kudo points" with `!kudos username`:

```
!kudos Bender
Bender has 4 kudo points.
```

### DnsUtils

The DnsUtils plugin gives us the ability to run `!dig`, `!host` and `!nslookup`
right in the chat. Use `!repos install err-dnsutils` to install the plugin.

Now you can run DNS lookup commands in the chat:

``` bash
!host 8.8.8.8
8.8.8.8.in-addr.arpa domain name pointer google-public-dns-a.google.com.
```



And that’s all for now. In [Part III](/writes/adventures-with-errbot-part-3),
I will tackle creating my own plugin for Errbot.

Was this guide useful? Did you notice any mistakes?
[<i class="fa fa-twitter"></i>Tell me](https://twitter.com/alimacio).
