-- Sprint 1 · Python for Complete Beginners (English). Idempotent; existing rows keep IDs.
do $content$
declare
  c constant text := 'python-for-complete-beginners';
  q uuid;
begin
  perform seed.ensure_module(c, 'Making decisions', 'Conditions, comparison and if/else.');
  perform seed.ensure_module(c, 'Repetition', 'Let the computer repeat work with while and for loops.');
  perform seed.ensure_module(c, 'Collections and functions', 'Store many values in lists and dictionaries, and package code into functions.');
  perform seed.ensure_module(c, 'Files, errors and projects', 'Save data to files, handle errors and build two complete programs.');

  perform seed.ensure_lesson(c, 'Thinking like a programmer', 'Input and output', 'exercise', 12,
    'Ask the user questions with input(), turn text into numbers and print friendly results with f-strings.',
$md$## Programs that talk to people

So far your programs have printed fixed text. In this lesson you will write programs that **ask questions**, use the answers and reply — the basis of every interactive program.

## Output with print()

```python
print("Salom!")
print("Apples:", 5)
print("Done", end="")
```

`print()` can show several values separated by commas; it puts a space between them and starts a new line at the end. `end=""` stops it from moving to a new line.

## Input with input()

```python
name = input("What is your name? ")
print("Nice to meet you,", name)
```

`input()` shows the message, waits for the user to type something and press **Enter**, then returns what they typed.

> [!WARNING]
> `input()` always returns **text** (`str`), even if the user types a number. `"5" + "3"` gives `"53"`, not `8`.

## Turning text into numbers

```python
age = int(input("How old are you? "))
price = float(input("Price of one book: "))
print(age + 1)
print(price * 3)
```

- `int()` converts text such as `"17"` into a whole number.
- `float()` converts text such as `"2.5"` into a decimal number.

If the user types something that is not a number, such as `seventeen`, Python stops with a `ValueError`. You will learn to handle this gracefully in the lesson on errors.

## Friendly output with f-strings

An **f-string** has an `f` before the quotes and puts values inside curly braces:

```python
name = "Aziz"
lessons = 12
print(f"{name} has finished {lessons} lessons.")
print(f"Next year you will be {age + 1}.")
```

You can even format numbers: `f"{price:.2f}"` shows a number with exactly two decimal places.

## A worked example

```python
name = input("Name: ")
minutes = int(input("Minutes you studied today: "))
goal = 30
left = goal - minutes
print(f"Well done, {name}! {left} minutes left to reach your goal.")
```

If the user types `Malika` and `20`, the program prints: `Well done, Malika! 10 minutes left to reach your goal.`

## Try it

Write a program that asks for the price of a product and how many the user wants, then prints the total with two decimal places. Test it with `2.5` and `4` — the answer should be `10.00`.

## Common mistakes

- Forgetting that `input()` returns text and adding it to a number (`TypeError`).
- Forgetting the `f` before the quotes, so `{name}` is printed literally.
- Leaving out the space at the end of the input message, so the answer sticks to the question.

## Key terms

- **input()** — reads a line of text typed by the user.
- **print()** — shows values on the screen.
- **int() / float()** — convert text into a whole number or a decimal number.
- **f-string** — a string with values inserted in `{}`.$md$, 'published', false, 15);

  perform seed.ensure_lesson(c, 'Making decisions', 'Comparing values', 'article', 10,
    'True, False and the comparison operators that let programs ask questions.',
$md$## Questions with yes-or-no answers

Programs make decisions by asking questions whose answer is either **True** or **False**. In this lesson you will learn how to ask those questions in Python.

```python
print(10 > 3)
print(2 == 5)
```

The first line prints `True`, the second `False`. `True` and `False` are values of the type `bool` (boolean), named after the mathematician George Boole.

## Comparison operators

| Operator | Meaning | Example | Result |
| --- | --- | --- | --- |
| `==` | equal to | `5 == 5` | `True` |
| `!=` | not equal to | `5 != 3` | `True` |
| `<` | less than | `2 < 1` | `False` |
| `>` | greater than | `7 > 4` | `True` |
| `<=` | less than or equal to | `3 <= 3` | `True` |
| `>=` | greater than or equal to | `2 >= 5` | `False` |

> [!WARNING]
> `=` and `==` are different. `=` **stores** a value (`age = 17`); `==` **compares** two values (`age == 17`). Mixing them up is one of the most common beginner mistakes.

## Comparing text

Text can be compared too:

```python
print("apple" == "apple")
print("Apple" == "apple")
```

The first is `True`; the second is `False`, because comparisons are **case-sensitive**. To compare without caring about capitals, convert both sides first: `answer.lower() == "yes"`.

## Saving the result

A comparison is an expression like any other, so you can store its result:

```python
score = 82
passed = score >= 70
print(passed)
```

This prints `True`. Naming a boolean well — `passed`, `is_adult`, `has_ticket` — makes the code read like a sentence.

## Combining comparisons

Python lets you chain comparisons in a natural way:

```python
age = 15
print(13 <= age <= 19)
```

This asks “is `age` between 13 and 19?” and prints `True`.

## Try it

Ask the user for a number with `input()` and `int()`, then print whether it is greater than 100, whether it equals 0, and whether it is between 1 and 10.

## Common mistakes

- Writing `=` when you mean `==`.
- Comparing a number with text: `5 == "5"` is `False`, because one is an `int` and the other a `str`.
- Forgetting that `"Yes"` and `"yes"` are different strings.

## Key terms

- **Boolean (`bool`)** — a value that is either `True` or `False`.
- **Comparison operator** — a symbol such as `==` or `<` that compares two values.
- **Case-sensitive** — treating capital and small letters as different.
- **Expression** — a piece of code that produces a value.$md$);

  perform seed.ensure_lesson(c, 'Making decisions', 'if, elif and else', 'exercise', 14,
    'Let your program choose what to do with if, elif and else.',
$md$## Choosing a path

Now that you can ask True-or-False questions, you can make your program **act** on the answer. In this lesson you will use `if`, `elif` and `else` to choose between different paths.

```python
temperature = int(input("Temperature today: "))

if temperature > 30:
    print("It is hot. Drink plenty of water.")
```

- The line with `if` ends with a **colon** `:`.
- The code that belongs to the `if` is **indented** by four spaces. Python uses indentation to know which lines are inside the decision.

## else: the other way

```python
if temperature > 30:
    print("It is hot.")
else:
    print("It is not too hot.")
```

Exactly one of the two blocks runs.

## elif: more than two choices

`elif` means “else, if”. Python checks the conditions from top to bottom and runs the **first** block whose condition is True:

```python
score = int(input("Your score: "))

if score >= 90:
    grade = "excellent"
elif score >= 70:
    grade = "good"
elif score >= 50:
    grade = "satisfactory"
else:
    grade = "needs more practice"

print(f"Result: {grade}")
```

A score of 75 gives “good” — Python stops checking as soon as `score >= 70` is True.

> [!TIP]
> Order matters. If you checked `score >= 50` first, a score of 95 would be reported as “satisfactory”. Put the strictest condition first.

## Combining conditions

- `and` — both conditions must be True.
- `or` — at least one condition must be True.
- `not` — reverses True and False.

```python
age = 16
has_permission = True

if age >= 18 or has_permission:
    print("You may join the trip.")
```

## Try it

Write a ticket price program: children under 7 travel free, people aged 7–17 pay 2 000 so‘m, adults pay 4 000 so‘m, and anyone with a student card pays half price. Test it with ages 5, 12 and 30.

## Common mistakes

- Forgetting the colon at the end of `if`, `elif` or `else`.
- Inconsistent indentation, which causes an `IndentationError`.
- Putting conditions in the wrong order, so a later branch is never reached.

## Key terms

- **if / elif / else** — keywords that choose which block of code runs.
- **Condition** — an expression that is True or False.
- **Indentation** — spaces at the start of a line that show which block it belongs to.
- **and / or / not** — operators that combine or reverse conditions.$md$, 'published', false, 15);

  perform seed.ensure_lesson(c, 'Making decisions', 'Making decisions: check', 'quiz', 5,
    'Five questions on comparisons and if/elif/else.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Making decisions: check', 'Making decisions check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'What is the difference between `=` and `==`?',
    '`=` stores a value in a variable; `==` compares two values.',
    array['`=` stores a value; `==` compares two values', 'They mean the same thing', '`==` stores a value; `=` compares'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'single_choice', 'What does this print?',
    'Comparisons are case-sensitive, so "Yes" and "yes" are different.',
    array['False', 'True', 'yes'], array[true, false, false],
    array[null, 'Capital and small letters are different characters.', 'A comparison prints True or False.'],
    'print("Yes" == "yes")');
  perform seed.ensure_question(q, 2, 'single_choice', 'With `score = 75`, what does this program print?',
    'Python runs the first block whose condition is True: 75 >= 70, so it prints "good".',
    array['good', 'excellent', 'good and satisfactory'], array[true, false, false],
    array[null, '75 is not >= 90.', 'Only one block of an if/elif/else chain runs.'],
    E'if score >= 90:\n    print("excellent")\nelif score >= 70:\n    print("good")\nelif score >= 50:\n    print("satisfactory")');
  perform seed.ensure_question(q, 3, 'single_choice', 'Which condition is True only when **both** parts are True?',
    '`and` requires both conditions to be True.',
    array['`a and b`', '`a or b`', '`not a`'], array[true, false, false],
    array[null, '`or` needs only one of them.', '`not` reverses a single condition.']);
  perform seed.ensure_question(q, 4, 'true_false', 'True or false: Python uses indentation to decide which lines belong to an `if` block.',
    'True — the indented lines after the colon form the block.',
    array['True', 'False'], array[true, false], null);

  perform seed.ensure_lesson(c, 'Repetition', 'while loops', 'article', 11,
    'Repeat code for as long as a condition is True — and avoid loops that never end.',
$md$## Doing something again and again

Computers never get bored. A **loop** repeats a block of code, so you can do a task many times without writing it many times. In this lesson you will use the `while` loop, which repeats **as long as a condition is True**.

```python
count = 1
while count <= 5:
    print(count)
    count = count + 1
print("Finished")
```

This prints the numbers 1 to 5, then `Finished`. Step by step:

1. Python checks the condition `count <= 5`.
2. If it is True, it runs the indented block, then goes back to step 1.
3. When the condition is False, it continues after the loop.

## Updating the loop variable

The line `count = count + 1` is essential. Python also has a shorter way to write it: `count += 1`.

> [!WARNING]
> If nothing inside the loop ever makes the condition False, the loop runs **forever**. This is called an infinite loop. If it happens, press **Ctrl + C** in the terminal to stop the program.

## Loops that wait for the user

`while` is ideal when you do not know in advance how many times to repeat:

```python
answer = ""
while answer != "stop":
    answer = input("Type a word (or stop): ")
    print(f"You typed {len(answer)} letters.")
```

## Leaving a loop early with break

```python
secret = 7
while True:
    guess = int(input("Guess the number from 1 to 10: "))
    if guess == secret:
        print("Correct!")
        break
    print("Try again.")
```

`while True` would run forever, but `break` jumps out of the loop as soon as the guess is right.

## A worked example: a savings plan

```python
savings = 0
month = 0
while savings < 1000000:
    savings += 150000
    month += 1
print(f"You reach 1 000 000 so'm after {month} months.")
```

The loop adds 150 000 each month until the target is reached and then reports `7` months.

## Try it

Write a program that keeps asking the user for numbers and adds them up until they type `0`, then prints the total.

## Common mistakes

- Forgetting to update the variable in the condition, which creates an infinite loop.
- Using `=` instead of `==` or `!=` in the condition.
- Putting the update outside the indented block, so it runs only after the loop.

## Key terms

- **Loop** — code that repeats.
- **while loop** — repeats while a condition is True.
- **Infinite loop** — a loop whose condition never becomes False.
- **break** — leaves a loop immediately.$md$);

  perform seed.ensure_lesson(c, 'Repetition', 'for loops and range()', 'exercise', 12,
    'Repeat a fixed number of times or go through every item with for and range().',
$md$## Going through a sequence

A `for` loop takes the items of a sequence **one by one**. It is the loop you will use most often. In this lesson you will repeat code a fixed number of times and walk through text and lists.

```python
for letter in "Salom":
    print(letter)
```

This prints `S`, `a`, `l`, `o`, `m` on separate lines. Each time round the loop, the variable `letter` holds the next character.

## Counting with range()

`range()` produces a sequence of numbers:

| Code | Numbers produced |
| --- | --- |
| `range(5)` | 0, 1, 2, 3, 4 |
| `range(1, 6)` | 1, 2, 3, 4, 5 |
| `range(0, 10, 2)` | 0, 2, 4, 6, 8 |
| `range(5, 0, -1)` | 5, 4, 3, 2, 1 |

> [!NOTE]
> `range(5)` stops **before** 5. The end number is never included — a detail that surprises almost everyone at first.

```python
for i in range(1, 4):
    print(f"Lesson {i}")
```

## Building up a result

A very common pattern is to start with an empty or zero value and build it up inside the loop:

```python
total = 0
for number in range(1, 11):
    total += number
print(total)
```

This adds 1 to 10 and prints `55`.

## Skipping with continue

`continue` skips the rest of the current round and moves on to the next item:

```python
for n in range(1, 11):
    if n % 2 == 0:
        continue
    print(n)
```

`%` gives the remainder of a division, so `n % 2 == 0` is True for even numbers. The program prints only the odd numbers.

## while or for?

- Use **for** when you know how many times to repeat, or you are going through every item.
- Use **while** when you repeat until something happens, such as the user typing “stop”.

## Try it

Print a multiplication table for a number the user chooses, from 1 to 10, in the form `7 x 3 = 21`.

## Common mistakes

- Expecting `range(10)` to include 10.
- Changing the loop variable inside a `for` loop and expecting it to affect the next round.
- Forgetting to indent the body of the loop.

## Key terms

- **for loop** — repeats once for each item of a sequence.
- **range()** — produces a sequence of whole numbers.
- **continue** — skips to the next round of the loop.
- **Remainder (`%`)** — what is left over after division.$md$, 'published', false, 15);

  perform seed.ensure_lesson(c, 'Repetition', 'Repetition: check', 'quiz', 5,
    'Five questions on while, for and range().', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Repetition: check', 'Repetition check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'Which numbers does `range(4)` produce?',
    '`range(4)` starts at 0 and stops before 4.',
    array['0, 1, 2, 3', '1, 2, 3, 4', '0, 1, 2, 3, 4'], array[true, false, false],
    array[null, 'It starts at 0, not 1.', 'The end number is not included.']);
  perform seed.ensure_question(q, 1, 'single_choice', 'What does this program print?',
    'The loop adds 1 + 2 + 3 = 6.',
    array['6', '3', '123'], array[true, false, false],
    array[null, 'That is only the last number; the loop adds them all.', 'The numbers are added, not joined as text.'],
    E'total = 0\nfor n in range(1, 4):\n    total += n\nprint(total)');
  perform seed.ensure_question(q, 2, 'single_choice', 'Why does this loop never stop?',
    '`count` never changes, so `count < 5` stays True forever.',
    array['`count` is never increased', 'The condition should use `==`', '`print` cannot be used in loops'], array[true, false, false], null,
    E'count = 0\nwhile count < 5:\n    print(count)');
  perform seed.ensure_question(q, 3, 'single_choice', 'What does `break` do inside a loop?',
    '`break` leaves the loop immediately.',
    array['Leaves the loop immediately', 'Skips to the next round', 'Restarts the program'], array[true, false, false],
    array[null, 'That is `continue`.', 'The program carries on after the loop.']);
  perform seed.ensure_question(q, 4, 'single_choice', 'You want to keep asking for a password until it is correct. Which loop fits best?',
    'You do not know how many attempts are needed, so `while` fits.',
    array['A `while` loop', 'A `for` loop with `range(3)`', 'No loop is needed'], array[true, false, false],
    array[null, 'That would allow exactly three attempts, not “until correct”.', 'Without a loop you could only ask once.']);

  perform seed.ensure_lesson(c, 'Collections and functions', 'Lists', 'article', 12,
    'Store many values in one variable, change them and loop over them.',
$md$## Many values in one place

Imagine storing the marks of 30 students in 30 separate variables. A **list** keeps them all in one variable, in order. In this lesson you will create, read, change and loop over lists.

```python
cities = ["Tashkent", "Samarkand", "Bukhara"]
marks = [5, 4, 5, 3]
empty = []
```

A list is written with square brackets, and its items are separated by commas. Items can be of any type.

## Reading items by index

Each item has a position number called an **index**. Counting starts at **0**:

```python
print(cities[0])
print(cities[2])
print(cities[-1])
```

This prints `Tashkent`, `Bukhara` and `Bukhara` — a negative index counts from the end.

> [!WARNING]
> Asking for an index that does not exist, such as `cities[3]` in a three-item list, stops the program with an `IndexError`.

## Changing a list

| Code | What it does |
| --- | --- |
| `cities.append("Khiva")` | Adds an item to the end |
| `cities.insert(0, "Nukus")` | Inserts an item at position 0 |
| `cities.remove("Bukhara")` | Removes the first matching item |
| `cities[1] = "Andijan"` | Replaces the item at position 1 |
| `cities.sort()` | Sorts the list in place |

## Useful questions about a list

```python
marks = [5, 4, 5, 3]
print(len(marks))
print(sum(marks) / len(marks))
print(4 in marks)
print(max(marks), min(marks))
```

`len()` gives the number of items, `sum()` adds them, `in` checks whether an item is present, and `max()` and `min()` find the largest and smallest.

## Looping over a list

```python
for city in cities:
    print(f"I would like to visit {city}.")
```

## Taking part of a list

A **slice** takes several items at once: `marks[1:3]` gives the items at positions 1 and 2, `[4, 5]`. As with `range()`, the end position is not included.

## Try it

Make an empty list called `shopping`. Use a `while` loop to ask the user for items until they type `done`, adding each one with `append()`. Then print how many items there are and each item on its own line.

## Common mistakes

- Starting to count at 1 instead of 0.
- Using an index that is too large.
- Writing `cities.append = "Khiva"` instead of calling `cities.append("Khiva")`.

## Key terms

- **List** — an ordered collection of values.
- **Index** — the position of an item, starting at 0.
- **Method** — a function that belongs to a value, such as `append()`.
- **Slice** — part of a list, such as `marks[1:3]`.$md$);

  perform seed.ensure_lesson(c, 'Collections and functions', 'Dictionaries', 'article', 11,
    'Look values up by name with key–value pairs.',
$md$## Looking things up by name

A list finds items by position. A **dictionary** finds values by a **key** — like a real dictionary, where you look up a word to find its meaning. In this lesson you will store and look up information with dictionaries.

```python
student = {
    "name": "Malika",
    "age": 16,
    "city": "Namangan",
}
```

A dictionary uses curly braces. Each entry is a **key–value pair** written `key: value`.

## Reading values

```python
print(student["name"])
print(student.get("phone", "not given"))
```

The first line prints `Malika`. Square brackets stop the program with a `KeyError` if the key is missing, so `get()` is safer: it returns the second value (`"not given"`) when the key does not exist.

## Adding and changing entries

```python
student["phone"] = "+998 90 123 45 67"
student["age"] = 17
del student["city"]
```

Assigning to a new key adds it; assigning to an existing key replaces its value; `del` removes an entry.

## Looping over a dictionary

```python
prices = {"bread": 4000, "milk": 12000, "tea": 25000}

for item, price in prices.items():
    print(f"{item}: {price} so'm")
```

`items()` gives each key together with its value.

## Counting with a dictionary

Dictionaries are perfect for counting:

```python
text = "olma anor olma uzum olma"
counts = {}
for word in text.split():
    counts[word] = counts.get(word, 0) + 1
print(counts)
```

This prints `{'olma': 3, 'anor': 1, 'uzum': 1}`. `split()` breaks the text into words.

> [!TIP]
> Use a list when order matters and items are similar (a queue of names). Use a dictionary when you look things up by a label (a price for each product).

## Try it

Create a dictionary of five English words and their Uzbek translations. Ask the user for an English word and print the translation, or “Not in the dictionary yet” if it is missing.

## Common mistakes

- Using square brackets for a key that may not exist, instead of `get()`.
- Forgetting the quotes around text keys: `student[name]` instead of `student["name"]`.
- Expecting a dictionary to be sorted by value.

## Key terms

- **Dictionary (`dict`)** — a collection of key–value pairs.
- **Key** — the label used to look up a value.
- **get()** — reads a value, with a default if the key is missing.
- **items()** — gives keys and values together in a loop.$md$);

  perform seed.ensure_lesson(c, 'Collections and functions', 'Functions', 'exercise', 13,
    'Package code into reusable functions with parameters and return values.',
$md$## Name a piece of work

You have already used many functions: `print()`, `input()`, `len()`. In this lesson you will write your own. A **function** is a named block of code you can run whenever you need it — so you write it once and use it many times.

```python
def greet(name):
    print(f"Salom, {name}!")

greet("Aziz")
greet("Malika")
```

- `def` starts a function definition; `greet` is its name.
- `name` is a **parameter** — a variable that receives a value when the function is called.
- `"Aziz"` and `"Malika"` are **arguments** — the values passed in.

## Returning a value

`print()` only shows something. To give a result **back** to the code that called the function, use `return`:

```python
def area(width, height):
    return width * height

room = area(4, 5)
print(f"The room is {room} square metres.")
```

`return` ends the function and sends the value back. Here `room` becomes `20`.

> [!WARNING]
> A function without `return` gives back the special value `None`. If you write `result = greet("Aziz")`, `result` is `None`, because `greet` prints but does not return anything.

## Default values

```python
def price_with_tax(price, tax=0.12):
    return price * (1 + tax)

print(round(price_with_tax(100000)))
print(round(price_with_tax(100000, 0.05)))
```

If no second argument is given, `tax` is `0.12`, so the first line prints `112000` and the second `105000`. (`round()` hides the tiny rounding errors that decimal numbers can have in any programming language.)

## Variables inside functions

Variables created inside a function exist only while it runs — they are **local**. This keeps functions independent: a variable called `total` inside one function does not clash with a `total` elsewhere.

## Why functions matter

- **No repetition:** fix a bug once, and every use is fixed.
- **Readability:** `average(marks)` explains itself.
- **Testing:** you can check a small function on its own.

## A worked example

```python
def average(numbers):
    """Return the average of a list of numbers."""
    return sum(numbers) / len(numbers)

def grade(mark):
    if mark >= 4.5:
        return "excellent"
    elif mark >= 3.5:
        return "good"
    return "needs practice"

marks = [5, 4, 5, 4]
avg = average(marks)
print(f"Average {avg:.1f}: {grade(avg)}")
```

The text in triple quotes is a **docstring** — a short description of what the function does. The program prints `Average 4.5: excellent`.

## Try it

Write a function `convert_to_som(dollars, rate)` that returns the amount in so'm, and a function `format_som(amount)` that returns text such as `1 250 000 so'm`. Hint: `f"{amount:,.0f}".replace(",", " ")` puts spaces between thousands.

## Common mistakes

- Printing inside a function when the result should be returned.
- Calling a function before defining it in the file.
- Forgetting the parentheses: `greet` refers to the function; `greet()` runs it.

## Key terms

- **Function** — a named, reusable block of code.
- **Parameter / argument** — the variable in the definition / the value passed in.
- **return** — sends a value back from a function.
- **Local variable** — a variable that exists only inside a function.$md$, 'published', false, 15);

  perform seed.ensure_lesson(c, 'Collections and functions', 'Collections and functions: check', 'quiz', 5,
    'Five questions on lists, dictionaries and functions.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Collections and functions: check', 'Collections and functions check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'What does this print?',
    'Indexes start at 0, so index 1 is the second item.',
    array['Samarkand', 'Tashkent', 'Bukhara'], array[true, false, false],
    array[null, 'That is index 0.', 'That is index 2.'],
    E'cities = ["Tashkent", "Samarkand", "Bukhara"]\nprint(cities[1])');
  perform seed.ensure_question(q, 1, 'single_choice', 'Which line adds `"Khiva"` to the end of the list `cities`?',
    '`append()` adds an item to the end of a list.',
    array['`cities.append("Khiva")`', '`cities.add("Khiva")`', '`cities[3] = "Khiva"`'], array[true, false, false],
    array[null, 'Lists do not have an `add()` method.', 'Assigning to an index that does not exist raises an IndexError.']);
  perform seed.ensure_question(q, 2, 'single_choice', 'The key `"phone"` may be missing from `student`. Which line is safe?',
    '`get()` returns a default value instead of raising a KeyError.',
    array['`student.get("phone", "none")`', '`student["phone"]`', '`student[phone]`'], array[true, false, false],
    array[null, 'This raises a KeyError if the key is missing.', 'Without quotes, Python looks for a variable called phone.']);
  perform seed.ensure_question(q, 3, 'single_choice', 'What is stored in `x`?',
    'The function prints but does not return anything, so it returns None.',
    array['`None`', '`"Hi"`', 'An error'], array[true, false, false],
    array[null, '"Hi" is printed, not returned.', 'This code runs without an error.'],
    E'def say_hi():\n    print("Hi")\n\nx = say_hi()');
  perform seed.ensure_question(q, 4, 'single_choice', 'When is a dictionary a better choice than a list?',
    'Dictionaries look values up by a key, such as a price for each product.',
    array['When you look values up by a label, such as a price per product', 'When the order of similar items matters', 'When you store only one value'],
    array[true, false, false],
    array[null, 'Ordered, similar items fit a list.', 'One value fits a simple variable.']);

  perform seed.ensure_lesson(c, 'Files, errors and projects', 'Files and errors', 'article', 13,
    'Save data in text files, read it back and handle errors instead of crashing.',
$md$## Keeping data after the program ends

Variables disappear when a program stops. To keep data — a to-do list, scores, expenses — you save it in a **file**. In this lesson you will write and read text files, and handle errors so your program does not crash.

## Writing a file

```python
with open("notes.txt", "w", encoding="utf-8") as f:
    f.write("Oʻzbekcha matn ham toʻgʻri saqlanadi.\n")
    f.write("Second line\n")
```

- `open()` opens a file; `"w"` means **write** (it creates the file, or replaces it if it exists).
- `with` closes the file automatically when the block ends, even if something goes wrong.
- `encoding="utf-8"` makes sure every alphabet, including oʻ, gʻ and Cyrillic, is saved correctly.
- `\n` starts a new line.

## Reading a file

```python
with open("notes.txt", encoding="utf-8") as f:
    for line in f:
        print(line.strip())
```

The default mode is `"r"` (read). Looping over the file gives one line at a time; `strip()` removes the line break at the end.

| Mode | Meaning |
| --- | --- |
| `"r"` | Read (the default); the file must exist |
| `"w"` | Write; replaces everything in the file |
| `"a"` | Append; adds to the end of the file |

## When things go wrong

Errors are normal: the user types letters where a number is expected, or a file does not exist. Python reports these as **exceptions**. Without handling, the program stops and prints a **traceback** — read it from the bottom: the last line names the error, the lines above show where it happened.

## Handling errors with try and except

```python
try:
    age = int(input("Your age: "))
    print(f"Next year you will be {age + 1}.")
except ValueError:
    print("Please type your age in digits, for example 17.")
```

If the code inside `try` raises a `ValueError`, Python jumps to the `except` block instead of crashing.

```python
try:
    with open("scores.txt", encoding="utf-8") as f:
        print(f.read())
except FileNotFoundError:
    print("No scores saved yet.")
```

> [!TIP]
> Catch only the errors you expect and know how to handle, such as `ValueError` or `FileNotFoundError`. Catching every error hides real bugs.

## Try it

Write a program that asks for a short note, appends it to `diary.txt` with mode `"a"`, then prints all the notes saved so far. Make it print a friendly message instead of crashing if the file does not exist yet.

## Common mistakes

- Using `"w"` when you meant `"a"` and wiping the file.
- Forgetting `encoding="utf-8"`, so Uzbek or Russian letters are garbled on some computers.
- Wrapping a whole program in `try` / `except` and hiding mistakes.

## Key terms

- **File mode** — how a file is opened: read, write or append.
- **Encoding (UTF-8)** — how text is turned into bytes; UTF-8 supports every alphabet.
- **Exception** — an error that happens while a program runs.
- **Traceback** — Python's report showing where an error happened.$md$);

  perform seed.ensure_lesson(c, 'Files, errors and projects', 'Project: quiz game', 'project', 45,
    'Build a quiz game that asks questions, checks answers and keeps score.',
$md$## Your first complete program

Build a **quiz game** that asks the player several questions, checks the answers and reports a score. It uses almost everything you have learned: variables, input, conditions, loops, lists, dictionaries and functions.

### Requirements

1. Store at least **five questions** in a list of dictionaries, each with a question and its answer, for example `{"question": "Capital of Uzbekistan?", "answer": "tashkent"}`.
2. Ask the questions one by one with a loop.
3. Compare answers without caring about capitals or spaces (use `lower()` and `strip()`).
4. Keep a score and tell the player after each question whether they were right — and the right answer if not.
5. Put the checking code in a function, for example `check_answer(given, correct)`.
6. At the end, print the score and a message that depends on it (for example, “Excellent!” for full marks).

### Ideas for extra challenge

- Let the player play again without restarting the program.
- Save the best score to a file and show it at the start.

### How to submit

Paste your code into the text box or upload your `.py` file, and add the output of one complete game.

> [!NOTE]
> A reviewer checks your program against the rubric and leaves feedback. You can improve it and resubmit.$md$, 'published', false, 50);
  perform seed.ensure_assignment(c, 'Project: quiz game', 'Quiz game',
    'Build a quiz game with questions stored in a list of dictionaries, a scoring loop and at least one function.',
$r$| Criterion | Points |
| --- | --- |
| Questions stored in a list of dictionaries (five or more) | 20 |
| Loop asks every question; score is kept correctly | 25 |
| Answers compared fairly (lower and strip) with feedback | 20 |
| Checking logic in a well-named function | 20 |
| Final score and message; clear, readable code | 15 |$r$);

  perform seed.ensure_lesson(c, 'Files, errors and projects', 'Project: budget tracker', 'project', 60,
    'Build a menu-driven budget tracker that saves expenses to a file.',
$md$## A tool you can actually use

Build a **personal budget tracker** that runs in the terminal, remembers expenses between runs and shows totals by category.

### Requirements

1. A menu that repeats until the user chooses to quit, for example: `1) Add expense  2) Show all  3) Totals by category  4) Quit`.
2. **Add expense** asks for an amount and a category (such as food, transport or books). Invalid amounts are handled with `try` / `except` instead of crashing.
3. Expenses are saved to a text file (for example, one line per expense: `25000,food`) and loaded again when the program starts.
4. **Show all** lists every expense.
5. **Totals by category** uses a dictionary to add up the amounts per category and prints the grand total.
6. Use at least three functions, such as `load_expenses()`, `save_expense()` and `totals_by_category()`.

### Ideas for extra challenge

- Show the largest expense and its category.
- Print amounts with spaces between thousands, such as `1 250 000 so'm`.

