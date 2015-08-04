---
layout: default
use: [writes]

---

Writes!

<ul>
{% for post in data.writes %}
  <li>
    <a href="{{ post.url }}">{{ post.title }}</a>
  </li>
{% endfor %}
</ul>
