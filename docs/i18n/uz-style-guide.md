# Oʻzbekcha uslub qoʻllanmasi — Uzbek style guide for Mahorat content

This guide is for authors, translators and the **native-speaker reviewer**. It records the decisions behind the Uzbek (Latin) text so that every course reads as one consistent, professional voice. The automated content audit (`npm run db:test`) enforces the mechanical rules. Everything else relies on editorial judgement and native review.

## 1. Tone

- **Siz**, always: polite and warm, never stiff. Write as a patient teacher talking to an adult beginner, for example “Fayl yarating”, “Oʻzingiz sinab koʻring”.
- Prefer short, clear sentences. Break long English sentences into two.
- Use natural Uzbek word order (subject – object – verb) rather than mirroring the English.
- Avoid bureaucratic language (*amalga oshirilsin*, *taʼminlansin*) and Russianisms when a common Uzbek word exists.

## 2. Orthography (checked automatically)

| Rule | Correct | Wrong |
| --- | --- | --- |
| oʻ, gʻ use **ʻ** (U+02BB) | oʻzbek, toʻgʻri | o'zbek, o‘zbek, oʼzbek |
| The tutuq belgisi uses **ʼ** (U+02BC) | maʼlumot, sunʼiy, eʼtibor, taʼminot | ma'lumot, ma’lumot, malumot |
| Suffixes attach directly to abbreviations | HTMLdagi, RAMdan, GB ga | HTML’dagi, HTML-dagi |
| A suffix after a **foreign name in its original spelling** is separated with **’** (U+2019), as in Uzbek media | Unreal Engine’ni, Launcher’da, iPhone’da | Unreal Engine dvigatelini (redundant) |
| Numbers: space for thousands, comma for decimals in prose | 1 000 bayt, 2,5 soat | 1,000 bayt |
| Numbers inside code and UI values stay as written | `1.5`, 4.5 : 1 | — |
| No Cyrillic letters in Latin text | — | mixed scripts |

## 3. What stays in English

- **Interface labels of tools without an Uzbek interface** (Blender, Unreal Engine, DaVinci Resolve, Figma): keep the exact label in bold and explain it in Uzbek, for example **Edit → Preferences**, **Content Drawer** (resurslar paneli).
- **Code**: keywords, tags, functions, commands and file names do not change. Translate comments and on-screen text inside examples, for example `<h1>Salom, veb!</h1>` and `city = "Samarqand"`.
- **Established English terms** that learners will meet in tutorials: give the Uzbek term first, then the English in italics on first use, for example *Sheyderlar* (*shaders*), *Lavha* (*shot*).

## 4. Course vocabulary

| English | Oʻzbekcha | Note |
| --- | --- | --- |
| course / module / lesson | kurs / modul / dars | “modul”, not “boʻlim”, everywhere (interface included) |
| knowledge check / quiz / final assessment | bilimni tekshirish / test / yakuniy imtihon | |
| project / assignment / rubric | loyiha / topshiriq / baholash mezonlari | |
| pass mark | oʻtish balli | “ball”, possessive “balli” |
| learner / reviewer | oʻquvchi / tekshiruvchi | |
| progress | natija, oʻzlashtirish | “progress” only in UI badges |

## 5. Technical glossary

| English | Oʻzbekcha |
| --- | --- |
| input / processing / storage / output | kiritish / qayta ishlash / saqlash / chiqarish |
| hardware / software | apparat taʼminoti / dasturiy taʼminot |
| operating system | operatsion tizim (OT) |
| RAM / storage | operativ xotira (RAM) / doimiy xotira |
| motherboard / power supply | ona plata (tizim platasi) / quvvat bloki |
| file / folder / path / extension | fayl / papka / yoʻl / kengaytma |
| backup | zaxira nusxa |
| browser / server / request / response | brauzer / server / soʻrov / javob |
| tag / element / attribute | teg / element / atribut |
| heading / paragraph / list | sarlavha / xatboshi / roʻyxat |
| indentation / nesting | chekinish / ichma-ich joylashtirish |
| variable / value / string / integer / float / boolean | oʻzgaruvchi / qiymat / satr / butun son / kasr son / mantiqiy qiymat |
| function / loop / condition | funksiya / sikl / shart |
| comment | izoh |
| bug / debugging | xato (inglizcha *bug*) / xatolarni tuzatish (*debugging*) |
| terminal / command | terminal / buyruq |
| vertex / edge / face / mesh | uch / qirra / yoq / mesh |
| viewport | koʻrinish maydoni |
| render | render qilish, rendering |
| game engine / actor / asset / level | oʻyin dvigateli / aktor / resurs / daraja |
| shaders | sheyderlar |
| footage / clip / shot / cut | xom material / klip / lavha / kesish |
| frame / frame rate | kadr / kadrlar chastotasi |
| timeline / track / playhead | vaqt shkalasi / trek / ijro kursori |
| resolution / aspect ratio | ruxsat / tomonlar nisbati |
| colour grading | rang korreksiyasi, rang tusini berish |
| hierarchy / contrast / alignment / proximity / white space | ierarxiya / kontrast / tekislash / yaqinlik / boʻsh joy |
| artificial intelligence / machine learning / large language model | sunʼiy intellekt (SI) / mashinali oʻqitish / katta til modeli |
| prompt / token / hallucination | prompt / token / gallyutsinatsiya |
| fine-tuning | qoʻshimcha oʻqitish (*fine-tuning*) |

**Words to avoid:** *kadr* for a shot (use *lavha*); *boʻlim* for a module; *debaging*, *bag*; *dvijok* (use *dvigatel*); redundant pairs such as “Unreal Editor muharriri”.

## 6. Structure rules (checked automatically)

A translated lesson keeps exactly the same:
- headings
- callouts (`> [!NOTE]`, `> [!TIP]`, `> [!WARNING]`)
- tables (same number of rows)
- list items
- fenced code blocks (same languages)

Do not merge or split list items, even where Uzbek phrasing would allow it.

## 7. Review status

1. **Draft:** written or translated.
2. **Edited:** an editorial pass against this guide is complete. All Uzbek starter content is at this stage as of 15 November 2026.
3. **Native-approved:** a native speaker with subject knowledge has signed off in Mahorat Studio (Course → Review).

A course cannot be marked complete until its expert and native-Uzbek reviews are approved. The database enforces this.
