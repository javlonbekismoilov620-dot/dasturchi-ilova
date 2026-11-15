-- Sprint 1 · AI Fundamentals & Prompting (English + Oʻzbekcha). Idempotent.
do $content$
declare
  c constant text := 'ai-fundamentals-and-prompting';
  q uuid;
begin
  perform seed.ensure_module(c, 'Using AI well', 'Know the limits, check the answers and protect your privacy.');
  perform seed.ensure_module(c, 'AI in everyday life', 'Use AI to learn and work better — honestly and responsibly.');

  perform seed.ensure_lesson(c, 'Using AI well', 'Limits: hallucination, outdated knowledge and bias', 'article', 10,
    'Where AI assistants go wrong, why it happens and how to notice it.',
$md$## Powerful, but not all-knowing

AI assistants write fluently about almost anything, which makes their mistakes easy to miss. In this lesson you will learn the three most common limits — hallucination, outdated knowledge and bias — so you can recognise them before they cause problems.

## Hallucination

A **hallucination** is an answer that sounds confident and believable but is false. Remember from the previous module that a language model predicts likely text; it does not look facts up unless it is connected to a search tool or documents. When it does not know, it may still produce a plausible-sounding answer.

Typical hallucinations:

- invented statistics, dates and quotations,
- books, articles or court cases that do not exist,
- web links that lead nowhere,
- confident step-by-step instructions that do not work.

> [!WARNING]
> AI assistants can invent sources that look real, with authors, titles and page numbers. Always open and check a source before you cite it.

## Outdated knowledge

A model learns from data collected up to a certain date, its **knowledge cut-off**. Unless it can search the web, it may not know about recent events, new laws, current prices or the latest version of a program — and it may not tell you that its information is old.

## Bias

AI systems learn from huge amounts of text written by people, so they can repeat people's biases:

- assuming that certain jobs belong to men or women,
- giving less accurate answers about smaller languages and countries, including Uzbek and Uzbekistan,
- treating one culture's habits as “normal”.

Bias is often subtle. Ask yourself: would the answer be different if the person, place or language in the question were different?

## Where AI is strong

None of this means AI is useless. It is genuinely good at explaining concepts in simple words, suggesting ideas, restructuring and shortening text, drafting first versions and practising a language. Use it for these jobs, and check it on facts.

| Usually reliable | Check carefully |
| --- | --- |
| Explaining general concepts | Numbers, dates and statistics |
| Brainstorming ideas | Quotes and sources |
| Rewriting and summarising text you provide | Recent events and prices |
| Practising conversation | Medical, legal and financial advice |

## Try it

Ask an AI assistant about a small, specific topic you know well — your town's history or a local recipe. Mark every sentence as correct, incorrect or unsure, and count the mistakes.

## Common mistakes

- Trusting an answer because it is well written.
- Asking about recent events without checking whether the assistant can search.
- Copying a list of “sources” into homework without opening them.

## Key terms

- **Hallucination** — a fluent but false AI answer.
- **Knowledge cut-off** — the date after which a model has no training data.
- **Bias** — a systematic unfairness or distortion in answers.
- **Grounding** — connecting a model to search or documents so it can cite real sources.$md$);

  perform seed.ensure_lesson(c, 'Using AI well', 'Checking AI answers', 'article', 10,
    'A practical routine for verifying facts, numbers and sources from AI assistants.',
$md$## Trust, but verify

Professionals treat AI output as a draft from a fast assistant: useful, but checked before it is used. In this lesson you will learn a short routine to verify AI answers quickly.

## The verification routine

1. **Separate claims from wording.** Underline every fact, number, date, name and quote. These are what you check.
2. **Find the original source.** Look for the organisation that produced the information: a government statistics office, a university, the official documentation of a program, a reputable newspaper.
3. **Check with two independent sources.** If two reliable sources agree, you can be more confident. If you cannot find any, treat the claim as unverified.
4. **Recalculate numbers.** If the answer says “prices rose by 25%”, do the arithmetic yourself from the original figures.
5. **Note what you checked.** Keep a short list: claim, source, result.

## Asking better follow-up questions

You can make the assistant help you check itself:

- “Which parts of this answer are you least certain about?”
- “Give me sources I can open, with their full titles.” — then open them.
- “What would someone who disagrees say?”
- “Explain how you calculated this, step by step.”

> [!NOTE]
> Follow-up questions help you find weak points, but they are not proof. An assistant can be wrong about its own confidence. The real check is always an independent source.

## Lateral reading

When you meet an unfamiliar website, do not judge it only by how professional it looks. **Read laterally**: open new tabs and search for what others say about the site or the author. Fact-checkers work this way.

## A worked example

An assistant says: “The Registan in Samarkand was built in the 14th century by Amir Temur.”

| Claim | Check | Result |
| --- | --- | --- |
| Registan is in Samarkand | Encyclopedia, UNESCO site | Correct |
| Built in the 14th century | The three madrasas date from the 15th–17th centuries | Incorrect |
| Built by Amir Temur | The oldest madrasa was built by Ulugbek, Temur's grandson | Incorrect |

Two of three claims were wrong, even though the sentence sounded authoritative.

## Try it

Ask an assistant for five facts about a topic from your studies. Verify each one with the routine above and write a short table like the one in the example.

## Common mistakes

- Checking with the same assistant instead of an independent source.
- Accepting a source without opening it.
- Verifying the easy claims and skipping the numbers.

## Key terms

- **Claim** — a statement that can be true or false.
- **Primary source** — the original origin of information.
- **Independent sources** — sources that did not copy from each other.
- **Lateral reading** — checking a source by seeing what others say about it.$md$);

  perform seed.ensure_lesson(c, 'Using AI well', 'Privacy and safety with AI', 'article', 9,
    'What never to share with AI tools, how to check settings and how to spot AI-powered scams.',
$md$## What happens to what you type

When you use an online AI tool, your messages are sent to the company's servers. Depending on the service and your settings, they may be stored, reviewed by staff for safety or used to improve future models. In this lesson you will learn what to keep out of AI tools and how to stay safe.

## Never paste these

- **Passwords, PIN codes and one-time codes.**
- **Bank card numbers and passport details.**
- **Other people's personal information** — names with phone numbers, addresses, health information, photos of their documents.
- **Confidential school or work material** — unpublished exam questions, client files, internal documents — unless your school or employer has approved the tool.

> [!WARNING]
> Laws in many countries, including Uzbekistan, protect personal data. Sharing someone else's personal information with an online service without permission can be illegal, not just impolite.

## Check the settings

Most AI services have privacy settings. Look for:

1. Whether your conversations are used to train future models, and how to turn that off.
2. How long chat history is kept, and how to delete it.
3. Whether you can use a temporary chat that is not saved.

Read the service's privacy policy, at least the summary — it tells you what is collected and why.

## Rules at school and work

Many schools and employers have rules about AI tools: which tools are allowed, for which tasks, and whether you must say when you used one. Follow them. When there are no rules, ask before using AI with anything that is not yours.

## AI-powered scams

Criminals use AI too:

- **Voice cloning** — a phone call that sounds like a relative asking urgently for money.
- **Deepfake videos** — a well-known person “recommending” an investment.
- **Perfectly written phishing messages** — without the spelling mistakes that used to give scams away.

Agree on a **family code word** for emergencies, and if a call or message asks for money or codes, hang up and contact the person through a number you already know.

## Try it

Open the settings of an AI tool you use. Find whether your chats are used for training and how to delete your history. Write down three things you will not share with AI tools from now on.

## Common mistakes

- Pasting a document full of other people's personal data to “summarise it quickly”.
- Assuming chats are private because the window looks private.
- Trusting a familiar voice on the phone without checking.

## Key terms

- **Personal data** — information that identifies a person.
- **Training data** — material used to teach a model; may include user chats, depending on settings.
- **Voice cloning** — using AI to imitate someone's voice.
- **Deepfake** — realistic fake video or audio made with AI.$md$);

  perform seed.ensure_lesson(c, 'Using AI well', 'Using AI well: check', 'quiz', 5,
    'Five questions on limits, verification and privacy.', null, 'published', false, 15);
  q := seed.ensure_quiz(c, 'Using AI well: check', 'Using AI well check', 'knowledge_check', 70, 20);
  perform seed.ensure_question(q, 0, 'single_choice', 'An assistant gives you a book title and author as a source. What should you do?',
    'AI can invent realistic-looking sources; open and check before citing.',
    array['Find and open the book before citing it', 'Cite it — the details look real', 'Ask the assistant whether it is sure, then cite it'],
    array[true, false, false],
    array[null, 'Invented sources often look very real.', 'The assistant''s confidence is not proof.']);
  perform seed.ensure_question(q, 1, 'single_choice', 'Why might an assistant give outdated prices or rules?',
    'Models learn from data up to a knowledge cut-off and may not know recent changes.',
    array['Its training data ends at a knowledge cut-off', 'It deliberately hides new information', 'Prices never change'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 2, 'single_choice', 'What is the strongest way to check an AI claim?',
    'Independent, reliable sources are the real check.',
    array['Confirm it with two independent, reliable sources', 'Ask the same assistant again', 'Check that the answer is well written'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 3, 'multiple_choice', 'Which of these should you never paste into an online AI tool? Select **all** that apply.',
    'Passwords, codes, card details and other people''s personal data must stay out.',
    array['A one-time SMS code', 'A classmate''s phone number and address', 'Your bank card number', 'A paragraph of your own essay you want feedback on'],
    array[true, true, true, false],
    array[null, null, null, 'Your own non-sensitive writing is fine to share for feedback, if your school allows it.']);
  perform seed.ensure_question(q, 4, 'single_choice', 'A relative calls in panic asking you to send money urgently. The voice sounds exactly like them. What do you do?',
    'Voices can be cloned. Hang up and call the person back on a number you already know.',
    array['Hang up and call them back on a number you know', 'Send the money quickly', 'Ask the caller to confirm their birthday'],
    array[true, false, false],
    array[null, 'This is exactly what voice-cloning scams rely on.', 'Scammers may already know personal details.']);

  perform seed.ensure_lesson(c, 'AI in everyday life', 'Studying and working with AI', 'article', 10,
    'Use AI as a tutor and an assistant without giving up your own learning or honesty.',
$md$## A tutor, not a ghostwriter

AI can make you learn faster — or stop you from learning at all. The difference is how you use it. In this lesson you will see practical ways to study and work with AI honestly and well.

## Studying with AI

Good uses keep **you** doing the thinking:

- **Explain it differently:** “Explain photosynthesis as if I were 12, then give me one everyday example.”
- **Quiz me:** “Ask me five questions about the causes of the First World War, one at a time, and tell me what I got wrong.”
- **Check my reasoning:** paste your own solution and ask, “Where is the mistake in my working?”
- **Make a plan:** “I have three weeks before my exam and 40 minutes a day. Make a revision plan.”

> [!WARNING]
> Submitting AI-written work as your own is usually treated as cheating, just like copying from another person. It also means you do not learn the skill the task was designed to teach. Follow your school's rules and say when and how you used AI.

## Writing with AI, keeping your voice

- Ask for an **outline** or **questions to consider**, then write the text yourself.
- Ask for **feedback** on your draft: clarity, structure, grammar.
- Keep your own examples and opinions — they are what make writing yours.

## Translation in Uzbek and Russian

AI translation between Uzbek, Russian and English is helpful for understanding, but quality varies — especially for Uzbek, technical terms and formal documents. Check important translations with a fluent speaker, and never rely on machine translation alone for legal or medical texts.

## Working with AI

| Task | How AI helps | What you still do |
| --- | --- | --- |
| Emails | Drafts a polite first version | Check facts, tone and names |
| Meeting notes | Summarises notes you took | Get permission before recording people |
| Spreadsheets | Suggests formulas and explains them | Test formulas on known data |
| Learning a tool | Explains features step by step | Check against the official documentation |

## Disclosure

When AI contributed meaningfully to your work, say so briefly — for example: “I used an AI assistant to suggest an outline and check grammar. All facts were verified and the final text is my own.” Honesty builds trust with teachers, colleagues and clients.

## Try it

Pick a topic you are studying. Ask an AI assistant to quiz you with five questions, answer them yourself, then ask for feedback. Write two sentences about what you learned that you did not know before.

## Common mistakes

- Asking AI to do the whole assignment instead of helping you learn.
- Trusting machine translation for important documents.
- Forgetting to mention AI use where your school or workplace requires it.

## Key terms

- **Academic integrity** — honesty in learning and assessment.
- **Disclosure** — stating how AI was used in your work.
- **Socratic questioning** — learning by answering a sequence of questions.
- **Draft** — an early version that you will improve.$md$);

  perform seed.ensure_lesson(c, 'AI in everyday life', 'Project: a verified explainer', 'project', 45,
    'Write a short explainer with AI help, verify every fact and disclose how AI was used.',
$md$## Your project

Write a short **explainer** (300–500 words) that teaches a topic to a beginner — for example, how mobile internet works, why the Aral Sea shrank or how compound interest grows savings. Use an AI assistant as a helper, then prove that every fact is correct.

### Requirements

1. **Prompt:** a structured prompt with role, context, task, constraints and format (from module 1). Include it in your submission.
2. **Your text:** the final explainer, written or substantially rewritten by you, in clear language for a beginner.
3. **Verification log:** a table listing every factual claim, the source you checked it with (at least one reliable source per claim, two for numbers) and whether it was correct, corrected or removed.
4. **Corrections:** at least one example of something the AI got wrong or could not support, and what you did about it.
5. **Disclosure:** two or three sentences explaining exactly how you used AI.
6. **Privacy:** no personal data about real private individuals.

### How to submit

Paste everything into the text box or upload a document. Links to your sources must open.

> [!NOTE]
> A reviewer checks your explainer and verification log against the rubric and leaves feedback. You can improve and resubmit.$md$, 'published', false, 50);
  perform seed.ensure_assignment(c, 'Project: a verified explainer', 'Verified explainer',
    'Write a 300–500 word explainer with AI assistance, verify every claim in a log and disclose how AI was used.',
$r$| Criterion | Points |
| --- | --- |
| Structured prompt with all five parts | 15 |
| Clear, accurate explainer for a beginner, in your own words | 25 |
| Verification log covering every factual claim with working sources | 30 |
| At least one documented correction of an AI error | 15 |
| Honest, specific disclosure and no private personal data | 15 |$r$);

  perform seed.ensure_lesson(c, 'AI in everyday life', 'Final assessment', 'quiz', 8,
    'A short exam covering the whole course. Pass mark: 70%.', null, 'published', false, 30);
  q := seed.ensure_quiz(c, 'Final assessment', 'AI Fundamentals & Prompting — final assessment', 'final_assessment', 70, 50);
  perform seed.ensure_question(q, 0, 'single_choice', 'Which statement about machine learning is correct?',
    'ML is one way to build AI: systems learn patterns from examples.',
    array['It is a way to build AI by learning patterns from examples', 'It is the same as a robot', 'It means computers understand the world like people'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 1, 'single_choice', 'What is the core skill of a large language model?',
    'An LLM predicts the next piece of text (token) from what came before.',
    array['Predicting the next piece of text', 'Looking up every fact in a database', 'Understanding intentions like a person'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 2, 'single_choice', 'An assistant confidently quotes a statistic with no source. What is the risk?',
    'It may be a hallucination: fluent but false.',
    array['It may be a hallucination', 'None — fluent answers are reliable', 'The statistic is automatically out of date'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 3, 'multiple_choice', 'Which parts make a prompt more useful? Select **all** that apply.',
    'Role, context, task, constraints and format all help.',
    array['Relevant context', 'Constraints such as length and audience', 'The output format you want', 'Keeping it as vague as possible'],
    array[true, true, true, false],
    array[null, null, null, 'Vague prompts get generic answers.']);
  perform seed.ensure_question(q, 4, 'single_choice', 'Which is the best way to verify a number from an AI answer?',
    'Find the original source and recalculate.',
    array['Find the original source and recalculate it', 'Ask the assistant to repeat it', 'Trust it if it has decimals'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 5, 'single_choice', 'Which use of AI supports your own learning best?',
    'Being quizzed and getting feedback keeps you doing the thinking.',
    array['Asking it to quiz you and explain your mistakes', 'Asking it to write your homework', 'Copying its answer to a test question'],
    array[true, false, false], null);
  perform seed.ensure_question(q, 6, 'true_false', 'True or false: it is fine to paste a client''s personal documents into any AI tool if it helps you work faster.',
    'False — personal and confidential data needs permission and an approved tool.',
    array['True', 'False'], array[false, true], null);
  perform seed.ensure_question(q, 7, 'single_choice', 'Why add a short note about how you used AI in your work?',
    'Disclosure is honest and is often required by schools and employers.',
    array['It is honest and often required', 'It makes the text longer', 'AI tools require it legally in every case'],
    array[true, false, false], null);

  perform seed.order_modules(c, array['Understanding modern AI', 'Using AI well', 'AI in everyday life']);
  perform seed.order_lessons(c, 'Using AI well', array['Limits: hallucination, outdated knowledge and bias', 'Checking AI answers', 'Privacy and safety with AI', 'Using AI well: check']);
  perform seed.order_lessons(c, 'AI in everyday life', array['Studying and working with AI', 'Project: a verified explainer', 'Final assessment']);
end $content$;

-- Oʻzbekcha ------------------------------------------------------------------------------
do $tr$
declare
  c constant text := 'ai-fundamentals-and-prompting';
begin
  perform seed.tr_module(c, 'Using AI well', 'uz', 'Sunʼiy intellektdan toʻgʻri foydalanish',
    'Cheklovlarni biling, javoblarni tekshiring va maxfiyligingizni himoya qiling.');
  perform seed.tr_module(c, 'AI in everyday life', 'uz', 'Kundalik hayotda sunʼiy intellekt',
    'Sunʼiy intellektdan halol va masʼuliyat bilan foydalanib, yaxshiroq oʻqing va ishlang.');

  perform seed.tr_lesson(c, 'Limits: hallucination, outdated knowledge and bias', 'uz', 'Cheklovlar: gallyutsinatsiya, eskirgan bilim va xolislik muammosi',
    'Sunʼiy intellekt yordamchilari qayerda xato qiladi, bu nega sodir boʻladi va uni qanday payqash mumkin.',
$md$## Kuchli, ammo hamma narsani bilmaydi

Sunʼiy intellekt yordamchilari deyarli har qanday mavzuda ravon yozadi, shuning uchun ularning xatolarini payqamay qolish oson. Bu darsda eng keng tarqalgan uchta cheklovni — gallyutsinatsiya, eskirgan bilim va xolislik muammosini oʻrganasiz, shunda ular muammo tugʻdirishidan oldin ularni taniy olasiz.

## Gallyutsinatsiya

**Gallyutsinatsiya** — ishonch bilan aytilgan va ishonarli eshitiladigan, ammo yolgʻon javob. Oldingi moduldan eslang: til modeli ehtimoliy matnni bashorat qiladi; agar u qidiruv vositasi yoki hujjatlarga ulanmagan boʻlsa, faktlarni qidirib topmaydi. U bilmagan paytda ham ishonarli eshitiladigan javob hosil qilishi mumkin.

Odatiy gallyutsinatsiyalar:

- oʻylab topilgan statistika, sanalar va iqtiboslar,
- mavjud boʻlmagan kitoblar, maqolalar yoki sud ishlari,
- hech qayerga olib bormaydigan veb-havolalar,
- ishlamaydigan, lekin ishonch bilan berilgan qadamma-qadam koʻrsatmalar.

> [!WARNING]
> Sunʼiy intellekt yordamchilari muallifi, nomi va sahifa raqamlari bilan haqiqiydek koʻrinadigan manbalarni oʻylab topishi mumkin. Manbaga iqtibos keltirishdan oldin uni har doim ochib tekshiring.

## Eskirgan bilim

Model maʼlum sanagacha — **bilimlar chegarasi**gacha yigʻilgan maʼlumotlardan oʻrganadi. Agar u internetda qidira olmasa, soʻnggi voqealar, yangi qonunlar, joriy narxlar yoki dasturning eng soʻnggi versiyasi haqida bilmasligi mumkin — va uning maʼlumotlari eskirganini sizga aytmasligi ham mumkin.

## Xolislik muammosi

Sunʼiy intellekt tizimlari odamlar yozgan ulkan hajmdagi matnlardan oʻrganadi, shuning uchun ular odamlarning notoʻgʻri qarashlarini (*bias*) takrorlashi mumkin:

- muayyan kasblarni erkaklar yoki ayollarga xos deb hisoblash,
- kichikroq tillar va mamlakatlar, jumladan, oʻzbek tili va Oʻzbekiston haqida kamroq aniq javob berish,
- bitta madaniyat odatlarini “meʼyor” deb bilish.

Xolislik muammosi koʻpincha sezilmaydi. Oʻzingizdan soʻrang: savoldagi inson, joy yoki til boshqacha boʻlganda javob ham boshqacha boʻlarmidi?

## Sunʼiy intellekt qayerda kuchli

Bularning hech biri sunʼiy intellekt foydasiz degani emas. U tushunchalarni oddiy soʻzlar bilan tushuntirish, gʻoyalar taklif qilish, matnni qayta tuzish va qisqartirish, birinchi qoralamani yozish hamda til mashq qilishda haqiqatan ham yaxshi. Undan shu vazifalar uchun foydalaning, faktlar boʻyicha esa tekshiring.

| Odatda ishonchli | Diqqat bilan tekshiring |
| --- | --- |
| Umumiy tushunchalarni tushuntirish | Raqamlar, sanalar va statistika |
| Gʻoyalar topish | Iqtiboslar va manbalar |
| Siz bergan matnni qayta yozish va qisqartirish | Soʻnggi voqealar va narxlar |
| Suhbat mashqi | Tibbiy, huquqiy va moliyaviy maslahatlar |

## Oʻzingiz sinab koʻring

Sunʼiy intellekt yordamchisidan oʻzingiz yaxshi biladigan kichik, aniq mavzu — shahringiz tarixi yoki mahalliy taom retsepti haqida soʻrang. Har bir gapni toʻgʻri, notoʻgʻri yoki noaniq deb belgilang va xatolarni sanang.

## Keng tarqalgan xatolar

- Javob yaxshi yozilgani uchun unga ishonish.
- Yordamchi internetda qidira olishini tekshirmasdan soʻnggi voqealar haqida soʻrash.
- “Manbalar” roʻyxatini ochmasdan uy vazifasiga koʻchirish.

## Asosiy atamalar

- **Gallyutsinatsiya** — sunʼiy intellektning ravon, ammo yolgʻon javobi.
- **Bilimlar chegarasi** (*knowledge cut-off*) — modelda undan keyingi davr uchun oʻqitish maʼlumotlari boʻlmagan sana.
- **Xolislik muammosi** (*bias*) — javoblardagi tizimli adolatsizlik yoki buzilish.
- **Asoslash** (*grounding*) — modelni haqiqiy manbalarga tayanishi uchun qidiruv yoki hujjatlarga ulash.$md$);

  perform seed.tr_lesson(c, 'Checking AI answers', 'uz', 'Sunʼiy intellekt javoblarini tekshirish',
    'Sunʼiy intellekt yordamchilari bergan faktlar, raqamlar va manbalarni tekshirishning amaliy tartibi.',
$md$## Ishon, lekin tekshir

Mutaxassislar sunʼiy intellekt javobiga tez ishlaydigan yordamchining qoralamasi sifatida qaraydi: foydali, ammo ishlatishdan oldin tekshiriladi. Bu darsda sunʼiy intellekt javoblarini tez tekshirishning qisqa tartibini oʻrganasiz.

## Tekshirish tartibi

1. **Daʼvolarni soʻzlardan ajrating.** Har bir fakt, raqam, sana, ism va iqtibosning tagiga chizing. Aynan shularni tekshirasiz.
2. **Asl manbani toping.** Maʼlumotni tayyorlagan tashkilotni qidiring: davlat statistika idorasi, universitet, dasturning rasmiy hujjatlari, nufuzli gazeta.
3. **Ikkita mustaqil manba bilan tekshiring.** Ikki ishonchli manba bir xil maʼlumot bersa, koʻproq ishonch hosil qilishingiz mumkin. Hech qanday manba topa olmasangiz, daʼvoni tasdiqlanmagan deb hisoblang.
4. **Raqamlarni qayta hisoblang.** Agar javobda “narxlar 25% oshdi” deyilgan boʻlsa, asl raqamlardan hisob-kitobni oʻzingiz bajaring.
5. **Nimani tekshirganingizni yozib qoʻying.** Qisqa roʻyxat yuriting: daʼvo, manba, natija.

## Yaxshiroq aniqlashtiruvchi savollar berish

Yordamchining oʻzidan ham uni tekshirishda yordam berishini soʻrashingiz mumkin:

- “Bu javobning qaysi qismlariga eng kam ishonchingiz komil?”
- “Ochib koʻrishim mumkin boʻlgan manbalarni toʻliq nomlari bilan bering.” — soʻngra ularni oching.
- “Bunga qoʻshilmaydigan odam nima degan boʻlardi?”
- “Buni qanday hisoblaganingizni qadamma-qadam tushuntiring.”

> [!NOTE]
> Aniqlashtiruvchi savollar zaif joylarni topishga yordam beradi, ammo ular isbot emas. Yordamchi oʻz ishonchi haqida ham xato qilishi mumkin. Haqiqiy tekshiruv har doim mustaqil manba orqali boʻladi.

## Yonma-yon oʻqish

Notanish veb-saytga duch kelganingizda, uni faqat qanchalik professional koʻrinishiga qarab baholamang. **Yonma-yon oʻqing** (*lateral reading*): yangi yorliqlar ochib, boshqalar sayt yoki muallif haqida nima deyishini qidiring. Faktlarni tekshiruvchilar aynan shunday ishlaydi.

## Ishlangan misol

Yordamchi shunday deydi: “Samarqanddagi Registon XIV asrda Amir Temur tomonidan qurilgan.”

| Daʼvo | Tekshiruv | Natija |
| --- | --- | --- |
| Registon Samarqandda joylashgan | Ensiklopediya, UNESCO sayti | Toʻgʻri |
| XIV asrda qurilgan | Uchta madrasa XV–XVII asrlarga tegishli | Notoʻgʻri |
| Amir Temur tomonidan qurilgan | Eng qadimgi madrasani Temurning nevarasi Ulugʻbek qurdirgan | Notoʻgʻri |

Gap nufuzli eshitilgan boʻlsa-da, uchta daʼvodan ikkitasi notoʻgʻri chiqdi.

## Oʻzingiz sinab koʻring

Yordamchidan oʻqiyotgan mavzuingiz boʻyicha beshta fakt soʻrang. Ularning har birini yuqoridagi tartib bilan tekshiring va misoldagiga oʻxshash qisqa jadval tuzing.

## Keng tarqalgan xatolar

- Mustaqil manba oʻrniga oʻsha yordamchining oʻzi bilan tekshirish.
- Manbani ochmasdan qabul qilish.
- Oson daʼvolarni tekshirib, raqamlarni tashlab ketish.

## Asosiy atamalar

- **Daʼvo** — toʻgʻri yoki notoʻgʻri boʻlishi mumkin boʻlgan fikr.
- **Birlamchi manba** — maʼlumotning asl kelib chiqish joyi.
- **Mustaqil manbalar** — bir-biridan koʻchirmagan manbalar.
- **Yonma-yon oʻqish** (*lateral reading*) — manbani boshqalar u haqda nima deyishiga qarab tekshirish.$md$);

  perform seed.tr_lesson(c, 'Privacy and safety with AI', 'uz', 'Sunʼiy intellekt bilan ishlashda maxfiylik va xavfsizlik',
    'Sunʼiy intellekt vositalariga nimani hech qachon bermaslik, sozlamalarni qanday tekshirish va sunʼiy intellekt yordamidagi firibgarlikni qanday aniqlash.',
$md$## Yozganlaringiz bilan nima sodir boʻladi

Onlayn sunʼiy intellekt vositasidan foydalanganingizda xabarlaringiz kompaniya serverlariga yuboriladi. Xizmat va sozlamalaringizga qarab, ular saqlanishi, xavfsizlik uchun xodimlar tomonidan koʻrib chiqilishi yoki kelajakdagi modellarni yaxshilash uchun ishlatilishi mumkin. Bu darsda sunʼiy intellekt vositalariga nimani bermaslik va qanday xavfsiz qolishni oʻrganasiz.

## Bularni hech qachon joylamang

- **Parollar, PIN-kodlar va bir martalik kodlar.**
- **Bank karta raqamlari va pasport maʼlumotlari.**
- **Boshqa odamlarning shaxsiy maʼlumotlari** — telefon raqamlari bilan ismlar, manzillar, sogʻligʻi haqidagi maʼlumotlar, hujjatlarining suratlari.
- **Maktab yoki ishdagi maxfiy materiallar** — eʼlon qilinmagan imtihon savollari, mijozlar fayllari, ichki hujjatlar — agar maktabingiz yoki ish beruvchingiz vositani tasdiqlamagan boʻlsa.

> [!WARNING]
> Koʻplab mamlakatlarda, jumladan, Oʻzbekistonda ham qonunlar shaxsga doir maʼlumotlarni himoya qiladi. Birovning shaxsiy maʼlumotlarini ruxsatisiz onlayn xizmatga berish shunchaki odobsizlik emas, balki qonunga zid boʻlishi mumkin.

## Sozlamalarni tekshiring

Aksariyat sunʼiy intellekt xizmatlarida maxfiylik sozlamalari bor. Quyidagilarni qidiring:

1. Suhbatlaringiz kelajakdagi modellarni oʻqitishda ishlatiladimi va buni qanday oʻchirish mumkin.
2. Suhbatlar tarixi qancha muddat saqlanadi va uni qanday oʻchirish mumkin.
3. Saqlanmaydigan vaqtinchalik suhbatdan foydalanish mumkinmi.

Xizmatning maxfiylik siyosatini, hech boʻlmaganda qisqacha mazmunini oʻqing — unda nima yigʻilishi va nima uchun ekani aytilgan.

## Maktab va ishdagi qoidalar

Koʻplab maktablar va ish beruvchilarda sunʼiy intellekt vositalari boʻyicha qoidalar bor: qaysi vositalarga, qaysi vazifalar uchun ruxsat berilgan va ulardan foydalanganingizni aytishingiz shartmi. Ularga amal qiling. Qoidalar boʻlmasa, sizga tegishli boʻlmagan narsa bilan sunʼiy intellektdan foydalanishdan oldin soʻrang.

## Sunʼiy intellekt yordamidagi firibgarliklar

Jinoyatchilar ham sunʼiy intellektdan foydalanadi:

- **Ovozni klonlash** — qarindoshingiz ovoziga oʻxshash, shoshilinch pul soʻrayotgan qoʻngʻiroq.
- **Deepfake videolar** — taniqli inson investitsiyani “tavsiya qilayotgan” soxta video.
- **Mukammal yozilgan fishing xabarlari** — avval firibgarlikni fosh qilgan imlo xatolarisiz.

Favqulodda holatlar uchun **oilaviy kod soʻz** kelishib oling va qoʻngʻiroq yoki xabarda pul yoxud kod soʻralsa, goʻshakni qoʻyib, oʻsha inson bilan oʻzingiz biladigan raqam orqali bogʻlaning.

## Oʻzingiz sinab koʻring

Foydalanadigan sunʼiy intellekt vositangiz sozlamalarini oching. Suhbatlaringiz oʻqitishda ishlatiladimi va tarixingizni qanday oʻchirish mumkinligini toping. Bundan buyon sunʼiy intellekt vositalariga bermaydigan uchta narsani yozib qoʻying.

## Keng tarqalgan xatolar

- Boshqa odamlarning shaxsiy maʼlumotlari bilan toʻla hujjatni “tez xulosa qilish uchun” joylash.
- Oyna shaxsiy koʻringani uchun suhbatlar maxfiy deb hisoblash.
- Telefondagi tanish ovozga tekshirmasdan ishonish.

## Asosiy atamalar

- **Shaxsga doir maʼlumotlar** — insonni aniqlashga imkon beradigan maʼlumotlar.
- **Oʻqitish maʼlumotlari** — modelni oʻqitish uchun ishlatiladigan material; sozlamalarga qarab foydalanuvchi suhbatlari ham kirishi mumkin.
- **Ovozni klonlash** — sunʼiy intellekt yordamida birovning ovoziga taqlid qilish.
- **Deepfake** — sunʼiy intellekt yordamida yaratilgan haqiqiydek soxta video yoki audio.$md$);

  perform seed.tr_lesson(c, 'Using AI well: check', 'uz', 'Sunʼiy intellektdan toʻgʻri foydalanish: bilimni tekshirish',
    'Cheklovlar, tekshirish va maxfiylik boʻyicha beshta savol.', null);
  perform seed.tr_quiz(c, 'Using AI well check', 'uz', '“Sunʼiy intellektdan toʻgʻri foydalanish” moduli boʻyicha test');
  perform seed.tr_question(c, 'Using AI well check', 0, 'uz', 'Yordamchi sizga manba sifatida kitob nomi va muallifini berdi. Nima qilish kerak?',
    'Sunʼiy intellekt haqiqiydek koʻrinadigan manbalarni oʻylab topishi mumkin; iqtibos keltirishdan oldin ochib tekshiring.',
    array['Iqtibos keltirishdan oldin kitobni topib, ochib koʻrish', 'Iqtibos keltirish — tafsilotlar haqiqiy koʻrinadi', 'Yordamchidan ishonchi komilmi, deb soʻrab, soʻngra iqtibos keltirish'],
    array[null, 'Oʻylab topilgan manbalar koʻpincha juda haqiqiy koʻrinadi.', 'Yordamchining ishonchi isbot emas.']);
  perform seed.tr_question(c, 'Using AI well check', 1, 'uz', 'Nega yordamchi eskirgan narx yoki qoidalarni aytishi mumkin?',
    'Modellar bilimlar chegarasigacha boʻlgan maʼlumotlardan oʻrganadi va soʻnggi oʻzgarishlarni bilmasligi mumkin.',
    array['Uning oʻqitish maʼlumotlari bilimlar chegarasida tugaydi', 'U yangi maʼlumotlarni ataylab yashiradi', 'Narxlar hech qachon oʻzgarmaydi']);
  perform seed.tr_question(c, 'Using AI well check', 2, 'uz', 'Sunʼiy intellekt daʼvosini tekshirishning eng ishonchli usuli qaysi?',
    'Haqiqiy tekshiruv — mustaqil, ishonchli manbalar.',
    array['Uni ikkita mustaqil, ishonchli manba bilan tasdiqlash', 'Oʻsha yordamchidan qayta soʻrash', 'Javob yaxshi yozilganini tekshirish']);
  perform seed.tr_question(c, 'Using AI well check', 3, 'uz', 'Quyidagilardan qaysilarini onlayn sunʼiy intellekt vositasiga hech qachon joylamaslik kerak? Mos keladigan **barcha** variantlarni belgilang.',
    'Parollar, kodlar, karta maʼlumotlari va boshqa odamlarning shaxsiy maʼlumotlari berilmasligi kerak.',
    array['Bir martalik SMS kod', 'Sinfdoshingizning telefon raqami va manzili', 'Bank karta raqamingiz', 'Fikr-mulohaza olmoqchi boʻlgan oʻz inshoyingizdan bir xatboshi'],
    array[null, null, null, 'Agar maktabingiz ruxsat bersa, maxfiy boʻlmagan oʻz matningizni fikr-mulohaza uchun berish mumkin.']);
  perform seed.tr_question(c, 'Using AI well check', 4, 'uz', 'Qarindoshingiz xavotirda qoʻngʻiroq qilib, zudlik bilan pul yuborishingizni soʻramoqda. Ovoz xuddi unikidek. Nima qilasiz?',
    'Ovozni klonlash mumkin. Goʻshakni qoʻying va oʻsha insonga oʻzingiz biladigan raqam orqali qayta qoʻngʻiroq qiling.',
    array['Goʻshakni qoʻyib, oʻzim biladigan raqam orqali qayta qoʻngʻiroq qilaman', 'Pulni tezda yuboraman', 'Qoʻngʻiroq qiluvchidan tugʻilgan kunini tasdiqlashni soʻrayman'],
    array[null, 'Ovozni klonlash firibgarliklari aynan shunga tayanadi.', 'Firibgarlar shaxsiy maʼlumotlarni allaqachon bilishi mumkin.']);

  perform seed.tr_lesson(c, 'Studying and working with AI', 'uz', 'Sunʼiy intellekt bilan oʻqish va ishlash',
    'Sunʼiy intellektdan oʻz bilimingiz va halolligingizdan voz kechmasdan, repetitor va yordamchi sifatida foydalaning.',
$md$## Siz uchun yozuvchi emas, repetitor

Sunʼiy intellekt sizga tezroq oʻrganishga yordam berishi — yoki umuman oʻrganmay qoʻyishingizga sabab boʻlishi mumkin. Farq undan qanday foydalanishingizda. Bu darsda sunʼiy intellekt bilan halol va samarali oʻqish va ishlashning amaliy usullarini koʻrasiz.

## Sunʼiy intellekt bilan oʻqish

Yaxshi usullarda fikrlashni **siz** davom ettirasiz:

- **Boshqacha tushuntirib ber:** “Fotosintezni 12 yoshli bolaga tushuntirgandek tushuntir, keyin bitta kundalik misol keltir.”
- **Meni sinab koʻr:** “Birinchi jahon urushining sabablari boʻyicha menga birma-bir beshta savol ber va qayerda xato qilganimni ayt.”
- **Fikrlashimni tekshir:** oʻz yechimingizni joylab, “Hisob-kitobimdagi xato qayerda?” deb soʻrang.
- **Reja tuz:** “Imtihonimga uch hafta qoldi, kuniga 40 daqiqa vaqtim bor. Takrorlash rejasini tuz.”

> [!WARNING]
> Sunʼiy intellekt yozgan ishni oʻzingizniki sifatida topshirish, xuddi boshqa odamdan koʻchirish kabi, odatda koʻchirmachilik deb hisoblanadi. Bundan tashqari, siz topshiriq oʻrgatishi kerak boʻlgan koʻnikmani oʻzlashtirmaysiz. Maktabingiz qoidalariga amal qiling va sunʼiy intellektdan qachon va qanday foydalanganingizni ayting.

## Sunʼiy intellekt bilan yozish va oʻz uslubingizni saqlash

- **Reja** yoki **oʻylab koʻrish kerak boʻlgan savollar**ni soʻrang, matnni esa oʻzingiz yozing.
- Qoralamangiz boʻyicha **fikr-mulohaza** soʻrang: aniqlik, tuzilma, grammatika.
- Oʻz misollaringiz va fikrlaringizni saqlang — aynan ular yozuvni sizniki qiladi.

## Oʻzbek va rus tillarida tarjima

Oʻzbek, rus va ingliz tillari oʻrtasidagi sunʼiy intellekt tarjimasi tushunish uchun foydali, ammo sifati har xil — ayniqsa, oʻzbek tilida, texnik atamalar va rasmiy hujjatlarda. Muhim tarjimalarni tilni yaxshi biladigan odam bilan tekshiring va huquqiy yoki tibbiy matnlar uchun hech qachon faqat mashina tarjimasiga tayanmang.

## Sunʼiy intellekt bilan ishlash

| Vazifa | Sunʼiy intellekt qanday yordam beradi | Siz baribir nima qilasiz |
| --- | --- | --- |
| Elektron xatlar | Muloyim birinchi variantni yozadi | Faktlar, ohang va ismlarni tekshirasiz |
| Yigʻilish qaydlari | Siz yozgan qaydlarni qisqacha bayon qiladi | Odamlarni yozib olishdan oldin ruxsat olasiz |
| Elektron jadvallar | Formulalar taklif qiladi va ularni tushuntiradi | Formulalarni maʼlum maʼlumotlarda sinab koʻrasiz |
| Vositani oʻrganish | Imkoniyatlarni qadamma-qadam tushuntiradi | Rasmiy hujjatlar bilan solishtirasiz |

## Oshkor qilish

Sunʼiy intellekt ishingizga sezilarli hissa qoʻshgan boʻlsa, buni qisqacha ayting — masalan: “Reja taklif qilish va grammatikani tekshirish uchun sunʼiy intellekt yordamchisidan foydalandim. Barcha faktlar tekshirildi, yakuniy matn esa oʻzimniki.” Halollik oʻqituvchilar, hamkasblar va mijozlar ishonchini mustahkamlaydi.

## Oʻzingiz sinab koʻring

Oʻqiyotgan mavzuingizni tanlang. Sunʼiy intellekt yordamchisidan sizni beshta savol bilan sinashni soʻrang, ularga oʻzingiz javob bering, soʻngra fikr-mulohaza soʻrang. Ilgari bilmagan va endi oʻrgangan narsangiz haqida ikki gap yozing.

## Keng tarqalgan xatolar

- Oʻrganishga yordam soʻrash oʻrniga butun topshiriqni sunʼiy intellektga bajartirish.
- Muhim hujjatlar uchun mashina tarjimasiga ishonish.
- Maktab yoki ish joyi talab qilganda sunʼiy intellektdan foydalanganini aytishni unutish.

## Asosiy atamalar

- **Akademik halollik** — oʻqish va baholashdagi halollik.
- **Oshkor qilish** (*disclosure*) — ishingizda sunʼiy intellektdan qanday foydalanilganini aytish.
- **Sokratcha savollar** — ketma-ket savollarga javob berish orqali oʻrganish.
- **Qoralama** — keyinchalik yaxshilanadigan dastlabki variant.$md$);

  perform seed.tr_lesson(c, 'Project: a verified explainer', 'uz', 'Loyiha: tekshirilgan tushuntirish matni',
    'Sunʼiy intellekt yordamida qisqa tushuntirish matni yozing, har bir faktni tekshiring va sunʼiy intellektdan qanday foydalanganingizni oshkor qiling.',
$md$## Loyihangiz

Boshlovchiga biror mavzuni oʻrgatadigan qisqa **tushuntirish matni** (300–500 soʻz) yozing — masalan, mobil internet qanday ishlaydi, Orol dengizi nega qurib qoldi yoki murakkab foiz jamgʻarmani qanday oʻstiradi. Sunʼiy intellekt yordamchisidan yordamchi sifatida foydalaning, soʻngra har bir fakt toʻgʻri ekanini isbotlang.

### Talablar

1. **Prompt:** rol, kontekst, vazifa, cheklovlar va formatdan iborat tuzilmali prompt (1-moduldan). Uni topshiriqqa ilova qiling.
2. **Matningiz:** boshlovchi uchun tushunarli tilda, siz yozgan yoki jiddiy qayta ishlagan yakuniy matn.
3. **Tekshiruv jurnali:** har bir faktik daʼvo, uni tekshirgan manbangiz (har bir daʼvo uchun kamida bitta, raqamlar uchun ikkita ishonchli manba) va u toʻgʻri boʻlgani, tuzatilgani yoki olib tashlangani koʻrsatilgan jadval.
4. **Tuzatishlar:** sunʼiy intellekt xato qilgan yoki tasdiqlay olmagan kamida bitta misol va siz bu borada nima qilganingiz.
5. **Oshkor qilish:** sunʼiy intellektdan aynan qanday foydalanganingizni tushuntiradigan ikki-uch gap.
6. **Maxfiylik:** haqiqiy xususiy shaxslar haqida shaxsiy maʼlumotlar yoʻq.

### Qanday topshiriladi

Hammasini matn maydoniga joylang yoki hujjat sifatida yuklang. Manbalaringizga havolalar ochilishi shart.

> [!NOTE]
> Tekshiruvchi tushuntirish matningiz va tekshiruv jurnalingizni baholash mezonlari asosida koʻrib chiqadi va fikr-mulohaza qoldiradi. Uni yaxshilab, qayta topshirishingiz mumkin.$md$);
  perform seed.tr('assignments', (select id from public.assignments where course_id = seed.course(c) and title = 'Verified explainer'), 'uz',
    jsonb_build_object(
      'title', 'Tekshirilgan tushuntirish matni',
      'brief_md', 'Sunʼiy intellekt yordamida 300–500 soʻzlik tushuntirish matni yozing, har bir daʼvoni jurnalda tekshiring va sunʼiy intellektdan qanday foydalanganingizni oshkor qiling.',
      'rubric_md', $r$| Mezon | Ball |
| --- | --- |
| Beshala qismi bor tuzilmali prompt | 15 |
| Boshlovchi uchun oʻz soʻzlaringiz bilan yozilgan aniq va toʻgʻri matn | 25 |
| Har bir faktik daʼvoni ishlaydigan manbalar bilan qamrab olgan tekshiruv jurnali | 30 |
| Sunʼiy intellekt xatosini tuzatishning kamida bitta hujjatlashtirilgan misoli | 15 |
| Halol, aniq oshkor qilish va xususiy shaxsiy maʼlumotlarning yoʻqligi | 15 |$r$),
    c || ' / Verified explainer');

  perform seed.tr_lesson(c, 'Final assessment', 'uz', 'Yakuniy imtihon',
    'Butun kursni qamrab oluvchi qisqa imtihon. Oʻtish balli: 70%.', null);
  perform seed.tr_quiz(c, 'AI Fundamentals & Prompting — final assessment', 'uz', 'Sunʼiy intellekt asoslari va promptlar — yakuniy imtihon');
  perform seed.tr_question(c, 'AI Fundamentals & Prompting — final assessment', 0, 'uz', 'Mashinali oʻqitish haqidagi qaysi fikr toʻgʻri?',
    'Mashinali oʻqitish — sunʼiy intellekt yaratish usullaridan biri: tizimlar misollardan qonuniyatlarni oʻrganadi.',
    array['Bu misollardan qonuniyatlarni oʻrganish orqali sunʼiy intellekt yaratish usuli', 'Bu robot bilan bir xil narsa', 'Bu kompyuterlar dunyoni odamlar kabi tushunishini anglatadi']);
  perform seed.tr_question(c, 'AI Fundamentals & Prompting — final assessment', 1, 'uz', 'Katta til modelining asosiy mahorati nima?',
    'Katta til modeli oldingi matndan kelib chiqib matnning navbatdagi boʻlagini (tokenini) bashorat qiladi.',
    array['Matnning navbatdagi boʻlagini bashorat qilish', 'Har bir faktni maʼlumotlar bazasidan qidirish', 'Niyatlarni inson kabi tushunish']);
  perform seed.tr_question(c, 'AI Fundamentals & Prompting — final assessment', 2, 'uz', 'Yordamchi manbasiz statistikani ishonch bilan keltirmoqda. Xavf nimada?',
    'Bu gallyutsinatsiya boʻlishi mumkin: ravon, ammo yolgʻon.',
    array['Bu gallyutsinatsiya boʻlishi mumkin', 'Hech qanday xavf yoʻq — ravon javoblar ishonchli', 'Statistika avtomatik ravishda eskirgan boʻladi']);
  perform seed.tr_question(c, 'AI Fundamentals & Prompting — final assessment', 3, 'uz', 'Qaysi qismlar promptni foydaliroq qiladi? Mos keladigan **barcha** variantlarni belgilang.',
    'Rol, kontekst, vazifa, cheklovlar va format — hammasi yordam beradi.',
    array['Tegishli kontekst', 'Hajm va auditoriya kabi cheklovlar', 'Siz istagan javob formati', 'Iloji boricha noaniq yozish'],
    array[null, null, null, 'Noaniq promptlar umumiy javoblar oladi.']);
  perform seed.tr_question(c, 'AI Fundamentals & Prompting — final assessment', 4, 'uz', 'Sunʼiy intellekt javobidagi raqamni tekshirishning eng yaxshi usuli qaysi?',
    'Asl manbani toping va qayta hisoblang.',
    array['Asl manbani topib, qayta hisoblash', 'Yordamchidan uni takrorlashni soʻrash', 'Kasr qismi boʻlsa, ishonish']);
  perform seed.tr_question(c, 'AI Fundamentals & Prompting — final assessment', 5, 'uz', 'Sunʼiy intellektdan qanday foydalanish oʻz bilimingizni eng yaxshi rivojlantiradi?',
    'Sizni sinashi va fikr-mulohaza berishi fikrlashni sizda qoldiradi.',
    array['Undan sizni sinab, xatolaringizni tushuntirishini soʻrash', 'Undan uy vazifangizni yozishni soʻrash', 'Uning javobini test savoliga koʻchirish']);
  perform seed.tr_question(c, 'AI Fundamentals & Prompting — final assessment', 6, 'uz', 'Toʻgʻrimi yoki notoʻgʻri: tezroq ishlashga yordam bersa, mijozning shaxsiy hujjatlarini istalgan sunʼiy intellekt vositasiga joylash mumkin.',
    'Notoʻgʻri — shaxsiy va maxfiy maʼlumotlar uchun ruxsat va tasdiqlangan vosita kerak.',
    array['Toʻgʻri', 'Notoʻgʻri']);
  perform seed.tr_question(c, 'AI Fundamentals & Prompting — final assessment', 7, 'uz', 'Nega ishingizda sunʼiy intellektdan qanday foydalanganingiz haqida qisqa izoh qoʻshish kerak?',
    'Oshkor qilish — halollik, maktablar va ish beruvchilar esa koʻpincha buni talab qiladi.',
    array['Bu halollik va koʻpincha talab qilinadi', 'U matnni uzunroq qiladi', 'Sunʼiy intellekt vositalari buni har doim qonuniy talab qiladi']);
end $tr$;
