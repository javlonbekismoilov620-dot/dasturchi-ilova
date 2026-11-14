-- Oʻzbekcha tarjima: “Python for Complete Beginners” va “AI Fundamentals & Prompting”.
do $tr$
declare
  c constant text := 'python-for-complete-beginners';
begin
  perform seed.tr_course(c, 'uz', 'Python: mutlaq boshlovchilar uchun',
    'Birinchi dasturlash tilingiz — murakkab atamalarsiz tushuntirilgan',
    $d$Python dunyodagi eng mashhur dasturlash tillaridan biri: u avtomatlashtirish, maʼlumotlar fani, sunʼiy intellekt, veb-saytlar va taʼlimda qoʻllaniladi. Uning kodi deyarli oddiy ingliz tilidek oʻqiladi, shuning uchun u birinchi til sifatida juda qulay.

Kurs bitta ham qator yozishdan oldin **dasturlash nima ekanini** tushuntirishdan boshlanadi, keyin bosqichma-bosqich Pythonni oʻrnatish, dasturlarni ishga tushirish va qiymatlar bilan ishlashga oʻtadi.$d$,
    array['Dastur nima ekanini va kompyuter uni qanday bajarishini tushuntira olasiz',
          'Pythonni oʻrnatib, kodni terminalda va fayllarda ishga tushira olasiz',
          'Oʻzgaruvchilar yordamida maʼlumotni saqlaysiz va oʻzgartirasiz',
          'Asosiy maʼlumot turlarini taniysiz: matn, butun sonlar, kasr sonlar va rost/yolgʻon'],
    array['“Kompyuter asoslari: noldan boshlab” kursi yoki fayl va papkalar bilan bemalol ishlay olish']);

  perform seed.tr_module(c, 'Thinking like a programmer', 'uz', 'Dasturchidek fikrlash',
    'Kod nima va sizning eng birinchi dasturingiz.');
  perform seed.tr_module(c, 'Making decisions', 'uz', 'Qaror qabul qilish',
    'Shartlar, taqqoslash va if/else.');

  perform seed.tr_lesson(c, 'What is programming?', 'uz', 'Dasturlash nima?',
    'Dasturlar — aniq retseptlar. Dasturlash esa ularni kompyuter tushunadigan tilda yozishdir.',
$md$## Aniq retseptlar

**Dastur** — koʻrsatmalar roʻyxati. **Dasturlash** esa shu koʻrsatmalarni sogʻlom fikrdan mutlaqo mahrum mashina ham bajara oladigan darajada aniq yozish mahoratidir.

Robotga choy damlashni tushuntirayotganingizni tasavvur qiling. “Choy damla” deyish yetarli emas. Sizga shunday koʻrsatmalar kerak boʻladi: *choynakka suv quy, uni yoq, suv qaynaguncha kut, piyolaga choy paketini sol, suvni quy…* — har bir qadam, tartib bilan, hech narsani tashlab ketmasdan. Dasturchilar aynan shunday fikrlaydi.

## Dasturlash tillari nima uchun kerak

Kompyuterlar faqat juda oddiy, raqamli koʻrsatmalarni tushunadi. Ularni bevosita yozish sekin va xatoga moyil. Python kabi **dasturlash tillari** koʻrsatmalarni oʻqilishi oson soʻzlar bilan yozish imkonini beradi, maxsus dastur esa ularni kompyuter uchun tarjima qiladi.

```python
print("Salom, dunyo!")
```

Bu birgina qator kompyuterga `Salom, dunyo!` matnini ekranga chiqarishni buyuradi. Deyarli har bir dasturchining birinchi dasturi aynan shu ishni qiladi.

## Doimo foydalanadigan uchta gʻoya

1. **Ketma-ketlik** — koʻrsatmalar birin-ketin, yuqoridan pastga bajariladi.
2. **Qarorlar** — biror ishni faqat shart rost *boʻlsa* bajarish.
3. **Takrorlash** — biror ishni koʻp marta yozmasdan, koʻp marta bajarish.

> [!TIP]
> Koddagi xatolar **bag** (inglizcha *bug*), ularni tuzatish esa **debaging** (*debugging*) deyiladi. Har bir dasturchi — jumladan, tajribali mutaxassislar ham — har kuni xato qiladi. Xato haqidagi xabarlar muvaffaqiyatsizlik emas, balki yoʻl koʻrsatuvchi ishoralardir.$md$);

  perform seed.tr_lesson(c, 'Installing Python and running your first program', 'uz', 'Pythonni oʻrnatish va birinchi dasturni ishga tushirish',
    'Pythonni oʻrnating, terminalni oching va kodni ikki xil usulda ishga tushiring.',
$md$## 1. Pythonni oʻrnating

- **Windows:** **python.org** saytidan eng soʻnggi *Python 3* oʻrnatuvchisini yuklab oling. Oʻrnatuvchining birinchi oynasida **“Add python.exe to PATH”** katagiga belgi qoʻying, soʻngra *Install Now* tugmasini bosing.
- **macOS:** **python.org** saytidan macOS uchun oʻrnatuvchini yuklab oling va ishga tushiring.
- **Linux:** Python 3 odatda allaqachon oʻrnatilgan boʻladi.

> [!WARNING]
> Pythonni faqat rasmiy sayt — **python.org** dan yuklab oling. Norasmiy yuklab olish saytlari baʼzan keraksiz dasturlarni ham qoʻshib yuboradi.

## 2. Terminalni oching

**Terminal** — sichqoncha bilan bosish oʻrniga buyruqlar yoziladigan oyna.

- Windows: Start menyusini oching va **Terminal** (yoki *Command Prompt*) ni qidiring.
- macOS: Applications → Utilities boʻlimidan **Terminal** ni oching.

Oʻrnatilganini tekshiring:

```bash
python --version
```

macOS va Linuxda `python3 --version` deb yozish kerak boʻlishi mumkin. Ekranda `Python 3.13.1` ga oʻxshash yozuv chiqishi kerak.

## 3. Kodni interaktiv rejimda ishga tushiring

`python` (yoki `python3`) deb yozing va Enter tugmasini bosing. Taklif belgisi `>>>` ga oʻzgaradi. Endi quyidagini yozing:

```python
>>> 2 + 3
5
>>> print("Salom, dunyo!")
Salom, dunyo!
```

Chiqish uchun `exit()` deb yozing.

## 4. Dasturni fayldan ishga tushiring

`hello.py` nomli fayl yarating va unga quyidagini yozing:

```python
name = "Aziz"
print("Salom,", name)
print("Pythonga xush kelibsiz.")
```

Terminalda `cd` buyrugʻi (*change directory* — papkani almashtirish) yordamida fayl joylashgan papkaga oʻting, masalan, `cd Documents`. Soʻngra dasturni ishga tushiring:

```bash
python hello.py
```

> [!TIP]
> Interaktiv rejim tezkor tajribalar uchun juda qulay. Fayllar esa saqlab qolib, qayta-qayta ishga tushirmoqchi boʻlgan dasturlar uchun.$md$);

  perform seed.tr_lesson(c, 'Variables: giving names to values', 'uz', 'Oʻzgaruvchilar: qiymatlarga nom berish',
    'Maʼlumotni saqlang, uni oʻzgartiring va qiymatlarning toʻrtta asosiy turini kashf eting.',
$md$## Yorliqli quti

**Oʻzgaruvchi** — qiymatga ishora qiluvchi nom; uni ichiga biror narsa solish mumkin boʻlgan yorliqli qutiga oʻxshatish mumkin.

```python
age = 17
city = "Samarqand"
```

`=` belgisi matematikadagidek “teng” degan maʼnoni **bildirmaydi**. U *“oʻngdagi qiymatni chapdagi nom ostida saqla”* degani. Uni “age 17 ga **aylanadi**” deb oʻqing.

Oʻzgaruvchini keyinroq oʻzgartirish mumkin:

```python
age = 17
age = age + 1
print(age)  # 18
```

`#` belgisidan keyingi matn — **izoh**: Python eʼtibor bermaydigan, odamlar uchun yozilgan qayd.

## Asosiy turlar

| Tur | Pythondagi nomi | Misol |
| --- | --- | --- |
| Matn | `str` (satr, *string*) | `"Salom"` |
| Butun son | `int` (*integer*) | `42` |
| Kasr son | `float` | `3.14` |
| Rost / yolgʻon | `bool` (mantiqiy qiymat, *boolean*) | `True` |

Qiymatning turini `type()` yordamida Pythondan soʻrash mumkin:

```python
print(type("Salom"))  # <class 'str'>
print(type(42))       # <class 'int'>
```

## Nomlash qoidalari

- Harflar, raqamlar va pastki chiziqdan foydalaning: `total_price`, `player2`.
- Nom raqam bilan boshlanmasin: `2player` — notoʻgʻri nom.
- Nomlar katta-kichik harfga sezgir: `Age` va `age` — ikki xil oʻzgaruvchi.
- Nomi oʻzini oʻzi tushuntiradigan boʻlsin: `minutes_per_day` nomi `m` dan yaxshiroq. Oʻzgaruvchilarni lotin harflarida, odatda inglizcha nomlash qabul qilingan.

## Mashq

Quyidagi dastur nimani chiqarishini ishga tushirishdan **oldin** taxmin qiling:

```python
apples = 5
apples = apples * 2
price = 1.5
print(apples * price)
```

Keyin uni ishga tushiring. `15.0` deb taxmin qildingizmi? `int` ni `float` ga koʻpaytirsangiz, natija `float` boʻladi.$md$);

  perform seed.tr_quiz(c, 'Knowledge check: variables', 'uz', 'Bilim tekshiruvi: oʻzgaruvchilar');
  perform seed.tr_question(c, 'Knowledge check: variables', 0, 'uz',
    'Bu dastur nimani chiqaradi?',
    '`x` 4 dan boshlanadi, soʻngra 4 + 3 = 7 ga aylanadi.',
    array['4', '7', 'x + 3'],
    array['Ikkinchi qator `x` ni oʻzgartiradi.', null, 'Python ifodani hisoblaydi; uni matn sifatida chiqarmaydi.']);
  perform seed.tr_question(c, 'Knowledge check: variables', 1, 'uz',
    'Qaysi biri toʻgʻri oʻzgaruvchi nomi?',
    'Nomlar raqam bilan boshlanmaydi, ularda boʻsh joy yoki defis boʻlishi mumkin emas.',
    array['`2nd_place`', '`second-place`', '`second_place`'],
    array['Raqam bilan boshlangan.', 'Defis ayirish belgisi (minus) sifatida oʻqiladi.', null]);
  perform seed.tr_question(c, 'Knowledge check: variables', 2, 'uz',
    '`3.0` qiymatining turi qanday?',
    'Oʻnlik nuqtasi bor har qanday son `float` hisoblanadi, hatto kasr qismi nol boʻlsa ham.',
    array['`int`', '`float`', '`str`'],
    array[null, null, 'U faqat qoʻshtirnoq ichida boʻlganda satr boʻlar edi: `"3.0"`.']);

  perform seed.tr_lesson(c, 'Comparing values', 'uz', 'Qiymatlarni taqqoslash',
    'True, False va taqqoslash operatorlari.', null);
  perform seed.tr_lesson(c, 'if, elif and else', 'uz', 'if, elif va else',
    'Dasturingizga nima qilishni tanlash imkonini bering.', null);
