-- Sprint 1 · Design Principles from Zero (English + Oʻzbekcha). Idempotent.
do $content$
declare
  c constant text := 'design-principles-from-zero';
  q uuid;
begin
  perform seed.ensure_module(c, 'Colour and type', 'Choose colours and typefaces that communicate clearly.');
  perform seed.ensure_module(c, 'Layout and critique', 'Arrange elements on a grid, judge designs with precise words and make your first poster.');

  perform seed.ensure_lesson(c, 'Colour and type', 'Colour basics', 'article', 10,
    'What colour does, how to describe it and how to build a simple, readable palette.',
$md$## What colour does

Colour is often the first thing people notice. In this lesson you will learn to choose colours on purpose, so they guide attention instead of competing for it. In design, colour does four jobs:

1. **Attention** — a bright accent pulls the eye.
2. **Mood** — warm colours feel energetic, cool colours feel calm.
3. **Meaning** — red often signals errors or urgency, green success.
4. **Grouping** — things in the same colour look related.

## Describing colour

Designers describe a colour with three properties:

- **Hue** — the colour family: red, orange, blue.
- **Saturation** — how intense it is, from grey to vivid.
- **Lightness** — how light or dark it is.

On screens, colours are written as codes such as **HEX** (`#1E3A8A`) or **RGB**. Printers use **CMYK** inks instead, so a bright screen colour may look duller on paper.

## Building a simple palette

A reliable starting point is the **60-30-10** rule:

| Share | Role | Example |
| --- | --- | --- |
| 60% | Dominant neutral background | Off-white |
| 30% | Secondary colour for large areas | Deep blue |
| 10% | Accent for the most important elements | Warm orange |

Other simple schemes are **monochromatic** (shades of one hue) and **complementary** (two hues opposite each other on the colour wheel, such as blue and orange).

## Colour and readable text

Text must contrast strongly with its background. The WCAG accessibility guidelines ask for a contrast ratio of at least **4.5 : 1** for normal text and **3 : 1** for large text. Free online contrast checkers calculate the ratio from two colour codes.

> [!WARNING]
> Never rely on colour alone to carry meaning. About 1 in 12 men and 1 in 200 women have some form of colour blindness. Add a label, an icon or a pattern: “Error: password too short” in red with a warning icon, not just a red border.

## Colour and culture

Colour meanings change between cultures and situations. White is the colour of weddings in many places but of mourning in others; red can mean danger or celebration. Think about who will see your design.

## Try it

Take a photo of a place you love — for example, the blue tiles of Samarkand. Pick five colours from it: one dominant, one secondary, one accent and two neutrals for text and background. Check that your text colour has at least 4.5 : 1 contrast with your background.

## Common mistakes

- Using many bright colours at once, so nothing stands out.
- Light grey text on white, which looks elegant but is hard to read.
- Showing status with colour alone.

## Key terms

- **Hue, saturation, lightness** — the colour family, its intensity and its brightness.
- **HEX / RGB / CMYK** — colour codes for screens and inks for print.
- **Palette** — the set of colours used in a design.
- **Contrast ratio** — how different two colours are in lightness, used to judge readability.$md$);

  perform seed.ensure_lesson(c, 'Colour and type', 'Type basics', 'article', 10,
    'Choose, size and pair typefaces for readable text in Latin and Cyrillic.',
$md$## Why type matters

Most designs are mostly text. Good typography is invisible: people read easily and understand the message. In this lesson you will choose, size and combine typefaces with confidence.

## Typeface or font?

A **typeface** is the design of the letters, such as Inter or Georgia. A **font** is one specific style of it, such as Inter Bold 16 px. In everyday speech the words are used interchangeably.

Main families:

- **Serif** — small strokes at the ends of letters; traditional and bookish.
- **Sans-serif** — no serifs; clean and common on screens.
- **Display** — decorative, for large headlines only.
- **Monospace** — every character the same width; used for code.

## Readable text

| Setting | Good starting point |
| --- | --- |
| Body size on screens | 16 px or larger |
| Line height | 1.4–1.6 times the font size |
| Line length | About 45–75 characters per line |
| Number of typefaces | One or two per design |

Long lines make the eye lose its place; tight line height makes text feel cramped.

## Hierarchy with type

Make levels clearly different. A simple scale such as 32 / 24 / 16 px, combined with weight (bold for headings, regular for body), is enough for most layouts. If two sizes are almost the same, the difference looks like a mistake.

## Type for Uzbek and Russian

Before choosing a typeface, check that it contains every character you need:

- Uzbek Latin: **oʻ** and **gʻ** use the ʻ mark, and the tutuq belgisi ʼ appears in words such as *maʼlumot*.
- Uzbek and Russian Cyrillic: letters such as `Ў Қ Ғ Ҳ` and `Ё Ж Щ Ы`.

Type a test line such as `Oʻzbekiston, maʼlumot — Ўзбекистон, Ғалаба` and look for missing or mismatched letters.

> [!TIP]
> Many free typefaces on Google Fonts are released under the SIL Open Font License, which allows commercial use. For any other typeface, read its licence before using it in a paid project.

## Try it

Set the same short paragraph in a serif and a sans-serif typeface at 16 px with a line height of 1.5. Compare which is easier to read on your phone. Then check both with the Uzbek and Cyrillic test line.

## Common mistakes

- Using four or five typefaces in one design.
- Body text that is too small or too long per line.
- Choosing a typeface that lacks oʻ, gʻ or Cyrillic letters, so the computer substitutes a different font.

## Key terms

- **Typeface / font** — a letter design / one style and size of it.
- **Serif / sans-serif** — with or without small strokes at letter ends.
- **Line height (leading)** — the vertical space between lines.
- **Type scale** — a set of sizes used consistently for hierarchy.$md$);

  perform seed.ensure_lesson(c, 'Colour and type', 'Colour and type: check', 'quiz', 5,
    'Five questions on colour and typography.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Colour and type: check', 'Colour and type check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'In the 60-30-10 rule, what is the 10% used for?',
    'The small accent share highlights the most important elements.',
    array['An accent for the most important elements', 'The background', 'Body text'], array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'single_choice', 'What minimum contrast ratio does WCAG ask for normal body text?',
    'Normal text needs at least 4.5 : 1; large text at least 3 : 1.',
    array['4.5 : 1', '2 : 1', '1 : 1'], array[true, false, false], null);
  perform seed.ensure_question(q, 2, 'single_choice', 'A form shows errors only with a red border. What is the problem?',
    'People with colour blindness may not see it; add text or an icon.',
    array['Meaning is carried by colour alone', 'Red is not allowed in forms', 'Borders slow the page down'], array[true, false, false], null);
  perform seed.ensure_question(q, 3, 'single_choice', 'Which line length is most comfortable for reading body text?',
    'About 45–75 characters per line is easiest to follow.',
    array['About 45–75 characters', 'About 150 characters', 'About 10 characters'], array[true, false, false], null);
  perform seed.ensure_question(q, 4, 'single_choice', 'Before using a typeface for an Uzbek poster, what should you check first?',
    'It must contain oʻ, gʻ, ʼ (and Cyrillic letters if needed).',
    array['That it has every letter you need, such as oʻ and gʻ', 'That it is the newest typeface', 'That it has a decorative style'], array[true, false, false], null);

  perform seed.ensure_lesson(c, 'Layout and critique', 'Grids and layout', 'article', 10,
    'Columns, gutters and spacing systems that make layouts look intentional.',
$md$## The invisible structure

Behind most good layouts is a **grid**: invisible lines that decide where things go. In this lesson you will place content on a grid and use consistent spacing, so your designs look organised even before you add colour.

A grid has three parts:

- **Columns** — vertical areas that hold content.
- **Gutters** — the gaps between columns.
- **Margins** — the space between the content and the edge of the page or screen.

## Common grids

| Grid | Where it is used |
| --- | --- |
| Single column | Articles and simple mobile screens |
| 4 columns | Phone layouts |
| 12 columns | Websites — 12 divides into 2, 3, 4 and 6 equal parts |
| Modular grid | Columns and rows, for galleries and dashboards |

## A spacing system

Pick spacing values from a small set and reuse them. Many designers use multiples of **8**: 8, 16, 24, 32, 48 px. When every gap comes from the same set, the layout feels calm and consistent — this is the principle of repetition at work.

## How people scan a page

- On text-heavy pages, people often read in an **F-pattern**: across the top, then down the left side.
- On simple pages such as posters, the eye tends to follow a **Z-pattern**: top left, top right, diagonally down, bottom right.

Place the most important elements where the eye naturally lands.

## Balance

- **Symmetrical** layouts feel formal and stable.
- **Asymmetrical** layouts feel dynamic; a large element on one side is balanced by several small ones or by white space on the other.

> [!TIP]
> Turn on the grid or layout guides in your design tool (Figma, Canva and others have them) and snap elements to the columns. Alignment becomes automatic.

## A worked example

A poster on a 6-column grid with 24 px margins:

1. The title spans all 6 columns at the top.
2. A large photo spans columns 1–4.
3. Date and place sit in columns 5–6, aligned with the top of the photo.
4. Small print sits along the bottom, aligned to column 1.

Every element starts and ends on a column line, so the poster looks deliberate.

## Try it

Draw a 6-column grid (on paper or in a design tool) and lay out a poster for a school or community event using only rectangles for text and images. Use spacing values from the 8-point set only.

## Common mistakes

- Placing elements by eye, so edges almost — but not quite — line up.
- Using a different gap size every time.
- Filling every column, leaving no white space.

## Key terms

- **Grid** — a set of columns (and sometimes rows) used to place content.
- **Gutter** — the space between columns.
- **Margin** — the space around the content.
- **Spacing system** — a fixed set of spacing values, such as multiples of 8.$md$);

  perform seed.ensure_lesson(c, 'Layout and critique', 'Giving and receiving critique', 'article', 9,
    'Judge designs with precise vocabulary and turn feedback into better work.',
$md$## Why critique matters

Designers improve fastest by showing work early and discussing it. A **critique** is a structured conversation about whether a design achieves its goal. In this lesson you will learn to give useful critique and to receive it calmly.

## A simple structure for giving critique

1. **Start with the goal.** “This poster should make students sign up for the robotics club.”
2. **Say what works, and why.** “The large photo of the robot grabs attention immediately.”
3. **Name problems with a principle.** “The date and the sign-up link are the same size as the small print, so the hierarchy hides them.”
4. **Suggest a direction, not an order.** “What if the date and the link were larger and in the accent colour?”

> [!NOTE]
> Critique is about the work, not the person. “The text is hard to read on this background” helps; “You have bad taste” does not.

## Words that make feedback precise

Use the vocabulary from this course instead of “I like it” or “it feels off”: **hierarchy, contrast, alignment, proximity, repetition, white space, palette, type scale, grid**.

## A critique checklist

| Question | Principle |
| --- | --- |
| What do I see first, second and third? | Hierarchy |
| Is the text easy to read? | Contrast, type |
| Do the edges line up? | Alignment, grid |
| Are related things grouped? | Proximity |
| Are colours, fonts and spacing consistent? | Repetition |
| Does the design have room to breathe? | White space |
| Can everyone use it? | Accessibility |

## Receiving critique

- Listen to the end before answering, and take notes.
- Ask questions: “Which part did you notice first?”
- Do not defend every choice — explain the goal, then decide later what to change.
- You do not have to accept every suggestion, but every comment tells you how someone experienced your design.

## Try it

Find three real designs: a poster in your street, an app screen and a website. Critique each one in four sentences using the structure above and at least two words from the checklist.

## Common mistakes

- Feedback without reasons: “Make it pop.”
- Rewriting someone's design for them instead of naming the problem.
- Taking critique personally and stopping listening.

## Key terms

- **Critique** — a structured discussion of how well a design meets its goal.
- **Actionable feedback** — feedback that points to a specific change.
- **Design rationale** — the reasons behind your design choices.
- **Iteration** — improving a design in repeated rounds.$md$);

  perform seed.ensure_lesson(c, 'Layout and critique', 'Project: an event poster', 'project', 50,
    'Design a poster for a real or imagined local event and explain your choices.',
$md$## Your project

Design a **poster for an event** — a concert, a school fair, a sports match, a book club or a startup meetup. Use a free tool such as Figma or Canva, and apply everything in this course.

### Requirements

1. A clear hierarchy: the event name first, then the date, time and place, then the details.
2. A palette of three to five colours following the 60-30-10 idea, with text contrast of at least 4.5 : 1.
3. At most two typefaces, with a clear type scale. If the poster includes Uzbek or Russian text, the typeface must support every letter.
4. A grid: elements align to columns and use consistent spacing.
5. Enough white space for the poster to feel calm.
6. A short **rationale** (about 150 words) explaining your choices with the course vocabulary.

### How to submit

Upload the poster as a PNG or PDF and paste your rationale in the text box, or share a link to your Figma or Canva file.

> [!NOTE]
> A reviewer critiques your poster against the rubric. Use the feedback, improve the design and resubmit.$md$, 'published', false, 50);
  perform seed.ensure_assignment(c, 'Project: an event poster', 'Event poster',
    'Design an event poster with clear hierarchy, an accessible palette, consistent type and a grid, plus a short rationale.',
$r$| Criterion | Points |
| --- | --- |
| Hierarchy: the most important information is seen first | 25 |
| Palette and contrast (60-30-10 idea, 4.5 : 1 text contrast) | 20 |
| Typography: two or fewer typefaces, clear scale, full letter support | 20 |
| Grid, alignment and consistent spacing | 20 |
| Rationale uses precise design vocabulary | 15 |$r$);

  perform seed.ensure_lesson(c, 'Layout and critique', 'Final assessment', 'quiz', 8,
    'A short exam covering the whole course. Pass mark: 70%.', null, 'published', false, 30);
  q := seed.ensure_quiz(c, 'Final assessment', 'Design Principles from Zero — final assessment', 'final_assessment', 70, 50);
  perform seed.ensure_question(q, 0, 'single_choice', 'What is visual hierarchy?',
    'Arranging elements so people notice them in order of importance.',
    array['Arranging elements so people see them in order of importance', 'Using as many colours as possible', 'Centring everything'], array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'single_choice', 'A caption is far from its photo. Which principle is broken?',
    'Proximity: related items belong close together.',
    array['Proximity', 'Repetition', 'Contrast'], array[true, false, false], null);
  perform seed.ensure_question(q, 2, 'single_choice', 'Which palette approach keeps one accent for the most important elements?',
    'The 60-30-10 rule reserves about 10% for an accent.',
    array['60-30-10', 'Use every colour equally', 'No neutral colours'], array[true, false, false], null);
  perform seed.ensure_question(q, 3, 'true_false', 'True or false: light grey text on a white background is always fine because it looks elegant.',
    'False — low contrast makes text hard to read; check for at least 4.5 : 1.',
    array['True', 'False'], array[false, true], null);
  perform seed.ensure_question(q, 4, 'single_choice', 'How many typefaces should a typical design use?',
    'One or two keeps a design consistent and readable.',
    array['One or two', 'At least four', 'A different one for every line'], array[true, false, false], null);
  perform seed.ensure_question(q, 5, 'single_choice', 'Why do many web layouts use 12 columns?',
    '12 divides evenly into 2, 3, 4 and 6 parts, which makes flexible layouts easy.',
    array['12 divides into 2, 3, 4 and 6 equal parts', 'Browsers require it', 'It looks like a clock'], array[true, false, false], null);
  perform seed.ensure_question(q, 6, 'single_choice', 'Which is the most useful piece of critique?',
    'It names the problem, the principle and a possible direction.',
    array['“The date is as small as the fine print, so the hierarchy hides it — could it be larger?”', '“Make it pop.”', '“I don''t like it.”'], array[true, false, false], null);
  perform seed.ensure_question(q, 7, 'multiple_choice', 'Which of these help a design work for people with colour blindness? Select **all** that apply.',
    'Text labels, icons and strong contrast carry meaning without relying on colour.',
    array['Adding a text label to colour-coded states', 'Using icons alongside colour', 'Strong lightness contrast', 'Telling errors apart only by a red colour'],
    array[true, true, true, false],
    array[null, null, null, 'Colour alone is not enough.']);

  perform seed.order_modules(c, array['Seeing like a designer', 'Colour and type', 'Layout and critique']);
  perform seed.order_lessons(c, 'Colour and type', array['Colour basics', 'Type basics', 'Colour and type: check']);
  perform seed.order_lessons(c, 'Layout and critique', array['Grids and layout', 'Giving and receiving critique', 'Project: an event poster', 'Final assessment']);
