-- Course: HTML from Absolute Zero (free, level: zero)
do $seed$
declare
  c uuid; m1 uuid; m2 uuid; m3 uuid; l uuid; q uuid; qq uuid;
begin
  insert into public.courses (slug, title, subtitle, description, category_id, subcategory_id, instructor_id,
    level, access_tier, status, estimated_minutes, learning_outcomes, prerequisites, tags, is_featured, cover_style)
  values ('html-from-absolute-zero', 'HTML from Absolute Zero',
    'Build your first real web page — and understand every line of it',
    $d$HTML is the language every web page is written in. In this course you start with **how the web works**, then write a complete page by hand.

No installs are needed beyond a text editor and a browser you already have. Each lesson explains the *why* before the *how*, so you understand the code instead of copying it.$d$,
    seed.cat('programming'), seed.cat('html'),
    (select id from public.instructors where slug = 'mahorat-editorial'),
    'zero', 'free', 'published', 90,
    array['Explain what happens between typing an address and seeing a page',
          'Write a valid HTML document from memory',
          'Structure content with headings, paragraphs and lists',
          'Publish-ready habits: indentation, semantic tags and comments'],
    array['Basic computer use: creating a file and opening it'],
    array['html', 'web', 'frontend', 'beginner'], true,
    '{"pattern": "brackets", "hue": 255}')
  returning id into c;

  m1 := seed.module(c, 0, 'How the web works', 'What a browser does, and where HTML fits in.');

  perform seed.lesson(m1, 0, 'What happens when you open a website', 'article', 7,
    'From the address bar to pixels on your screen in five steps.',
$md$## Five steps from address to page

When you type `example.com` and press Enter, this happens in well under a second:

1. **Your browser asks for the address.** Computers on the internet find each other by numbers called *IP addresses*. A system called **DNS** works like a phone book and turns `example.com` into a number.
2. **The browser sends a request.** It contacts the computer at that address — a **server** — and asks: “Please send me your home page.” This conversation follows rules called **HTTP** (or **HTTPS** when it is encrypted — look for the padlock).
3. **The server responds** with files: an **HTML** file, usually some **CSS** and **JavaScript**, plus images and fonts.
4. **The browser reads the HTML** from top to bottom and builds the structure of the page.
5. **The browser paints the page** on your screen, applying styles and running scripts.

## The three languages of the web

| Language | Job | Comparison with a house |
| --- | --- | --- |
| **HTML** | Structure and content | Walls, rooms and furniture |
| **CSS** | Appearance and layout | Paint, lighting and decoration |
| **JavaScript** | Behaviour and interaction | Electricity, doors that open, the doorbell |

> [!NOTE]
> HTML is not a programming language in the strict sense — it does not make decisions or repeat steps. It is a **markup language**: it *labels* content so the browser knows what each piece is.

## Key terms

- **Browser** — the app that requests and displays web pages (Chrome, Safari, Firefox, Edge).
- **Server** — a computer that stores a website and sends it on request.
- **URL** — the full address of a page, such as `https://example.com/about`.$md$,
    'published', false, 10);

  perform seed.lesson(m1, 1, 'What is HTML?', 'article', 8,
    'Elements, tags and attributes — the three ideas behind every page.',
$md$## Labelling content

HTML stands for **HyperText Markup Language**. You write normal text and wrap each part in **tags** that say what it is.

```html
<h1>My first page</h1>
<p>Hello! This is a paragraph.</p>
```

- `<h1>` means “a top-level heading starts here”.
- `</h1>` — with a slash — means “the heading ends here”.
- The opening tag, the content and the closing tag together form an **element**.

## Attributes add extra information

Some elements need more details. These go inside the opening tag as **attributes**, written `name="value"`:

```html
<a href="https://example.com">Visit Example</a>
<img src="cat.jpg" alt="A ginger cat asleep on a sofa">
```

- `href` tells a link where to go.
- `src` tells an image which file to show.
- `alt` describes the image for people using screen readers, and appears if the image fails to load.

> [!TIP]
> Always write a meaningful `alt`. It is required for accessibility and helps search engines understand your page.

## Elements can contain other elements

```html
<p>This is <strong>very</strong> important.</p>
```

Here `<strong>` lives *inside* `<p>`. Close tags in the reverse order you opened them — like nesting boxes.

> [!WARNING]
> Overlapping tags like `<p><strong>text</p></strong>` are a mistake. Browsers try to guess what you meant, but the result is unpredictable.

## Empty elements

A few elements have no content and no closing tag, for example `<img>` and `<br>` (a line break).$md$,
    'published', false, 10);

  l := seed.lesson(m1, 2, 'Your first web page', 'exercise', 12,
    'Write a complete HTML document, save it and open it in your browser.',
$md$## The skeleton of every page

Every HTML document has the same basic structure. Read each line and its explanation:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My first page</title>
  </head>
  <body>
    <h1>Hello, web!</h1>
    <p>I wrote this page myself.</p>
  </body>
</html>
```

- `<!DOCTYPE html>` — tells the browser this is modern HTML.
- `<html lang="en">` — the root element; `lang` declares the page language (use `uz` for Uzbek, `ru` for Russian).
- `<head>` — information *about* the page that is not shown directly.
- `<meta charset="utf-8">` — lets the page display every alphabet and emoji correctly.
- `<meta name="viewport" …>` — makes the page fit phone screens.
- `<title>` — the text on the browser tab.
- `<body>` — everything visible on the page.

## Try it yourself

1. Open a plain text editor — *Notepad* on Windows, *TextEdit* on macOS (choose **Format → Make Plain Text**), or a code editor such as VS Code.
2. Type the code above. Typing it, rather than pasting it, helps you remember it.
3. Save the file as `index.html`. Make sure the extension is `.html`, not `.txt`.
4. Double-click the file. It opens in your browser.
5. Change the heading text, save, and refresh the browser to see your change.

> [!TIP]
> Indent elements that are inside other elements by two spaces. Browsers ignore the spaces, but people reading your code — including future you — will thank you.

When you can explain what each line does, take the knowledge check below.$md$,
    'published', false, 20);

  -- Knowledge check embedded at the end of the exercise lesson (passing it completes the lesson).
  q := seed.quiz(c, m1, l, 'Knowledge check: HTML basics', 'knowledge_check', 70, 20);
  qq := seed.question(q, 0, 'single_choice', 'Which part of the document holds the text shown on the browser tab?',
    'The `<title>` element lives in `<head>` and sets the tab text.');
  perform seed.answer(qq, 0, '`<h1>`', false, '`<h1>` is the main heading *on the page*, not the tab.');
  perform seed.answer(qq, 1, '`<title>`', true);
  perform seed.answer(qq, 2, '`<body>`', false, '`<body>` holds the visible page content.');
  qq := seed.question(q, 1, 'single_choice', 'What is wrong with this code?', 'Tags must close in reverse order: open `p`, open `strong`, close `strong`, close `p`.',
    '<p><strong>Hello</p></strong>');
  perform seed.answer(qq, 0, 'Nothing — it is valid', false);
  perform seed.answer(qq, 1, 'The tags overlap instead of nesting', true);
  perform seed.answer(qq, 2, '`<strong>` cannot be used inside `<p>`', false, 'It can — it just has to be closed before the paragraph closes.');
  qq := seed.question(q, 2, 'single_choice', 'Which attribute describes an image for screen-reader users?',
    '`alt` (alternative text) describes the image. `src` points to the file.');
  perform seed.answer(qq, 0, '`src`', false);
  perform seed.answer(qq, 1, '`href`', false, '`href` belongs to links.');
  perform seed.answer(qq, 2, '`alt`', true);

  l := seed.lesson(m1, 3, 'Module 1 quiz', 'quiz', 5, 'Test what you learned about how the web works.', null, 'published', false, 15);
  q := seed.quiz(c, m1, l, 'How the web works', 'module_exam', 70, 25);
  qq := seed.question(q, 0, 'single_choice', 'What does DNS do?', 'DNS turns human-friendly names like `example.com` into IP addresses.');
  perform seed.answer(qq, 0, 'Encrypts the connection', false, 'Encryption is the job of HTTPS (TLS).');
  perform seed.answer(qq, 1, 'Translates a domain name into an IP address', true);
  perform seed.answer(qq, 2, 'Paints the page on screen', false, 'That is the browser’s rendering step.');
  qq := seed.question(q, 1, 'single_choice', 'Which language controls a page’s *appearance*?', 'HTML = structure, CSS = appearance, JavaScript = behaviour.');
  perform seed.answer(qq, 0, 'HTML', false);
  perform seed.answer(qq, 1, 'CSS', true);
  perform seed.answer(qq, 2, 'JavaScript', false);
  qq := seed.question(q, 2, 'true_false', 'True or false: HTML is a markup language that labels content.', 'Correct — HTML labels content so the browser knows what each part is.');
  perform seed.answer(qq, 0, 'True', true);
  perform seed.answer(qq, 1, 'False', false);
  qq := seed.question(q, 3, 'short_answer', 'What is the name of the element that wraps all visible page content? (just the word, no brackets)',
    'Everything you see on the page lives inside `<body>`.');
  perform seed.answer(qq, 0, 'body', true);
  perform seed.answer(qq, 1, '<body>', true);

  m2 := seed.module(c, 1, 'Structuring content', 'Headings, paragraphs, lists and your first project.');

  perform seed.lesson(m2, 0, 'Headings, paragraphs and lists', 'article', 9,
    'Give your content a clear outline that both people and machines understand.',
$md$## Headings create an outline

HTML has six heading levels, `<h1>` to `<h6>`. They are not about size — they describe **importance and structure**, like chapters and sections in a book.

```html
<h1>Learning to cook</h1>
<h2>Breakfast</h2>
<h3>Omelette</h3>
<h3>Porridge</h3>
<h2>Dinner</h2>
```

> [!TIP]
> Use exactly one `<h1>` per page and never skip levels (do not jump from `<h2>` to `<h4>`). Screen-reader users navigate by headings, and search engines read them to understand your page.

## Paragraphs

Wrap each block of text in `<p>`. Browsers ignore extra spaces and line breaks in your code, so pressing Enter in the editor does **not** create a new paragraph — a new `<p>` does.

## Lists

**Unordered lists** (bullets) are for items where order does not matter:

```html
<ul>
  <li>Flour</li>
  <li>Eggs</li>
  <li>Milk</li>
</ul>
```

**Ordered lists** (numbers) are for steps where order matters:

```html
<ol>
  <li>Crack the eggs</li>
  <li>Whisk with milk</li>
  <li>Cook for three minutes</li>
</ol>
```

`<li>` means *list item*, and it must always be inside a `<ul>` or `<ol>`.

## Emphasis with meaning

- `<strong>` — strong importance (shown in bold by default).
- `<em>` — stress emphasis, as when you change your tone of voice (shown in italics).

These carry *meaning*. If you only want a visual style, that is a job for CSS.$md$,
    'published', false, 10);

  l := seed.lesson(m2, 1, 'Project: your personal profile page', 'project', 30,
    'Apply everything so far to build and submit a one-page profile.',
$md$## Your first project

Build a single page called `index.html` that introduces you (or a fictional person). It must use what you have learned — and nothing more is expected.

### Requirements

1. A valid document skeleton with `lang`, `charset`, `viewport` and a `<title>`.
2. Exactly one `<h1>` with the person’s name.
3. At least two `<h2>` sections, for example *About me* and *Skills I am learning*.
4. At least two paragraphs.
5. One unordered list and one ordered list (e.g. *My goals for this year*, in order).
6. At least one `<strong>` and one `<em>` used for meaning.
7. Neat indentation.

### How to submit

Paste your HTML code in the text box, **or** upload your `index.html` file, **or** share a link if you have published it (for example with GitHub Pages).

> [!NOTE]
> A reviewer checks your work against the rubric and leaves feedback. You can resubmit after making changes.$md$,
    'published', false, 50);

  insert into public.assignments (course_id, module_id, lesson_id, title, brief_md, rubric_md, submission_type, is_project, max_score, status)
  values (c, m2, l, 'Personal profile page',
    'Build a one-page profile using a valid HTML skeleton, headings, paragraphs and lists.',
$r$| Criterion | Points |
| --- | --- |
| Valid skeleton (doctype, lang, charset, viewport, title) | 20 |
| Correct heading outline (one h1, h2 sections, no skipped levels) | 20 |
| Paragraphs and both list types used correctly | 25 |
| Meaningful use of strong / em | 15 |
| Readable indentation and clean nesting | 20 |$r$,
    'any', true, 100, 'published');

  m3 := seed.module(c, 2, 'Links, images and media', 'Connect pages together and add pictures.', 'draft');
  perform seed.lesson(m3, 0, 'Links: connecting the web', 'article', 8, 'Absolute and relative links, opening in new tabs safely.', null, 'draft');
  perform seed.lesson(m3, 1, 'Images done right', 'article', 8, 'Formats, sizes and alternative text.', null, 'draft');
end $seed$;
