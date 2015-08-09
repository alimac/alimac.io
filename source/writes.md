---
layout: default
use: [writes]

---

# /writes

<ul>
{% for post in data.writes %}
  <li>
    <a href="{{ post.url }}">{{ post.title }}</a> {{ post.date|date("F Y") }}
  </li>
{% endfor %}
</ul>
