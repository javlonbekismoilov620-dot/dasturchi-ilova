-- Oʻzbekcha tarjima: “HTML from Absolute Zero”.
do $tr$
declare
  c constant text := 'html-from-absolute-zero';
begin
  perform seed.tr_course(c, 'uz', 'HTML: mutlaq noldan',
    'Birinchi haqiqiy veb-sahifangizni yarating — va undagi har bir qatorni tushuning',
    $d$HTML — har bir veb-sahifa yoziladigan til. Bu kursda avval **internet qanday ishlashini** bilib olasiz, soʻngra toʻliq sahifani oʻz qoʻlingiz bilan yozasiz.

Sizda allaqachon bor boʻlgan matn muharriri va brauzerdan boshqa hech narsa oʻrnatish shart emas. Har bir dars avval *nima uchun*ni, keyin *qanday qilib*ni tushuntiradi — shu tufayli kodni koʻchirib olmaysiz, balki tushunasiz.$d$,
    array['Manzilni yozganingizdan sahifani koʻrguningizgacha nima sodir boʻlishini tushuntira olasiz',
          'Toʻgʻri HTML hujjatni yoddan yoza olasiz',
          'Kontentni sarlavhalar, xatboshilar va roʻyxatlar yordamida tuzilmalaysiz',
          'Kodni nashrga tayyor yozish odatlari: chekinishlar, semantik teglar va izohlar'],
    array['Kompyuterdan oddiy foydalana olish: fayl yaratish va uni ochish']);

  perform seed.tr_module(c, 'How the web works', 'uz', 'Internet qanday ishlaydi',
    'Brauzer nima qiladi va HTML bu jarayonda qayerda turadi.');
  perform seed.tr_module(c, 'Structuring content', 'uz', 'Kontentni tuzilmalash',
    'Sarlavhalar, xatboshilar, roʻyxatlar va birinchi loyihangiz.');
  perform seed.tr_module(c, 'Links, images and media', 'uz', 'Havolalar, tasvirlar va media',
    'Sahifalarni bir-biri bilan bogʻlang va rasmlar qoʻshing.');

  perform seed.tr_lesson(c, 'What happens when you open a website', 'uz', 'Saytni ochganingizda nima sodir boʻladi',
    'Manzil satridan ekraningizdagi piksellargacha — besh qadamda.',
$md$## Manzildan sahifagacha besh qadam

`example.com` deb yozib Enter tugmasini bosganingizda, bir soniyaga ham yetmaydigan vaqt ichida quyidagilar sodir boʻladi:

1. **Brauzer manzilni aniqlaydi.** Internetdagi kompyuterlar bir-birini *IP-manzil* deb ataladigan raqamlar orqali topadi. **DNS** deb ataladigan tizim telefon maʼlumotnomasi kabi ishlaydi va `example.com` nomini raqamga aylantiradi.
2. **Brauzer soʻrov yuboradi.** U shu manzildagi kompyuterga — **server**ga murojaat qiladi va “Iltimos, bosh sahifangizni yuboring” deb soʻraydi. Bu muloqot **HTTP** (shifrlangan boʻlsa **HTTPS** — qulf belgisiga eʼtibor bering) deb ataladigan qoidalar asosida boradi.
3. **Server javob beradi** va fayllarni yuboradi: **HTML** fayl, odatda biroz **CSS** va **JavaScript**, shuningdek, rasmlar va shriftlar.
4. **Brauzer HTMLni** yuqoridan pastga qarab oʻqiydi va sahifa tuzilmasini quradi.
5. **Brauzer sahifani ekraningizda chizadi**: uslublarni qoʻllaydi va skriptlarni ishga tushiradi.

## Internetning uchta tili

| Til | Vazifasi | Uy bilan taqqoslash |
| --- | --- | --- |
| **HTML** | Tuzilma va kontent | Devorlar, xonalar va mebel |
| **CSS** | Tashqi koʻrinish va joylashuv | Boʻyoq, yoritish va bezak |
| **JavaScript** | Xatti-harakat va interaktivlik | Elektr, ochiladigan eshiklar, qoʻngʻiroq |

> [!NOTE]
> HTML qatʼiy maʼnoda dasturlash tili emas — u qaror qabul qilmaydi va amallarni takrorlamaydi. U **belgilash tili** (*markup language*): brauzer har bir qism nima ekanini bilishi uchun kontentni *belgilab* chiqadi.

## Asosiy atamalar

- **Brauzer** — veb-sahifalarni soʻrab oladigan va koʻrsatadigan ilova (Chrome, Safari, Firefox, Edge).
- **Server** — veb-saytni saqlaydigan va soʻrov kelganda uni yuboradigan kompyuter.
- **URL** — sahifaning toʻliq manzili, masalan, `https://example.com/about`.$md$);

  perform seed.tr_lesson(c, 'What is HTML?', 'uz', 'HTML nima?',
    'Elementlar, teglar va atributlar — har bir sahifa ortidagi uchta gʻoya.',
$md$## Kontentni belgilash

HTML — **HyperText Markup Language** (gipermatnli belgilash tili) soʻzlarining qisqartmasi. Siz oddiy matn yozasiz va uning har bir qismini u nima ekanini bildiruvchi **teglar** ichiga olasiz.

```html
<h1>Mening birinchi sahifam</h1>
<p>Salom! Bu — xatboshi.</p>
```

- `<h1>` — “bu yerdan eng yuqori darajadagi sarlavha boshlanadi” degani.
- `</h1>` — qiya chiziq bilan — “sarlavha shu yerda tugaydi” degani.
- Ochiluvchi teg, kontent va yopiluvchi teg birgalikda **element**ni tashkil qiladi.

## Atributlar qoʻshimcha maʼlumot beradi

Baʼzi elementlarga qoʻshimcha tafsilotlar kerak. Ular ochiluvchi teg ichida **atribut** sifatida `nom="qiymat"` koʻrinishida yoziladi:

```html
<a href="https://example.com">Example saytiga oʻtish</a>
<img src="mushuk.jpg" alt="Divanda uxlab yotgan sargʻish mushuk">
```

- `href` havola qayerga olib borishini bildiradi.
- `src` tasvir qaysi faylni koʻrsatishini bildiradi.
- `alt` ekran oʻquvchi dasturlardan foydalanadigan odamlar uchun tasvirni tavsiflaydi va rasm yuklanmay qolsa, uning oʻrnida koʻrinadi.

> [!TIP]
> Har doim mazmunli `alt` yozing. U sahifaning hamma uchun qulay boʻlishi uchun zarur va qidiruv tizimlariga sahifangizni tushunishga yordam beradi.

## Elementlar boshqa elementlarni oʻz ichiga olishi mumkin

```html
<p>Bu <strong>juda</strong> muhim.</p>
```

Bu yerda `<strong>` elementi `<p>` *ichida* joylashgan. Teglarni ochgan tartibingizga teskari tartibda yoping — xuddi qutilarni bir-birining ichiga joylagandek.

> [!WARNING]
> `<p><strong>matn</p></strong>` kabi bir-biriga chalkashib ketgan teglar — xato. Brauzerlar nimani nazarda tutganingizni taxmin qilishga urinadi, ammo natijani oldindan aytib boʻlmaydi.

## Boʻsh elementlar

Baʼzi elementlarning kontenti ham, yopiluvchi tegi ham boʻlmaydi, masalan, `<img>` va `<br>` (qatorni yangi qatorga oʻtkazish).$md$);

  perform seed.tr_lesson(c, 'Your first web page', 'uz', 'Birinchi veb-sahifangiz',
    'Toʻliq HTML hujjat yozing, uni saqlang va brauzerda oching.',
$md$## Har bir sahifaning skeleti

Har bir HTML hujjat bir xil asosiy tuzilmaga ega. Har bir qatorni va uning izohini oʻqing:

```html
<!DOCTYPE html>
<html lang="uz">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mening birinchi sahifam</title>
  </head>
  <body>
    <h1>Salom, veb!</h1>
    <p>Bu sahifani oʻzim yozdim.</p>
  </body>
</html>
```

- `<!DOCTYPE html>` — brauzerga bu zamonaviy HTML ekanini bildiradi.
- `<html lang="uz">` — ildiz element; `lang` sahifa tilini bildiradi (oʻzbekcha uchun `uz`, ruscha uchun `ru`, inglizcha uchun `en`).
- `<head>` — sahifaning *oʻzi haqidagi*, bevosita koʻrsatilmaydigan maʼlumotlar.
- `<meta charset="utf-8">` — sahifa barcha alifbolar va emojilarni toʻgʻri koʻrsatishiga imkon beradi (jumladan, oʻzbekcha “oʻ” va “gʻ” harflarini ham).
- `<meta name="viewport" …>` — sahifani telefon ekraniga moslashtiradi.
- `<title>` — brauzer yorligʻidagi matn.
- `<body>` — sahifada koʻrinadigan hamma narsa.

## Oʻzingiz sinab koʻring

1. Oddiy matn muharririni oching: Windowsda *Notepad*, macOSda *TextEdit* (**Format → Make Plain Text** menyusini tanlang) yoki VS Code kabi kod muharriri.
2. Yuqoridagi kodni yozing. Uni koʻchirib qoʻyish emas, qoʻlda yozish eslab qolishga yordam beradi.
3. Faylni `index.html` nomi bilan saqlang. Kengaytma `.txt` emas, aynan `.html` ekaniga ishonch hosil qiling.
4. Faylni ikki marta bosing. U brauzeringizda ochiladi.
5. Sarlavha matnini oʻzgartiring, saqlang va oʻzgarishni koʻrish uchun brauzer sahifasini yangilang.

> [!TIP]
> Boshqa element ichidagi elementlarni ikki boʻsh joy bilan surib yozing (chekinish qiling). Brauzerlar boʻsh joylarga eʼtibor bermaydi, ammo kodingizni oʻqiydigan odamlar — jumladan, kelajakdagi oʻzingiz ham — sizga minnatdor boʻladi.

Har bir qator nima qilishini tushuntira olsangiz, quyidagi bilim tekshiruvini topshiring.$md$);

  perform seed.tr_quiz(c, 'Knowledge check: HTML basics', 'uz', 'Bilim tekshiruvi: HTML asoslari');
  perform seed.tr_question(c, 'Knowledge check: HTML basics', 0, 'uz',
    'Hujjatning qaysi qismi brauzer yorligʻida koʻrinadigan matnni saqlaydi?',
    '`<title>` elementi `<head>` ichida joylashadi va yorliq matnini belgilaydi.',
    array['`<h1>`', '`<title>`', '`<body>`'],
    array['`<h1>` — yorliqdagi emas, *sahifadagi* asosiy sarlavha.', null, '`<body>` sahifaning koʻrinadigan kontentini saqlaydi.']);
  perform seed.tr_question(c, 'Knowledge check: HTML basics', 1, 'uz',
    'Bu kodda nima xato?',
    'Teglar teskari tartibda yopilishi kerak: `p` ochiladi, `strong` ochiladi, `strong` yopiladi, `p` yopiladi.',
    array['Hech narsa — kod toʻgʻri', 'Teglar ichma-ich joylashish oʻrniga bir-biriga chalkashgan', '`<strong>` ni `<p>` ichida ishlatib boʻlmaydi'],
    array[null, null, 'Ishlatish mumkin — faqat u xatboshi yopilishidan oldin yopilishi kerak.'],
    '<p><strong>Salom</p></strong>');
  perform seed.tr_question(c, 'Knowledge check: HTML basics', 2, 'uz',
    'Qaysi atribut ekran oʻquvchi dasturlardan foydalanuvchilar uchun tasvirni tavsiflaydi?',
    '`alt` (muqobil matn) tasvirni tavsiflaydi. `src` esa faylga ishora qiladi.',
    array['`src`', '`href`', '`alt`'],
    array[null, '`href` havolalarga tegishli.', null]);

  perform seed.tr_lesson(c, 'Module 1 quiz', 'uz', '1-modul testi',
    'Internet qanday ishlashi haqida oʻrganganlaringizni tekshiring.', null);
  perform seed.tr_quiz(c, 'How the web works', 'uz', 'Internet qanday ishlaydi');
  perform seed.tr_question(c, 'How the web works', 0, 'uz',
    'DNS nima ish qiladi?',
    'DNS `example.com` kabi odam uchun qulay nomlarni IP-manzillarga aylantiradi.',
    array['Ulanishni shifrlaydi', 'Domen nomini IP-manzilga aylantiradi', 'Sahifani ekranda chizadi'],
    array['Shifrlash — HTTPS (TLS) vazifasi.', null, 'Bu brauzerning sahifani chizish (render) bosqichi.']);
  perform seed.tr_question(c, 'How the web works', 1, 'uz',
    'Qaysi til sahifaning *tashqi koʻrinishini* boshqaradi?',
    'HTML — tuzilma, CSS — tashqi koʻrinish, JavaScript — xatti-harakat.',
    array['HTML', 'CSS', 'JavaScript']);
  perform seed.tr_question(c, 'How the web works', 2, 'uz',
    'Toʻgʻrimi yoki notoʻgʻri: HTML — kontentni belgilaydigan belgilash tili.',
    'Toʻgʻri — HTML kontentni belgilaydi, shunda brauzer har bir qism nima ekanini biladi.',
    array['Toʻgʻri', 'Notoʻgʻri']);
  perform seed.tr_question(c, 'How the web works', 3, 'uz',
    'Sahifaning barcha koʻrinadigan kontentini oʻz ichiga oluvchi element qanday nomlanadi? (faqat soʻzning oʻzi, qavslarsiz)',
    'Sahifada koʻrgan hamma narsangiz `<body>` ichida joylashadi.',
    array['body', '<body>']);

  perform seed.tr_lesson(c, 'Headings, paragraphs and lists', 'uz', 'Sarlavhalar, xatboshilar va roʻyxatlar',
    'Kontentingizga odamlar ham, mashinalar ham tushunadigan aniq reja bering.',
$md$## Sarlavhalar reja hosil qiladi

HTMLda oltita sarlavha darajasi bor: `<h1>` dan `<h6>` gacha. Ular harf oʻlchami haqida emas — kitobdagi boblar va boʻlimlar kabi **ahamiyat va tuzilmani** ifodalaydi.

```html
<h1>Ovqat pishirishni oʻrganamiz</h1>
<h2>Nonushta</h2>
<h3>Omlet</h3>
<h3>Boʻtqa</h3>
<h2>Kechki ovqat</h2>
```

> [!TIP]
> Har bir sahifada faqat bitta `<h1>` ishlating va darajalarni hech qachon tashlab ketmang (`<h2>` dan toʻgʻridan-toʻgʻri `<h4>` ga sakramang). Ekran oʻquvchi dasturlardan foydalanuvchilar sahifada sarlavhalar orqali harakatlanadi, qidiruv tizimlari esa sahifangizni tushunish uchun ularni oʻqiydi.

## Xatboshilar

Har bir matn blokini `<p>` ichiga oling. Brauzerlar kodingizdagi ortiqcha boʻsh joylar va qator koʻchirishlarga eʼtibor bermaydi, shuning uchun muharrirda Enter bosish yangi xatboshi **yaratmaydi** — yangi `<p>` yaratadi.

## Roʻyxatlar

**Tartiblanmagan roʻyxatlar** (markerli) tartibi muhim boʻlmagan elementlar uchun:

```html
<ul>
  <li>Un</li>
  <li>Tuxum</li>
  <li>Sut</li>
</ul>
```

**Tartiblangan roʻyxatlar** (raqamli) tartibi muhim boʻlgan qadamlar uchun:

```html
<ol>
  <li>Tuxumlarni chaqing</li>
  <li>Sut bilan koʻpirtiring</li>
  <li>Uch daqiqa pishiring</li>
</ol>
```

`<li>` — *list item*, yaʼni roʻyxat elementi. U har doim `<ul>` yoki `<ol>` ichida boʻlishi shart.

## Maʼnoli urgʻu

- `<strong>` — kuchli ahamiyat (odatda qalin harflarda koʻrsatiladi).
- `<em>` — urgʻu, xuddi gapirayotganda ohangingizni oʻzgartirgandek (odatda kursivda koʻrsatiladi).

Bu teglar *maʼno* tashiydi. Agar sizga faqat vizual uslub kerak boʻlsa, bu CSS vazifasi.$md$);

  perform seed.tr_lesson(c, 'Project: your personal profile page', 'uz', 'Loyiha: shaxsiy profil sahifangiz',
    'Shu paytgacha oʻrganganlaringizni qoʻllab, bir sahifali profil yarating va topshiring.',
$md$## Birinchi loyihangiz

Oʻzingizni (yoki toʻqima bir shaxsni) tanishtiradigan `index.html` nomli bitta sahifa yarating. Unda oʻrganganlaringizdan foydalanishingiz kerak — bundan ortigʻi talab qilinmaydi.

### Talablar

1. `lang`, `charset`, `viewport` va `<title>` mavjud boʻlgan toʻgʻri hujjat skeleti.
2. Shaxsning ismi yozilgan faqat bitta `<h1>`.
3. Kamida ikkita `<h2>` boʻlimi, masalan, *Men haqimda* va *Oʻrganayotgan koʻnikmalarim*.
4. Kamida ikkita xatboshi.
5. Bitta tartiblanmagan va bitta tartiblangan roʻyxat (masalan, *Bu yilgi maqsadlarim* — tartib bilan).
6. Maʼno uchun ishlatilgan kamida bitta `<strong>` va bitta `<em>`.
7. Tartibli chekinishlar.

### Qanday topshiriladi

HTML kodingizni matn maydoniga joylang **yoki** `index.html` faylingizni yuklang **yoki** sahifani eʼlon qilgan boʻlsangiz (masalan, GitHub Pages orqali), havolasini ulashing.

> [!NOTE]
> Tekshiruvchi ishingizni baholash mezonlari asosida koʻrib chiqadi va fikr-mulohaza qoldiradi. Oʻzgartirishlar kiritib, ishni qayta topshirishingiz mumkin.$md$);

  perform seed.tr('assignments',
    (select id from public.assignments where course_id = seed.course(c) and title = 'Personal profile page'), 'uz',
    jsonb_build_object(
      'title', 'Shaxsiy profil sahifasi',
      'brief_md', 'Toʻgʻri HTML skeleti, sarlavhalar, xatboshilar va roʻyxatlardan foydalanib, bir sahifali profil yarating.',
      'rubric_md', $r$| Mezon | Ball |
| --- | --- |
| Toʻgʻri skelet (doctype, lang, charset, viewport, title) | 20 |
| Toʻgʻri sarlavhalar tuzilmasi (bitta h1, h2 boʻlimlari, darajalar tashlab ketilmagan) | 20 |
| Xatboshilar va ikkala roʻyxat turidan toʻgʻri foydalanilgan | 25 |
| strong / em maʼno uchun toʻgʻri ishlatilgan | 15 |
| Oʻqilishi oson chekinishlar va toza ichma-ich joylashuv | 20 |$r$),
    c || ' / Personal profile page');

  perform seed.tr_lesson(c, 'Links: connecting the web', 'uz', 'Havolalar: internetni bogʻlash',
    'Absolyut va nisbiy havolalar, yangi yorliqda xavfsiz ochish.', null);
  perform seed.tr_lesson(c, 'Images done right', 'uz', 'Tasvirlar bilan toʻgʻri ishlash',
    'Formatlar, oʻlchamlar va muqobil matn.', null);
end $tr$;
