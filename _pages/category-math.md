---
title: "math"
layout: archive
permalink: /categories/math
author_profile: true
---

{% assign posts = site.categories.math %}
{% for post in posts %} {% include archive-single.html type=page.entries_layout %} {% endfor %}