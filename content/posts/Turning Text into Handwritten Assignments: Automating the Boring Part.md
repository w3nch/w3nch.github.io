---
title: "Turning Text into Handwritten Assignments: Automating the Boring Part"
date: 2023-04-15
tags: ["python", "automation", "cli-tools", "productivity", "student-life"]
categories: ["Projects", "Automation"]
draft: false
---



Let me start with the real reason this project exists.

My college keeps giving assignments and insists that they must be **handwritten**. Not typed. Not PDFs generated from Word. Handwritten and after writing everything, we still have to **scan or take photos and upload them to a Google Form**.

If you’ve ever done this, you already know how annoying it is.

Writing multiple pages by hand takes time, your hand starts hurting, and half the effort goes into making sure it looks neat enough to upload. The funny part? The assignment was already written digitally in the first place.

So I did what any tired student who knows a bit of coding would do:  
I decided to automate it.

![](https://c.tenor.com/RSc9Gw10HnsAAAAd/tenor.gif)


## The Idea

The goal was simple:

- Write the assignment normally as text
    
- Convert it into something that _looks handwritten_
    
- Upload it like everyone else
    

No fancy AI. No online services. Just a tool that saves time and sanity.

I wanted it to be:

- Fully offline
    
- Fast
    
- Easy to use
    
- Scriptable from the command line
    

## The First Attempt (and Why It Failed)

Like most people, I first tried libraries that promise “text to handwriting” in one function call. One popular example is `pywhatkit`.

On paper, it sounds perfect. In reality, it relies on an external API.

That caused problems almost immediately:

- Sometimes it worked, sometimes it didn’t
    
- Internet was required
    
- Random errors like “Unable to access API”
    
- No control over fonts or layout

![](https://i.ibb.co/RTDNcM49/2026-01-22-15-12.png)

For something as basic as converting text to handwriting, this felt unnecessarily fragile. If I’m already writing code, I want it to work every time.

So I scrapped that idea.
![](https://i.ibb.co/gXpJ1xh/2026-01-22-15-11.png)

## Rethinking the Problem
Instead of thinking “convert text into handwriting,” I changed the way I looked at it.

What I actually needed was this:

- Take text from a file
    
- Draw it onto a page
    
- Use a handwriting-style font
    
- Save the result as an image
    

That’s it.

Once you see it this way, the problem becomes much simpler and much more reliable.

## Why I Chose PNG Instead of PDF

At first, PDF seemed like the obvious choice. But PDFs come with annoying font restrictions, especially with decorative or calligraphy fonts.

PNG images are way more flexible:

- Almost any font works
    
- No font embedding issues
    
- Easy to preview
    
- Easy to upload to Google Forms
    
- Can be converted to PDF later if needed
    

Since the college only cares about seeing “handwritten” pages, PNG was more than enough.

## The CLI Workflow

I didn’t want a GUI. I wanted something fast.

The ideal workflow looks like this:

- Write the assignment in `input.txt`
    
- Run one command
    
- Get a handwritten image out
    

Something like:  
txt2hand input.txt output.png

That’s it.

This makes it easy to:

- Regenerate pages if something changes
    
- Try different fonts
    
- Batch-convert multiple assignments
    
- Automate everything
    

## The Tools That Made It Work

Here’s everything the tool actually uses:
    
- **Pillow (PIL)**  
    This is the core library. It’s used to create images, load handwriting fonts, and draw text onto a blank page.
    
- **A handwriting font (TTF or OTF)**  
    Any handwritten-style font works. This gives the output its “handwritten” look. Google Fonts.i used caveat here.
    

That’s it. No APIs. No internet. No background services.
    

Pillow lets you draw text directly onto an image, and unlike PDF tools, it doesn’t complain about artistic fonts. That meant I could use fonts that actually look like real handwriting.

Once the basics were working, it was easy to add small touches like:

- Slight text jitter
    
- Imperfect line spacing
    
- Natural margins
    

Those tiny imperfections make a huge difference. Perfect alignment looks fake. Slight messiness looks human.

You can install the only dependency like this:

```bash
pip install pillow
```

## How the Tool Works Internally

At a high level, the process looks like this:

1. Read the assignment text from a `.txt` file
    
2. Create a blank A4-sized image
    
3. Load a handwriting-style font
    
4. Draw each line of text onto the image
    
5. Add small random offsets to make it look human
    
6. Save the final result as a PNG image
    

Simple, predictable, and fully offline. The code can be found on my GitHub.

## Why the Randomness Matters

If you render text perfectly aligned, it immediately looks fake. Real handwriting has tiny inconsistencies.

That’s why the script adds:

- Small horizontal and vertical offsets
    
- Natural line spacing
    
- Soft margins
    
These imperfections make the output feel human instead of robotic.
## The Result

![](https://i.ibb.co/LhHTWfFc/handwritten-page-1.png)

Now instead of writing pages by hand, my workflow is:

- Write the assignment once
    
- Run the tool
    
- Upload the generated handwritten image
    
Adjust the values as you like the size , font , color add in more image  

from this whole thing the best part?  
Other students can use it too.

## Final Thoughts
I know this might not look the best but if it works it work **Don't Touch it**

This wasn’t about cheating or shortcuts. The work is still done. The content is still written. The only thing automated is the boring, repetitive part that adds no real value.

If colleges want handwritten submissions but accept digital uploads, tools like this are inevitable.

Sometimes the best motivation to build something isn’t innovation  it’s pure frustration.

And honestly?  
My wrist has never been happier.