---
title: "What Happens If You Import os on LeetCode?"
date: 2026-01-29
tags: [leetcode, python, sandbox, curiosity, hacking]
categories: [Learning, Experiments]
draft: false
---

**Disclaimer:** I do not promote hacking or abusing systems without permission. Everything shown here is purely for learning and experimentation.

I was doing what I usually do solving problems on **LeetCode** using python when a random thought popped into my head:

> _What if I import `os` and try to run something on the system?_

So I took a basic problem, **Two Sum**, solved it normally… and then added a tiny extra line at the end.
```python
import os

class Solution:
	def twoSum(self, nums: List[int], target: int) -> List[int]:
		seen = {}
		get = seen.get
	for i, n in enumerate(nums):
		j = get(target - n)
		if j is not None:
			return [j, i]
		seen[n] = i

files = os.listdir(".")
print(files)
```
To my surprise (and honestly, not much surprise ), it **did produce output** a list of files present in the working directory.


![](https://i.ibb.co/v6qVXtr8/Pasted-image-20260129135006.png)


## What’s Really Going On?

The code is clearly being executed inside a **sandboxed environment**. This is expected online judges like LeetCode _must_ isolate user code. Still, it’s interesting to see how permissive that sandbox is at a basic level.

Now, just to be clear:  
I’m **not** attempting any sandbox escape or bypass here. This is just curiosity exploration.

### Messing with Runtime
LeetCode displays runtime metrics, so naturally, I wondered how that value is being calculated. For fun, I tried tweaking the runtime display by changing the execution behavior at exit:
```python
import atexit; atexit.register(lambda: open("display_runtime.txt","w").write("0") or None)
```
basically what this code does is  overwrote `display_runtime.txt`, result with 0 value and as runtime tries to display it comes out as **0ms**.

![](https://i.ibb.co/QFsjxmxc/Pasted-image-20260129135818.png)
## Should You Do This?

Absolutely not.
This won’t improve:
- Your problem solving skills
- Your algorithmic thinking
- Your understanding of data structures
But what it _does_ help with is understanding:
- How online judges execute code
- How sandboxes are structured
- How runtime and metadata might be handled on the backend

There are more interesting files in the environment too, if you’re curious enough to look but again, **this is for learning, not abuse**.