end $tr$;

do $tr$
declare
  c constant text := 'ai-fundamentals-and-prompting';
begin
  perform seed.tr_course(c, 'uz', 'Sunʼiy intellekt asoslari va promptlar',
    'Zamonaviy sunʼiy intellekt aslida nima — va undan qanday qilib yaxshi natija olish mumkin',
    $d$Sunʼiy intellekt odamlarning oʻqish va ishlash usullarini oʻzgartirmoqda. Bu kurs sunʼiy intellekt tizimlari aslida nima qilishini, ular qayerda xato qilishini va foydali, ishonchli natija beradigan promptlarni qanday yozishni oddiy tilda tushuntiradi.$d$,
    array['Sunʼiy intellekt, mashinali oʻqitish va katta til modellari oʻrtasidagi farqni tushuntira olasiz',
          'Gallyutsinatsiyalarni taniysiz va sunʼiy intellekt javoblarini qanday tekshirishni bilasiz',
          'Kontekst, vazifa, cheklovlar va formatdan iborat tuzilmali promptlar yoza olasiz'],
    array['Talab qilinmaydi']);

  perform seed.tr_module(c, 'Understanding modern AI', 'uz', 'Zamonaviy sunʼiy intellektni tushunish',
    'Avval tushunchalar, keyin vositalar.');

  perform seed.tr_lesson(c, 'What AI is — and what it is not', 'uz', 'Sunʼiy intellekt nima — va nima emas',
    'Sunʼiy intellekt, mashinali oʻqitish va chuqur oʻqitish — chalkashliksiz.',
$md$## Bir-birining ichidagi uchta tushuncha

- **Sunʼiy intellekt (SI, inglizcha *AI*)** — keng maqsad: odatda inson aql-zakovatini talab qiladigan vazifalarni, masalan, tilni tushunish yoki tasvirlarni tanib olishni kompyuterlar bajarishi.
- **Mashinali oʻqitish** (*machine learning, ML*) — bu maqsadga erishish yoʻllaridan biri: har bir qoidani qoʻlda yozish oʻrniga kompyuterga koʻplab misollar koʻrsatiladi va u ulardan *qonuniyatlarni oʻrganadi*.
- **Chuqur oʻqitish** (*deep learning*) — katta **neyron tarmoqlar**dan, yaʼni miyadan qisman ilhomlangan koʻp qatlamli matematik modellardan foydalanadigan mashinali oʻqitish turi.

## Misollardan oʻrganish

Spam filtri — klassik misol. Hech kim har bir spam xat uchun alohida qoida yozmaydi. Buning oʻrniga tizim “spam” yoki “spam emas” deb belgilangan millionlab xatlarni koʻradi va qaysi qonuniyatlar odatda spamni bildirishini oʻrganadi.

## Sunʼiy intellekt nima emas

> [!WARNING]
> Bugungi sunʼiy intellekt tizimlari dunyoni odamlar kabi *tushunmaydi* va ularning niyatlari yoʻq. Ular oʻqitish maʼlumotlaridagi qonuniyatlar asosida javob hosil qiladi. Bu ularni kuchli qiladi — va ishonch bilan xato qilishga ham qodir qiladi.

## Sunʼiy intellektga allaqachon qayerda duch kelasiz

Telefoningizdagi suratlar boʻyicha qidiruv, ovozli yordamchilar, tarjima ilovalari, video platformalardagi tavsiyalar hamda matn yozib bera oladigan va tushuntira oladigan chat-yordamchilar.$md$);

  perform seed.tr_lesson(c, 'How large language models work, simply', 'uz', 'Katta til modellari qanday ishlaydi — sodda qilib',
    'Keyingi soʻzni bashorat qilish — ulkan miqyosda.',
$md$## Matnning keyingi boʻlagini bashorat qilish

**Katta til modeli** (*large language model, LLM*) ulkan hajmdagi matnlar asosida oʻqitiladi. Uning asosiy mahoratini taʼriflash hayratlanarli darajada oson: berilgan matndan keyin **nima kelishini bashorat qilish**.

Matn **token** deb ataladigan kichik boʻlaklarga — butun soʻzlar, soʻz qismlari yoki tinish belgilariga ajratiladi. Model navbatdagi tokenni bashorat qiladi, uni matnga qoʻshadi va yana bashorat qiladi. U juda koʻp yozma matndan oʻrgangani uchun bu bashoratlar tushuntirishlar, qisqacha bayonlar, kod va tarjimalarni hosil qila oladi.

## Bu siz uchun nima uchun muhim

- **Kontekst — hamma narsa.** Model faqat oʻqitilganda koʻrgan narsalarni va siz suhbatga kiritgan maʼlumotni biladi. Unga kerakli maʼlumotni bering.
- **U ravon tarzda xato qilishi mumkin.** Model ishonarli, ammo yolgʻon maʼlumot hosil qilsa, bu **gallyutsinatsiya** deyiladi.
- **Uning bilimlari maʼlum sanagacha.** Agar qidiruv tizimi yoki hujjatlarga ulanmagan boʻlsa, u soʻnggi voqealardan bexabar boʻlishi mumkin.

> [!TIP]
> Sunʼiy intellekt javobiga tez ishlaydigan va koʻp oʻqigan yordamchining qoralamasi sifatida qarang: foydali, ammo unga tayanishdan oldin **faktlar, raqamlar, iqtiboslar va manbalarni tekshiring**.$md$);

  perform seed.tr_lesson(c, 'Writing your first good prompt', 'uz', 'Birinchi yaxshi promptingizni yozish',
    'Har qanday yordamchi bilan ishlaydigan oddiy beshta qismli tuzilma.',
$md$## Noaniqdan aniqqa

Noaniq prompt umumiy javob oladi:

> Samarqand haqida yozib ber.

Tuzilmali prompt esa foydali javob oladi. Unga quyidagi beshta qismni kiriting:

1. **Rol** — yordamchi kim sifatida ish tutsin? *“Sen samimiy tarix oʻqituvchisisan.”*
2. **Kontekst** — vaziyat haqida maʼlumot. *“Oʻquvchilarim 14 yoshda va Buyuk Ipak yoʻlini hali oʻrganishmagan.”*
3. **Vazifa** — aynan nima kerakligi. *“Samarqand nima uchun muhim shaharga aylanganini tushuntir.”*
4. **Cheklovlar** — chegaralar. *“200 soʻzdan kam, oddiy soʻzlar bilan, asrlardan boshqa sanalarni keltirma.”*
5. **Format** — javobning shakli. *“Uchta qisqa xatboshi, soʻngra muhokama uchun bitta savol.”*

## Takomillashtiring

Birinchi promptingiz — faqat boshlangʻich nuqta. Javob juda uzun, haddan tashqari rasmiy boʻlsa yoki biror narsa yetishmasa, buni ayting: *“Qisqaroq yoz va oʻsmir oʻziga yaqin oladigan bitta misol qoʻsh.”*

## Mashq

Quyidagi zaif promptni beshta qismning hammasidan foydalanib qayta yozing, soʻngra uni oʻzingizda bor istalgan sunʼiy intellekt yordamchisida sinab koʻring:

> Rezyumemni yozishga yordam ber.

> [!NOTE]
> Vosita maʼlumotlarni qanday saqlashi va ishlatishini aniq bilmasangiz, unga hech qachon parollar, maxfiy hujjatlar yoki boshqa odamlarning shaxsiy maʼlumotlarini kiritmang.$md$);

  perform seed.tr_quiz(c, 'Knowledge check: prompting', 'uz', 'Bilim tekshiruvi: promptlar');
  perform seed.tr_question(c, 'Knowledge check: prompting', 0, 'uz',
    'Yordamchi oʻylab topilgan statistikani keltirib, ishonch bilan javob beradi. Bu hodisa nima deb ataladi?',
    'Gallyutsinatsiya — ravon va ishonarli, ammo haqiqatga toʻgʻri kelmaydigan javob.',
    array['Gallyutsinatsiya', 'Token', 'Qoʻshimcha oʻqitish (fine-tuning)'],
    array[null, 'Tokenlar — matn ajratiladigan kichik boʻlaklar.', 'Fine-tuning — modelni maxsus maʼlumotlar asosida qoʻshimcha oʻqitish.']);
  perform seed.tr_question(c, 'Knowledge check: prompting', 1, 'uz',
    'Quyidagilardan qaysilari promptni yaxshilaydi?',
    'Kontekst, aniq cheklovlar va soʻralgan format yordam beradi. Noaniqlik esa zarar qiladi.',
    array['Tegishli maʼlumot berish', 'Hajm va auditoriyani koʻrsatish', 'Javob formatini belgilash', 'Iloji boricha qisqa va noaniq yozish'],
    array[null, null, null, 'Qisqa boʻlishi mumkin; noaniq boʻlishi esa mumkin emas.']);
  perform seed.tr_question(c, 'Knowledge check: prompting', 2, 'uz',
    'Toʻgʻrimi yoki notoʻgʻri: mashinali oʻqitish sunʼiy intellektning bir qismi.',
    'Mashinali oʻqitish sunʼiy intellekt yaratish yondashuvlaridan biri, shuning uchun u kengroq soha ichida joylashadi.',
    array['Toʻgʻri', 'Notoʻgʻri']);
end $tr$;