### How to submit

Paste your code or upload your `.py` file, and include a short example session that shows adding an expense, closing the program, opening it again and seeing the expense still there.

> [!NOTE]
> A reviewer checks your program against the rubric and leaves feedback. You can improve it and resubmit.$md$, 'published', false, 60);
  perform seed.ensure_assignment(c, 'Project: budget tracker', 'Budget tracker',
    'Build a menu-driven budget tracker that saves expenses to a file and totals them by category.',
$r$| Criterion | Points |
| --- | --- |
| Menu loop with working options and a clean exit | 20 |
| Expenses saved to and loaded from a file with UTF-8 encoding | 25 |
| Invalid input handled with try / except | 15 |
| Category totals calculated with a dictionary | 20 |
| Three or more clear functions; readable code | 20 |$r$);

  perform seed.ensure_lesson(c, 'Files, errors and projects', 'Final assessment', 'quiz', 10,
    'A short exam covering the whole course. Pass mark: 70%.', null, 'published', false, 30);
  q := seed.ensure_quiz(c, 'Final assessment', 'Python for Complete Beginners — final assessment', 'final_assessment', 70, 50);
  perform seed.ensure_question(q, 0, 'single_choice', 'What type of value does `input()` return?',
    '`input()` always returns text (`str`); convert it with `int()` or `float()` when you need a number.',
    array['`str` (text)', '`int`', 'Whatever the user typed: a number or text'], array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'single_choice', 'What does this print?',
    '`f"{x * 2}"` evaluates the expression inside the braces: 7 * 2 = 14.',
    array['Result: 14', 'Result: {x * 2}', 'Result: 72'], array[true, false, false], null,
    E'x = 7\nprint(f"Result: {x * 2}")');
  perform seed.ensure_question(q, 2, 'single_choice', 'With `age = 12`, which line is printed?',
    'Python runs the first True branch: 12 < 13, so "child".',
    array['child', 'teen', 'adult'], array[true, false, false], null,
    E'if age < 13:\n    print("child")\nelif age < 18:\n    print("teen")\nelse:\n    print("adult")');
  perform seed.ensure_question(q, 3, 'single_choice', 'How many times does `print` run?',
    '`range(2, 6)` gives 2, 3, 4, 5 — four numbers.',
    array['4', '5', '6'], array[true, false, false], null,
    E'for i in range(2, 6):\n    print(i)');
  perform seed.ensure_question(q, 4, 'single_choice', 'What is `marks[-1]` if `marks = [3, 4, 5]`?',
    'A negative index counts from the end; -1 is the last item.',
    array['5', '3', 'An error'], array[true, false, false], null);
  perform seed.ensure_question(q, 5, 'single_choice', 'Which keyword sends a value back from a function?',
    '`return` ends the function and gives back a value.',
    array['`return`', '`print`', '`def`'], array[true, false, false], null);
  perform seed.ensure_question(q, 6, 'single_choice', 'Which file mode adds text to the end of an existing file?',
    '`"a"` appends; `"w"` replaces the content.',
    array['`"a"`', '`"w"`', '`"r"`'], array[true, false, false],
    array[null, '`"w"` deletes what was in the file.', '`"r"` only reads.']);
  perform seed.ensure_question(q, 7, 'single_choice', 'Which exception do you catch when `int()` receives text such as `"seventeen"`?',
    'Converting invalid text with `int()` raises a ValueError.',
    array['`ValueError`', '`FileNotFoundError`', '`KeyError`'], array[true, false, false], null);

  perform seed.order_modules(c, array['Thinking like a programmer', 'Making decisions', 'Repetition', 'Collections and functions', 'Files, errors and projects']);
  perform seed.order_lessons(c, 'Thinking like a programmer', array['What is programming?', 'Installing Python and running your first program', 'Variables: giving names to values', 'Input and output']);
  perform seed.order_lessons(c, 'Making decisions', array['Comparing values', 'if, elif and else', 'Making decisions: check']);
  perform seed.order_lessons(c, 'Repetition', array['while loops', 'for loops and range()', 'Repetition: check']);
  perform seed.order_lessons(c, 'Collections and functions', array['Lists', 'Dictionaries', 'Functions', 'Collections and functions: check']);
  perform seed.order_lessons(c, 'Files, errors and projects', array['Files and errors', 'Project: quiz game', 'Project: budget tracker', 'Final assessment']);
