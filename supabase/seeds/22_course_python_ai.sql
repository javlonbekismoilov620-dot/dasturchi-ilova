-- Course: Python for Complete Beginners (premium, with free preview lessons)
do $seed$
declare
  c uuid; m1 uuid; m2 uuid; l uuid; q uuid; qq uuid;
begin
  insert into public.courses (slug, title, subtitle, description, category_id, subcategory_id, instructor_id,
    level, access_tier, status, estimated_minutes, learning_outcomes, prerequisites, tags, is_featured, cover_style)
  values ('python-for-complete-beginners', 'Python for Complete Beginners',
    'Your first programming language, explained without jargon',
    $d$Python is one of the most popular programming languages in the world — used for automation, data science, AI, websites and teaching. It reads almost like English, which makes it an excellent first language.

This course starts with **what programming is** before you write a single line, then moves step by step through installing Python, running programs and working with values.$d$,
    seed.cat('programming'), seed.cat('python'),
    (select id from public.instructors where slug = 'mahorat-editorial'),
    'zero', 'premium', 'published', 120,
    array['Explain what a program is and how a computer runs it',
          'Install Python and run code in the terminal and in files',
          'Store and change information with variables',
          'Recognise the basic data types: text, whole numbers, decimals and true/false'],
    array['Computer Fundamentals from Zero, or equivalent confidence with files and folders'],
    array['python', 'programming', 'beginner', 'automation'], true,
    '{"pattern": "waves", "hue": 48}')
  returning id into c;

  insert into public.course_prerequisites (course_id, prerequisite_course_id)
  values (c, seed.course('computer-fundamentals-from-zero'));

  m1 := seed.module(c, 0, 'Thinking like a programmer', 'What code is, and your very first program.');

  perform seed.lesson(m1, 0, 'What is programming?', 'article', 7,
    'Programs are precise recipes. Programming is writing them in a language the computer understands.',
$md$## Precise recipes

A **program** is a list of instructions. **Programming** is the skill of writing those instructions so precisely that a machine with zero common sense can follow them.

Imagine explaining to a robot how to make tea. “Make tea” is not enough. You would need: *fill the kettle with water, switch it on, wait until it boils, put a tea bag in a cup, pour the water…* — every step, in order, with nothing left out. That is how programmers think.

## Why programming languages exist

Computers only understand very simple numeric instructions. Writing those directly is slow and error-prone. **Programming languages** like Python let you write instructions in readable words, and a special program translates them for the computer.

```python
print("Hello, world!")
```

This single line tells the computer to display the text `Hello, world!`. Almost every programmer’s first program does exactly this.

## Three ideas you will use forever

1. **Sequence** — instructions run one after another, top to bottom.
2. **Decisions** — do something only *if* a condition is true.
3. **Repetition** — do something many times without writing it many times.

> [!TIP]
> Mistakes in code are called **bugs**, and fixing them is **debugging**. Every programmer — including experts — writes bugs every day. Error messages are not failures; they are clues.$md$,
    'published', true, 10);

  perform seed.lesson(m1, 1, 'Installing Python and running your first program', 'article', 12,
    'Install Python, open a terminal, and run code two different ways.',
$md$## 1. Install Python

- **Windows:** download the latest *Python 3* installer from **python.org**. On the first screen of the installer, tick **“Add python.exe to PATH”**, then click *Install Now*.
- **macOS:** download the macOS installer from **python.org** and run it.
- **Linux:** Python 3 is usually already installed.

> [!WARNING]
> Only download Python from the official site, **python.org**. Unofficial download sites sometimes bundle unwanted software.

## 2. Open a terminal

A **terminal** is a window where you type commands instead of clicking.

- Windows: open the Start menu and search for **Terminal** (or *Command Prompt*).
- macOS: open **Terminal** from Applications → Utilities.

Check the installation:

```bash
python --version
```

On macOS and Linux you may need `python3 --version`. You should see something like `Python 3.13.1`.

## 3. Run code interactively

Type `python` (or `python3`) and press Enter. The prompt changes to `>>>`. Now type:

```python
>>> 2 + 3
5
>>> print("Salom, dunyo!")
Salom, dunyo!
```

Type `exit()` to leave.

## 4. Run a program from a file

Create a file called `hello.py` with this content:

```python
name = "Aziz"
print("Hello,", name)
print("Welcome to Python.")
```

In the terminal, go to the folder with the file and run:

```bash
python hello.py
```

> [!TIP]
> Interactive mode is perfect for quick experiments. Files are for programs you want to keep and run again.$md$,
    'published', true, 15);

  l := seed.lesson(m1, 2, 'Variables: giving names to values', 'exercise', 14,
    'Store information, change it, and discover the four basic types of values.',
$md$## A labelled box

A **variable** is a name that refers to a value — like a labelled box you can put something into.

```python
age = 17
city = "Samarkand"
```

The `=` sign does **not** mean “equals” as in maths. It means *“store the value on the right under the name on the left”*. Read it as “age **becomes** 17”.

You can change a variable later:

```python
age = 17
age = age + 1
print(age)  # 18
```

The text after `#` is a **comment** — a note for humans that Python ignores.

## The basic types

| Type | Name in Python | Example |
| --- | --- | --- |
| Text | `str` (string) | `"Hello"` |
| Whole number | `int` (integer) | `42` |
| Decimal number | `float` | `3.14` |
| True / false | `bool` (boolean) | `True` |

Ask Python for a value’s type with `type()`:

```python
print(type("Hello"))  # <class 'str'>
print(type(42))       # <class 'int'>
```

## Naming rules

- Use letters, digits and underscores: `total_price`, `player2`.
- Do not start with a digit: `2player` is invalid.
- Names are case-sensitive: `Age` and `age` are different variables.
- Choose names that explain themselves: `minutes_per_day` beats `m`.

## Practice

Predict what this program prints **before** you run it:

```python
apples = 5
apples = apples * 2
price = 1.5
print(apples * price)
```

Then run it. Did you predict `15.0`? Multiplying an `int` by a `float` produces a `float`.$md$,
    'published', false, 20);

  q := seed.quiz(c, m1, l, 'Knowledge check: variables', 'knowledge_check', 70, 20);
  qq := seed.question(q, 0, 'single_choice', 'What does this program print?',
    '`x` starts at 4, then becomes 4 + 3 = 7.', E'x = 4\nx = x + 3\nprint(x)');
  perform seed.answer(qq, 0, '4', false, 'The second line changes `x`.');
  perform seed.answer(qq, 1, '7', true);
  perform seed.answer(qq, 2, 'x + 3', false, 'Python evaluates the expression; it does not print it as text.');
  qq := seed.question(q, 1, 'single_choice', 'Which is a valid variable name?', 'Names cannot start with a digit or contain spaces or hyphens.');
  perform seed.answer(qq, 0, '`2nd_place`', false, 'Starts with a digit.');
  perform seed.answer(qq, 1, '`second-place`', false, 'Hyphens are read as minus signs.');
  perform seed.answer(qq, 2, '`second_place`', true);
  qq := seed.question(q, 2, 'single_choice', 'What is the type of `3.0`?', 'Any number with a decimal point is a `float`, even if the decimal part is zero.');
  perform seed.answer(qq, 0, '`int`', false);
  perform seed.answer(qq, 1, '`float`', true);
  perform seed.answer(qq, 2, '`str`', false, 'It would be a string only inside quotes: `"3.0"`.');

  m2 := seed.module(c, 1, 'Making decisions', 'Conditions, comparison and if/else.', 'draft');
  perform seed.lesson(m2, 0, 'Comparing values', 'article', 10, 'True, False and comparison operators.', null, 'in_review');
  perform seed.lesson(m2, 1, 'if, elif and else', 'exercise', 14, 'Let your program choose what to do.', null, 'draft');
