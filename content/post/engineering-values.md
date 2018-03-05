---
title: "Engineering Values"
date: 2017-10-31T07:49:47-05:00
categories:
- Personal
tags:
keywords:
- tech
showSocial: false
comments: false
---

When the word "values" comes up, people often think of one-word ideas, like ___honesty___ or __integrity__. When touted as organizational values, these are sometimes prefaced with adjectives intended to pump them up, such as "relentless" and "unstoppable".

<!--more-->
(What does "unstoppable honesty" even mean?)

Lately, I've been thinking a lot about about the core beliefs that make up how I approach work every day. I wanted to skip the high-level concepts, and dive into the low-level directives that are integral to my work.

## 1. Be open about not knowing (how to do) something

For a long time, I  thought that admitting that I did not know, or did not understand something would make others see me as a bad engineer. That my colleagues' opinion of me will be lower, if I revealed my lack of knowledge of a particular subject. [These are not exactly unfounded fears.](https://xkcd.com/385/)

My manager at the time would invite me to their office to run ideas by me. A lot of the concepts went over my head, and I struggled with providing good feedback. I thought I was incompetent for not understanding quickly enough, or following their train of thought.

One day, I broke through and asked _"What does this mean?"_. And followed up with _"I don't understand X, can you provide a brief background?"_ I started to raise my hand to gesture a pause and admit _"You lost me at C. We have A and I understand B, but how does C come into play?"_.

Now, this would not work if questions and statements like those were not safe to make. But I was fortunate to be in an environment where my questions were met with answers rather than ridicule or a _"how can you not know this already?"_.

By "breaking the glass" that protected my lack of knowledge, I became more engaged with the conversations, and the projects and tasks that followed.

### How do I practice this value?

I state publicly (at meetings, in team chat) _"I have not done X before,"_ or _"I don't know how to do Y"_. It is possible that 30 minutes from now, after some research, I will have already done X. But the starting point is always admitting first to myself, and then to my colleagues, that I do not now something.

In addition, I will also state what I _do_ know, such as similar tasks, technologies, or any assumptions I might have. This is to establish a starting point, a kind of baseline where I can meet other folks' knowledge.

### How does it benefit my team?

Being open about what I don't know benefits my team in a couple of ways:

1. My senior colleagues will know from the start that the task might take me longer, or that I might ask them for insight as I work on it.
1. It exposes my ignorance which is helpful to junior colleagues to reinforce the idea that good engineers do not have all the answers at all times, and that the process of learning and filling knowledge gaps is continuous.
1. It shows that exposing ignorance is a safe action. I do not want to work in places where exposing ignorance is not safe to do, because that kind of environment is dangerous.
1. Stating my assumptions presents an easy way for my colleagues to confirm them, or debunk them. Consider this: I’m given a task I haven't done before (that isn't documented yet). After a quick research, I might post in team chat: _"I have not done this before, but I think I need to take steps: 1. [...], 2. [...], and 3. [...]"_. Rather than start from scratch, a colleague might scan the list and reply _"Don't forget to do Z, it should be done ahead of step 2 on your list"_ or _"Instead of 2. run this command [...]"_.

## 2. Document everything I do

Last year I engaged in some contract-based work. It was a new experience, one which I enjoyed for its flexibility. From the start, I decided to keep a daily log of tasks that I worked on, in order to substantiate the hours billed.

Even after I returned to full-time employment, I continued this practice. Every day, I open a new page in Notes or Evernote and list tickets or tasks to be done. If anything comes up urgently, I also add it to the list. If I learn something as part of working on a task, such as new commands, I include them as well. At the end of the day I also paste a list of URLs of articles I found helpful (software documentation, Stack Overflow answers, etc).

### How do I practice this value?

When I am working on a ticket, I post a summary of what I have done to complete a task, or resolve a particular issue, including any commands and relevant output. My goal is to leave enough information so that a colleague (or myself a few weeks or months from now) can follow and replicate the steps, if needed.

Sometimes it is appropriate to transfer this content to a more permanent documentation space, such as a wiki. If I create new documentation in a wiki, or make a significant update, I post a link to the it within the ticket for easy reference.

### How does it benefit my team?