end $content$;

-- Oʻzbekcha ------------------------------------------------------------------------------
do $tr$
declare
  c constant text := 'python-for-complete-beginners';
begin
  perform seed.tr_module(c, 'Repetition', 'uz', 'Takrorlash',
    'while va for sikllari yordamida ishni kompyuterga takrorlating.');
  perform seed.tr_module(c, 'Collections and functions', 'uz', 'Toʻplamlar va funksiyalar',
    'Koʻplab qiymatlarni roʻyxat va lugʻatlarda saqlang hamda kodni funksiyalarga joylang.');
  perform seed.tr_module(c, 'Files, errors and projects', 'uz', 'Fayllar, xatolar va loyihalar',
    'Maʼlumotlarni fayllarga saqlang, xatolarni boshqaring va ikkita toʻliq dastur yarating.');

  perform seed.tr_lesson(c, 'Input and output', 'uz', 'Kiritish va chiqarish',
    'input() bilan foydalanuvchiga savol bering, matnni songa aylantiring va f-satrlar yordamida tushunarli natija chiqaring.',
$md$## Odamlar bilan “gaplashadigan” dasturlar

Hozirgacha dasturlaringiz oʻzgarmas matnni chiqarardi. Bu darsda **savol beradigan**, javoblardan foydalanadigan va javob qaytaradigan dasturlar yozasiz — bu har qanday interaktiv dasturning asosi.

## print() bilan chiqarish

```python
print("Salom!")
print("Olmalar:", 5)
print("Tayyor", end="")
```

`print()` vergul bilan ajratilgan bir nechta qiymatni koʻrsata oladi; ular orasiga boʻsh joy qoʻyadi va oxirida yangi qatorga oʻtadi. `end=""` uning yangi qatorga oʻtishini toʻxtatadi.

## input() bilan kiritish

```python
name = input("Ismingiz nima? ")
print("Tanishganimdan xursandman,", name)
```

`input()` xabarni koʻrsatadi, foydalanuvchi biror narsa yozib **Enter** ni bosishini kutadi, soʻngra yozilgan narsani qaytaradi.

> [!WARNING]
> `input()` foydalanuvchi son yozsa ham har doim **matn** (`str`) qaytaradi. `"5" + "3"` natijasi `8` emas, `"53"`.

## Matnni songa aylantirish

```python
age = int(input("Yoshingiz nechada? "))
price = float(input("Bitta kitobning narxi: "))
print(age + 1)
print(price * 3)
```

- `int()` `"17"` kabi matnni butun songa aylantiradi.
- `float()` `"2.5"` kabi matnni kasr songa aylantiradi.

Agar foydalanuvchi son boʻlmagan narsani, masalan, `oʻn yetti` deb yozsa, Python `ValueError` bilan toʻxtaydi. Buni qanday chiroyli boshqarishni xatolar haqidagi darsda oʻrganasiz.

## f-satrlar bilan tushunarli chiqarish

**f-satr** qoʻshtirnoq oldidagi `f` harfiga ega boʻladi va qiymatlarni jingalak qavslar ichiga joylaydi:

```python
name = "Aziz"
lessons = 12
print(f"{name} {lessons} ta darsni tugatdi.")
print(f"Kelasi yili {age + 1} yoshga toʻlasiz.")
```

Hatto sonlarni formatlash ham mumkin: `f"{price:.2f}"` sonni aynan ikki kasr xonasi bilan koʻrsatadi.

## Ishlangan misol

```python
name = input("Ism: ")
minutes = int(input("Bugun necha daqiqa oʻqidingiz: "))
goal = 30
left = goal - minutes
print(f"Barakalla, {name}! Maqsadingizga {left} daqiqa qoldi.")
```

Agar foydalanuvchi `Malika` va `20` deb yozsa, dastur shuni chiqaradi: `Barakalla, Malika! Maqsadingizga 10 daqiqa qoldi.`

## Oʻzingiz sinab koʻring

Mahsulot narxini va foydalanuvchi uni nechta olmoqchi ekanini soʻraydigan, soʻngra umumiy summani ikki kasr xonasi bilan chiqaradigan dastur yozing. Uni `2.5` va `4` bilan sinab koʻring — javob `10.00` boʻlishi kerak.

## Keng tarqalgan xatolar

- `input()` matn qaytarishini unutib, uni songa qoʻshish (`TypeError`).
- Qoʻshtirnoq oldidagi `f` ni unutish — natijada `{name}` aynan shunday chiqadi.
- Kiritish xabarining oxiridagi boʻsh joyni tashlab ketish — javob savolga yopishib qoladi.

## Asosiy atamalar

- **input()** — foydalanuvchi yozgan matn qatorini oʻqiydi.
- **print()** — qiymatlarni ekranga chiqaradi.
- **int() / float()** — matnni butun yoki kasr songa aylantiradi.
- **f-satr** — qiymatlar `{}` ichiga joylangan satr.$md$);

  perform seed.tr_lesson(c, 'Comparing values', 'uz', 'Qiymatlarni taqqoslash',
    'Dasturlarga savol berish imkonini beradigan True, False va taqqoslash operatorlari.',
$md$## Javobi “ha” yoki “yoʻq” boʻlgan savollar

Dasturlar javobi **True** (rost) yoki **False** (yolgʻon) boʻlgan savollar berib qaror qabul qiladi. Bu darsda bunday savollarni Pythonda qanday berishni oʻrganasiz.

```python
print(10 > 3)
print(2 == 5)
```

Birinchi qator `True`, ikkinchisi `False` chiqaradi. `True` va `False` — matematik Jorj Bul nomi bilan atalgan `bool` (mantiqiy) turdagi qiymatlar.

## Taqqoslash operatorlari

| Operator | Maʼnosi | Misol | Natija |
| --- | --- | --- | --- |
| `==` | teng | `5 == 5` | `True` |
| `!=` | teng emas | `5 != 3` | `True` |
| `<` | kichik | `2 < 1` | `False` |
| `>` | katta | `7 > 4` | `True` |
| `<=` | kichik yoki teng | `3 <= 3` | `True` |
| `>=` | katta yoki teng | `2 >= 5` | `False` |

> [!WARNING]
> `=` va `==` har xil. `=` qiymatni **saqlaydi** (`age = 17`); `==` ikki qiymatni **taqqoslaydi** (`age == 17`). Ularni chalkashtirish boshlovchilarning eng keng tarqalgan xatolaridan biri.

## Matnlarni taqqoslash

Matnlarni ham taqqoslash mumkin:

```python
print("olma" == "olma")
print("Olma" == "olma")
```

Birinchisi `True`; ikkinchisi `False`, chunki taqqoslash **katta-kichik harfga sezgir**. Bosh harflarga eʼtibor bermasdan taqqoslash uchun avval ikkala tomonni kichik harfga oʻtkazing: `answer.lower() == "ha"`.

## Natijani saqlash

Taqqoslash ham boshqa ifodalar kabi ifoda, shuning uchun uning natijasini saqlash mumkin:

```python
score = 82
passed = score >= 70
print(passed)
```

Bu `True` chiqaradi. Mantiqiy qiymatga yaxshi nom berish — `passed`, `is_adult`, `has_ticket` — kodni gap kabi oʻqiladigan qiladi.

## Taqqoslashlarni birlashtirish

Python taqqoslashlarni tabiiy tarzda zanjirga bogʻlash imkonini beradi:

```python
age = 15
print(13 <= age <= 19)
```

Bu “`age` 13 bilan 19 orasidami?” deb soʻraydi va `True` chiqaradi.

## Oʻzingiz sinab koʻring

Foydalanuvchidan `input()` va `int()` yordamida son soʻrang, soʻngra u 100 dan kattami, 0 ga tengmi va 1 bilan 10 orasidami — shularni chiqaring.

## Keng tarqalgan xatolar

- `==` nazarda tutilganda `=` yozish.
- Sonni matn bilan taqqoslash: `5 == "5"` natijasi `False`, chunki biri `int`, ikkinchisi `str`.
- `"Ha"` va `"ha"` har xil satrlar ekanini unutish.

## Asosiy atamalar

- **Mantiqiy qiymat (`bool`)** — `True` yoki `False` boʻladigan qiymat.
- **Taqqoslash operatori** — ikki qiymatni taqqoslaydigan `==` yoki `<` kabi belgi.
- **Katta-kichik harfga sezgir** — bosh va kichik harflarni har xil deb hisoblash.
- **Ifoda** — qiymat hosil qiladigan kod boʻlagi.$md$);

  perform seed.tr_lesson(c, 'if, elif and else', 'uz', 'if, elif va else',
    'if, elif va else yordamida dasturingizga nima qilishni tanlash imkonini bering.',
$md$## Yoʻlni tanlash

Endi True yoki False savollarini bera olasiz, demak, dasturingiz javobga qarab **harakat qila** oladi. Bu darsda turli yoʻllar orasidan tanlash uchun `if`, `elif` va `else` dan foydalanasiz.

```python
temperature = int(input("Bugungi harorat: "))

if temperature > 30:
    print("Havo issiq. Koʻproq suv iching.")
```

- `if` yozilgan qator **ikki nuqta** `:` bilan tugaydi.
- `if` ga tegishli kod toʻrt boʻsh joy bilan **chekinib** yoziladi. Python qaysi qatorlar shart ichida ekanini chekinish orqali biladi.

## else: boshqa yoʻl

```python
if temperature > 30:
    print("Havo issiq.")
else:
    print("Havo unchalik issiq emas.")
```

Ikki blokdan aynan bittasi bajariladi.

## elif: ikkitadan koʻp tanlov

`elif` — “aks holda, agar” degani. Python shartlarni yuqoridan pastga qarab tekshiradi va sharti True boʻlgan **birinchi** blokni bajaradi:

```python
score = int(input("Ballingiz: "))

if score >= 90:
    grade = "aʼlo"
elif score >= 70:
    grade = "yaxshi"
elif score >= 50:
    grade = "qoniqarli"
else:
    grade = "koʻproq mashq kerak"

print(f"Natija: {grade}")
```

75 ball “yaxshi” natijasini beradi — `score >= 70` True boʻlishi bilanoq Python tekshirishni toʻxtatadi.

> [!TIP]
> Tartib muhim. Agar avval `score >= 50` ni tekshirsangiz, 95 ball “qoniqarli” deb koʻrsatiladi. Eng qatʼiy shartni birinchi qoʻying.

## Shartlarni birlashtirish

- `and` — ikkala shart ham True boʻlishi kerak.
- `or` — kamida bitta shart True boʻlishi kerak.
- `not` — True va False ni teskarisiga aylantiradi.

```python
age = 16
has_permission = True

if age >= 18 or has_permission:
    print("Sayohatga qoʻshilishingiz mumkin.")
```

## Oʻzingiz sinab koʻring

Chipta narxi dasturini yozing: 7 yoshgacha boʻlgan bolalar bepul, 7–17 yoshdagilar 2 000 soʻm, kattalar 4 000 soʻm toʻlaydi, talabalik guvohnomasi borlar esa yarim narx toʻlaydi. Uni 5, 12 va 30 yosh bilan sinab koʻring.

## Keng tarqalgan xatolar

- `if`, `elif` yoki `else` oxiridagi ikki nuqtani unutish.
- Chekinishlarning har xil boʻlishi — `IndentationError` xatosiga olib keladi.
- Shartlarni notoʻgʻri tartibda yozish — keyingi tarmoqqa hech qachon yetib borilmaydi.

## Asosiy atamalar

- **if / elif / else** — qaysi kod bloki bajarilishini tanlaydigan kalit soʻzlar.
- **Shart** — True yoki False boʻladigan ifoda.
- **Chekinish** — qator boshidagi, u qaysi blokka tegishli ekanini koʻrsatadigan boʻsh joylar.
- **and / or / not** — shartlarni birlashtiradigan yoki teskarisiga aylantiradigan operatorlar.$md$);

  perform seed.tr_lesson(c, 'Making decisions: check', 'uz', 'Qaror qabul qilish: bilimni tekshirish',
    'Taqqoslashlar va if/elif/else boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Making decisions check', 'uz', '“Qaror qabul qilish” moduli boʻyicha test');
  perform seed.tr_question(c, 'Making decisions check', 0, 'uz', '`=` va `==` oʻrtasidagi farq nima?',
    '`=` qiymatni oʻzgaruvchida saqlaydi; `==` ikki qiymatni taqqoslaydi.',
    array['`=` qiymatni saqlaydi; `==` ikki qiymatni taqqoslaydi', 'Ular bir xil maʼnoni bildiradi', '`==` qiymatni saqlaydi; `=` taqqoslaydi']);
  perform seed.tr_question(c, 'Making decisions check', 1, 'uz', 'Bu kod nimani chiqaradi?',
    'Taqqoslash katta-kichik harfga sezgir, shuning uchun "Yes" va "yes" har xil.',
    array['False', 'True', 'yes'],
    array[null, 'Bosh va kichik harflar — har xil belgilar.', 'Taqqoslash True yoki False chiqaradi.']);
  perform seed.tr_question(c, 'Making decisions check', 2, 'uz', '`score = 75` boʻlganda bu dastur nimani chiqaradi?',
    'Python sharti True boʻlgan birinchi blokni bajaradi: 75 >= 70, shuning uchun "good" chiqadi.',
    array['good', 'excellent', 'good va satisfactory'],
    array[null, '75 soni 90 dan katta yoki teng emas.', 'if/elif/else zanjiridan faqat bitta blok bajariladi.']);
  perform seed.tr_question(c, 'Making decisions check', 3, 'uz', 'Qaysi shart faqat **ikkala** qism ham True boʻlganda True boʻladi?',
    '`and` ikkala shartning ham True boʻlishini talab qiladi.',
    array['`a and b`', '`a or b`', '`not a`'],
    array[null, '`or` uchun ulardan bittasi yetarli.', '`not` bitta shartni teskarisiga aylantiradi.']);
  perform seed.tr_question(c, 'Making decisions check', 4, 'uz', 'Toʻgʻrimi yoki notoʻgʻri: Python qaysi qatorlar `if` blokiga tegishli ekanini chekinish orqali aniqlaydi.',
    'Toʻgʻri — ikki nuqtadan keyingi chekinib yozilgan qatorlar blokni tashkil qiladi.',
    array['Toʻgʻri', 'Notoʻgʻri']);

  perform seed.tr_lesson(c, 'while loops', 'uz', 'while sikli',
    'Shart True boʻlib turgan ekan, kodni takrorlang — va hech qachon tugamaydigan sikllardan saqlaning.',
$md$## Bir ishni qayta-qayta bajarish

Kompyuterlar hech qachon zerikmaydi. **Sikl** kod blokini takrorlaydi, shuning uchun bir vazifani koʻp marta yozmasdan, koʻp marta bajarishingiz mumkin. Bu darsda **shart True boʻlib turgan ekan** takrorlanadigan `while` siklidan foydalanasiz.

```python
count = 1
while count <= 5:
    print(count)
    count = count + 1
print("Tugadi")
```

Bu 1 dan 5 gacha sonlarni, soʻngra `Tugadi` ni chiqaradi. Qadamma-qadam:

1. Python `count <= 5` shartini tekshiradi.
2. Agar u True boʻlsa, chekinib yozilgan blokni bajaradi va 1-qadamga qaytadi.
3. Shart False boʻlganda sikldan keyingi kodga oʻtadi.

## Sikl oʻzgaruvchisini yangilash

`count = count + 1` qatori juda muhim. Pythonda uni qisqaroq yozish usuli ham bor: `count += 1`.

> [!WARNING]
> Agar sikl ichidagi hech narsa shartni False ga aylantirmasa, sikl **abadiy** davom etadi. Bu cheksiz sikl deb ataladi. Shunday boʻlsa, dasturni toʻxtatish uchun terminalda **Ctrl + C** ni bosing.

## Foydalanuvchini kutadigan sikllar

`while` necha marta takrorlash kerakligini oldindan bilmaganingizda juda qulay:

```python
answer = ""
while answer != "stop":
    answer = input("Soʻz yozing (yoki stop): ")
    print(f"Siz {len(answer)} ta harf yozdingiz.")
```

## break bilan sikldan erta chiqish

```python
secret = 7
while True:
    guess = int(input("1 dan 10 gacha sonni toping: "))
    if guess == secret:
        print("Toʻgʻri!")
        break
    print("Yana urinib koʻring.")
```

`while True` abadiy davom etardi, ammo taxmin toʻgʻri boʻlishi bilanoq `break` sikldan chiqib ketadi.

## Ishlangan misol: jamgʻarma rejasi

```python
savings = 0
month = 0
while savings < 1000000:
    savings += 150000
    month += 1
print(f"{month} oydan keyin 1 000 000 so'm yigʻasiz.")
```

Sikl maqsadga yetguncha har oy 150 000 qoʻshadi va natijada `7` oyni koʻrsatadi.

## Oʻzingiz sinab koʻring

Foydalanuvchidan `0` yozguncha sonlarni soʻrab, ularni qoʻshib boradigan, soʻngra yigʻindini chiqaradigan dastur yozing.

## Keng tarqalgan xatolar

- Shartdagi oʻzgaruvchini yangilashni unutish — cheksiz sikl paydo boʻladi.
- Shartda `==` yoki `!=` oʻrniga `=` ishlatish.
- Yangilash qatorini chekinib yozilgan blokdan tashqariga qoʻyish — u faqat sikldan keyin bajariladi.

## Asosiy atamalar

- **Sikl** — takrorlanadigan kod.
- **while sikli** — shart True boʻlib turgan ekan takrorlanadi.
- **Cheksiz sikl** — sharti hech qachon False boʻlmaydigan sikl.
- **break** — sikldan darhol chiqadi.$md$);

  perform seed.tr_lesson(c, 'for loops and range()', 'uz', 'for sikli va range()',
    'for va range() yordamida kodni maʼlum marta takrorlang yoki har bir element boʻylab yuring.',
$md$## Ketma-ketlik boʻylab yurish

`for` sikli ketma-ketlikning elementlarini **birma-bir** oladi. Bu siz eng koʻp foydalanadigan sikl. Bu darsda kodni maʼlum marta takrorlaysiz hamda matn va roʻyxatlar boʻylab yurasiz.

```python
for letter in "Salom":
    print(letter)
```

Bu `S`, `a`, `l`, `o`, `m` harflarini alohida qatorlarda chiqaradi. Sikl har aylanganda `letter` oʻzgaruvchisi navbatdagi belgini saqlaydi.

## range() bilan sanash

`range()` sonlar ketma-ketligini hosil qiladi:

| Kod | Hosil qilinadigan sonlar |
| --- | --- |
| `range(5)` | 0, 1, 2, 3, 4 |
| `range(1, 6)` | 1, 2, 3, 4, 5 |
| `range(0, 10, 2)` | 0, 2, 4, 6, 8 |
| `range(5, 0, -1)` | 5, 4, 3, 2, 1 |

> [!NOTE]
> `range(5)` 5 ga **yetmasdan** toʻxtaydi. Oxirgi son hech qachon kirmaydi — bu tafsilot dastlab deyarli hammani hayron qoldiradi.

```python
for i in range(1, 4):
    print(f"{i}-dars")
```

## Natijani yigʻib borish

Juda keng tarqalgan usul — boʻsh yoki nol qiymatdan boshlab, uni sikl ichida yigʻib borish:

```python
total = 0
for number in range(1, 11):
    total += number
print(total)
```

Bu 1 dan 10 gacha sonlarni qoʻshadi va `55` ni chiqaradi.

## continue bilan oʻtkazib yuborish

`continue` joriy aylanishning qolgan qismini oʻtkazib, keyingi elementga oʻtadi:

```python
for n in range(1, 11):
    if n % 2 == 0:
        continue
    print(n)
```

`%` boʻlishdan qolgan qoldiqni beradi, shuning uchun `n % 2 == 0` juft sonlar uchun True. Dastur faqat toq sonlarni chiqaradi.

## while yoki for?

- Necha marta takrorlashni bilsangiz yoki har bir element boʻylab yursangiz, **for** dan foydalaning.
- Biror narsa sodir boʻlguncha, masalan, foydalanuvchi “stop” deb yozguncha takrorlasangiz, **while** dan foydalaning.

## Oʻzingiz sinab koʻring

Foydalanuvchi tanlagan son uchun 1 dan 10 gacha boʻlgan koʻpaytirish jadvalini `7 x 3 = 21` koʻrinishida chiqaring.

## Keng tarqalgan xatolar

- `range(10)` ichida 10 ham bor deb kutish.
- `for` sikli ichida sikl oʻzgaruvchisini oʻzgartirib, bu keyingi aylanishga taʼsir qiladi deb kutish.
- Sikl tanasini chekinib yozishni unutish.

## Asosiy atamalar

- **for sikli** — ketma-ketlikning har bir elementi uchun bir marta takrorlanadi.
- **range()** — butun sonlar ketma-ketligini hosil qiladi.
- **continue** — siklning keyingi aylanishiga oʻtkazadi.
- **Qoldiq (`%`)** — boʻlishdan keyin ortib qoladigan son.$md$);

  perform seed.tr_lesson(c, 'Repetition: check', 'uz', 'Takrorlash: bilimni tekshirish',
    'while, for va range() boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Repetition check', 'uz', '“Takrorlash” moduli boʻyicha test');
  perform seed.tr_question(c, 'Repetition check', 0, 'uz', '`range(4)` qaysi sonlarni hosil qiladi?',
    '`range(4)` 0 dan boshlanadi va 4 ga yetmasdan toʻxtaydi.',
    array['0, 1, 2, 3', '1, 2, 3, 4', '0, 1, 2, 3, 4'],
    array[null, 'U 1 dan emas, 0 dan boshlanadi.', 'Oxirgi son kirmaydi.']);
  perform seed.tr_question(c, 'Repetition check', 1, 'uz', 'Bu dastur nimani chiqaradi?',
    'Sikl 1 + 2 + 3 = 6 ni qoʻshadi.',
    array['6', '3', '123'],
    array[null, 'Bu faqat oxirgi son; sikl hammasini qoʻshadi.', 'Sonlar matn kabi ulanmaydi, qoʻshiladi.']);
  perform seed.tr_question(c, 'Repetition check', 2, 'uz', 'Nega bu sikl hech qachon toʻxtamaydi?',
    '`count` hech qachon oʻzgarmaydi, shuning uchun `count < 5` abadiy True boʻlib qoladi.',
    array['`count` hech qachon oshirilmaydi', 'Shartda `==` ishlatilishi kerak', '`print` ni sikllarda ishlatib boʻlmaydi']);
  perform seed.tr_question(c, 'Repetition check', 3, 'uz', 'Sikl ichida `break` nima qiladi?',
    '`break` sikldan darhol chiqadi.',
    array['Sikldan darhol chiqadi', 'Keyingi aylanishga oʻtkazadi', 'Dasturni qaytadan boshlaydi'],
    array[null, 'Bu `continue` vazifasi.', 'Dastur sikldan keyingi kod bilan davom etadi.']);
  perform seed.tr_question(c, 'Repetition check', 4, 'uz', 'Parol toʻgʻri boʻlguncha uni soʻrashda davom etmoqchisiz. Qaysi sikl eng mos?',
    'Nechta urinish kerakligini bilmaysiz, shuning uchun `while` mos keladi.',
    array['`while` sikli', '`range(3)` bilan `for` sikli', 'Sikl kerak emas'],
    array[null, 'Bu “toʻgʻri boʻlguncha” emas, aynan uchta urinishga ruxsat beradi.', 'Siklsiz faqat bir marta soʻrash mumkin.']);

  perform seed.tr_lesson(c, 'Lists', 'uz', 'Roʻyxatlar',
    'Koʻplab qiymatlarni bitta oʻzgaruvchida saqlang, ularni oʻzgartiring va ular boʻylab sikl yuriting.',
$md$## Koʻplab qiymatlar bir joyda

30 nafar oʻquvchining baholarini 30 ta alohida oʻzgaruvchida saqlashni tasavvur qiling. **Roʻyxat** (*list*) ularning hammasini bitta oʻzgaruvchida, tartib bilan saqlaydi. Bu darsda roʻyxatlarni yaratasiz, oʻqiysiz, oʻzgartirasiz va ular boʻylab sikl yuritasiz.

```python
cities = ["Toshkent", "Samarqand", "Buxoro"]
marks = [5, 4, 5, 3]
empty = []
```

Roʻyxat kvadrat qavslar bilan yoziladi, elementlari esa vergul bilan ajratiladi. Elementlar istalgan turda boʻlishi mumkin.

## Elementlarni indeks boʻyicha oʻqish

Har bir elementning **indeks** deb ataladigan oʻrin raqami bor. Sanash **0** dan boshlanadi:

```python
print(cities[0])
print(cities[2])
print(cities[-1])
```

Bu `Toshkent`, `Buxoro` va `Buxoro` ni chiqaradi — manfiy indeks oxiridan sanaydi.

> [!WARNING]
> Mavjud boʻlmagan indeksni, masalan, uch elementli roʻyxatda `cities[3]` ni soʻrash dasturni `IndexError` bilan toʻxtatadi.

## Roʻyxatni oʻzgartirish

| Kod | Nima qiladi |
| --- | --- |
| `cities.append("Xiva")` | Oxiriga element qoʻshadi |
| `cities.insert(0, "Nukus")` | 0-oʻringa element joylaydi |
| `cities.remove("Buxoro")` | Birinchi mos elementni olib tashlaydi |
| `cities[1] = "Andijon"` | 1-oʻrindagi elementni almashtiradi |
| `cities.sort()` | Roʻyxatni joyida saralaydi |

## Roʻyxat haqidagi foydali savollar

```python
marks = [5, 4, 5, 3]
print(len(marks))
print(sum(marks) / len(marks))
print(4 in marks)
print(max(marks), min(marks))
```

`len()` elementlar sonini beradi, `sum()` ularni qoʻshadi, `in` element bor-yoʻqligini tekshiradi, `max()` va `min()` esa eng katta va eng kichigini topadi.

## Roʻyxat boʻylab sikl

```python
for city in cities:
    print(f"Men {city} shahriga borishni xohlayman.")
```

## Roʻyxatning bir qismini olish

**Kesma** (*slice*) bir vaqtda bir nechta elementni oladi: `marks[1:3]` 1- va 2-oʻrindagi elementlarni, yaʼni `[4, 5]` ni beradi. `range()` dagi kabi oxirgi oʻrin kirmaydi.

## Oʻzingiz sinab koʻring

`shopping` nomli boʻsh roʻyxat yarating. `while` sikli yordamida foydalanuvchi `done` deb yozguncha undan mahsulotlarni soʻrab, har birini `append()` bilan qoʻshing. Soʻngra mahsulotlar sonini va har bir mahsulotni alohida qatorda chiqaring.

## Keng tarqalgan xatolar

- Sanashni 0 dan emas, 1 dan boshlash.
- Juda katta indeksdan foydalanish.
- `cities.append("Xiva")` ni chaqirish oʻrniga `cities.append = "Xiva"` deb yozish.

## Asosiy atamalar

- **Roʻyxat** (*list*) — qiymatlarning tartiblangan toʻplami.
- **Indeks** — elementning 0 dan boshlanadigan oʻrni.
- **Metod** — qiymatga tegishli funksiya, masalan, `append()`.
- **Kesma** (*slice*) — roʻyxatning bir qismi, masalan, `marks[1:3]`.$md$);

  perform seed.tr_lesson(c, 'Dictionaries', 'uz', 'Lugʻatlar',
    'Kalit–qiymat juftliklari yordamida qiymatlarni nomi boʻyicha toping.',
$md$## Narsalarni nomi boʻyicha topish

Roʻyxat elementlarni oʻrni boʻyicha topadi. **Lugʻat** (*dictionary*) esa qiymatlarni **kalit** boʻyicha topadi — xuddi haqiqiy lugʻatdagidek: soʻzni qidirib, uning maʼnosini topasiz. Bu darsda lugʻatlar yordamida maʼlumotlarni saqlaysiz va qidirasiz.

```python
student = {
    "name": "Malika",
    "age": 16,
    "city": "Namangan",
}
```

Lugʻat jingalak qavslardan foydalanadi. Har bir yozuv `kalit: qiymat` koʻrinishida yoziladigan **kalit–qiymat juftligi**.

## Qiymatlarni oʻqish

```python
print(student["name"])
print(student.get("phone", "kiritilmagan"))
```

Birinchi qator `Malika` ni chiqaradi. Kalit mavjud boʻlmasa, kvadrat qavslar dasturni `KeyError` bilan toʻxtatadi, shuning uchun `get()` xavfsizroq: kalit boʻlmasa, u ikkinchi qiymatni (`"kiritilmagan"`) qaytaradi.

## Yozuv qoʻshish va oʻzgartirish

```python
student["phone"] = "+998 90 123 45 67"
student["age"] = 17
del student["city"]
```

Yangi kalitga qiymat berish uni qoʻshadi; mavjud kalitga qiymat berish uni almashtiradi; `del` yozuvni oʻchiradi.

## Lugʻat boʻylab sikl

```python
prices = {"non": 4000, "sut": 12000, "choy": 25000}

for item, price in prices.items():
    print(f"{item}: {price} so'm")
```

`items()` har bir kalitni uning qiymati bilan birga beradi.

## Lugʻat yordamida sanash

Lugʻatlar sanash uchun juda qulay:

```python
text = "olma anor olma uzum olma"
counts = {}
for word in text.split():
    counts[word] = counts.get(word, 0) + 1
print(counts)
```

Bu `{'olma': 3, 'anor': 1, 'uzum': 1}` ni chiqaradi. `split()` matnni soʻzlarga ajratadi.

> [!TIP]
> Tartib muhim boʻlsa va elementlar bir xil turdagi boʻlsa (masalan, ismlar navbati), roʻyxatdan foydalaning. Narsalarni yorliq boʻyicha qidirsangiz (masalan, har bir mahsulot narxi), lugʻatdan foydalaning.

## Oʻzingiz sinab koʻring

Beshta inglizcha soʻz va ularning oʻzbekcha tarjimasidan iborat lugʻat yarating. Foydalanuvchidan inglizcha soʻz soʻrang va uning tarjimasini yoki, agar soʻz yoʻq boʻlsa, “Bu soʻz lugʻatda hali yoʻq” degan xabarni chiqaring.

## Keng tarqalgan xatolar

- Mavjud boʻlmasligi mumkin boʻlgan kalit uchun `get()` oʻrniga kvadrat qavslardan foydalanish.
- Matnli kalitlar atrofidagi qoʻshtirnoqni unutish: `student["name"]` oʻrniga `student[name]`.
- Lugʻat qiymat boʻyicha saralangan boʻladi deb kutish.

## Asosiy atamalar

- **Lugʻat (`dict`)** — kalit–qiymat juftliklari toʻplami.
- **Kalit** — qiymatni topish uchun ishlatiladigan yorliq.
- **get()** — kalit boʻlmasa, standart qiymat bilan oʻqiydi.
- **items()** — siklda kalit va qiymatlarni birga beradi.$md$);

  perform seed.tr_lesson(c, 'Functions', 'uz', 'Funksiyalar',
    'Parametrlar va qaytariladigan qiymatlar bilan kodni qayta ishlatiladigan funksiyalarga joylang.',
$md$## Ish boʻlagiga nom berish

Siz allaqachon koʻplab funksiyalardan foydalangansiz: `print()`, `input()`, `len()`. Bu darsda oʻzingiznikini yozasiz. **Funksiya** — kerak boʻlganda istalgan vaqtda ishga tushirish mumkin boʻlgan nomli kod bloki: uni bir marta yozib, koʻp marta ishlatasiz.

```python
def greet(name):
    print(f"Salom, {name}!")

greet("Aziz")
greet("Malika")
```

- `def` funksiya taʼrifini boshlaydi; `greet` — uning nomi.
- `name` — **parametr**, yaʼni funksiya chaqirilganda qiymat oladigan oʻzgaruvchi.
- `"Aziz"` va `"Malika"` — **argumentlar**, yaʼni uzatiladigan qiymatlar.

## Qiymat qaytarish

`print()` faqat biror narsani koʻrsatadi. Natijani funksiyani chaqirgan kodga **qaytarish** uchun `return` dan foydalaning:

```python
def area(width, height):
    return width * height

room = area(4, 5)
print(f"Xona {room} kvadrat metr.")
```

`return` funksiyani tugatadi va qiymatni qaytaradi. Bu yerda `room` qiymati `20` boʻladi.

> [!WARNING]
> `return` siz funksiya maxsus `None` qiymatini qaytaradi. Agar `result = greet("Aziz")` deb yozsangiz, `result` qiymati `None` boʻladi, chunki `greet` chiqaradi, lekin hech narsa qaytarmaydi.

## Standart qiymatlar

```python
def price_with_tax(price, tax=0.12):
    return price * (1 + tax)

print(round(price_with_tax(100000)))
print(round(price_with_tax(100000, 0.05)))
```

Ikkinchi argument berilmasa, `tax` qiymati `0.12` boʻladi, shuning uchun birinchi qator `112000`, ikkinchisi `105000` ni chiqaradi. (`round()` har qanday dasturlash tilida kasr sonlarda uchraydigan juda kichik yaxlitlash xatolarini yashiradi.)

## Funksiya ichidagi oʻzgaruvchilar

Funksiya ichida yaratilgan oʻzgaruvchilar faqat u ishlab turgan paytda mavjud — ular **lokal** oʻzgaruvchilar. Bu funksiyalarni mustaqil qiladi: bir funksiya ichidagi `total` oʻzgaruvchisi boshqa joydagi `total` bilan toʻqnashmaydi.

## Funksiyalar nega muhim

- **Takrorlanish yoʻq:** xatoni bir marta tuzatsangiz, uning barcha ishlatilgan joylari tuzaladi.
- **Oʻqilishi oson:** `average(marks)` oʻzini oʻzi tushuntiradi.
- **Sinash oson:** kichik funksiyani alohida tekshirish mumkin.

## Ishlangan misol

```python
def average(numbers):
    """Sonlar roʻyxatining oʻrtacha qiymatini qaytaradi."""
    return sum(numbers) / len(numbers)

def grade(mark):
    if mark >= 4.5:
        return "aʼlo"
    elif mark >= 3.5:
        return "yaxshi"
    return "mashq kerak"

marks = [5, 4, 5, 4]
avg = average(marks)
print(f"Oʻrtacha {avg:.1f}: {grade(avg)}")
```

Uchta qoʻshtirnoq ichidagi matn — **docstring**, yaʼni funksiya nima qilishining qisqa tavsifi. Dastur `Oʻrtacha 4.5: aʼlo` ni chiqaradi.

## Oʻzingiz sinab koʻring

Summani soʻmda qaytaradigan `convert_to_som(dollars, rate)` funksiyasini va `1 250 000 so'm` kabi matn qaytaradigan `format_som(amount)` funksiyasini yozing. Maslahat: `f"{amount:,.0f}".replace(",", " ")` minglar orasiga boʻsh joy qoʻyadi.

## Keng tarqalgan xatolar

- Natijani qaytarish kerak boʻlganda uni funksiya ichida chiqarish.
- Funksiyani faylda taʼriflashdan oldin chaqirish.
- Qavslarni unutish: `greet` funksiyaning oʻziga ishora qiladi; `greet()` esa uni ishga tushiradi.

## Asosiy atamalar

- **Funksiya** — nomli, qayta ishlatiladigan kod bloki.
- **Parametr / argument** — taʼrifdagi oʻzgaruvchi / uzatiladigan qiymat.
- **return** — funksiyadan qiymat qaytaradi.
- **Lokal oʻzgaruvchi** — faqat funksiya ichida mavjud boʻlgan oʻzgaruvchi.$md$);

  perform seed.tr_lesson(c, 'Collections and functions: check', 'uz', 'Toʻplamlar va funksiyalar: bilimni tekshirish',
    'Roʻyxatlar, lugʻatlar va funksiyalar boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Collections and functions check', 'uz', '“Toʻplamlar va funksiyalar” moduli boʻyicha test');
  perform seed.tr_question(c, 'Collections and functions check', 0, 'uz', 'Bu kod nimani chiqaradi?',
    'Indekslar 0 dan boshlanadi, shuning uchun 1-indeks — ikkinchi element.',
    array['Samarkand', 'Tashkent', 'Bukhara'],
    array[null, 'Bu 0-indeks.', 'Bu 2-indeks.']);
  perform seed.tr_question(c, 'Collections and functions check', 1, 'uz', 'Qaysi qator `cities` roʻyxatining oxiriga `"Khiva"` ni qoʻshadi?',
    '`append()` roʻyxat oxiriga element qoʻshadi.',
    array['`cities.append("Khiva")`', '`cities.add("Khiva")`', '`cities[3] = "Khiva"`'],
    array[null, 'Roʻyxatlarda `add()` metodi yoʻq.', 'Mavjud boʻlmagan indeksga qiymat berish IndexError ga olib keladi.']);
  perform seed.tr_question(c, 'Collections and functions check', 2, 'uz', '`student` lugʻatida `"phone"` kaliti boʻlmasligi mumkin. Qaysi qator xavfsiz?',
    '`get()` KeyError oʻrniga standart qiymatni qaytaradi.',
    array['`student.get("phone", "none")`', '`student["phone"]`', '`student[phone]`'],
    array[null, 'Kalit boʻlmasa, bu KeyError beradi.', 'Qoʻshtirnoqsiz Python phone nomli oʻzgaruvchini qidiradi.']);
  perform seed.tr_question(c, 'Collections and functions check', 3, 'uz', '`x` da nima saqlanadi?',
    'Funksiya chiqaradi, lekin hech narsa qaytarmaydi, shuning uchun u None qaytaradi.',
    array['`None`', '`"Hi"`', 'Xato'],
    array[null, '"Hi" chiqariladi, qaytarilmaydi.', 'Bu kod xatosiz ishlaydi.']);
  perform seed.tr_question(c, 'Collections and functions check', 4, 'uz', 'Qachon lugʻat roʻyxatdan yaxshiroq tanlov hisoblanadi?',
    'Lugʻatlar qiymatlarni kalit boʻyicha topadi, masalan, har bir mahsulot narxini.',
    array['Qiymatlarni yorliq boʻyicha qidirganda, masalan, har bir mahsulot narxi', 'Bir xil elementlarning tartibi muhim boʻlganda', 'Faqat bitta qiymat saqlanganda'],
    array[null, 'Tartibli, bir xil elementlar roʻyxatga mos keladi.', 'Bitta qiymat uchun oddiy oʻzgaruvchi yetarli.']);

  perform seed.tr_lesson(c, 'Files and errors', 'uz', 'Fayllar va xatolar',
    'Maʼlumotlarni matnli fayllarga saqlang, ularni qayta oʻqing va dastur ishdan chiqishi oʻrniga xatolarni boshqaring.',
$md$## Dastur tugagandan keyin ham maʼlumotni saqlash

Dastur toʻxtaganda oʻzgaruvchilar yoʻqoladi. Maʼlumotlarni — vazifalar roʻyxati, natijalar, xarajatlarni — saqlab qolish uchun ularni **fayl**ga yozasiz. Bu darsda matnli fayllarni yozasiz va oʻqiysiz hamda dasturingiz ishdan chiqmasligi uchun xatolarni boshqarasiz.

## Faylga yozish

```python
with open("notes.txt", "w", encoding="utf-8") as f:
    f.write("Oʻzbekcha matn ham toʻgʻri saqlanadi.\n")
    f.write("Ikkinchi qator\n")
```

- `open()` faylni ochadi; `"w"` — **yozish** rejimi (faylni yaratadi yoki, agar u mavjud boʻlsa, almashtiradi).
- `with` blok tugaganda, hatto biror narsa notoʻgʻri ketsa ham, faylni avtomatik yopadi.
- `encoding="utf-8"` barcha alifbolar, jumladan, oʻ, gʻ va kirill harflari toʻgʻri saqlanishini taʼminlaydi.
- `\n` yangi qatorni boshlaydi.

## Fayldan oʻqish

```python
with open("notes.txt", encoding="utf-8") as f:
    for line in f:
        print(line.strip())
```

Standart rejim — `"r"` (oʻqish). Fayl boʻylab sikl har safar bitta qatorni beradi; `strip()` qator oxiridagi yangi qator belgisini olib tashlaydi.

| Rejim | Maʼnosi |
| --- | --- |
| `"r"` | Oʻqish (standart); fayl mavjud boʻlishi shart |
| `"w"` | Yozish; fayldagi hamma narsani almashtiradi |
| `"a"` | Qoʻshish; fayl oxiriga yozadi |

## Biror narsa notoʻgʻri ketganda

Xatolar — odatiy hol: foydalanuvchi son kutilgan joyga harf yozadi yoki fayl mavjud boʻlmaydi. Python bularni **istisno** (*exception*) sifatida xabar qiladi. Ular boshqarilmasa, dastur toʻxtaydi va **traceback** chiqaradi — uni pastdan yuqoriga qarab oʻqing: oxirgi qator xato nomini, yuqoridagi qatorlar esa u qayerda sodir boʻlganini koʻrsatadi.

## try va except bilan xatolarni boshqarish

```python
try:
    age = int(input("Yoshingiz: "))
    print(f"Kelasi yili {age + 1} yoshga toʻlasiz.")
except ValueError:
    print("Iltimos, yoshingizni raqamlar bilan yozing, masalan, 17.")
```

Agar `try` ichidagi kod `ValueError` bersa, Python ishdan chiqish oʻrniga `except` blokiga oʻtadi.

```python
try:
    with open("scores.txt", encoding="utf-8") as f:
        print(f.read())
except FileNotFoundError:
    print("Hali hech qanday natija saqlanmagan.")
```

> [!TIP]
> Faqat kutgan va qanday boshqarishni biladigan xatolaringizni, masalan, `ValueError` yoki `FileNotFoundError` ni ushlang. Har qanday xatoni ushlash haqiqiy xatolarni yashiradi.

## Oʻzingiz sinab koʻring

Qisqa qayd soʻrab, uni `"a"` rejimida `diary.txt` fayliga qoʻshadigan, soʻngra shu paytgacha saqlangan barcha qaydlarni chiqaradigan dastur yozing. Fayl hali mavjud boʻlmasa, dastur ishdan chiqish oʻrniga tushunarli xabar chiqarsin.

## Keng tarqalgan xatolar

- `"a"` nazarda tutilganda `"w"` dan foydalanib, faylni tozalab yuborish.
- `encoding="utf-8"` ni unutish — natijada baʼzi kompyuterlarda oʻzbek yoki rus harflari buzilib ketadi.
- Butun dasturni `try` / `except` ichiga olib, xatolarni yashirish.

## Asosiy atamalar

- **Fayl rejimi** — fayl qanday ochilishi: oʻqish, yozish yoki qoʻshish.
- **Kodlash (UTF-8)** — matnni baytlarga aylantirish usuli; UTF-8 barcha alifbolarni qoʻllab-quvvatlaydi.
- **Istisno** (*exception*) — dastur ishlayotgan paytda yuz beradigan xato.
- **Traceback** — xato qayerda sodir boʻlganini koʻrsatadigan Python hisoboti.$md$);

  perform seed.tr_lesson(c, 'Project: quiz game', 'uz', 'Loyiha: viktorina oʻyini',
    'Savollar beradigan, javoblarni tekshiradigan va ball hisoblaydigan viktorina oʻyinini yarating.',
$md$## Birinchi toʻliq dasturingiz

Oʻyinchiga bir nechta savol beradigan, javoblarni tekshiradigan va natijani maʼlum qiladigan **viktorina oʻyini**ni yarating. U siz oʻrgangan deyarli hamma narsadan foydalanadi: oʻzgaruvchilar, kiritish, shartlar, sikllar, roʻyxatlar, lugʻatlar va funksiyalar.

### Talablar

1. Kamida **beshta savolni** lugʻatlar roʻyxatida saqlang; har birida savol va uning javobi boʻlsin, masalan, `{"question": "Oʻzbekiston poytaxti?", "answer": "toshkent"}`.
2. Savollarni sikl yordamida birma-bir bering.
3. Javoblarni bosh harf va boʻsh joylarga eʼtibor bermasdan taqqoslang (`lower()` va `strip()` dan foydalaning).
4. Ballni hisoblab boring va har bir savoldan keyin oʻyinchiga toʻgʻri javob berganini — agar notoʻgʻri boʻlsa, toʻgʻri javobni — ayting.
5. Tekshirish kodini funksiyaga joylang, masalan, `check_answer(given, correct)`.
6. Oxirida ballni va unga bogʻliq xabarni chiqaring (masalan, toʻliq ball uchun “Aʼlo!”).

### Qoʻshimcha murakkablik uchun gʻoyalar

- Oʻyinchiga dasturni qayta ishga tushirmasdan yana oʻynash imkonini bering.
- Eng yaxshi natijani faylga saqlang va uni boshida koʻrsating.

### Qanday topshiriladi

Kodingizni matn maydoniga joylang yoki `.py` faylingizni yuklang va bitta toʻliq oʻyin natijasini ham qoʻshing.

> [!NOTE]
> Tekshiruvchi dasturingizni baholash mezonlari asosida koʻrib chiqadi va fikr-mulohaza qoldiradi. Uni yaxshilab, qayta topshirishingiz mumkin.$md$);
  perform seed.tr('assignments', (select id from public.assignments where course_id = seed.course(c) and title = 'Quiz game'), 'uz',
    jsonb_build_object(
      'title', 'Viktorina oʻyini',
      'brief_md', 'Savollari lugʻatlar roʻyxatida saqlanadigan, ball hisoblaydigan sikli va kamida bitta funksiyasi bor viktorina oʻyinini yarating.',
      'rubric_md', $r$| Mezon | Ball |
| --- | --- |
| Savollar lugʻatlar roʻyxatida saqlangan (beshta va undan koʻp) | 20 |
| Sikl har bir savolni beradi; ball toʻgʻri hisoblanadi | 25 |
| Javoblar adolatli taqqoslanadi (lower va strip) va izoh beriladi | 20 |
| Tekshirish mantigʻi yaxshi nomlangan funksiyada | 20 |
| Yakuniy ball va xabar; aniq, oʻqilishi oson kod | 15 |$r$),
    c || ' / Quiz game');

  perform seed.tr_lesson(c, 'Project: budget tracker', 'uz', 'Loyiha: byudjet hisobchisi',
    'Xarajatlarni faylga saqlaydigan, menyu orqali boshqariladigan byudjet hisobchisini yarating.',
$md$## Haqiqatan ishlatsa boʻladigan vosita

Terminalda ishlaydigan, xarajatlarni ishga tushirishlar orasida eslab qoladigan va toifalar boʻyicha jami summalarni koʻrsatadigan **shaxsiy byudjet hisobchisi**ni yarating.

### Talablar

1. Foydalanuvchi chiqishni tanlaguncha takrorlanadigan menyu, masalan: `1) Xarajat qoʻshish  2) Hammasini koʻrsatish  3) Toifalar boʻyicha jami  4) Chiqish`.
2. **Xarajat qoʻshish** summa va toifani (masalan, oziq-ovqat, transport yoki kitoblar) soʻraydi. Notoʻgʻri summalar dastur ishdan chiqishi oʻrniga `try` / `except` bilan boshqariladi.
3. Xarajatlar matnli faylga saqlanadi (masalan, har bir xarajat uchun bitta qator: `25000,food`) va dastur ishga tushganda qayta yuklanadi.
4. **Hammasini koʻrsatish** barcha xarajatlarni roʻyxat qilib chiqaradi.
5. **Toifalar boʻyicha jami** har bir toifa summalarini lugʻat yordamida qoʻshadi va umumiy summani chiqaradi.
6. Kamida uchta funksiyadan foydalaning, masalan, `load_expenses()`, `save_expense()` va `totals_by_category()`.

### Qoʻshimcha murakkablik uchun gʻoyalar

- Eng katta xarajatni va uning toifasini koʻrsating.
- Summalarni minglar orasida boʻsh joy bilan chiqaring, masalan, `1 250 000 so'm`.

### Qanday topshiriladi

Kodingizni joylang yoki `.py` faylingizni yuklang va xarajat qoʻshish, dasturni yopish, uni qayta ochish va xarajat saqlanib qolganini koʻrsatadigan qisqa namuna seansini ilova qiling.

> [!NOTE]
> Tekshiruvchi dasturingizni baholash mezonlari asosida koʻrib chiqadi va fikr-mulohaza qoldiradi. Uni yaxshilab, qayta topshirishingiz mumkin.$md$);
  perform seed.tr('assignments', (select id from public.assignments where course_id = seed.course(c) and title = 'Budget tracker'), 'uz',
    jsonb_build_object(
      'title', 'Byudjet hisobchisi',
      'brief_md', 'Xarajatlarni faylga saqlaydigan va ularni toifalar boʻyicha jamlaydigan, menyu orqali boshqariladigan byudjet hisobchisini yarating.',
      'rubric_md', $r$| Mezon | Ball |
| --- | --- |
| Ishlaydigan bandlari va toza chiqishi bor menyu sikli | 20 |
| Xarajatlar UTF-8 kodlashda faylga saqlanadi va undan yuklanadi | 25 |
| Notoʻgʻri kiritish try / except bilan boshqariladi | 15 |
| Toifalar boʻyicha jami lugʻat yordamida hisoblanadi | 20 |
| Uch va undan ortiq aniq funksiya; oʻqilishi oson kod | 20 |$r$),
    c || ' / Budget tracker');

  perform seed.tr_lesson(c, 'Final assessment', 'uz', 'Yakuniy imtihon',
    'Butun kursni qamrab oluvchi qisqa imtihon. Oʻtish balli: 70%.', null);
  perform seed.tr_quiz(c, 'Python for Complete Beginners — final assessment', 'uz', 'Python: mutlaq boshlovchilar uchun — yakuniy imtihon');
  perform seed.tr_question(c, 'Python for Complete Beginners — final assessment', 0, 'uz', '`input()` qanday turdagi qiymat qaytaradi?',
    '`input()` har doim matn (`str`) qaytaradi; son kerak boʻlsa, uni `int()` yoki `float()` bilan aylantiring.',
    array['`str` (matn)', '`int`', 'Foydalanuvchi nima yozgan boʻlsa: son yoki matn']);
  perform seed.tr_question(c, 'Python for Complete Beginners — final assessment', 1, 'uz', 'Bu kod nimani chiqaradi?',
    '`f"{x * 2}"` qavslar ichidagi ifodani hisoblaydi: 7 * 2 = 14.',
    array['Result: 14', 'Result: {x * 2}', 'Result: 72']);
  perform seed.tr_question(c, 'Python for Complete Beginners — final assessment', 2, 'uz', '`age = 12` boʻlganda qaysi qator chiqariladi?',
    'Python birinchi True tarmoqni bajaradi: 12 < 13, shuning uchun "child".',
    array['child', 'teen', 'adult']);
  perform seed.tr_question(c, 'Python for Complete Beginners — final assessment', 3, 'uz', '`print` necha marta bajariladi?',
    '`range(2, 6)` 2, 3, 4, 5 ni — toʻrtta sonni beradi.',
    array['4', '5', '6']);
  perform seed.tr_question(c, 'Python for Complete Beginners — final assessment', 4, 'uz', '`marks = [3, 4, 5]` boʻlsa, `marks[-1]` nimaga teng?',
    'Manfiy indeks oxiridan sanaydi; -1 — oxirgi element.',
    array['5', '3', 'Xato']);
  perform seed.tr_question(c, 'Python for Complete Beginners — final assessment', 5, 'uz', 'Qaysi kalit soʻz funksiyadan qiymat qaytaradi?',
    '`return` funksiyani tugatadi va qiymatni qaytaradi.',
    array['`return`', '`print`', '`def`']);
  perform seed.tr_question(c, 'Python for Complete Beginners — final assessment', 6, 'uz', 'Qaysi fayl rejimi mavjud fayl oxiriga matn qoʻshadi?',
    '`"a"` qoʻshadi; `"w"` esa tarkibni almashtiradi.',
    array['`"a"`', '`"w"`', '`"r"`'],
    array[null, '`"w"` fayldagi narsalarni oʻchirib yuboradi.', '`"r"` faqat oʻqiydi.']);
  perform seed.tr_question(c, 'Python for Complete Beginners — final assessment', 7, 'uz', '`int()` `"seventeen"` kabi matn olganda qaysi istisnoni ushlaysiz?',
    'Notoʻgʻri matnni `int()` bilan aylantirish ValueError beradi.',
    array['`ValueError`', '`FileNotFoundError`', '`KeyError`']);
end $tr$;