end $content$;

-- Oʻzbekcha ------------------------------------------------------------------------------
do $tr$
declare
  c constant text := 'design-principles-from-zero';
begin
  perform seed.tr_module(c, 'Colour and type', 'uz', 'Rang va shrift',
    'Fikrni aniq yetkazadigan ranglar va shriftlarni tanlang.');
  perform seed.tr_module(c, 'Layout and critique', 'uz', 'Maket va tanqidiy tahlil',
    'Elementlarni toʻrga joylashtiring, dizaynlarni aniq atamalar bilan baholang va birinchi afishangizni yarating.');

  perform seed.tr_lesson(c, 'Colour basics', 'uz', 'Rang asoslari',
    'Rang nima qiladi, uni qanday tavsiflash va oddiy, oʻqilishi oson palitrani qanday tuzish.',
$md$## Rang nima qiladi

Koʻpincha odamlar birinchi boʻlib rangni payqaydi. Bu darsda ranglarni ongli tanlashni oʻrganasiz — shunda ular diqqat uchun bir-biri bilan bellashmay, uni yoʻnaltiradi. Dizaynda rang toʻrtta vazifani bajaradi:

1. **Diqqat** — yorqin urgʻu rang nigohni tortadi.
2. **Kayfiyat** — iliq ranglar gʻayratli, sovuq ranglar xotirjam tuyuladi.
3. **Maʼno** — qizil koʻpincha xato yoki shoshilinchlikni, yashil esa muvaffaqiyatni bildiradi.
4. **Guruhlash** — bir xil rangdagi narsalar bir-biriga bogʻliqdek koʻrinadi.

## Rangni tavsiflash

Dizaynerlar rangni uchta xususiyat bilan tavsiflaydi:

- **Tus** (*hue*) — rang oilasi: qizil, toʻq sariq, koʻk.
- **Toʻyinganlik** (*saturation*) — rangning kulrangdan yorqingacha boʻlgan jadalligi.
- **Yorqinlik** (*lightness*) — rangning qanchalik och yoki toʻq ekani.

Ekranlarda ranglar **HEX** (`#1E3A8A`) yoki **RGB** kabi kodlar bilan yoziladi. Printerlar esa **CMYK** boʻyoqlaridan foydalanadi, shuning uchun ekrandagi yorqin rang qogʻozda xiraroq koʻrinishi mumkin.

## Oddiy palitra tuzish

Ishonchli boshlangʻich nuqta — **60-30-10** qoidasi:

| Ulush | Vazifasi | Misol |
| --- | --- | --- |
| 60% | Asosiy neytral fon | Oqish rang |
| 30% | Katta maydonlar uchun ikkinchi rang | Toʻq koʻk |
| 10% | Eng muhim elementlar uchun urgʻu rang | Iliq toʻq sariq |

Boshqa oddiy sxemalar — **monoxrom** (bitta tusning turli soyalari) va **komplementar** (rang doirasida bir-biriga qarama-qarshi joylashgan ikki tus, masalan, koʻk va toʻq sariq).

## Rang va oʻqilishi oson matn

Matn fon bilan kuchli kontrast hosil qilishi kerak. WCAG foydalanish qulayligi tavsiyalari oddiy matn uchun kamida **4.5 : 1**, katta matn uchun esa **3 : 1** kontrast nisbatini talab qiladi. Bepul onlayn kontrast tekshirgichlar ikki rang kodi asosida bu nisbatni hisoblab beradi.

> [!WARNING]
> Maʼnoni hech qachon faqat rang orqali yetkazmang. Taxminan har 12 erkakdan biri va har 200 ayoldan biri rangni farqlashda qandaydir qiyinchilikka ega. Yorliq, ikonka yoki naqsh qoʻshing: faqat qizil chegara emas, ogohlantirish ikonkasi bilan qizil rangda yozilgan “Xato: parol juda qisqa” matni.

## Rang va madaniyat

Ranglarning maʼnosi madaniyat va vaziyatga qarab oʻzgaradi. Koʻp joylarda oq rang toʻy rangi, boshqa joylarda esa motam rangi; qizil xavfni ham, bayramni ham bildirishi mumkin. Dizayningizni kim koʻrishini oʻylab koʻring.

## Oʻzingiz sinab koʻring

Sevgan joyingizni, masalan, Samarqandning moviy koshinlarini suratga oling. Undan beshta rang tanlang: bitta asosiy, bitta ikkinchi darajali, bitta urgʻu rang va matn hamda fon uchun ikkita neytral rang. Matn rangingiz fon bilan kamida 4.5 : 1 kontrast hosil qilishini tekshiring.

## Keng tarqalgan xatolar

- Bir vaqtda koʻplab yorqin ranglardan foydalanish — natijada hech narsa ajralib turmaydi.
- Oq fondagi och kulrang matn — nafis koʻrinadi, ammo oʻqish qiyin.
- Holatni faqat rang bilan koʻrsatish.

## Asosiy atamalar

- **Tus, toʻyinganlik, yorqinlik** — rang oilasi, uning jadalligi va ochligi.
- **HEX / RGB / CMYK** — ekranlar uchun rang kodlari va chop etish uchun boʻyoqlar.
- **Palitra** — dizaynda ishlatiladigan ranglar toʻplami.
- **Kontrast nisbati** — ikki rangning yorqinlik boʻyicha farqi; oʻqilishini baholash uchun ishlatiladi.$md$);

  perform seed.tr_lesson(c, 'Type basics', 'uz', 'Shrift asoslari',
    'Lotin va kirill yozuvidagi oʻqilishi oson matn uchun shriftlarni tanlang, oʻlchamini belgilang va juftlang.',
$md$## Shrift nega muhim

Aksariyat dizaynlarning katta qismi matndan iborat. Yaxshi tipografiya koʻzga tashlanmaydi: odamlar matnni oson oʻqiydi va fikrni tushunadi. Bu darsda shriftlarni ishonch bilan tanlash, oʻlchamini belgilash va birlashtirishni oʻrganasiz.

## Garnitura yoki shrift?

**Garnitura** (*typeface*) — harflar dizayni, masalan, Inter yoki Georgia. **Shrift** (*font*) esa uning muayyan uslubi, masalan, Inter Bold 16 px. Kundalik nutqda bu soʻzlar bir-birining oʻrnida ishlatiladi.

Asosiy oilalar:

- **Serifli** — harflar uchida kichik chiziqchalar bor; anʼanaviy va kitobiy.
- **Serifsiz** (*sans-serif*) — serifsiz; toza va ekranlarda keng tarqalgan.
- **Dekorativ** (*display*) — bezakli, faqat katta sarlavhalar uchun.
- **Monospace** — har bir belgi bir xil kenglikda; kod uchun ishlatiladi.

## Oʻqilishi oson matn

| Sozlama | Yaxshi boshlangʻich qiymat |
| --- | --- |
| Ekranlardagi asosiy matn oʻlchami | 16 px yoki undan katta |
| Qatorlar oraligʻi | Shrift oʻlchamidan 1.4–1.6 marta |
| Qator uzunligi | Har qatorda taxminan 45–75 belgi |
| Shriftlar soni | Har bir dizaynda bitta yoki ikkita |

Uzun qatorlarda koʻz joyini yoʻqotadi; qatorlar oraligʻi tor boʻlsa, matn siqilgandek tuyuladi.

## Shrift bilan ierarxiya

Darajalarni bir-biridan aniq farqlang. 32 / 24 / 16 px kabi oddiy shkala va qalinlik (sarlavhalar uchun qalin, asosiy matn uchun oddiy) aksariyat maketlar uchun yetarli. Agar ikki oʻlcham deyarli bir xil boʻlsa, farq xatodek koʻrinadi.

## Oʻzbek va rus tillari uchun shrift

Shriftni tanlashdan oldin unda sizga kerakli barcha belgilar borligini tekshiring:

- Oʻzbek lotin yozuvi: **oʻ** va **gʻ** ʻ belgisidan foydalanadi, tutuq belgisi ʼ esa *maʼlumot* kabi soʻzlarda uchraydi.
- Oʻzbek va rus kirill yozuvi: `Ў Қ Ғ Ҳ` hamda `Ё Ж Щ Ы` kabi harflar.

`Oʻzbekiston, maʼlumot — Ўзбекистон, Ғалаба` kabi sinov qatorini yozing va yetishmayotgan yoki mos kelmayotgan harflarni qidiring.

> [!TIP]
> Google Fonts’dagi koʻplab bepul shriftlar tijoriy foydalanishga ruxsat beruvchi SIL Open Font License asosida tarqatiladi. Boshqa har qanday shriftdan pullik loyihada foydalanishdan oldin uning litsenziyasini oʻqing.

## Mashq

Bitta qisqa xatboshini serifli va serifsiz shriftda 16 px oʻlchamda, 1.5 qatorlar oraligʻi bilan yozing. Telefoningizda qaysi birini oʻqish osonroq ekanini solishtiring. Keyin ikkalasini ham oʻzbekcha va kirill sinov qatori bilan tekshiring.

## Keng tarqalgan xatolar

- Bitta dizaynda toʻrt-besh xil shriftdan foydalanish.
- Asosiy matnning juda kichik yoki qatorlarning juda uzun boʻlishi.
- oʻ, gʻ yoki kirill harflari boʻlmagan shriftni tanlash — natijada kompyuter ularni boshqa shrift bilan almashtiradi.

## Asosiy atamalar

- **Garnitura / shrift** — harflar dizayni / uning bitta uslubi va oʻlchami.
- **Serifli / serifsiz** — harf uchlarida kichik chiziqchalari bor yoki yoʻq.
- **Qatorlar oraligʻi** (*leading*) — qatorlar orasidagi vertikal masofa.
- **Shrift shkalasi** — ierarxiya uchun izchil ishlatiladigan oʻlchamlar toʻplami.$md$);

  perform seed.tr_lesson(c, 'Colour and type: check', 'uz', 'Rang va shrift: bilimni tekshirish',
    'Rang va tipografiya boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Colour and type check', 'uz', '“Rang va shrift” moduli boʻyicha test');
  perform seed.tr_question(c, 'Colour and type check', 0, 'uz', '60-30-10 qoidasida 10% nima uchun ishlatiladi?',
    'Kichik urgʻu ulushi eng muhim elementlarni ajratib koʻrsatadi.',
    array['Eng muhim elementlar uchun urgʻu rang', 'Fon', 'Asosiy matn']);
  perform seed.tr_question(c, 'Colour and type check', 1, 'uz', 'WCAG oddiy asosiy matn uchun qanday eng kam kontrast nisbatini talab qiladi?',
    'Oddiy matn uchun kamida 4.5 : 1, katta matn uchun kamida 3 : 1.',
    array['4.5 : 1', '2 : 1', '1 : 1']);
  perform seed.tr_question(c, 'Colour and type check', 2, 'uz', 'Forma xatolarni faqat qizil chegara bilan koʻrsatadi. Muammo nimada?',
    'Rangni farqlashda qiynaladigan odamlar uni koʻrmasligi mumkin; matn yoki ikonka qoʻshing.',
    array['Maʼno faqat rang orqali yetkaziladi', 'Formalarda qizil rang taqiqlangan', 'Chegaralar sahifani sekinlashtiradi']);
  perform seed.tr_question(c, 'Colour and type check', 3, 'uz', 'Asosiy matnni oʻqish uchun qanday qator uzunligi eng qulay?',
    'Har qatorda taxminan 45–75 belgini kuzatish eng oson.',
    array['Taxminan 45–75 belgi', 'Taxminan 150 belgi', 'Taxminan 10 belgi']);
  perform seed.tr_question(c, 'Colour and type check', 4, 'uz', 'Oʻzbekcha afisha uchun shriftdan foydalanishdan oldin birinchi navbatda nimani tekshirish kerak?',
    'Unda oʻ, gʻ, ʼ (kerak boʻlsa, kirill harflari ham) boʻlishi shart.',
    array['Unda oʻ va gʻ kabi sizga kerakli barcha harflar borligini', 'U eng yangi shrift ekanini', 'Uning bezakli uslubi borligini']);

  perform seed.tr_lesson(c, 'Grids and layout', 'uz', 'Toʻrlar va maket',
    'Maketlarni puxta oʻylangan koʻrinishga keltiradigan ustunlar, oraliqlar va masofa tizimlari.',
$md$## Koʻrinmas tuzilma

Aksariyat yaxshi maketlar ortida **toʻr** (*grid*) turadi: narsalar qayerga joylashishini belgilaydigan koʻrinmas chiziqlar. Bu darsda kontentni toʻrga joylashtirasiz va izchil masofalardan foydalanasiz — shunda dizaynlaringiz rang qoʻshilishidan oldin ham tartibli koʻrinadi.

Toʻr uch qismdan iborat:

- **Ustunlar** — kontent joylashadigan vertikal maydonlar.
- **Oraliqlar** (*gutters*) — ustunlar orasidagi boʻshliqlar.
- **Chetlar** (*margins*) — kontent bilan sahifa yoki ekran cheti orasidagi masofa.

## Keng tarqalgan toʻrlar

| Toʻr | Qayerda ishlatiladi |
| --- | --- |
| Bir ustunli | Maqolalar va oddiy mobil ekranlar |
| 4 ustunli | Telefon maketlari |
| 12 ustunli | Veb-saytlar — 12 soni 2, 3, 4 va 6 teng qismga boʻlinadi |
| Modulli toʻr | Ustun va qatorlar; galereyalar va boshqaruv panellari uchun |

## Masofa tizimi

Masofa qiymatlarini kichik toʻplamdan tanlang va ulardan qayta foydalaning. Koʻp dizaynerlar **8** ga karrali sonlardan foydalanadi: 8, 16, 24, 32, 48 px. Har bir boʻshliq bir xil toʻplamdan olinganda maket xotirjam va izchil tuyuladi — bu takrorlash tamoyilining amaldagi koʻrinishi.

## Odamlar sahifani qanday koʻzdan kechiradi

- Matni koʻp sahifalarda odamlar koʻpincha **F-shaklida** oʻqiydi: tepada chapdan oʻngga, soʻngra chap tomon boʻylab pastga.
- Afisha kabi oddiy sahifalarda nigoh **Z-shaklida** harakatlanishga moyil: yuqori chap, yuqori oʻng, diagonal boʻylab pastga, pastki oʻng.

Eng muhim elementlarni nigoh tabiiy ravishda tushadigan joylarga qoʻying.

## Muvozanat

- **Simmetrik** maketlar rasmiy va barqaror tuyuladi.
- **Asimmetrik** maketlar dinamik tuyuladi; bir tomondagi katta element boshqa tomondagi bir nechta kichik element yoki boʻsh joy bilan muvozanatlanadi.

> [!TIP]
> Dizayn dasturingizda (Figma, Canva va boshqalarda bor) toʻr yoki maket yoʻnaltiruvchilarini yoqing va elementlarni ustunlarga yopishtiring. Tekislash avtomatik boʻladi.

## Ishlangan misol

24 px chetli 6 ustunli toʻrdagi afisha:

1. Sarlavha yuqorida barcha 6 ta ustunni egallaydi.
2. Katta fotosurat 1–4-ustunlarni egallaydi.
3. Sana va joy 5–6-ustunlarda, fotosuratning yuqori qirrasi bilan tekislangan holda joylashadi.
4. Mayda yozuv pastda, 1-ustunga tekislangan holda joylashadi.

Har bir element ustun chizigʻida boshlanib, ustun chizigʻida tugaydi, shuning uchun afisha puxta oʻylangan koʻrinadi.

## Oʻzingiz sinab koʻring

6 ustunli toʻr chizing (qogʻozda yoki dizayn dasturida) va matn hamda rasmlar uchun faqat toʻrtburchaklardan foydalanib, maktab yoki mahalla tadbiri uchun afisha maketini tuzing. Faqat 8 lik toʻplamdagi masofa qiymatlaridan foydalaning.

## Keng tarqalgan xatolar

- Elementlarni koʻz bilan joylashtirish — chetlar deyarli, lekin toʻliq emas, bir chiziqqa tushadi.
- Har safar har xil boʻshliq oʻlchamidan foydalanish.
- Har bir ustunni toʻldirib, boʻsh joy qoldirmaslik.

## Asosiy atamalar

- **Toʻr** (*grid*) — kontentni joylashtirish uchun ishlatiladigan ustunlar (baʼzan qatorlar ham) toʻplami.
- **Oraliq** (*gutter*) — ustunlar orasidagi masofa.
- **Chet** (*margin*) — kontent atrofidagi masofa.
- **Masofa tizimi** — 8 ga karrali sonlar kabi qatʼiy masofa qiymatlari toʻplami.$md$);

  perform seed.tr_lesson(c, 'Giving and receiving critique', 'uz', 'Tanqidiy fikr bildirish va qabul qilish',
    'Dizaynlarni aniq atamalar bilan baholang va fikr-mulohazani yaxshiroq ishga aylantiring.',
$md$## Tanqidiy tahlil nega muhim

Dizaynerlar ishini erta koʻrsatib, uni muhokama qilganda eng tez oʻsadi. **Tanqidiy tahlil** (*critique*) — dizayn oʻz maqsadiga erishgan-erishmaganligi haqidagi tuzilmali suhbat. Bu darsda foydali tanqidiy fikr bildirishni va uni xotirjam qabul qilishni oʻrganasiz.

## Tanqidiy fikr bildirishning oddiy tuzilmasi

1. **Maqsaddan boshlang.** “Bu afisha talabalarni robototexnika toʻgaragiga yozilishga undashi kerak.”
2. **Nima ishlayotganini va nega ishlayotganini ayting.** “Robotning katta surati darhol eʼtiborni tortadi.”
3. **Muammolarni tamoyil bilan nomlang.** “Sana va roʻyxatdan oʻtish havolasi mayda yozuv bilan bir xil oʻlchamda, shuning uchun ierarxiya ularni yashirib qoʻyadi.”
4. **Buyruq emas, yoʻnalish taklif qiling.** “Sana va havola kattaroq va urgʻu rangda boʻlsa-chi?”

> [!NOTE]
> Tanqidiy tahlil insonga emas, ishga qaratiladi. “Bu fonda matnni oʻqish qiyin” degan gap yordam beradi; “Didingiz yoʻq” degani esa yordam bermaydi.

## Fikr-mulohazani aniq qiladigan soʻzlar

“Menga yoqdi” yoki “nimadir notoʻgʻri” oʻrniga ushbu kursdagi atamalardan foydalaning: **ierarxiya, kontrast, tekislash, yaqinlik, takrorlash, boʻsh joy, palitra, shrift shkalasi, toʻr**.

## Tanqidiy tahlil uchun nazorat roʻyxati

| Savol | Tamoyil |
| --- | --- |
| Birinchi, ikkinchi va uchinchi boʻlib nimani koʻraman? | Ierarxiya |
| Matnni oʻqish osonmi? | Kontrast, shrift |
| Chetlar bir chiziqqa tushyaptimi? | Tekislash, toʻr |
| Bir-biriga aloqador narsalar guruhlanganmi? | Yaqinlik |
| Ranglar, shriftlar va masofalar izchilmi? | Takrorlash |
| Dizaynda “nafas olish” uchun joy bormi? | Boʻsh joy |
| Undan hamma foydalana oladimi? | Foydalanish qulayligi |

## Tanqidiy fikrni qabul qilish

- Javob berishdan oldin oxirigacha tinglang va qayd qilib boring.
- Savol bering: “Birinchi boʻlib qaysi qismni payqadingiz?”
- Har bir tanlovingizni himoya qilmang — maqsadni tushuntiring, nimani oʻzgartirishni esa keyinroq hal qiling.
- Har bir taklifni qabul qilishingiz shart emas, ammo har bir izoh kimdir dizayningizni qanday his qilganini aytadi.

## Oʻzingiz sinab koʻring

Uchta haqiqiy dizayn toping: koʻchangizdagi afisha, ilova ekrani va veb-sayt. Har birini yuqoridagi tuzilma va nazorat roʻyxatidagi kamida ikkita soʻz yordamida toʻrt gap bilan tahlil qiling.

## Keng tarqalgan xatolar

- Sababsiz fikr-mulohaza: “Yorqinroq qiling.”
- Muammoni nomlash oʻrniga birovning dizaynini uning oʻrniga qayta chizish.
- Tanqidiy fikrni shaxsiy qabul qilib, tinglashni toʻxtatish.

## Asosiy atamalar

- **Tanqidiy tahlil** (*critique*) — dizayn oʻz maqsadiga qanchalik erishganini tuzilmali muhokama qilish.
- **Amaliy fikr-mulohaza** — muayyan oʻzgarishni koʻrsatadigan fikr-mulohaza.
- **Dizayn asoslanishi** (*rationale*) — dizayn tanlovlaringiz ortidagi sabablar.
- **Iteratsiya** — dizaynni takroriy bosqichlarda yaxshilash.$md$);

  perform seed.tr_lesson(c, 'Project: an event poster', 'uz', 'Loyiha: tadbir afishasi',
    'Haqiqiy yoki toʻqima mahalliy tadbir uchun afisha yarating va tanlovlaringizni tushuntiring.',
$md$## Loyihangiz

**Tadbir uchun afisha** yarating — konsert, maktab yarmarkasi, sport musobaqasi, kitobxonlar klubi yoki startap uchrashuvi. Figma yoki Canva kabi bepul dasturdan foydalaning va ushbu kursdagi hamma narsani qoʻllang.

### Talablar

1. Aniq ierarxiya: avval tadbir nomi, keyin sana, vaqt va joy, soʻngra tafsilotlar.
2. 60-30-10 gʻoyasiga amal qilgan, matn kontrasti kamida 4.5 : 1 boʻlgan uchtadan beshtagacha rangli palitra.
3. Aniq shrift shkalasiga ega koʻpi bilan ikkita shrift. Agar afishada oʻzbekcha yoki ruscha matn boʻlsa, shrift barcha harflarni qoʻllab-quvvatlashi shart.
4. Toʻr: elementlar ustunlarga tekislangan va izchil masofalardan foydalanilgan.
5. Afisha xotirjam tuyulishi uchun yetarli boʻsh joy.
6. Tanlovlaringizni kurs atamalari bilan tushuntiradigan qisqa **asoslash** (taxminan 150 soʻz).

### Qanday topshiriladi

Afishani PNG yoki PDF sifatida yuklang va asoslash matnini matn maydoniga joylang yoki Figma yoxud Canva faylingizga havola ulashing.

> [!NOTE]
> Tekshiruvchi afishangizni baholash mezonlari asosida tahlil qiladi. Fikr-mulohazadan foydalanib, dizaynni yaxshilang va qayta topshiring.$md$);
  perform seed.tr('assignments', (select id from public.assignments where course_id = seed.course(c) and title = 'Event poster'), 'uz',
    jsonb_build_object(
      'title', 'Tadbir afishasi',
      'brief_md', 'Aniq ierarxiya, hamma uchun qulay palitra, izchil shrift va toʻrga ega tadbir afishasini qisqa asoslash bilan birga yarating.',
      'rubric_md', $r$| Mezon | Ball |
| --- | --- |
| Ierarxiya: eng muhim maʼlumot birinchi koʻrinadi | 25 |
| Palitra va kontrast (60-30-10 gʻoyasi, matn kontrasti 4.5 : 1) | 20 |
| Tipografiya: ikkitadan koʻp boʻlmagan shrift, aniq shkala, barcha harflar qoʻllab-quvvatlanadi | 20 |
| Toʻr, tekislash va izchil masofalar | 20 |
| Asoslashda aniq dizayn atamalaridan foydalanilgan | 15 |$r$),
    c || ' / Event poster');

  perform seed.tr_lesson(c, 'Final assessment', 'uz', 'Yakuniy imtihon',
    'Butun kursni qamrab oluvchi qisqa imtihon. Oʻtish balli: 70%.', null);
  perform seed.tr_quiz(c, 'Design Principles from Zero — final assessment', 'uz', 'Dizayn tamoyillari: noldan boshlab — yakuniy imtihon');
  perform seed.tr_question(c, 'Design Principles from Zero — final assessment', 0, 'uz', 'Vizual ierarxiya nima?',
    'Elementlarni odamlar ularni muhimlik tartibida payqaydigan qilib joylashtirish.',
    array['Elementlarni odamlar ularni muhimlik tartibida koʻradigan qilib joylashtirish', 'Iloji boricha koʻp rangdan foydalanish', 'Hamma narsani markazga joylash']);
  perform seed.tr_question(c, 'Design Principles from Zero — final assessment', 1, 'uz', 'Rasm izohi rasmdan uzoqda joylashgan. Qaysi tamoyil buzilgan?',
    'Yaqinlik: bir-biriga aloqador elementlar yaqin joylashishi kerak.',
    array['Yaqinlik', 'Takrorlash', 'Kontrast']);
  perform seed.tr_question(c, 'Design Principles from Zero — final assessment', 2, 'uz', 'Qaysi palitra usuli eng muhim elementlar uchun bitta urgʻu rangni ajratib qoʻyadi?',
    '60-30-10 qoidasi taxminan 10% ni urgʻu rang uchun ajratadi.',
    array['60-30-10', 'Barcha ranglardan teng foydalanish', 'Neytral ranglarsiz']);
  perform seed.tr_question(c, 'Design Principles from Zero — final assessment', 3, 'uz', 'Toʻgʻrimi yoki notoʻgʻri: oq fondagi och kulrang matn nafis koʻrinishi sababli har doim maqbul.',
    'Notoʻgʻri — past kontrast matnni oʻqishni qiyinlashtiradi; kamida 4.5 : 1 ekanini tekshiring.',
    array['Toʻgʻri', 'Notoʻgʻri']);
  perform seed.tr_question(c, 'Design Principles from Zero — final assessment', 4, 'uz', 'Odatiy dizaynda nechta shriftdan foydalanish kerak?',
    'Bitta yoki ikkita shrift dizaynni izchil va oʻqilishi oson qiladi.',
    array['Bitta yoki ikkita', 'Kamida toʻrtta', 'Har bir qator uchun alohida']);
  perform seed.tr_question(c, 'Design Principles from Zero — final assessment', 5, 'uz', 'Nega koʻplab veb-maketlar 12 ustunli toʻrdan foydalanadi?',
    '12 soni 2, 3, 4 va 6 qismga teng boʻlinadi, bu esa moslashuvchan maketlar yaratishni osonlashtiradi.',
    array['12 soni 2, 3, 4 va 6 teng qismga boʻlinadi', 'Brauzerlar buni talab qiladi', 'U soatga oʻxshaydi']);
  perform seed.tr_question(c, 'Design Principles from Zero — final assessment', 6, 'uz', 'Qaysi tanqidiy fikr eng foydali?',
    'U muammoni, tamoyilni va mumkin boʻlgan yoʻnalishni nomlaydi.',
    array['“Sana mayda yozuv bilan bir xil kichik, shuning uchun ierarxiya uni yashiradi — kattaroq qilsa boʻladimi?”', '“Yorqinroq qiling.”', '“Menga yoqmadi.”']);
  perform seed.tr_question(c, 'Design Principles from Zero — final assessment', 7, 'uz', 'Quyidagilardan qaysilari dizaynni rangni farqlashda qiynaladigan odamlar uchun qulay qiladi? Mos keladigan **barcha** variantlarni belgilang.',
    'Matnli yorliqlar, ikonkalar va kuchli kontrast maʼnoni rangga tayanmasdan yetkazadi.',
    array['Rang bilan belgilangan holatlarga matnli yorliq qoʻshish', 'Rang bilan birga ikonkalardan foydalanish', 'Yorqinlik boʻyicha kuchli kontrast', 'Xatolarni faqat qizil rang orqali ajratish'],
    array[null, null, null, 'Rangning oʻzi yetarli emas.']);
end $tr$;
