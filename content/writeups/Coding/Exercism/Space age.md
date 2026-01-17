---
title: "Space Age"
date: 2026-01-17
tags: ["python", "oop", "space-age", "programming-basics", "exercism"]
categories: ["Programming", "Python"]
draft: false
---

## Introduction

The year is 2525 and you've just embarked on a journey to visit all planets in the Solar System (Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus and Neptune). The first stop is Mercury, where customs require you to fill out a form (bureaucracy is apparently _not_ Earth-specific). As you hand over the form to the customs officer, they scrutinize it and frown. "Do you _really_ expect me to believe you're just 50 years old? You must be closer to 200 years old!"

Amused, you wait for the customs officer to start laughing, but they appear to be dead serious. You realize that you've entered your age in _Earth years_, but the officer expected it in _Mercury years_! As Mercury's orbital period around the sun is significantly shorter than Earth, you're actually a lot older in Mercury years. After some quick calculations, you're able to provide your age in Mercury Years. The customs officer smiles, satisfied, and waves you through. You make a mental note to pre-calculate your planet-specific age _before_ future customs checks, to avoid such mix-ups.
## Instructions

Given an age in seconds, calculate how old someone would be on a planet in our Solar System.

One Earth year equals 365.25 Earth days, or 31,557,600 seconds. If you were told someone was 1,000,000,000 seconds old, their age would be 31.69 Earth-years.

For the other planets, you have to account for their orbital period in Earth Years:

| Planet  | Orbital period in Earth Years |
| ------- | ----------------------------- |
| Mercury | 0.2408467                     |
| Venus   | 0.61519726                    |
| Earth   | 1.0                           |
| Mars    | 1.8808158                     |
| Jupiter | 11.862615                     |
| Saturn  | 29.447498                     |
| Uranus  | 84.016846                     |
| Neptune | 164.79132                     |
**NOTE:**
```
The actual length of one complete orbit of the Earth around the sun is closer to 365.256 days (1 sidereal year). The Gregorian calendar has, on average, 365.2425 days. While not entirely accurate, 365.25 is the value used in this exercise. See [Year on Wikipedia](https://en.wikipedia.org/wiki/Year#Summary) for more ways to measure a year.
```
For the Python track, this exercise asks you to create a `SpaceAge` _class_ (_[classes](https://exercism.org/tracks/python/concepts/classes)_) that includes methods for all the planets of the solar system. Methods should follow the naming convention `on_<planet name>`.

Each method should `return` the age (_"on" that planet_) in years, rounded to two decimal places:

```python
#creating an instance with one billion seconds, and calling .on_earth().
>>> SpaceAge(1000000000).on_earth()

#This is one billion seconds on Earth in years
31.69
```

For more information on constructing and using classes, see:

- [**A First Look at Classes**](https://docs.python.org/3/tutorial/classes.html#a-first-look-at-classes) from the Python documentation.
- [**A Word About names and Objects**](https://docs.python.org/3/tutorial/classes.html#a-word-about-names-and-objects) from the Python documentation.
- [**Objects, values, and types**](https://docs.python.org/3/reference/datamodel.html#objects-values-and-types) in the Python data model documentation.
- [**What is a Class?**](https://www.pythonmorsels.com/what-is-a-class/) from Trey Hunners Python Morsels website.


## Logic

We are not changing time itself, we are only changing what a “year” means. We start with a large number of seconds and ask how many years fit into that time. On Earth, a year has a fixed length in seconds, so we divide by that value. On other planets, a year is shorter or longer than an Earth year, so we adjust the year length first and then divide. The same seconds give different ages because each planet takes a different amount of time to go around the sun. In the end, we round the result so it matches how we normally talk about age.

```python
age = seconds / (EARTH_YEAR * planet_year_ratio)
```

![](https://i.ibb.co/tw4RTHGX/Pasted-image-20260117155211.png)
- We start by defining `EARTH_YEAR = 31557600` as a constant, since one Earth year has 31,557,600 seconds.
    
- Instead of hard-coding values inside each method, we store the orbital periods in a table so the data is centralized and easy to extend with new planets later.
    
- We then create a `SpaceAge` object by passing in a number of seconds, which gets saved inside the object for reuse.
    
- After that, we write a private helper method that performs the core age calculation, avoiding repeated logic across multiple methods.
    
- Finally, we create planet-specific methods like `on_earth`, `on_mars`, and others, which simply call the helper method with the correct planet name.
![](https://i.ibb.co/8n2F1Zct/Pasted-image-20260117155233.png)
