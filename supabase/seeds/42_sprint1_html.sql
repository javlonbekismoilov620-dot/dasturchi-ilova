-- Sprint 1 · HTML from Absolute Zero (English). Idempotent; existing rows keep IDs.
do $content$
declare
  c constant text := 'html-from-absolute-zero';
  q uuid;
begin
  perform seed.ensure_module(c, 'Links, images and media', 'Connect pages together and add pictures.');
  perform seed.ensure_module(c, 'Forms and accessibility', 'Collect input from people and build pages that everyone can use.');
  perform seed.ensure_module(c, 'Publish your site', 'Put your site on the internet and finish your portfolio.');

  perform seed.ensure_lesson(c, 'Structuring content', 'Tables for real data', 'article', 9,
    'Present timetables, prices and results in tables that people and screen readers understand.',
$md$## When a table is the right choice

A table shows **data with rows and columns**: a class timetable, a price list, sports results. If the information would make sense in a spreadsheet, a table is right. In this lesson you will build a correct, accessible HTML table.

> [!WARNING]
> Never use tables to arrange the layout of a page (for example, to put a menu beside the text). That was common in the 1990s; today layout is a job for CSS, and layout tables confuse screen readers.

## Building a table

```html
<table>
  <caption>Monday timetable</caption>
  <thead>
    <tr>
      <th scope="col">Time</th>
      <th scope="col">Subject</th>
      <th scope="col">Room</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>09:00</td>
      <td>Mathematics</td>
      <td>204</td>
    </tr>
    <tr>
      <td>10:00</td>
      <td>History</td>
      <td>112</td>
    </tr>
  </tbody>
</table>
```

What each element does:

- `<table>` wraps the whole table.
- `<caption>` gives the table a title. It is read first by screen readers.
- `<thead>` holds the header row; `<tbody>` holds the data rows.
- `<tr>` is a **t**able **r**ow.
- `<th>` is a **header cell** — bold and centred by default.
- `<td>` is an ordinary **data cell**.

## Headers that help everyone

The `scope` attribute tells assistive technology which cells a header describes: `scope="col"` for a column header and `scope="row"` for a row header. When a screen reader announces a cell, it can then say “Room, 204” instead of just “204”.

## Merging cells

Sometimes one cell should cover several columns or rows:

```html
<tr>
  <td>12:00</td>
  <td colspan="2">Lunch break</td>
</tr>
```

`colspan="2"` makes the cell two columns wide; `rowspan` does the same for rows. Use merging sparingly — complex tables are hard to read on small screens and for screen-reader users.

## Try it

Build a table of your weekly timetable (or a fictional one) with a caption, a header row and at least five days as rows. Check that every row has the same number of cells.

## Common mistakes

- Using a table for page layout.
- Forgetting `<th>` and `<caption>`, so the table has no clear meaning.
- Rows with different numbers of cells, which shifts columns out of place.

## Key terms

- **Table row (`<tr>`)** — one horizontal line of cells.
- **Header cell (`<th>`)** — a cell that labels a row or column.
- **Data cell (`<td>`)** — a cell containing a value.
- **Caption** — the title of a table.$md$);

  perform seed.ensure_lesson(c, 'Structuring content', 'Structuring content: check', 'quiz', 5,
    'Five questions on headings, lists and tables.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Structuring content: check', 'Structuring content check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'Which of these should be built as an HTML table?',
    'Tables are for data with rows and columns, such as a timetable.',
    array['A weekly class timetable', 'Placing a menu next to the main text', 'A list of ingredients'],
    array[true, false, false],
    array[null, 'Layout is a job for CSS, not tables.', 'A simple list of items belongs in `<ul>`.']);
  perform seed.ensure_question(q, 1, 'single_choice', 'Which element labels a column of a table?',
    '`<th>` is a header cell; `scope="col"` says it labels a column.',
    array['`<th>`', '`<td>`', '`<tr>`'], array[true, false, false],
    array[null, '`<td>` holds ordinary data.', '`<tr>` is a whole row.']);
  perform seed.ensure_question(q, 2, 'single_choice', 'What does `colspan="2"` do?',
    'It makes one cell stretch across two columns.',
    array['Makes a cell span two columns', 'Adds two empty rows', 'Doubles the font size'], array[true, false, false], null);
  perform seed.ensure_question(q, 3, 'single_choice', 'You list the steps of a recipe in order. Which element fits best?',
    'Ordered steps belong in an ordered list, `<ol>`.',
    array['`<ol>`', '`<ul>`', '`<table>`'], array[true, false, false],
    array[null, '`<ul>` is for items whose order does not matter.', 'A table is for data in rows and columns.']);
  perform seed.ensure_question(q, 4, 'true_false', 'True or false: a page should have exactly one `<h1>`, and heading levels should not be skipped.',
    'True — one main heading, then `<h2>`, `<h3>` and so on in order.',
    array['True', 'False'], array[true, false], null);

  perform seed.ensure_lesson(c, 'Links, images and media', 'Links: connecting the web', 'article', 9,
    'Absolute and relative links, links inside a page, and opening new tabs safely.',
$md$## The “hyper” in hypertext

Links are what make the web a web. In this lesson you will create links to other sites, to your own pages and to places within a page.

```html
<a href="https://developer.mozilla.org">MDN Web Docs</a>
```

`<a>` stands for **anchor**. The `href` attribute holds the destination; the text between the tags is what people click.

## Absolute and relative addresses

- An **absolute URL** contains the full address, including `https://`. Use it for other websites.
- A **relative URL** describes where a file is **compared to the current page**. Use it for pages and files in your own site.

Imagine this site:

```text
my-site/
├── index.html
├── about.html
└── projects/
    └── game.html
```

| From | To | Relative link |
| --- | --- | --- |
| `index.html` | `about.html` | `about.html` |
| `index.html` | `projects/game.html` | `projects/game.html` |
| `projects/game.html` | `index.html` | `../index.html` |

`../` means “go up one folder”. Relative links keep working when you move the whole site to a server.

## Links within a page

Give an element an `id`, then link to it with `#`:

```html
<a href="#contact">Jump to contact details</a>
<h2 id="contact">Contact</h2>
```

## Opening a new tab

```html
<a href="https://example.com" target="_blank" rel="noopener">Example (opens in a new tab)</a>
```

`target="_blank"` opens a new tab. Add `rel="noopener"` so the new page cannot control yours. Open new tabs only when there is a good reason, and say so in the link text.

## Email and phone links

- `<a href="mailto:hello@example.com">Email us</a>` opens the email app.
- `<a href="tel:+998901234567">Call us</a>` starts a call on phones.

## Writing good link text

Link text should make sense on its own. Screen-reader users often jump from link to link, hearing only the link text.

> [!TIP]
> Write “Read the timetable” instead of “Click here”. Clear link text also helps search engines understand your pages.

## Try it

Create `index.html` and `about.html` in the same folder. Add a navigation list to each page that links to the other one, and add a link that jumps to a section further down the page.

## Common mistakes

- Using absolute paths from your own computer (`C:\Users\...`) — they break on any other device.
- Forgetting `https://` for external links, so the browser treats them as files in your site.
- Vague link text such as “here” or “more”.

## Key terms

- **Anchor (`<a>`)** — the link element.
- **Absolute URL** — a full address including the protocol.
- **Relative URL** — an address relative to the current file.
- **Fragment (`#id`)** — a link to a place within a page.$md$);

  perform seed.ensure_lesson(c, 'Links, images and media', 'Images done right', 'article', 9,
    'Formats, sizes and alternative text for images that load fast and work for everyone.',
$md$## Adding an image

In this lesson you will add images that load quickly, keep the page stable and are described for people who cannot see them.

```html
<img src="images/samarkand.jpg" alt="Registan square at sunset" width="800" height="533">
```

- `src` — the file to show (a relative or absolute URL).
- `alt` — a text description of the image.
- `width` and `height` — the image's size in pixels. Giving them lets the browser reserve space, so the text does not jump when the image loads.

## Choosing a format

| Format | Best for |
| --- | --- |
| **JPEG** (`.jpg`) | Photographs |
| **PNG** (`.png`) | Screenshots and images that need transparency |
| **WebP** (`.webp`) | Photos and graphics, usually smaller than JPEG or PNG |
| **SVG** (`.svg`) | Logos, icons and illustrations made of shapes — sharp at any size |

## Size matters

A photo straight from a phone can be 4000 pixels wide and several megabytes. Shown at 800 pixels wide, most of that data is wasted and the page loads slowly on mobile data.

1. Resize the image to roughly the largest size it will be shown at.
2. Export it with moderate compression.
3. Add `loading="lazy"` to images further down the page so they load only when needed.

## Writing alternative text

Alternative text (**alt text**) is read aloud by screen readers and shown if the image fails to load.

- Describe what matters in this context: `alt="Bar chart: sales doubled between March and June"`.
- Do not start with “Image of…” — screen readers already say it is an image.
- For purely decorative images, use an empty alt: `alt=""`. The screen reader then skips them.

> [!WARNING]
> Never leave the `alt` attribute out entirely. Without it, many screen readers read the file name aloud, such as “IMG underscore 4 0 3 2 dot jpg”.

## Captions

To give an image a visible caption, wrap it in `<figure>`:

```html
<figure>
  <img src="images/plov.jpg" alt="A large kazan of plov with carrots and raisins" width="600" height="400">
  <figcaption>Plov cooked for a family celebration.</figcaption>
</figure>
```

## Try it

Add three images to your site: a photo (JPEG or WebP), a logo or icon (SVG or PNG) and one decorative image. Resize the photo before adding it, and write suitable alt text for each.

## Common mistakes

- Uploading huge photos and shrinking them with HTML or CSS.
- Missing `width` and `height`, which makes the layout jump.
- Alt text that says nothing useful, such as `alt="photo"`.

## Key terms

- **Alt text** — a text alternative for an image.
- **Lossy / lossless** — compression that discards some detail (JPEG) or none (PNG).
- **Lazy loading** — loading an image only when it is about to appear.
- **`<figure>` / `<figcaption>`** — an image with a visible caption.$md$);

  perform seed.ensure_lesson(c, 'Links, images and media', 'Links and images: check', 'quiz', 5,
    'Five questions on links, paths and images.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Links and images: check', 'Links and images check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'From `projects/game.html`, which link goes back to `index.html` in the folder above?',
    '`../` means “go up one folder”.',
    array['`../index.html`', '`index.html`', '`/projects/index.html`'], array[true, false, false],
    array[null, 'That looks for `index.html` inside the `projects` folder.', 'That points to a file that does not exist.']);
  perform seed.ensure_question(q, 1, 'single_choice', 'Which alt text is right for a purely decorative swirl image?',
    'Decorative images get an empty alt so screen readers skip them.',
    array['`alt=""`', '`alt="swirl.png"`', 'No alt attribute at all'], array[true, false, false],
    array[null, 'File names are not useful descriptions.', 'Without alt, screen readers may read out the file name.']);
  perform seed.ensure_question(q, 2, 'single_choice', 'Which format is best for a company logo that must look sharp at every size?',
    'SVG is a vector format, so it stays sharp at any size.',
    array['SVG', 'JPEG', 'A screenshot of the logo'], array[true, false, false],
    array[null, 'JPEG is designed for photographs and blurs sharp edges.', 'Screenshots are pixel images and blur when enlarged.']);
  perform seed.ensure_question(q, 3, 'single_choice', 'Why add `rel="noopener"` to a link with `target="_blank"`?',
    'It stops the newly opened page from controlling the original page.',
    array['So the new page cannot control your page', 'To make the link load faster', 'To make the text bold'], array[true, false, false], null);
  perform seed.ensure_question(q, 4, 'single_choice', 'Which link text is best?',
    'Link text should describe the destination on its own.',
    array['Read the exam timetable', 'Click here', 'More'], array[true, false, false],
    array[null, '“Click here” says nothing about where the link goes.', '“More” is unclear out of context.']);

  perform seed.ensure_lesson(c, 'Forms and accessibility', 'Forms: collecting input', 'article', 10,
    'Text fields, choices and buttons with proper labels and built-in validation.',
$md$## What forms are for

Forms let people send information: signing up, searching, ordering, leaving feedback. In this lesson you will build a complete registration form with labels and validation that the browser checks for you.

```html
<form action="/register" method="post">
  <label for="name">Full name</label>
  <input id="name" name="name" type="text" required>

  <label for="email">Email</label>
  <input id="email" name="email" type="email" required>

  <label for="level">Your level</label>
  <select id="level" name="level">
    <option value="zero">Complete beginner</option>
    <option value="some">I know a little</option>
  </select>

  <label for="goal">What do you want to learn?</label>
  <textarea id="goal" name="goal" rows="4"></textarea>

  <button type="submit">Sign up</button>
</form>
```

## Labels are not optional

Every input needs a `<label>`. The label's `for` must match the input's `id`. Then:

- screen readers announce what the field is for,
- clicking the label puts the cursor in the field — a bigger target on phones.

> [!WARNING]
> A `placeholder` is not a label. It disappears as soon as someone starts typing and is often too faint to read. Use it only for an example, such as `placeholder="name@example.com"`.

## Choosing the right input type

| Type | Use it for | Bonus |
| --- | --- | --- |
| `text` | Names and short text | — |
| `email` | Email addresses | Checks the format; phones show an @ keyboard |
| `password` | Passwords | Hides the characters |
| `number` | Quantities | Number keyboard and arrows |
| `date` | Dates | A date picker |
| `checkbox` | Yes/no choices | Each can be ticked separately |
| `radio` | One choice from several | Give all options the same `name` |

## Built-in validation

The browser checks these attributes before the form is sent:

- `required` — the field cannot be empty.
- `minlength` and `maxlength` — limits on the number of characters.
- `min` and `max` — limits for numbers and dates.

Browser validation helps people fix mistakes quickly, but it can be bypassed. A real website must always check the data again on the server.

## Where the data goes

The `action` attribute is the address that receives the data, and `method` says how it is sent: `get` puts the data in the URL (good for searches), `post` sends it in the body of the request (for sign-ups and anything private). Receiving the data needs a server, which you will learn about in backend courses. For now, focus on building the form correctly.

## Try it

Build a feedback form with a name, an email, a rating from 1 to 5 (radio buttons sharing one `name`), a message and a submit button. Make the name and email required, then try submitting it empty to see the browser's messages.

## Common mistakes

- Inputs without labels, or using placeholders instead.
- Forgetting the `name` attribute, so the field's value is never sent.
- Using `type="text"` for everything and losing the right keyboard on phones.

## Key terms

- **Form** — a group of fields that sends data.
- **Label** — the visible name of a field, linked with `for` and `id`.
- **Validation** — checking that input is complete and in the right format.
- **GET / POST** — two ways of sending form data.$md$);

  perform seed.ensure_lesson(c, 'Forms and accessibility', 'Semantic layout and accessibility', 'article', 10,
    'Structure pages with landmarks and make them usable with a keyboard and a screen reader.',
$md$## Elements that describe their role

Before HTML5, pages were built from many anonymous `<div>` elements. Today we use **semantic elements** that say what each part of the page is. In this lesson you will structure a page with them and test it the way people with disabilities use the web.

```html
<body>
  <header>
    <a href="/">Aziza's portfolio</a>
    <nav>
      <ul>
        <li><a href="index.html">Home</a></li>
        <li><a href="projects.html">Projects</a></li>
        <li><a href="contact.html">Contact</a></li>
      </ul>
    </nav>
  </header>
  <main>
    <h1>Projects</h1>
    <article>
      <h2>Weather widget</h2>
      <p>A small page that shows the forecast for Tashkent.</p>
    </article>
  </main>
  <footer>
    <p>© 2026 Aziza Karimova</p>
  </footer>
</body>
```

| Element | Meaning |
| --- | --- |
| `<header>` | Introductory content, often the logo and navigation |
| `<nav>` | A group of main navigation links |
| `<main>` | The main content — only one per page |
| `<article>` | A self-contained piece, such as a post or a project |
| `<section>` | A themed section with its own heading |
| `<aside>` | Related, secondary content |
| `<footer>` | Closing information, such as copyright or contacts |

## Why semantics matter

- **Screen readers** list these **landmarks**, so users can jump straight to the navigation or the main content.
- **Search engines** understand the structure of your page better.
- **Developers** — including you, later — read the code more easily.

## Accessibility basics

Accessibility means everyone can use your site, including people who are blind, have low vision, cannot use a mouse or have a temporary injury. Most of it comes from HTML you already know:

1. Set the page language: `<html lang="uz">` or `lang="en"`.
2. Use headings in order.
3. Give every image suitable alt text.
4. Give every form field a label.
5. Make sure everything works with the keyboard alone.
6. Keep strong contrast between text and background.
7. Write link text that makes sense on its own.

## Test it yourself

- **Keyboard test:** put the mouse aside and press **Tab** to move through the page and **Enter** to follow links. You should always see where the focus is.
- **Screen reader:** try VoiceOver on Mac and iPhone, TalkBack on Android or the free NVDA on Windows for a few minutes.
- **Automatic check:** in Chrome, open **DevTools → Lighthouse** and run an **Accessibility** audit.

> [!NOTE]
> Automatic tools find only some problems. A keyboard test and a few minutes with a screen reader reveal much more.

## Try it

Rewrite a page built only from `<div>` elements using `header`, `nav`, `main`, `article` and `footer`. Then do the keyboard test and fix anything you cannot reach.

## Common mistakes

- Several `<main>` elements on one page.
- Choosing headings by size instead of structure.
- Removing the focus outline with CSS, so keyboard users get lost.

## Key terms

- **Semantic element** — an element whose name describes its meaning.
- **Landmark** — a region (header, nav, main, footer) that assistive technology can jump to.
- **Accessibility** — designing so that everyone can use a site.
- **Focus** — the element that currently receives keyboard input.$md$);

  perform seed.ensure_lesson(c, 'Forms and accessibility', 'Forms and accessibility: check', 'quiz', 5,
    'Five questions on forms, semantics and accessibility.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Forms and accessibility: check', 'Forms and accessibility check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'How do you connect a label to its input?',
    'The label''s `for` must match the input''s `id`.',
    array['The label''s `for` matches the input''s `id`', 'Put the label after the form', 'Use the same `class` on both'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'single_choice', 'Which input type should an email field use?',
    '`type="email"` checks the format and shows a suitable keyboard on phones.',
    array['`email`', '`text`', '`password`'], array[true, false, false],
    array[null, 'It works, but you lose format checking and the @ keyboard.', 'That hides the characters.']);
  perform seed.ensure_question(q, 2, 'single_choice', 'How many `<main>` elements should a page have?',
    'Exactly one `<main>` holds the page''s main content.',
    array['One', 'One per section', 'As many as needed'], array[true, false, false], null);
  perform seed.ensure_question(q, 3, 'true_false', 'True or false: a placeholder can replace a label.',
    'False — placeholders disappear while typing and are often hard to read.',
    array['True', 'False'], array[false, true],
    array['Placeholders vanish as soon as you type.', null]);
  perform seed.ensure_question(q, 4, 'single_choice', 'What is the quickest way to check that a page works without a mouse?',
    'Press Tab through the whole page and check that everything can be reached and the focus is visible.',
    array['Use only the Tab and Enter keys to go through the page', 'Make the window smaller', 'Check the page in a second browser'],
    array[true, false, false], null);

  perform seed.ensure_lesson(c, 'Publish your site', 'Publishing with GitHub Pages', 'exercise', 15,
    'Put your site on the internet for free and update it whenever you like.',
$md$## What “publishing” means

So far your pages have lived on your computer. **Publishing** means copying them to a **web server** so anyone can open them with a URL. **GitHub Pages** is a free service that publishes static sites (HTML, CSS, images) straight from a GitHub repository. In this exercise you will publish your site.

## Prepare your folder

```text
my-site/
├── index.html
├── projects.html
├── contact.html
└── images/
    └── profile.jpg
```

- The home page must be called `index.html` and sit at the top of the folder.
- Use only relative links between your pages.
- Use lowercase file names without spaces. Web servers are **case-sensitive**: `Photo.JPG` and `photo.jpg` are different files.

## Step by step

1. Create a free account at **github.com** and turn on two-factor authentication.
2. Click **New repository**. Name it `your-username.github.io` (replace with your GitHub user name), make it **Public** and create it.
3. On the repository page, choose **Add file → Upload files**, drag in the contents of your site folder (not the folder itself) and click **Commit changes**.
4. Open **Settings → Pages**. Under **Build and deployment**, check that the source is **Deploy from a branch**, the branch is **main** and the folder is **/ (root)**, then save.
5. After a minute or two, your site is live at `https://your-username.github.io/`.

## Updating your site

Upload changed files the same way, or edit them directly on GitHub. Every commit republishes the site within a minute or two. If you do not see the change, refresh the page with **Ctrl + F5** (Windows) or **Cmd + Shift + R** (Mac).

> [!WARNING]
> A published site is public. Do not put your home address, phone number, passport details or anything else private on it.

## Checking the result

- Open the site on your phone as well as your computer.
- Click every link and check that every image appears.
- Run the keyboard test from the previous lesson.

## Try it

Publish your profile page from the earlier project. Send the link to a friend and ask them whether everything works on their phone.

## Common mistakes

- `index.html` inside a sub-folder instead of at the top, so the home page shows a 404 error.
- Links that differ from file names only by capital letters.
- Links pointing to files on your computer (`C:\...`) instead of relative paths.

## Key terms

- **Web server** — a computer that sends web pages to browsers.
- **Static site** — a site made of fixed files, without server-side code.
- **Repository** — a project folder on GitHub with its history.
- **Commit** — a saved change in a repository.$md$);

  perform seed.ensure_lesson(c, 'Publish your site', 'Final project: your portfolio site', 'project', 60,
    'Build and publish a multi-page, accessible portfolio site.',
$md$## Your final project

Build a small **portfolio site** about yourself (or a fictional person) and publish it with GitHub Pages. It brings together everything in this course.

### Requirements

1. At least three pages: **Home**, **Projects** and **Contact**, linked by the same navigation on every page.
2. A valid document skeleton on every page, with `lang`, `charset`, `viewport` and a unique `<title>`.
3. Semantic layout: `header`, `nav`, `main` and `footer`, with a correct heading outline.
4. At least three images with suitable alt text, sensible file sizes, and `width` and `height`.
5. One table (for example, skills and levels) or a well-structured list of projects.
6. A contact form with labels, suitable input types and `required` fields (it does not need to send messages yet).
7. The keyboard test passes: everything can be reached with Tab and the focus is visible.
8. Published on GitHub Pages.

### How to submit

Submit the URL of your published site. You can also add a short note about what you are most proud of and what you would improve.

> [!NOTE]
> A reviewer checks your site against the rubric and leaves feedback. You can update the site and resubmit.$md$,
    'published', false, 80);
  perform seed.ensure_assignment(c, 'Final project: your portfolio site', 'Portfolio site',
    'Build and publish a three-page, semantic and accessible portfolio site on GitHub Pages.',
$r$| Criterion | Points |
| --- | --- |
| Three or more pages with working, consistent navigation | 15 |
| Valid skeleton on every page (lang, charset, viewport, unique title) | 10 |
| Semantic layout and a correct heading outline | 20 |
| Images: alt text, file sizes, width and height | 15 |
| Table or structured list used correctly | 10 |
| Accessible contact form (labels, input types, required) | 15 |
| Keyboard accessible and published on GitHub Pages | 15 |$r$, 'url');

  perform seed.ensure_lesson(c, 'Publish your site', 'Final assessment', 'quiz', 10,
    'A short exam covering the whole course. Pass mark: 70%.', null, 'published', false, 30);
  q := seed.ensure_quiz(c, 'Final assessment', 'HTML from Absolute Zero — final assessment', 'final_assessment', 70, 50);
  perform seed.ensure_question(q, 0, 'single_choice', 'What does DNS do when you type `example.com`?',
    'DNS translates a domain name into an IP address.',
    array['Turns the domain name into an IP address', 'Draws the page on the screen', 'Encrypts your password'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'single_choice', 'Which element holds everything visible on a page?',
    'All visible content lives inside `<body>`.',
    array['`<body>`', '`<head>`', '`<title>`'], array[true, false, false],
    array[null, '`<head>` holds information about the page.', '`<title>` sets the tab text.']);
  perform seed.ensure_question(q, 2, 'single_choice', 'What is wrong with `<p><em>Hi</p></em>`?',
    'Tags must close in reverse order: `<p><em>Hi</em></p>`.',
    array['The tags overlap instead of nesting', '`<em>` is not allowed in paragraphs', 'Nothing'], array[true, false, false], null);
  perform seed.ensure_question(q, 3, 'single_choice', 'Which element labels a column in a table?',
    '`<th>` with `scope="col"` labels a column.',
    array['`<th>`', '`<td>`', '`<caption>`'], array[true, false, false],
    array[null, '`<td>` holds data.', '`<caption>` is the title of the whole table.']);
  perform seed.ensure_question(q, 4, 'single_choice', 'Which link works when the whole site moves to a web server?',
    'Relative links describe the path between your own files, so they keep working on a server.',
    array['`about.html`', '`C:\Users\aziza\site\about.html`', '`file:///about.html`'], array[true, false, false],
    array[null, 'Paths on your computer do not exist on the server.', 'File links only work on your own computer.']);
  perform seed.ensure_question(q, 5, 'single_choice', 'Which alt text is best for a chart on a sales report page?',
    'Alt text should give the information the image carries.',
    array['`alt="Bar chart: sales doubled from March to June"`', '`alt="image"`', '`alt="chart.png"`'], array[true, false, false], null);
  perform seed.ensure_question(q, 6, 'multiple_choice', 'Which of these make a form more accessible? Select **all** that apply.',
    'Labels, suitable input types and clear required fields all help; placeholders are not labels.',
    array['A `<label>` for every field', 'Suitable input types such as `email`', 'Using placeholders instead of labels', 'Marking required fields with `required`'],
    array[true, true, false, true],
    array[null, null, 'Placeholders disappear and are hard to read.', null]);
  perform seed.ensure_question(q, 7, 'single_choice', 'Your GitHub Pages site shows a 404 error on the home page. What is the most likely cause?',
    'GitHub Pages looks for `index.html` at the top of the repository.',
    array['`index.html` is missing from the top of the repository', 'The images are too large', 'The page has no `<footer>`'],
    array[true, false, false], null);

  perform seed.order_modules(c, array['How the web works', 'Structuring content', 'Links, images and media', 'Forms and accessibility', 'Publish your site']);
  perform seed.order_lessons(c, 'Structuring content', array['Headings, paragraphs and lists', 'Tables for real data', 'Structuring content: check', 'Project: your personal profile page']);
  perform seed.order_lessons(c, 'Links, images and media', array['Links: connecting the web', 'Images done right', 'Links and images: check']);
  perform seed.order_lessons(c, 'Forms and accessibility', array['Forms: collecting input', 'Semantic layout and accessibility', 'Forms and accessibility: check']);
  perform seed.order_lessons(c, 'Publish your site', array['Publishing with GitHub Pages', 'Final project: your portfolio site', 'Final assessment']);
end $content$;

-- Oʻzbekcha ------------------------------------------------------------------------------
do $tr$
declare
  c constant text := 'html-from-absolute-zero';
begin
  perform seed.tr_module(c, 'Forms and accessibility', 'uz', 'Formalar va foydalanish qulayligi',
    'Odamlardan maʼlumot qabul qiling va hamma foydalana oladigan sahifalar yarating.');
  perform seed.tr_module(c, 'Publish your site', 'uz', 'Saytingizni eʼlon qiling',
    'Saytingizni internetga joylang va portfoliongizni yakunlang.');

  perform seed.tr_lesson(c, 'Tables for real data', 'uz', 'Haqiqiy maʼlumotlar uchun jadvallar',
    'Dars jadvali, narxlar va natijalarni odamlar ham, ekran oʻquvchi dasturlar ham tushunadigan jadvallarda koʻrsating.',
$md$## Jadval qachon toʻgʻri tanlov

Jadval **qator va ustunlardan iborat maʼlumotlarni** koʻrsatadi: dars jadvali, narxlar roʻyxati, sport natijalari. Agar maʼlumot elektron jadvalda (masalan, Excelda) mantiqiy koʻrinsa, jadval toʻgʻri tanlov. Bu darsda toʻgʻri va hamma uchun qulay HTML jadval yaratasiz.

> [!WARNING]
> Jadvallardan hech qachon sahifa joylashuvini tuzish uchun (masalan, menyuni matn yoniga qoʻyish uchun) foydalanmang. Bu 1990-yillarda keng tarqalgan edi; bugun joylashuv — CSS vazifasi, joylashuv uchun ishlatilgan jadvallar esa ekran oʻquvchi dasturlarni chalgʻitadi.

## Jadval yaratish

```html
<table>
  <caption>Dushanba kungi dars jadvali</caption>
  <thead>
    <tr>
      <th scope="col">Vaqt</th>
      <th scope="col">Fan</th>
      <th scope="col">Xona</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>09:00</td>
      <td>Matematika</td>
      <td>204</td>
    </tr>
    <tr>
      <td>10:00</td>
      <td>Tarix</td>
      <td>112</td>
    </tr>
  </tbody>
</table>
```

Har bir element nima qiladi:

- `<table>` butun jadvalni oʻz ichiga oladi.
- `<caption>` jadvalga sarlavha beradi. Ekran oʻquvchi dasturlar uni birinchi boʻlib oʻqiydi.
- `<thead>` sarlavha qatorini, `<tbody>` esa maʼlumotlar qatorlarini oʻz ichiga oladi.
- `<tr>` — jadval qatori (inglizcha *table row*).
- `<th>` — **sarlavha katagi**; odatda qalin va markazda koʻrsatiladi.
- `<td>` — oddiy **maʼlumot katagi**.

## Hammaga yordam beradigan sarlavhalar

`scope` atributi yordamchi texnologiyalarga sarlavha qaysi kataklarni tavsiflashini bildiradi: ustun sarlavhasi uchun `scope="col"`, qator sarlavhasi uchun `scope="row"`. Shunda ekran oʻquvchi dastur katakni oʻqiganda shunchaki “204” emas, “Xona, 204” deydi.

## Kataklarni birlashtirish

Baʼzan bitta katak bir nechta ustun yoki qatorni egallashi kerak:

```html
<tr>
  <td>12:00</td>
  <td colspan="2">Tushlik tanaffusi</td>
</tr>
```

`colspan="2"` katakni ikki ustun kengligida qiladi; `rowspan` qatorlar uchun xuddi shu ishni bajaradi. Birlashtirishdan kam foydalaning — murakkab jadvallarni kichik ekranlarda va ekran oʻquvchi dasturlar orqali oʻqish qiyin.

## Oʻzingiz sinab koʻring

Haftalik dars jadvalingizni (yoki toʻqima jadvalni) sarlavha, sarlavha qatori va qator sifatida kamida besh kun bilan jadval koʻrinishida yarating. Har bir qatordagi kataklar soni bir xil ekanini tekshiring.

## Keng tarqalgan xatolar

- Jadvaldan sahifa joylashuvi uchun foydalanish.
- `<th>` va `<caption>` ni unutish — natijada jadvalning maʼnosi noaniq qoladi.
- Kataklar soni har xil boʻlgan qatorlar — ustunlar joyidan siljiydi.

## Asosiy atamalar

- **Jadval qatori (`<tr>`)** — kataklarning bitta gorizontal qatori.
- **Sarlavha katagi (`<th>`)** — qator yoki ustunni nomlaydigan katak.
- **Maʼlumot katagi (`<td>`)** — qiymatni oʻz ichiga olgan katak.
- **Jadval sarlavhasi** (*caption*) — jadvalning nomi.$md$);

  perform seed.tr_lesson(c, 'Structuring content: check', 'uz', 'Kontentni tuzilmaga solish: bilimni tekshirish',
    'Sarlavhalar, roʻyxatlar va jadvallar boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Structuring content check', 'uz', '“Kontentni tuzilmaga solish” moduli boʻyicha test');
  perform seed.tr_question(c, 'Structuring content check', 0, 'uz', 'Quyidagilardan qaysi biri HTML jadval sifatida yaratilishi kerak?',
    'Jadvallar dars jadvali kabi qator va ustunlardan iborat maʼlumotlar uchun.',
    array['Haftalik dars jadvali', 'Menyuni asosiy matn yoniga joylashtirish', 'Masalliqlar roʻyxati'],
    array[null, 'Joylashuv jadvallarning emas, CSS ning vazifasi.', 'Oddiy roʻyxat `<ul>` ga tegishli.']);
  perform seed.tr_question(c, 'Structuring content check', 1, 'uz', 'Qaysi element jadval ustunini nomlaydi?',
    '`<th>` — sarlavha katagi; `scope="col"` uning ustunni nomlashini bildiradi.',
    array['`<th>`', '`<td>`', '`<tr>`'],
    array[null, '`<td>` oddiy maʼlumotni saqlaydi.', '`<tr>` — butun qator.']);
  perform seed.tr_question(c, 'Structuring content check', 2, 'uz', '`colspan="2"` nima qiladi?',
    'U bitta katakni ikki ustun boʻylab choʻzadi.',
    array['Katakni ikki ustun boʻylab choʻzadi', 'Ikkita boʻsh qator qoʻshadi', 'Shrift oʻlchamini ikki baravar oshiradi']);
  perform seed.tr_question(c, 'Structuring content check', 3, 'uz', 'Siz retsept qadamlarini tartib bilan sanab chiqasiz. Qaysi element eng mos keladi?',
    'Tartibli qadamlar tartiblangan roʻyxat — `<ol>` ga tegishli.',
    array['`<ol>`', '`<ul>`', '`<table>`'],
    array[null, '`<ul>` tartibi muhim boʻlmagan elementlar uchun.', 'Jadval qator va ustunlardagi maʼlumotlar uchun.']);
  perform seed.tr_question(c, 'Structuring content check', 4, 'uz', 'Toʻgʻrimi yoki notoʻgʻri: sahifada faqat bitta `<h1>` boʻlishi va sarlavha darajalari tashlab ketilmasligi kerak.',
    'Toʻgʻri — bitta asosiy sarlavha, soʻngra tartib bilan `<h2>`, `<h3>` va hokazo.',
    array['Toʻgʻri', 'Notoʻgʻri']);

  perform seed.tr_lesson(c, 'Links: connecting the web', 'uz', 'Havolalar: internetni bogʻlash',
    'Absolyut va nisbiy havolalar, sahifa ichidagi havolalar va yangi yorliqni xavfsiz ochish.',
$md$## Gipermatndagi “giper”

Internetni “toʻr”ga aylantiradigan narsa — havolalar. Bu darsda boshqa saytlarga, oʻz sahifalaringizga va sahifa ichidagi joylarga havolalar yaratasiz.

```html
<a href="https://developer.mozilla.org">MDN Web Docs</a>
```

`<a>` — inglizcha **anchor** (langar) soʻzidan. `href` atributi manzilni saqlaydi; teglar orasidagi matn esa odamlar bosadigan qism.

## Absolyut va nisbiy manzillar

- **Absolyut URL** toʻliq manzilni, jumladan, `https://` ni oʻz ichiga oladi. Undan boshqa saytlar uchun foydalaning.
- **Nisbiy URL** fayl **joriy sahifaga nisbatan** qayerda ekanini tavsiflaydi. Undan oʻz saytingizdagi sahifa va fayllar uchun foydalaning.

Quyidagi saytni tasavvur qiling:

```text
my-site/
├── index.html
├── about.html
└── projects/
    └── game.html
```

| Qayerdan | Qayerga | Nisbiy havola |
| --- | --- | --- |
| `index.html` | `about.html` | `about.html` |
| `index.html` | `projects/game.html` | `projects/game.html` |
| `projects/game.html` | `index.html` | `../index.html` |

`../` — “bir papka yuqoriga chiqish” degani. Butun saytni serverga koʻchirganingizda ham nisbiy havolalar ishlashda davom etadi.

## Sahifa ichidagi havolalar

Elementga `id` bering, soʻngra unga `#` yordamida havola qiling:

```html
<a href="#contact">Aloqa maʼlumotlariga oʻtish</a>
<h2 id="contact">Aloqa</h2>
```

## Yangi yorliqda ochish

```html
<a href="https://example.com" target="_blank" rel="noopener">Example (yangi yorliqda ochiladi)</a>
```

`target="_blank"` yangi yorliq ochadi. Yangi sahifa sizning sahifangizni boshqara olmasligi uchun `rel="noopener"` ni qoʻshing. Yangi yorliqni faqat jiddiy sabab boʻlganda oching va buni havola matnida ayting.

## Email va telefon havolalari

- `<a href="mailto:hello@example.com">Bizga yozing</a>` pochta ilovasini ochadi.
- `<a href="tel:+998901234567">Qoʻngʻiroq qiling</a>` telefonlarda qoʻngʻiroqni boshlaydi.

## Yaxshi havola matnini yozish

Havola matni oʻz-oʻzidan tushunarli boʻlishi kerak. Ekran oʻquvchi dasturdan foydalanuvchilar koʻpincha faqat havola matnini eshitib, bir havoladan boshqasiga sakraydi.

> [!TIP]
> “Bu yerni bosing” oʻrniga “Dars jadvalini oʻqing” deb yozing. Aniq havola matni qidiruv tizimlariga ham sahifalaringizni tushunishga yordam beradi.

## Oʻzingiz sinab koʻring

Bitta papkada `index.html` va `about.html` fayllarini yarating. Har bir sahifaga ikkinchisiga havola qiluvchi navigatsiya roʻyxatini va sahifaning pastroq qismidagi boʻlimga oʻtkazuvchi havolani qoʻshing.

## Keng tarqalgan xatolar

- Kompyuteringizdagi absolyut yoʻllardan (`C:\Users\...`) foydalanish — ular boshqa qurilmada ishlamaydi.
- Tashqi havolalarda `https://` ni unutish — brauzer ularni saytingizdagi fayllar deb hisoblaydi.
- “Bu yerda” yoki “Batafsil” kabi noaniq havola matni.

## Asosiy atamalar

- **Anchor (`<a>`)** — havola elementi.
- **Absolyut URL** — protokolni oʻz ichiga olgan toʻliq manzil.
- **Nisbiy URL** — joriy faylga nisbatan berilgan manzil.
- **Fragment (`#id`)** — sahifa ichidagi joyga havola.$md$);

  perform seed.tr_lesson(c, 'Images done right', 'uz', 'Tasvirlar bilan toʻgʻri ishlash',
    'Tez yuklanadigan va hamma uchun ishlaydigan tasvirlar uchun formatlar, oʻlchamlar va muqobil matn.',
$md$## Tasvir qoʻshish

Bu darsda tez yuklanadigan, sahifani barqaror saqlaydigan va koʻra olmaydigan odamlar uchun tavsiflangan tasvirlar qoʻshasiz.

```html
<img src="images/samarkand.jpg" alt="Quyosh botayotgan paytdagi Registon maydoni" width="800" height="533">
```

- `src` — koʻrsatiladigan fayl (nisbiy yoki absolyut URL).
- `alt` — tasvirning matnli tavsifi.
- `width` va `height` — tasvirning piksellardagi oʻlchami. Ular berilsa, brauzer oldindan joy ajratadi va tasvir yuklanganda matn sakrab ketmaydi.

## Formatni tanlash

| Format | Nima uchun eng yaxshi |
| --- | --- |
| **JPEG** (`.jpg`) | Fotosuratlar |
| **PNG** (`.png`) | Skrinshotlar va shaffoflik kerak boʻlgan tasvirlar |
| **WebP** (`.webp`) | Fotosurat va grafika; odatda JPEG yoki PNG dan kichikroq |
| **SVG** (`.svg`) | Logotiplar, ikonkalar va shakllardan iborat illyustratsiyalar — har qanday oʻlchamda tiniq |

## Oʻlcham muhim

Telefondan olingan fotosurat 4000 piksel kenglikda va bir necha megabayt hajmda boʻlishi mumkin. U 800 piksel kenglikda koʻrsatilsa, maʼlumotlarning katta qismi behuda ketadi va sahifa mobil internetda sekin yuklanadi.

1. Tasvirni u koʻrsatiladigan eng katta oʻlchamga yaqin qilib kichraytiring.
2. Uni oʻrtacha siqish bilan eksport qiling.
3. Sahifaning pastroq qismidagi tasvirlarga `loading="lazy"` qoʻshing — ular faqat kerak boʻlganda yuklanadi.

## Muqobil matn yozish

Muqobil matnni (**alt matn**) ekran oʻquvchi dasturlar ovoz chiqarib oʻqiydi, tasvir yuklanmay qolsa esa u koʻrsatiladi.

- Shu kontekstda muhim boʻlgan narsani tavsiflang: `alt="Ustunli diagramma: savdo martdan iyungacha ikki baravar oshdi"`.
- “Rasm: …” deb boshlamang — ekran oʻquvchi dastur bu tasvir ekanini oʻzi aytadi.
- Faqat bezak uchun ishlatilgan tasvirlarga boʻsh alt bering: `alt=""`. Shunda ekran oʻquvchi dastur ularni oʻtkazib yuboradi.

> [!WARNING]
> `alt` atributini hech qachon butunlay tashlab ketmang. Usiz koʻplab ekran oʻquvchi dasturlar fayl nomini, masalan, “IMG pastki chiziq 4 0 3 2 nuqta jpg” deb oʻqiydi.

## Izohli tasvirlar

Tasvirga koʻrinadigan izoh berish uchun uni `<figure>` ichiga oling:

```html
<figure>
  <img src="images/plov.jpg" alt="Sabzi va mayiz solingan katta qozondagi palov" width="600" height="400">
  <figcaption>Oilaviy tantana uchun damlangan palov.</figcaption>
</figure>
```

## Oʻzingiz sinab koʻring

Saytingizga uchta tasvir qoʻshing: fotosurat (JPEG yoki WebP), logotip yoki ikonka (SVG yoki PNG) va bitta bezak tasvir. Fotosuratni qoʻshishdan oldin kichraytiring va har biri uchun mos alt matn yozing.

## Keng tarqalgan xatolar

- Ulkan fotosuratlarni yuklab, ularni HTML yoki CSS bilan kichraytirish.
- `width` va `height` ning yoʻqligi — sahifa joylashuvi sakrab ketadi.
- `alt="rasm"` kabi hech narsa bildirmaydigan alt matn.

## Asosiy atamalar

- **Alt matn** — tasvirning matnli muqobili.
- **Yoʻqotishli / yoʻqotishsiz siqish** — tafsilotlarning bir qismini tashlab yuboradigan (JPEG) yoki hech narsani yoʻqotmaydigan (PNG) siqish.
- **Kechiktirib yuklash** (*lazy loading*) — tasvirni faqat u koʻrinish arafasida yuklash.
- **`<figure>` / `<figcaption>`** — koʻrinadigan izohli tasvir.$md$);

  perform seed.tr_lesson(c, 'Links and images: check', 'uz', 'Havolalar va tasvirlar: bilimni tekshirish',
    'Havolalar, yoʻllar va tasvirlar boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Links and images check', 'uz', '“Havolalar, tasvirlar va media” moduli boʻyicha test');
  perform seed.tr_question(c, 'Links and images check', 0, 'uz', '`projects/game.html` faylidan yuqoridagi papkadagi `index.html` ga qaysi havola qaytaradi?',
    '`../` — “bir papka yuqoriga chiqish” degani.',
    array['`../index.html`', '`index.html`', '`/projects/index.html`'],
    array[null, 'Bu `projects` papkasi ichidan `index.html` ni qidiradi.', 'Bu mavjud boʻlmagan faylga ishora qiladi.']);
  perform seed.tr_question(c, 'Links and images check', 1, 'uz', 'Faqat bezak uchun ishlatilgan jingalak tasvir uchun qaysi alt matn toʻgʻri?',
    'Bezak tasvirlarga boʻsh alt beriladi, shunda ekran oʻquvchi dasturlar ularni oʻtkazib yuboradi.',
    array['`alt=""`', '`alt="swirl.png"`', 'Umuman alt atributisiz'],
    array[null, 'Fayl nomlari foydali tavsif emas.', 'Alt boʻlmasa, ekran oʻquvchi dasturlar fayl nomini oʻqishi mumkin.']);
  perform seed.tr_question(c, 'Links and images check', 2, 'uz', 'Har qanday oʻlchamda tiniq koʻrinishi kerak boʻlgan kompaniya logotipi uchun qaysi format eng yaxshi?',
    'SVG vektor format, shuning uchun u har qanday oʻlchamda tiniq qoladi.',
    array['SVG', 'JPEG', 'Logotipning skrinshoti'],
    array[null, 'JPEG fotosuratlar uchun moʻljallangan va keskin qirralarni xiralashtiradi.', 'Skrinshotlar piksellardan iborat va kattalashtirilganda xiralashadi.']);
  perform seed.tr_question(c, 'Links and images check', 3, 'uz', 'Nega `target="_blank"` bor havolaga `rel="noopener"` qoʻshish kerak?',
    'U yangi ochilgan sahifaga dastlabki sahifani boshqarishga yoʻl qoʻymaydi.',
    array['Yangi sahifa sizning sahifangizni boshqara olmasligi uchun', 'Havola tezroq yuklanishi uchun', 'Matnni qalin qilish uchun']);
  perform seed.tr_question(c, 'Links and images check', 4, 'uz', 'Qaysi havola matni eng yaxshi?',
    'Havola matni manzilni oʻz-oʻzidan tavsiflashi kerak.',
    array['Imtihonlar jadvalini oʻqing', 'Bu yerni bosing', 'Batafsil'],
    array[null, '“Bu yerni bosing” havola qayerga olib borishini aytmaydi.', '“Batafsil” kontekstsiz tushunarsiz.']);

  perform seed.tr_lesson(c, 'Forms: collecting input', 'uz', 'Formalar: maʼlumot qabul qilish',
    'Toʻgʻri yorliqlari va brauzerning oʻrnatilgan tekshiruvi bor matn maydonlari, tanlovlar va tugmalar.',
$md$## Formalar nima uchun kerak

Formalar odamlarga maʼlumot yuborish imkonini beradi: roʻyxatdan oʻtish, qidirish, buyurtma berish, fikr qoldirish. Bu darsda yorliqlari va brauzer oʻzi tekshiradigan validatsiyasi bor toʻliq roʻyxatdan oʻtish formasini yaratasiz.

```html
<form action="/register" method="post">
  <label for="name">Ism-sharifingiz</label>
  <input id="name" name="name" type="text" required>

  <label for="email">Email</label>
  <input id="email" name="email" type="email" required>

  <label for="level">Darajangiz</label>
  <select id="level" name="level">
    <option value="zero">Mutlaq boshlovchi</option>
    <option value="some">Bir oz bilaman</option>
  </select>

  <label for="goal">Nimani oʻrganmoqchisiz?</label>
  <textarea id="goal" name="goal" rows="4"></textarea>

  <button type="submit">Roʻyxatdan oʻtish</button>
</form>
```

## Yorliqlar majburiy

Har bir maydonga `<label>` (yorliq) kerak. Yorliqning `for` qiymati maydonning `id` siga mos kelishi shart. Shunda:

- ekran oʻquvchi dasturlar maydon nima uchun ekanini aytadi,
- yorliqni bosish kursorni maydonga qoʻyadi — telefonlarda bosish uchun kattaroq joy.

> [!WARNING]
> `placeholder` yorliq emas. U yozishni boshlashingiz bilanoq yoʻqoladi va koʻpincha oʻqish uchun juda xira boʻladi. Undan faqat namuna uchun foydalaning, masalan, `placeholder="name@example.com"`.

## Maydonning toʻgʻri turini tanlash

| Tur | Nima uchun | Qoʻshimcha qulaylik |
| --- | --- | --- |
| `text` | Ismlar va qisqa matn | — |
| `email` | Email manzillar | Formatni tekshiradi; telefonda @ belgili klaviatura chiqadi |
| `password` | Parollar | Belgilarni yashiradi |
| `number` | Miqdorlar | Raqamli klaviatura va strelkalar |
| `date` | Sanalar | Sana tanlash oynasi |
| `checkbox` | Ha/yoʻq tanlovlari | Har birini alohida belgilash mumkin |
| `radio` | Bir nechtadan bittasini tanlash | Barcha variantlarga bir xil `name` bering |

## Oʻrnatilgan validatsiya

Brauzer forma yuborilishidan oldin quyidagi atributlarni tekshiradi:

- `required` — maydon boʻsh qolishi mumkin emas.
- `minlength` va `maxlength` — belgilar soniga cheklov.
- `min` va `max` — sonlar va sanalar uchun cheklov.

Brauzer validatsiyasi odamlarga xatolarni tez tuzatishga yordam beradi, ammo uni chetlab oʻtish mumkin. Haqiqiy veb-sayt maʼlumotlarni har doim serverda qayta tekshirishi kerak.

## Maʼlumotlar qayerga boradi

`action` atributi maʼlumotlarni qabul qiladigan manzil, `method` esa ular qanday yuborilishini bildiradi: `get` maʼlumotlarni URL ga qoʻshadi (qidiruv uchun qulay), `post` ularni soʻrov tanasida yuboradi (roʻyxatdan oʻtish va har qanday maxfiy maʼlumot uchun). Maʼlumotlarni qabul qilish uchun server kerak — u haqida backend kurslarida oʻrganasiz. Hozircha formani toʻgʻri yaratishga eʼtibor qarating.

## Oʻzingiz sinab koʻring

Ism, email, 1 dan 5 gacha baho (bir xil `name` ga ega radio tugmalar), xabar va yuborish tugmasidan iborat fikr-mulohaza formasini yarating. Ism va emailni majburiy qiling, soʻngra brauzer xabarlarini koʻrish uchun uni boʻsh holda yuborib koʻring.

## Keng tarqalgan xatolar

- Yorliqsiz maydonlar yoki yorliq oʻrniga placeholder ishlatish.
- `name` atributini unutish — maydon qiymati umuman yuborilmaydi.
- Hamma narsa uchun `type="text"` dan foydalanish va telefonlarda mos klaviaturani yoʻqotish.

## Asosiy atamalar

- **Forma** — maʼlumot yuboradigan maydonlar guruhi.
- **Yorliq** (*label*) — maydonning `for` va `id` orqali bogʻlangan koʻrinadigan nomi.
- **Validatsiya** — kiritilgan maʼlumot toʻliq va toʻgʻri formatda ekanini tekshirish.
- **GET / POST** — forma maʼlumotlarini yuborishning ikki usuli.$md$);

  perform seed.tr_lesson(c, 'Semantic layout and accessibility', 'uz', 'Semantik joylashuv va foydalanish qulayligi',
    'Sahifalarni landmark elementlar bilan tuzing va ularni klaviatura hamda ekran oʻquvchi dastur bilan qulay qiling.',
$md$## Oʻz vazifasini bildiradigan elementlar

HTML5 dan oldin sahifalar koʻplab nomsiz `<div>` elementlaridan qurilardi. Bugun sahifaning har bir qismi nima ekanini bildiradigan **semantik elementlardan** foydalanamiz. Bu darsda sahifani shu elementlar bilan tuzasiz va uni imkoniyati cheklangan odamlar internetdan qanday foydalansa, shunday sinab koʻrasiz.

```html
<body>
  <header>
    <a href="/">Azizaning portfoliosi</a>
    <nav>
      <ul>
        <li><a href="index.html">Bosh sahifa</a></li>
        <li><a href="projects.html">Loyihalar</a></li>
        <li><a href="contact.html">Aloqa</a></li>
      </ul>
    </nav>
  </header>
  <main>
    <h1>Loyihalar</h1>
    <article>
      <h2>Ob-havo vidjeti</h2>
      <p>Toshkent uchun ob-havo maʼlumotini koʻrsatadigan kichik sahifa.</p>
    </article>
  </main>
  <footer>
    <p>© 2026 Aziza Karimova</p>
  </footer>
</body>
```

| Element | Maʼnosi |
| --- | --- |
| `<header>` | Kirish qismi, koʻpincha logotip va navigatsiya |
| `<nav>` | Asosiy navigatsiya havolalari guruhi |
| `<main>` | Asosiy kontent — har bir sahifada faqat bitta |
| `<article>` | Post yoki loyiha kabi mustaqil qism |
| `<section>` | Oʻz sarlavhasiga ega mavzuli boʻlim |
| `<aside>` | Bogʻliq, ikkinchi darajali kontent |
| `<footer>` | Mualliflik huquqi yoki aloqa kabi yakuniy maʼlumot |

## Semantika nega muhim

- **Ekran oʻquvchi dasturlar** bu **landmark**larni roʻyxat qilib koʻrsatadi, shunda foydalanuvchilar toʻgʻridan-toʻgʻri navigatsiya yoki asosiy kontentga oʻta oladi.
- **Qidiruv tizimlari** sahifangiz tuzilmasini yaxshiroq tushunadi.
- **Dasturchilar** — jumladan, keyinchalik oʻzingiz ham — kodni osonroq oʻqiydi.

## Foydalanish qulayligi asoslari

Foydalanish qulayligi (*accessibility*) — saytingizdan hamma, jumladan, koʻzi ojiz yoki zaif koʻradigan, sichqonchadan foydalana olmaydigan yoki vaqtincha jarohat olgan odamlar ham foydalana olishi demakdir. Uning katta qismi siz allaqachon biladigan HTML dan kelib chiqadi:

1. Sahifa tilini belgilang: `<html lang="uz">` yoki `lang="en"`.
2. Sarlavhalardan tartib bilan foydalaning.
3. Har bir tasvirga mos alt matn bering.
4. Har bir forma maydoniga yorliq bering.
5. Hamma narsa faqat klaviatura bilan ishlashiga ishonch hosil qiling.
6. Matn va fon oʻrtasida kuchli kontrastni saqlang.
7. Oʻz-oʻzidan tushunarli havola matnini yozing.

## Oʻzingiz sinab koʻring

- **Klaviatura sinovi:** sichqonchani chetga qoʻying, sahifa boʻylab harakatlanish uchun **Tab** ni, havolaga oʻtish uchun **Enter** ni bosing. Diqqat (fokus) qayerda ekanini har doim koʻrib turishingiz kerak.
- **Ekran oʻquvchi dastur:** bir necha daqiqa Mac va iPhone’da VoiceOver, Android’da TalkBack yoki Windowsda bepul NVDA dan foydalanib koʻring.
- **Avtomatik tekshiruv:** Chrome’da **DevTools → Lighthouse** ni oching va **Accessibility** auditini ishga tushiring.

> [!NOTE]
> Avtomatik vositalar muammolarning faqat bir qismini topadi. Klaviatura sinovi va ekran oʻquvchi dastur bilan bir necha daqiqa ishlash ancha koʻp narsani koʻrsatadi.

## Mashq

Faqat `<div>` elementlaridan qurilgan sahifani `header`, `nav`, `main`, `article` va `footer` yordamida qayta yozing. Soʻngra klaviatura sinovini oʻtkazing va yetib borib boʻlmaydigan joylarni tuzating.

## Keng tarqalgan xatolar

- Bitta sahifada bir nechta `<main>` elementi.
- Sarlavhalarni tuzilmaga qarab emas, oʻlchamiga qarab tanlash.
- CSS orqali fokus chegarasini olib tashlash — klaviatura foydalanuvchilari adashib qoladi.

## Asosiy atamalar

- **Semantik element** — nomi maʼnosini bildiradigan element.
- **Landmark** — yordamchi texnologiyalar oʻta oladigan hudud (header, nav, main, footer).
- **Foydalanish qulayligi** (*accessibility*) — saytdan hamma foydalana oladigan qilib loyihalash.
- **Fokus** — ayni paytda klaviatura kiritishini qabul qilayotgan element.$md$);

  perform seed.tr_lesson(c, 'Forms and accessibility: check', 'uz', 'Formalar va foydalanish qulayligi: bilimni tekshirish',
    'Formalar, semantika va foydalanish qulayligi boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Forms and accessibility check', 'uz', '“Formalar va foydalanish qulayligi” moduli boʻyicha test');
  perform seed.tr_question(c, 'Forms and accessibility check', 0, 'uz', 'Yorliq maydonga qanday bogʻlanadi?',
    'Yorliqning `for` qiymati maydonning `id` siga mos kelishi kerak.',
    array['Yorliqning `for` qiymati maydonning `id` siga mos keladi', 'Yorliq formadan keyin qoʻyiladi', 'Ikkalasiga bir xil `class` beriladi']);
  perform seed.tr_question(c, 'Forms and accessibility check', 1, 'uz', 'Email maydoni qaysi turdan foydalanishi kerak?',
    '`type="email"` formatni tekshiradi va telefonlarda mos klaviaturani koʻrsatadi.',
    array['`email`', '`text`', '`password`'],
    array[null, 'Ishlaydi, lekin format tekshiruvi va @ klaviaturasi yoʻqoladi.', 'Bu belgilarni yashiradi.']);
  perform seed.tr_question(c, 'Forms and accessibility check', 2, 'uz', 'Sahifada nechta `<main>` elementi boʻlishi kerak?',
    'Sahifaning asosiy kontentini aynan bitta `<main>` oʻz ichiga oladi.',
    array['Bitta', 'Har bir boʻlim uchun bittadan', 'Qancha kerak boʻlsa']);
  perform seed.tr_question(c, 'Forms and accessibility check', 3, 'uz', 'Toʻgʻrimi yoki notoʻgʻri: placeholder yorliq oʻrnini bosa oladi.',
    'Notoʻgʻri — placeholder yozish paytida yoʻqoladi va koʻpincha oʻqish qiyin boʻladi.',
    array['Toʻgʻri', 'Notoʻgʻri'],
    array['Placeholder yozishni boshlashingiz bilanoq yoʻqoladi.', null]);
  perform seed.tr_question(c, 'Forms and accessibility check', 4, 'uz', 'Sahifa sichqonchasiz ishlashini tekshirishning eng tez usuli qaysi?',
    'Butun sahifa boʻylab Tab bilan oʻting va hamma narsaga yetib borish mumkinligi hamda fokus koʻrinib turishini tekshiring.',
    array['Sahifa boʻylab faqat Tab va Enter tugmalari bilan oʻtish', 'Oynani kichraytirish', 'Sahifani boshqa brauzerda tekshirish']);

  perform seed.tr_lesson(c, 'Publishing with GitHub Pages', 'uz', 'GitHub Pages orqali eʼlon qilish',
    'Saytingizni bepul internetga joylang va istalgan vaqtda yangilang.',
$md$## “Eʼlon qilish” nimani anglatadi

Hozirgacha sahifalaringiz kompyuteringizda edi. **Eʼlon qilish** — ularni istalgan kishi URL orqali ocha olishi uchun **veb-serverga** koʻchirish demakdir. **GitHub Pages** — statik saytlarni (HTML, CSS, rasmlar) toʻgʻridan-toʻgʻri GitHub repozitoriyasidan eʼlon qiladigan bepul xizmat. Bu mashqda saytingizni eʼlon qilasiz.

## Papkangizni tayyorlang

```text
my-site/
├── index.html
├── projects.html
├── contact.html
└── images/
    └── profile.jpg
```

- Bosh sahifa `index.html` deb nomlanishi va papkaning eng yuqori qismida turishi shart.
- Sahifalaringiz orasida faqat nisbiy havolalardan foydalaning.
- Fayl nomlarini kichik harflarda va boʻsh joysiz yozing. Veb-serverlar **katta-kichik harfni farqlaydi**: `Photo.JPG` va `photo.jpg` — ikki xil fayl.

## Qadamma-qadam

1. **github.com** saytida bepul hisob yarating va ikki bosqichli autentifikatsiyani yoqing.
2. **New repository** tugmasini bosing. Uni `your-username.github.io` deb nomlang (oʻrniga GitHub foydalanuvchi nomingizni yozing), **Public** qiling va yarating.
3. Repozitoriya sahifasida **Add file → Upload files** ni tanlang, sayt papkangizning ichidagi fayllarni (papkaning oʻzini emas) torting va **Commit changes** ni bosing.
4. **Settings → Pages** ni oching. **Build and deployment** boʻlimida manba **Deploy from a branch**, branch **main** va papka **/ (root)** ekanini tekshirib, saqlang.
5. Bir-ikki daqiqadan soʻng saytingiz `https://your-username.github.io/` manzilida ishlay boshlaydi.

## Saytni yangilash

Oʻzgargan fayllarni xuddi shu usulda yuklang yoki ularni bevosita GitHub’da tahrirlang. Har bir commit saytni bir-ikki daqiqa ichida qayta eʼlon qiladi. Oʻzgarishni koʻrmasangiz, sahifani **Ctrl + F5** (Windows) yoki **Cmd + Shift + R** (Mac) bilan yangilang.

> [!WARNING]
> Eʼlon qilingan sayt hammaga ochiq. Unga uy manzilingiz, telefon raqamingiz, pasport maʼlumotlaringiz yoki boshqa shaxsiy narsalarni joylamang.

## Natijani tekshirish

- Saytni kompyuterdan tashqari telefonda ham oching.
- Har bir havolani bosib koʻring va har bir rasm koʻrinishini tekshiring.
- Oldingi darsdagi klaviatura sinovini oʻtkazing.

## Oʻzingiz sinab koʻring

Oldingi loyihadagi profil sahifangizni eʼlon qiling. Havolani doʻstingizga yuboring va telefonida hammasi ishlayaptimi, deb soʻrang.

## Keng tarqalgan xatolar

- `index.html` eng yuqorida emas, ichki papkada turgani — bosh sahifa 404 xatosini koʻrsatadi.
- Fayl nomlaridan faqat katta-kichik harf bilan farq qiladigan havolalar.
- Nisbiy yoʻllar oʻrniga kompyuteringizdagi fayllarga (`C:\...`) ishora qiluvchi havolalar.

## Asosiy atamalar

- **Veb-server** — brauzerlarga veb-sahifalarni yuboradigan kompyuter.
- **Statik sayt** — server tomonidagi kodsiz, tayyor fayllardan iborat sayt.
- **Repozitoriya** — GitHub’dagi tarixi bilan birga saqlanadigan loyiha papkasi.
- **Commit** — repozitoriyada saqlangan oʻzgarish.$md$);

  perform seed.tr_lesson(c, 'Final project: your portfolio site', 'uz', 'Yakuniy loyiha: portfolio saytingiz',
    'Koʻp sahifali, hamma uchun qulay portfolio sayt yarating va uni eʼlon qiling.',
$md$## Yakuniy loyihangiz

Oʻzingiz (yoki toʻqima shaxs) haqida kichik **portfolio sayt** yarating va uni GitHub Pages orqali eʼlon qiling. U ushbu kursdagi hamma narsani birlashtiradi.

### Talablar

1. Kamida uchta sahifa: **Bosh sahifa**, **Loyihalar** va **Aloqa** — har bir sahifada bir xil navigatsiya bilan bogʻlangan.
2. Har bir sahifada `lang`, `charset`, `viewport` va takrorlanmas `<title>` mavjud boʻlgan toʻgʻri hujjat skeleti.
3. Semantik joylashuv: toʻgʻri sarlavhalar tuzilmasi bilan `header`, `nav`, `main` va `footer`.
4. Mos alt matnli, oqilona fayl hajmli hamda `width` va `height` berilgan kamida uchta tasvir.
5. Bitta jadval (masalan, koʻnikmalar va darajalar) yoki loyihalarning yaxshi tuzilgan roʻyxati.
6. Yorliqlar, mos maydon turlari va `required` maydonlari bor aloqa formasi (hozircha xabar yuborishi shart emas).
7. Klaviatura sinovidan oʻtadi: hamma narsaga Tab bilan yetib borish mumkin va fokus koʻrinib turadi.
8. GitHub Pages orqali eʼlon qilingan.

### Qanday topshiriladi

Eʼlon qilingan saytingiz URL manzilini topshiring. Nimadan eng koʻp faxrlanishingiz va nimani yaxshilagan boʻlardingiz, degan qisqa izoh ham qoʻshishingiz mumkin.

> [!NOTE]
> Tekshiruvchi saytingizni baholash mezonlari asosida koʻrib chiqadi va fikr-mulohaza qoldiradi. Saytni yangilab, qayta topshirishingiz mumkin.$md$);
  perform seed.tr('assignments', (select id from public.assignments where course_id = seed.course(c) and title = 'Portfolio site'), 'uz',
    jsonb_build_object(
      'title', 'Portfolio sayt',
      'brief_md', 'Uch sahifali, semantik va hamma uchun qulay portfolio sayt yarating va uni GitHub Pages’da eʼlon qiling.',
      'rubric_md', $r$| Mezon | Ball |
| --- | --- |
| Ishlaydigan, bir xil navigatsiyali uch va undan ortiq sahifa | 15 |
| Har bir sahifada toʻgʻri skelet (lang, charset, viewport, takrorlanmas title) | 10 |
| Semantik joylashuv va toʻgʻri sarlavhalar tuzilmasi | 20 |
| Tasvirlar: alt matn, fayl hajmi, width va height | 15 |
| Jadval yoki tuzilgan roʻyxatdan toʻgʻri foydalanilgan | 10 |
| Hamma uchun qulay aloqa formasi (yorliqlar, maydon turlari, required) | 15 |
| Klaviatura bilan qulay va GitHub Pages’da eʼlon qilingan | 15 |$r$),
    c || ' / Portfolio site');

  perform seed.tr_lesson(c, 'Final assessment', 'uz', 'Yakuniy imtihon',
    'Butun kursni qamrab oluvchi qisqa imtihon. Oʻtish balli: 70%.', null);
  perform seed.tr_quiz(c, 'HTML from Absolute Zero — final assessment', 'uz', 'HTML: mutlaq noldan — yakuniy imtihon');
  perform seed.tr_question(c, 'HTML from Absolute Zero — final assessment', 0, 'uz', '`example.com` deb yozganingizda DNS nima qiladi?',
    'DNS domen nomini IP-manzilga aylantiradi.',
    array['Domen nomini IP-manzilga aylantiradi', 'Sahifani ekranda chizadi', 'Parolingizni shifrlaydi']);
  perform seed.tr_question(c, 'HTML from Absolute Zero — final assessment', 1, 'uz', 'Qaysi element sahifada koʻrinadigan hamma narsani oʻz ichiga oladi?',
    'Barcha koʻrinadigan kontent `<body>` ichida joylashadi.',
    array['`<body>`', '`<head>`', '`<title>`'],
    array[null, '`<head>` sahifa haqidagi maʼlumotlarni saqlaydi.', '`<title>` yorliq matnini belgilaydi.']);
  perform seed.tr_question(c, 'HTML from Absolute Zero — final assessment', 2, 'uz', '`<p><em>Salom</p></em>` kodida nima xato?',
    'Teglar teskari tartibda yopilishi kerak: `<p><em>Salom</em></p>`.',
    array['Teglar ichma-ich joylashish oʻrniga bir-biriga chalkashgan', '`<em>` ni xatboshilarda ishlatib boʻlmaydi', 'Hech narsa']);
  perform seed.tr_question(c, 'HTML from Absolute Zero — final assessment', 3, 'uz', 'Qaysi element jadvaldagi ustunni nomlaydi?',
    '`scope="col"` atributli `<th>` ustunni nomlaydi.',
    array['`<th>`', '`<td>`', '`<caption>`'],
    array[null, '`<td>` maʼlumotni saqlaydi.', '`<caption>` — butun jadvalning nomi.']);
  perform seed.tr_question(c, 'HTML from Absolute Zero — final assessment', 4, 'uz', 'Butun sayt veb-serverga koʻchirilganda qaysi havola ishlaydi?',
    'Nisbiy havolalar oʻz fayllaringiz orasidagi yoʻlni tavsiflaydi, shuning uchun ular serverda ham ishlaydi.',
    array['`about.html`', '`C:\Users\aziza\site\about.html`', '`file:///about.html`'],
    array[null, 'Kompyuteringizdagi yoʻllar serverda mavjud emas.', 'Fayl havolalari faqat oʻz kompyuteringizda ishlaydi.']);
  perform seed.tr_question(c, 'HTML from Absolute Zero — final assessment', 5, 'uz', 'Savdo hisoboti sahifasidagi diagramma uchun qaysi alt matn eng yaxshi?',
    'Alt matn tasvir yetkazadigan maʼlumotni berishi kerak.',
    array['`alt="Ustunli diagramma: savdo martdan iyungacha ikki baravar oshdi"`', '`alt="rasm"`', '`alt="chart.png"`']);
  perform seed.tr_question(c, 'HTML from Absolute Zero — final assessment', 6, 'uz', 'Quyidagilardan qaysilari formani qulayroq qiladi? Mos keladigan **barcha** variantlarni belgilang.',
    'Yorliqlar, mos maydon turlari va aniq majburiy maydonlar yordam beradi; placeholder yorliq emas.',
    array['Har bir maydon uchun `<label>`', '`email` kabi mos maydon turlari', 'Yorliqlar oʻrniga placeholder ishlatish', 'Majburiy maydonlarni `required` bilan belgilash'],
    array[null, null, 'Placeholderlar yoʻqoladi va ularni oʻqish qiyin.', null]);
  perform seed.tr_question(c, 'HTML from Absolute Zero — final assessment', 7, 'uz', 'GitHub Pages’dagi saytingiz bosh sahifada 404 xatosini koʻrsatmoqda. Eng ehtimoliy sababi nima?',
    'GitHub Pages repozitoriyaning eng yuqori qismidan `index.html` ni qidiradi.',
    array['Repozitoriyaning eng yuqori qismida `index.html` yoʻq', 'Rasmlar juda katta', 'Sahifada `<footer>` yoʻq']);
end $tr$;