Intra-team and inter-team communication is crucial to building trust and affinity. It is important to me to post timely updates to all of the conversations I participate in, whether they are tickets or chats. This includes my reaching out to external parties. For example, _"I opened a ticket with our X service provider. Here is the ticket ID, viewing link, and a screenshot of my initial report."_

My goal is that in event I become ill, or leave unexpectedly, the work I participated in can be continued by another colleague after reading through the log of the conversation.

I have a slightly morbid joke about this: in case of sudden death, I would like for my colleagues to attend my funeral party without worries. All of my work was conducted in the open, and is documented, so raise a glass!

## 3. Experiment

Growth happens in different ways. Sometimes, during high-stakes triage and troubleshooting. It can also happen through experimentation, or hypothesizing, building out proof of concept systems, and course-correcting along the way.

### How do I practice this value?

At one previous job, my colleagues and I interacted with a cloud service provider. We had a number of environments with this provider, and keeping track of how to connect to services in each environment was a pain point.

So I took some time to experiment.

I came up with a set of shell scripts built on top of the provider's own command line interface, that made it easy to switch between environments, and to connect to the services in each environment. The scripts performed a on-demand lookups so that even if the service changed it network location, we could still connect to it with a two-word command.

### How does it benefit my team?

Without taking the time to experiment, we might have gone the route of maintaining a static inventory of services and their network locations. Instead, experimenting to develop these scripts inspired my colleagues to make further, human-centered improvements to them.

By the way, observing how people work, and figuring out how to make it easier for folks to do their work is kind of my jam. Some folks have described this role as developer advocate or developer experience.

## 4. Make small incremental improvements

Many years ago, I worked on a directory listing app. We got a few requests for making the search output available in a way that another website could consume. This way, the directory information did not have to be duplicated and maintained in more than one place.

I thought, _"We can totally do this, I'll add a flag that will generate output in JSON!"_ Excited, I ran with this idea to my boss. He agreed, but scaled up the implementation to an extent where it would become a major project, instead of a feature that I was confident I could deliver in a few hours. I smiled and nodded (this was long before I started practicing my first engineering value).

As I walked out of his office, I felt daunted by the scale of his suggestion. I did not have a starting point for implementing his ambitious, abstracted design, so I ended up dropping the idea altogether. The feature never got implemented.

In her talk about [Livable Code](https://vimeo.com/231672897) Sarah Mei makes a point about the codebase as a space where teams "live", and outlines some rules that teams can agree to follow to make those spaces more livable. One such rule is "Improvement over consistency" -- for example, reshelving a single book out of a pile rather than waiting until the perfect time to address the entire pile.

There is a balance to be struck between striving for big impact (say, replacing a shabby couch) and persisting at making smaller, less implactful improvements (washing or straightening the blanket that covers the shabby couch).
 
### How do I practice this value?
 
Whenever a technical quandary presents itself, I try to find an immediate solution (which might be a workaround), followed by short to mid-term solution (which might involve a few hours' work), and a long-term solution (one that might require further research or prototyping).

Not all of my "immediate solutions" are worth implementing. Sometimes the drawbacks of taking a shortcut outweigh their benefits, and should be avoided. I worked with a very talented engineer who would very kindly shoot those down. She would encourage me to take the time to think one step beyond satisfying the immediate conditions. To push back just enough so that a more sustainable solution can be built.

### How does it benefit my team?

As exciting as working on new services can be, I find much joy in maintenance -- taking an existing service and figuring out low-cost ways to improve it. I was once a caretaker of an application that automated account setups. There were known issues, but since both myself and my colleague (the primary admin user of the application) were both busy, we never prioritized investigating these issues. Off and on, rumors floated about an upstream solution that would replace the app entirely. Not to mention that since I haven't worked on the backend code for a while, I  dreaded having to load it back into my memory.

In my last two weeks with the organization, I decided to push the dread aside and dive into the murky pool of code. I was able to identify the issues, and came up with a few optimizations that reduced the amount of manual work my coworker had been doing. It turned out to be easier than expected, and it was a kind of parting gift. In retrospect, I wish I had done this dive sooner.

Since then, I'm always keeping my eyes open for all places where a small incremental improvement can make a big impact in my colleagues lives.