end $seed$;

-- Course: AI Fundamentals & Prompting (free)
do $seed$
declare
  c uuid; m1 uuid; l uuid; q uuid; qq uuid;
begin
  insert into public.courses (slug, title, subtitle, description, category_id, subcategory_id, instructor_id,
    level, access_tier, status, estimated_minutes, learning_outcomes, prerequisites, tags, is_featured, cover_style)
  values ('ai-fundamentals-and-prompting', 'AI Fundamentals & Prompting',
    'What modern AI really is — and how to get great results from it',
    $d$Artificial intelligence is changing how people learn and work. This course explains, in plain language, what AI systems actually do, where they fail, and how to write prompts that produce useful, reliable results.$d$,
    seed.cat('ai-emerging'), seed.cat('ai-fundamentals'),
    (select id from public.instructors where slug = 'mahorat-editorial'),
    'zero', 'free', 'published', 45,
    array['Explain the difference between AI, machine learning and large language models',
          'Recognise hallucinations and know how to verify AI output',
          'Write structured prompts with context, task, constraints and format'],
    array['None'],
    array['ai', 'llm', 'prompting', 'productivity'], false,
    '{"pattern": "orbits", "hue": 155}')
  returning id into c;

  m1 := seed.module(c, 0, 'Understanding modern AI', 'Concepts first, tools second.');

  perform seed.lesson(m1, 0, 'What AI is — and what it is not', 'article', 7,
    'AI, machine learning and deep learning, untangled.',
$md$## Three nested ideas

- **Artificial intelligence (AI)** is the broad goal: computers performing tasks that normally require human intelligence, such as understanding language or recognising images.
- **Machine learning (ML)** is one way to achieve it: instead of writing every rule by hand, we show a computer many examples and it *learns patterns* from them.
- **Deep learning** is a kind of machine learning that uses large **neural networks** — layered mathematical models loosely inspired by the brain.

## Learning from examples

A spam filter is a classic example. Nobody writes a rule for every possible spam message. Instead, the system sees millions of emails labelled “spam” or “not spam” and learns which patterns usually mean spam.

## What AI is not

> [!WARNING]
> Today’s AI systems do not *understand* the world the way people do, and they have no intentions. They produce outputs based on patterns in their training data. That makes them powerful — and capable of confident mistakes.

## Where you already meet AI

Photo search on your phone, voice assistants, translation apps, recommendations on video platforms, and chat assistants that can write and explain text.$md$,
    'published', false, 10);

  perform seed.lesson(m1, 1, 'How large language models work, simply', 'article', 9,
    'Predicting the next word — at an enormous scale.',
$md$## Predicting the next piece of text

A **large language model (LLM)** is trained on a huge amount of text. Its core skill is surprisingly simple to state: given some text, **predict what comes next**.

Text is split into small pieces called **tokens** — whole words, parts of words or punctuation. The model repeatedly predicts the next token, adds it, and predicts again. Because it learned from so much writing, those predictions can form explanations, summaries, code and translations.

## Why this matters for you

- **Context is everything.** The model only knows what is in its training and what you put in the conversation. Give it the background it needs.
- **It can be wrong, fluently.** When a model produces believable but false information, this is called a **hallucination**.
- **It has a knowledge cut-off.** Unless connected to search or documents, it may not know recent events.

> [!TIP]
> Treat AI output like a draft from a fast, well-read assistant: useful, but **verify facts, numbers, quotes and sources** before you rely on them.$md$,
    'published', false, 10);

  l := seed.lesson(m1, 2, 'Writing your first good prompt', 'exercise', 10,
    'A simple five-part structure that works with any assistant.',
$md$## From vague to precise

A vague prompt gets a generic answer:

> Write about Samarkand.

A structured prompt gets a useful one. Include these five parts:

1. **Role** — who should the assistant act as? *“You are a friendly history teacher.”*
2. **Context** — the background. *“My students are 14 and have never studied the Silk Road.”*
3. **Task** — exactly what you want. *“Explain why Samarkand became an important city.”*
4. **Constraints** — limits. *“Under 200 words, simple vocabulary, no dates except centuries.”*
5. **Format** — the shape of the answer. *“Three short paragraphs, then one question for discussion.”*

## Iterate

Your first prompt is a starting point. If the answer is too long, too formal or misses something, say so: *“Shorter, and add one example a teenager would relate to.”*

## Practice

Rewrite this weak prompt using all five parts, then try it with any AI assistant you have access to:

> Help me with my CV.

> [!NOTE]
> Never paste passwords, private documents or other people’s personal data into an AI tool unless you know exactly how that tool stores and uses it.$md$,
    'published', false, 15);

  q := seed.quiz(c, m1, l, 'Knowledge check: prompting', 'knowledge_check', 60, 20);
  qq := seed.question(q, 0, 'single_choice', 'An assistant gives a confident answer with a made-up statistic. What is this called?',
    'A hallucination is fluent, believable output that is not true.');
  perform seed.answer(qq, 0, 'A hallucination', true);
  perform seed.answer(qq, 1, 'A token', false, 'Tokens are the small pieces text is split into.');
  perform seed.answer(qq, 2, 'Fine-tuning', false, 'Fine-tuning is extra training on specific data.');
  qq := seed.question(q, 1, 'multiple_choice', 'Which of these improve a prompt?',
    'Context, clear constraints and a requested format all help. Vagueness hurts.');
  perform seed.answer(qq, 0, 'Giving relevant background', true);
  perform seed.answer(qq, 1, 'Stating the length and audience', true);
  perform seed.answer(qq, 2, 'Specifying the output format', true);
  perform seed.answer(qq, 3, 'Keeping it as short and vague as possible', false, 'Short is fine; vague is not.');
  qq := seed.question(q, 2, 'true_false', 'True or false: machine learning is a subset of artificial intelligence.',
    'ML is one approach to building AI, so it sits inside the broader field.');
  perform seed.answer(qq, 0, 'True', true);
  perform seed.answer(qq, 1, 'False', false);
end $seed$;
