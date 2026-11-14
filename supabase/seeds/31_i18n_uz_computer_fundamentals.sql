-- Oʻzbekcha tarjima: “Computer Fundamentals from Zero”.
do $tr$
declare
  c constant text := 'computer-fundamentals-from-zero';
begin
  perform seed.tr_course(c, 'uz', 'Kompyuter asoslari: noldan boshlab',
    'Oldingizdagi mashinani tushunib oling — oldindan bilim shart emas',
    $d$Bu kurs sizdan **hech narsa** bilishni talab qilmaydi. Agar kompyuter ichida aslida nima sodir boʻlishi, fayllar nega `.pdf` kabi gʻalati qoʻshimchalar bilan tugashi yoki odamlar “apparat taʼminoti” va “dasturiy taʼminot” deganda nimani nazarda tutishi haqida oʻylab koʻrgan boʻlsangiz, toʻgʻri joydasiz.

Kompyuter maʼlumotni qanday qabul qilishi, uni qayta ishlashi, saqlashi va natijani sizga qanday koʻrsatishi haqida aniq tasavvur hosil qilasiz. Har bir atama birinchi marta uchraganda tushuntiriladi.$d$,
    array['Kompyuter nima ekanini kiritish → qayta ishlash → saqlash → chiqarish modeli orqali tushuntira olasiz',
          'Apparat va dasturiy taʼminotni farqlaysiz hamda kompyuterning asosiy qismlarini ayta olasiz',
          'Bit va baytlarni tushunasiz, GB va TB kabi xotira hajmlarini oʻqiy olasiz',
          'Fayllar, papkalar va fayl yoʻllarida bemalol harakatlanasiz'],
    array['Oldindan bilim shart emas — qiziqish va istalgan kompyuterdan foydalanish imkoniyati kifoya']);

  perform seed.tr_module(c, 'What a computer really is', 'uz', 'Kompyuter aslida nima',
    'Telefondan tortib serverlargacha — har bir kompyuter ortidagi asosiy gʻoya.');
  perform seed.tr_module(c, 'Working with files', 'uz', 'Fayllar bilan ishlash',
    'Maʼlumotni har doim qayta topa olishingiz uchun u qanday tartibga solinadi.');
  perform seed.tr_module(c, 'Final assessment', 'uz', 'Yakuniy imtihon',
    'Sertifikat olish uchun oʻrganganlaringizni koʻrsating.');

  perform seed.tr_lesson(c, 'What is a computer?', 'uz', 'Kompyuter nima?',
    'Kompyuter — kiritilgan maʼlumotni koʻrsatmalarga amal qilib foydali natijaga aylantiradigan mashina.',
$md$## Koʻrsatmalarga amal qiladigan mashina

**Kompyuter** — maʼlumotni qabul qiladigan, shu maʼlumot bilan ishlash uchun koʻrsatmalar roʻyxatiga amal qiladigan va sizga natija beradigan mashina. Bor-yoʻgʻi shu. Noutbukingiz, telefoningiz, aqlli soat, kassa apparati va veb-saytlarni ishlatadigan serverlar — bularning barchasi kompyuter.

Kompyuterlarni maxsus qiladigan narsa ularning aqlli ekani emas — ular aqlli emas. Ular **nihoyatda tez** va **soʻzsiz itoatkor**. Zamonaviy kompyuter har soniyada milliardlab oddiy koʻrsatmalarni aynan yozilganidek bajara oladi.

> [!NOTE]
> Kompyuter amal qiladigan koʻrsatmalar roʻyxati **dastur** deb ataladi. Dastur yozish esa **dasturlash** deyiladi.

## Har bir kompyuterning toʻrt vazifasi

Hajmidan qatʼi nazar, har qanday kompyuter bir xil toʻrt vazifani bajaradi:

1. **Kiritish** — maʼlumotni qabul qilish. Klaviaturada yozish, ekranga teginish, mikrofonga gapirish yoki suratga olish — bularning hammasi kiritish.
2. **Qayta ishlash** — koʻrsatmalarga amal qilib, shu maʼlumot ustida ishlash. Sonlarni qoʻshish, fotosuratga filtr qoʻllash yoki parolni tekshirish — bular qayta ishlash.
3. **Saqlash** — maʼlumotni keyinroq foydalanish uchun saqlab qoʻyish. Fotosuratlaringiz, hujjatlaringiz va oʻrnatilgan ilovalaringiz saqlanadi.
4. **Chiqarish** — natijani koʻrsatish yoki yuborish. Ekrandagi matn, karnaydan chiqqan ovoz, chop etilgan sahifa yoki doʻstingizga yuborilgan xabar — bular chiqarish.

## Kundalik misol

Telefoningizda suratga olganingizda:

- kamera yorugʻlikni qayd etadi — **kiritish**
- telefon ranglar va tiniqlikni yaxshilaydi — **qayta ishlash**
- surat galereyaga saqlanadi — **saqlash**
- surat ekraningizda paydo boʻladi — **chiqarish**

> [!TIP]
> Biror yangi texnologiya chalkash tuyulsa, oʻzingizdan soʻrang: *nima kiritiladi, qanday qayta ishlanadi, nima saqlanadi va natijada nima chiqariladi?* Shu birgina savol hisoblash texnikasidagi juda koʻp narsani tushuntirib beradi.

## Asosiy atamalar

- **Kompyuter** — koʻrsatmalarga amal qilib maʼlumotni qayta ishlaydigan mashina.
- **Dastur** — kompyuter uchun koʻrsatmalar roʻyxati.
- **Kiritish / Chiqarish** — kompyuterga kirayotgan / undan chiqayotgan maʼlumot.$md$);

  perform seed.tr_lesson(c, 'Hardware and software', 'uz', 'Apparat va dasturiy taʼminot',
    'Qoʻl bilan ushlash mumkin boʻlgan jismoniy qismlar va ularga jon kirituvchi koʻrsatmalar.',
$md$## Har bir kompyuterning ikki yarmi

Har qanday kompyuter ikki xil narsadan iborat:

- **Apparat taʼminoti** (inglizcha *hardware*) — qoʻl bilan ushlash mumkin boʻlgan jismoniy qismlar: ekran, klaviatura, mikrosxemalar va kabellar.
- **Dasturiy taʼminot** (inglizcha *software*) — apparatga nima qilishni aytadigan koʻrsatmalar, yaʼni dasturlar: operatsion tizim, veb-brauzer, oʻyin.

Dasturiy taʼminotsiz apparat hech narsa qilmaydigan qutidan boshqa narsa emas. Apparatsiz esa dasturiy taʼminot ishlaydigan joy yoʻq. Ikkalasi ham kerak.

## Asosiy apparat qismlari

| Qism | Vazifasi | Oddiy taqqoslash |
| --- | --- | --- |
| **CPU** (markaziy protsessor) | Koʻrsatmalarni bajaradi — “fikrlovchi” qism | Retsept boʻyicha ovqat tayyorlayotgan oshpaz |
| **RAM** (operativ xotira) | Ayni *hozir* ishlayotgan narsangizni ushlab turadi | Oshpazning ish stoli |
| **Doimiy xotira** (SSD yoki qattiq disk) | Elektr oʻchganda ham fayllar va ilovalarni saqlaydi | Oziq-ovqat omborxonasi |
| **GPU** (grafik protsessor) | Tasvir, video va 3D grafikani tez chizadi | Shirinliklarga ixtisoslashgan oshpaz |
| **Ona plata** (tizim platasi) | Barcha qismlarni bir-biri bilan bogʻlaydi | Oshxonaning oʻzi |
| **Quvvat bloki / batareya** | Elektr energiyasi bilan taʼminlaydi | Gaz quvuri |

> [!NOTE]
> **RAM vaqtinchalik xotira.** Elektr oʻchganda faqat RAMda turgan maʼlumot yoʻqoladi. Ishingizni aynan shuning uchun *saqlaysiz* — saqlash uni RAMdan doimiy xotiraga koʻchiradi.

## Dasturiy taʼminot turlari

- **Operatsion tizim (OT)** — apparatni boshqaradigan va qolgan barcha dasturlarni ishga tushiradigan asosiy dastur. Misollar: Windows, macOS, Linux, Android, iOS.
- **Ilovalar** — biror vazifani bajarishga yordam beradigan dasturlar: brauzer, fotomuharrir, messenjer.
- **Drayverlar** — operatsion tizimga muayyan qurilma, masalan, printer bilan “gaplashish” imkonini beradigan kichik dasturlar.

## Bit va baytlar

Kompyuter ichida barcha maʼlumot — matn, fotosurat, musiqa — faqat ikki raqam, **0** va **1** dan tashkil topgan sonlar koʻrinishida saqlanadi. Bunday bitta raqam **bit** deyiladi.

- 8 bit = 1 **bayt** (“A” kabi bitta oddiy harfni saqlashga yetadi)
- taxminan 1 000 bayt = 1 **kilobayt (KB)**
- taxminan 1 000 KB = 1 **megabayt (MB)** — oddiy fotosurat bir necha MB boʻladi
- taxminan 1 000 MB = 1 **gigabayt (GB)** — film bir necha GB boʻladi
- taxminan 1 000 GB = 1 **terabayt (TB)**

> [!TIP]
> Kompyuter sotib olayotganda *doimiy xotira* (masalan, 512 GB SSD) qancha narsa saqlay olishingizni, *RAM* (masalan, 16 GB) esa bir vaqtning oʻzida qancha narsa bilan ishlay olishingizni bildiradi.$md$);

  perform seed.tr_lesson(c, 'Check your understanding', 'uz', 'Bilimingizni tekshiring',
    'Kompyuterlar, apparat va dasturiy taʼminot boʻyicha beshta qisqa savol.', null);
  perform seed.tr_quiz(c, 'Module 1 check', 'uz', '1-modul boʻyicha test');

  perform seed.tr_question(c, 'Module 1 check', 0, 'uz',
    'Siz xabar yozib, **Yuborish** tugmasini bosasiz. Xabarni *yozish* toʻrt vazifaning qaysi biri?',
    'Yozish orqali siz kompyuterga maʼlumot **berasiz**, shuning uchun bu kiritish.',
    array['Kiritish', 'Qayta ishlash', 'Saqlash', 'Chiqarish'],
    array['Toʻgʻri — siz kompyuterga maʼlumot beryapsiz.',
          'Qayta ishlash — bu siz maʼlumot kiritishingiz emas, kompyuterning maʼlumot ustida ishlashi.',
          'Saqlash — maʼlumotni keyinroq foydalanish uchun saqlab qoʻyish.',
          'Chiqarish — kompyuterdan *chiqayotgan* maʼlumot.']);

  perform seed.tr_question(c, 'Module 1 check', 1, 'uz',
    'Qaysi qism ayni hozir ishlayotgan narsangizni vaqtincha ushlab turadi va elektr oʻchganda tozalanadi?',
    'RAM — tezkor, vaqtinchalik ishchi xotira. Doimiy xotira esa fayllarni uzoq muddat saqlaydi.',
    array['Doimiy xotira (SSD)', 'RAM', 'GPU', 'Quvvat bloki'],
    array['SSD elektr boʻlmaganda ham maʼlumotni saqlaydi.',
          'Ha — saqlanmagan ish shuning uchun yoʻqolishi mumkin.',
          'GPU grafikani chizadi; u umumiy ishchi xotira emas.',
          'Quvvat bloki xotira emas, elektr energiyasini beradi.']);

  perform seed.tr_question(c, 'Module 1 check', 2, 'uz',
    'Dasturiy taʼminotga tegishli **barcha** variantlarni belgilang.',
    'Dasturiy taʼminot — bu koʻrsatmalar. Windows va veb-brauzer dasturlardir; klaviatura va monitor esa jismoniy apparat qismlari.',
    array['Windows', 'Veb-brauzer', 'Klaviatura', 'Monitor'],
    array[null, null,
          'Klaviatura — jismoniy kiritish qurilmasi, yaʼni apparat.',
          'Monitor — jismoniy chiqarish qurilmasi, yaʼni apparat.']);

  perform seed.tr_question(c, 'Module 1 check', 3, 'uz',
    'Toʻgʻrimi yoki notoʻgʻri: 1 bayt 8 bitdan iborat.',
    'Bayt — 8 bitdan iborat guruh.',
    array['Toʻgʻri', 'Notoʻgʻri'],
    array[null, 'Bu toʻgʻri — 8 bit bitta baytni tashkil qiladi.']);

  perform seed.tr_question(c, 'Module 1 check', 4, 'uz',
    'Qaysi biri eng katta hajm?',
    'KB < MB < GB < TB. Har bir keyingi birlik taxminan 1 000 marta katta.',
    array['500 MB', '2 GB', '1 TB', '900 KB'],
    array[null, null, 'Toʻgʻri — bir terabayt taxminan 1 000 gigabaytga teng.', null]);

  perform seed.tr_lesson(c, 'Files, folders and paths', 'uz', 'Fayllar, papkalar va yoʻllar',
    'Fayllarni toʻgʻri nomlang, papkalarga joylang va fayl yoʻlini koʻcha manzili kabi oʻqing.',
$md$## Fayl nima?

**Fayl** — nomga ega boʻlgan, saqlangan bitta maʼlumot birligi: hujjat, fotosurat, qoʻshiq yoki dastur. Fayllar doimiy xotirada (SSD yoki qattiq diskda, fleshkada yoki bulutda) joylashadi.

Koʻpchilik fayl nomlari nuqta va bir nechta harf bilan tugaydi, masalan, `hisobot.pdf` yoki `dam-olish.jpg`. Ana shu oxirgi qism **fayl kengaytmasi** deyiladi. U kompyuterga faylning turini va uni qaysi ilova ochishi kerakligini bildiradi.

| Kengaytma | Fayl turi |
| --- | --- |
| `.pdf` | Har qanday qurilmada bir xil koʻrinadigan hujjat |
| `.docx` | Word hujjati |
| `.jpg`, `.png` | Tasvir |
| `.mp4` | Video |
| `.mp3` | Audio |
| `.zip` | Bitta faylga siqilgan bir nechta fayl |

> [!WARNING]
> `rasm.jpg` faylini `rasm.mp4` deb qayta nomlash fotosuratni videoga **aylantirmaydi**. Bu faqat kompyuterni qaysi ilovadan foydalanish kerakligi borasida chalgʻitadi.

## Papkalar

**Papka** (yoki *katalog*, *direktoriya*) — fayllar va boshqa papkalar uchun idish. Papka ichidagi papkalar daraxtsimon tuzilmani hosil qiladi:

```text
Documents
├── Maktab
│   ├── matematika-uy-vazifasi.pdf
│   └── insho.docx
└── Ish
    └── hisob-faktura-mart.pdf
```

## Yoʻl: faylning manzili

**Yoʻl** (inglizcha *path*) — faylning toʻliq manzili, yaʼni unga yetib borish uchun oʻtadigan barcha papkalar.

- **Windows**da: `C:\Users\Aziza\Documents\Maktab\insho.docx`
- **macOS** va **Linux**da: `/Users/aziza/Documents/Maktab/insho.docx`

Uni manzil kabi chapdan oʻngga oʻqing: disk yoki ildiz → foydalanuvchi → papka → ichki papka → fayl. Windows papkalar orasida teskari qiya chiziq `\`, macOS va Linux esa toʻgʻri qiya chiziq `/` ishlatadi. `Users` va `Documents` kabi tizim papkalari koʻpincha inglizcha nom bilan qoladi.

> [!TIP]
> Mutaxassislar amal qiladigan foydali odatlar:
> - Aniq nom bering: `hisob-faktura-2026-03.pdf` nomi `skan1 yakuniy YAKUNIY.pdf` dan ancha yaxshi.
> - Fayllar tartib bilan saralanishi uchun sanani `YYYY-MM-DD` (yil-oy-kun) koʻrinishida yozing.
> - Kodda yoki internetda ishlatiladigan fayllar nomida boʻsh joy va maxsus belgilardan qoching.
> - Muhim fayllarning zaxira nusxasini boshqa joyda ham saqlang.$md$);

  perform seed.tr_lesson(c, 'Installing and removing software safely', 'uz', 'Dasturlarni xavfsiz oʻrnatish va oʻchirish',
    'Ilovalarni qayerdan yuklab olish, oʻrnatuvchilar qanday ishlashi va dasturni toʻliq oʻchirish.', null);
  perform seed.tr_lesson(c, 'Backups and the cloud', 'uz', 'Zaxira nusxalar va bulut',
    '3-2-1 zaxiralash qoidasi va bulutli xotira qanday ishlashi.', null);

  perform seed.tr_lesson(c, 'Final assessment', 'uz', 'Yakuniy imtihon',
    'Butun kursni qamrab oluvchi qisqa imtihon. Oʻtish balli: 70%.', null);
  perform seed.tr_quiz(c, 'Computer Fundamentals — final assessment', 'uz', 'Kompyuter asoslari — yakuniy imtihon');

  perform seed.tr_question(c, 'Computer Fundamentals — final assessment', 0, 'uz',
    'Qaysi dasturiy taʼminot apparatni boshqaradi va boshqa barcha dasturlarni ishga tushiradi?',
    'Operatsion tizim (Windows, macOS, Linux, Android, iOS) apparat va ilovalar oʻrtasida turadi.',
    array['Veb-brauzer', 'Operatsion tizim', 'Drayver'],
    array['Brauzer — operatsion tizim *ustida* ishlaydigan ilova.',
          null,
          'Drayver operatsion tizimga bitta qurilma bilan aloqa qilishga yordam beradi; u hamma narsani ishga tushirmaydi.']);

  perform seed.tr_question(c, 'Computer Fundamentals — final assessment', 1, 'uz',
    '`yozgi-sayohat.mp4` faylining kengaytmasi qanday? (nuqtasiz, faqat harflarni yozing)',
    'Kengaytma — oxirgi nuqtadan keyingi qism: **mp4**. U video faylni bildiradi.',
    array['mp4', '.mp4']);

  perform seed.tr_question(c, 'Computer Fundamentals — final assessment', 2, 'uz',
    '`/Users/aziza/Documents/Maktab/insho.docx` yoʻlida faylni bevosita qaysi papka oʻz ichiga oladi?',
    'Yoʻlni chapdan oʻngga oʻqing — fayl nomidan oldingi oxirgi papka uni oʻz ichiga oladi.',
    array['Users', 'Documents', 'Maktab'],
    array[null, 'Documents ichida Maktab papkasi bor, fayl esa Maktab papkasida joylashgan.', null]);

  perform seed.tr_question(c, 'Computer Fundamentals — final assessment', 3, 'uz',
    'Quyidagilardan qaysilari **chiqarish**ga misol boʻladi?',
    'Chiqarish — kompyuterdan ekran, karnay yoki printer orqali chiqayotgan maʼlumot.',
    array['Karnaydan yangrayotgan musiqa', 'Printerdan chiqayotgan sahifa', 'Mikrofonga gapirish', 'Hujjatni skanerlash'],
    array[null, null, 'Bu kiritish.', 'Skaner maʼlumotni kompyuterga yuboradi — bu kiritish.']);
end $tr$;
