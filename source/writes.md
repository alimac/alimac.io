---
layout: default
use: [posts]

---

# /writes

<ul>
{% for post in data.posts %}
  <li>
    <a href="{{ post.url }}">{{ post.title }}</a> {{ post.date|date("F Y") }}
  </li>
{% endfor %}
</ul>
