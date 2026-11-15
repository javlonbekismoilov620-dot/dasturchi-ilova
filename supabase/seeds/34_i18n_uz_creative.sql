-- Oʻzbekcha tarjima: Blender, video montaj, Unreal Engine, dizayn tamoyillari,
-- tayyorlanayotgan kurslar va oʻquv yoʻnalishlari.
-- Blender, Unreal Engine va montaj dasturlarida oʻzbekcha interfeys yoʻq, shuning uchun
-- menyu va panel nomlari asl (inglizcha) holida qoldirilib, oʻzbekcha izoh beriladi.

do $tr$
declare
  c constant text := 'blender-first-steps-in-3d';
begin
  perform seed.tr_course(c, 'uz', 'Blender: 3D olamidagi ilk qadamlar',
    '“3D nima?” degan savoldan birinchi sahnangizda bemalol harakatlanishgacha',
    $d$Blender — 3D modellashtirish, animatsiya, vizual effektlar va rendering uchun ishlatiladigan bepul, ochiq kodli dastur. Undan havaskorlar ham, professional studiyalar ham foydalanadi.

Bu kurs Blenderdan oldin boshlanadi: avval **3D aslida nima ekanini** tushunib olasiz. Keyin Blenderni oʻrnatasiz, uning interfeysini oʻrganasiz hamda obyektlarni mutaxassislar ishlatadigan tezkor tugmalar yordamida siljitish, aylantirish va masshtablashni oʻrganasiz.$d$,
    array['Uchlar, qirralar, yoqlar hamda X/Y/Z oʻqlarini tushuntira olasiz',
          'Blenderni oʻrnatib, interfeysning asosiy qismlarini aniqlay olasiz',
          '3D koʻrinish maydonida sichqoncha, klaviatura va navigatsiya gizmosi yordamida harakatlanasiz',
          'Obyektlarni aniq qoʻshasiz, siljitasiz, aylantirasiz va masshtablaysiz'],
    array['Alohida yoki yangi avlod integratsiyalashgan grafik protsessorga ega kompyuter',
          'Uch tugmali sichqoncha tavsiya etiladi']);

  perform seed.tr_module(c, 'Understanding 3D', 'uz', '3D ni tushunish',
    'Har bir 3D tasvir va film ortidagi gʻoyalar.');
  perform seed.tr_module(c, 'Moving around and basic objects', 'uz', 'Sahnada harakatlanish va oddiy obyektlar',
    'Navigatsiya va transformatsiyalar — har daqiqada foydalanadigan koʻnikmalaringiz.');
  perform seed.tr_module(c, 'Your first render', 'uz', 'Birinchi renderingiz',
    'Materiallar, yorugʻlik manbai va kamera.');

  perform seed.tr_lesson(c, 'What is 3D?', 'uz', '3D nima?',
    'Fazo, oʻqlar va har qanday 3D obyektning qurilish bloklari.',
$md$## Uchta yoʻnalish

Qogʻozdagi rasm **2D** (ikki oʻlchamli): uning eni va boʻyi bor. Haqiqiy dunyo esa **3D** (uch oʻlchamli): unda chuqurlik ham mavjud. 3D fazodagi istalgan nuqtani tasvirlash uchun har bir yoʻnalish boʻyicha bittadan — jami uchta son kerak. Bu yoʻnalishlar **oʻqlar** deb ataladi:

- **X** — chap ↔ oʻng
- **Y** — old ↔ orqa
- **Z** — yuqori ↔ past

> [!NOTE]
> Blenderda **Z oʻqi yuqoriga qaragan**. Baʼzi boshqa dasturlar “yuqori” sifatida Y oʻqini ishlatadi — bu modellarni bir dasturdan boshqasiga koʻchirganda muhim.

## 3D obyekt nimalardan tashkil topgan

Aksariyat 3D obyektlar **mesh** (*mesh* — sirt toʻri) hisoblanadi, yaʼni uchta oddiy qismdan qurilgan sirtlar:

- **Uch** (*vertex*, koʻplikda *vertices*) — fazodagi bitta nuqta.
- **Qirra** (*edge*) — ikki uchni tutashtiruvchi toʻgʻri chiziq.
- **Yoq** (*face*) — qirralar bilan chegaralangan, odatda uch yoki toʻrt tomonli tekis sirt.

Kubning 8 ta uchi, 12 ta qirrasi va 6 ta yogʻi bor. Hatto juda batafsil personaj ham “bor-yoʻgʻi” shunday elementlarning minglab nusxalaridan iborat.

## Modeldan tasvirgacha

3D tasvir yaratish quyidagi jarayon (*pipeline*) asosida boradi — uni Mahorat kurslarida bosqichma-bosqich oʻrganasiz:

1. **Modellashtirish** — shaklni qurish.
2. **Materiallar va teksturalash** — sirtlar qanday koʻrinishini belgilash: metall, yogʻoch, teri.
3. **Yoritish** — xuddi kino suratga olish maydonidagidek yorugʻlik manbalarini joylashtirish.
4. **Kamera** — tomoshabin nimani koʻrishini tanlash.
5. **Rendering** — kompyuter yuqoridagilarning barchasidan yakuniy tasvirni hisoblab chiqadi.

Bunga **animatsiya**ni — vaqt oʻtishi bilan narsalarni oʻzgartirishni — qoʻshsangiz, filmlar va oʻyinlar yaratishingiz mumkin.$md$);

  perform seed.tr_lesson(c, 'What is Blender?', 'uz', 'Blender nima?',
    'Istalgan kishi bepul yuklab olishi mumkin boʻlgan toʻliq 3D studiya.',
$md$## Toʻliq 3D studiya

**Blender** — Blender Foundation (Blender jamgʻarmasi) va butun dunyodagi hamjamiyat tomonidan ishlab chiqilayotgan bepul va ochiq kodli 3D yaratish dasturlari toʻplami. “Ochiq kodli” degani — uning kodi ochiq va undan istalgan kishi shaxsiy yoki tijoriy ishlar uchun pul toʻlamasdan foydalanishi mumkin.

Blender butun jarayonni bitta dasturda qamrab oladi:

- modellashtirish va skulpting (raqamli haykaltaroshlik)
- materiallar, teksturalash va UV yoyish
- ikkita dvigatel yordamida yoritish va rendering: **EEVEE** (tezkor, real vaqt rejimida) va **Cycles** (fizik jihatdan aniq)
- animatsiya va riglash
- tutun, suyuqlik va mato kabi simulyatsiyalar
- video montaj va kompozitsiya (*compositing*)

## Undan kimlar foydalanadi?

Mustaqil rassomlar, oʻyin ishlab chiquvchilar, mahsulot dizaynerlari, arxitektorlar va animatsiya studiyalari. Blenderda oʻrganadigan koʻnikmalaringiz — topologiya, yoritish va kompozitsiya kabilar — boshqa har qanday 3D dasturga ham koʻchadi.

> [!TIP]
> Blender tez-tez yangilanadi va menyular versiyadan versiyaga joyini oʻzgartiradi. Koʻrsatmalar ekraningizga mos kelmasa, ochilish oynasidagi versiya raqamini va docs.blender.org manzilidagi rasmiy qoʻllanmani tekshiring.$md$);

  perform seed.tr_lesson(c, 'Installing Blender and the interface', 'uz', 'Blenderni oʻrnatish va interfeys',
    'Blenderni rasmiy manbadan oling va beshta asosiy qismni oʻrganing.',
$md$## Oʻrnatish

1. **blender.org** saytiga kiring va **Download** sahifasini oching.
2. Tizimingizga mos versiyani yuklab oling (Windows, macOS — Apple Silicon yoki Intel protsessorli variantni tanlang — yoki Linux).
3. Oʻrnatuvchini ishga tushiring, soʻngra Blenderni oching.

> [!WARNING]
> Blenderni faqat blender.org saytidan (yoki Steam va Microsoft Store kabi rasmiy doʻkonlardan) yuklab oling. U bepul — toʻlov soʻraydigan har qanday sayt rasmiy emas.

## Standart sahna

Blender **kub**, **kamera** va **yorugʻlik manbai** bilan ochiladi. Bu — tajriba qilishingiz uchun tayyor turgan standart sahna.

## Beshta asosiy qism

1. **3D Viewport** (3D koʻrinish maydoni) — sahnangizni koʻradigan va tahrirlaydigan katta markaziy maydon.
2. **Outliner** (oʻng yuqorida) — sahnadagi barcha obyektlar roʻyxati, xuddi mundarija kabi.
3. **Properties Editor** (xususiyatlar paneli, oʻng pastda) — tanlangan obyekt, uning materiali, render va boshqalar uchun sozlamalar; ular yorliqlarga ajratilgan.
4. **Timeline** (vaqt shkalasi, pastda) — vaqt boʻyicha animatsiyani boshqarish.
5. **Toolbar** (asboblar paneli, koʻrinish maydonining chap tomonida) — Select, Move, Rotate va Scale kabi asboblar.

Yuqori qismda **ish maydonlari** (*workspaces*: Layout, Modeling, Sculpting, Shading…) joylashgan. Ularning har biri muayyan ish uchun oldindan tayyorlangan oynalar toʻplami.

> [!TIP]
> Deyarli istalgan tugma ustiga kursorni olib borib, biroz kuting — Blender u nima qilishini tushuntiruvchi qisqa izoh koʻrsatadi.$md$);

  perform seed.tr_lesson(c, 'Navigating the 3D viewport', 'uz', '3D koʻrinish maydonida harakatlanish',
    'Sahnani bemalol aylantiring, suring va yaqinlashtiring.',
$md$## Uchta asosiy harakat

| Harakat | Sichqoncha | Nima qiladi |
| --- | --- | --- |
| **Orbit** (aylantirish) | **Sichqonchaning oʻrta tugmasini** bosib turib torting | Koʻrinishni sahna atrofida aylantiradi |
| **Pan** (surish) | **Shift** + oʻrta tugmani bosib torting | Koʻrinishni yon tomonga suradi |
| **Zoom** (yaqinlashtirish) | Gʻildirakni aylantiring | Yaqinlashtiradi yoki uzoqlashtiradi |

## Foydali koʻrinishlar (raqamli klaviatura)

- **1** — old tomon, **3** — oʻng tomon, **7** — yuqoridan
- **Ctrl** + oʻsha tugma — qarama-qarshi tomon
- **0** — kamera orqali qarash
- Raqamli klaviaturadagi **.** (nuqta) — tanlangan obyektni ekranga sigʻdirish

Raqamli klaviatura yoʻqmi? Koʻrinishlarning doiraviy menyusini ochish uchun **` (backtick)** tugmasini bosing yoki koʻrinish maydonining oʻng yuqori burchagidagi **navigatsiya gizmosi**dagi oʻqlarni bosing.

> [!TIP]
> Oʻrta tugmasi yoʻq noutbukdan foydalanyapsizmi? **Edit → Preferences → Input** boʻlimini oching va **Emulate 3 Button Mouse** parametrini yoqing. Shundan soʻng **Alt + chap tugma bilan tortish** koʻrinishni aylantiradi.

## Adashib qoldingizmi?

Hamma narsani ekranga sigʻdirish uchun **Home** tugmasini bosing.$md$);

  perform seed.tr_lesson(c, 'Basic objects: add, move, rotate, scale', 'uz', 'Oddiy obyektlar: qoʻshish, siljitish, aylantirish, masshtablash',
    'G, R, S tezkor tugmalari va oʻq boʻyicha cheklash.',
$md$## Obyekt qoʻshish

**Add** menyusini ochish uchun koʻrinish maydonida **Shift + A** tugmalarini bosing. **Mesh → UV Sphere** ni tanlang. Yangi obyektlar **3D kursor** (qizil-oq halqa) turgan joyda paydo boʻladi.

## Transformatsiya

Obyektni sichqonchaning chap tugmasi bilan bosib tanlang, soʻngra:

| Tugma | Amal |
| --- | --- |
| **G** | Grab — siljitish |
| **R** | Rotate — aylantirish |
| **S** | Scale — masshtablash |

Sichqonchani harakatlantiring, keyin tasdiqlash uchun **chap tugmani**, bekor qilish uchun **oʻng tugmani** (yoki Esc) bosing.

## Oʻq boʻyicha cheklash

G, R yoki S tugmasidan keyin oʻzgarishni faqat bitta oʻq boʻyicha cheklash uchun **X**, **Y** yoki **Z** ni bosing. Son ham kiritishingiz mumkin:

- **G Z 2** → 2 metr yuqoriga siljitish
- **R X 90** → X oʻqi atrofida 90° aylantirish
- **S 0.5** → yarim oʻlchamgacha kichraytirish

## Bekor qilish va yon panel

- **Ctrl + Z** amalni bekor qiladi, **Ctrl + Shift + Z** esa qaytaradi.
- **N** tugmasi **yon panel**ni (*sidebar*) ochadi — unda Location (joylashuv), Rotation (burilish) va Scale (masshtab) qiymatlarini aniq kiritish mumkin.

## Mashq

Standart kubni oʻchiring (**X → Delete**), soʻngra oddiy qorbobo yasang: oʻlchami kichrayib boruvchi uchta UV sferani Z oʻqi boʻylab ustma-ust qoʻying va burun uchun X oʻqi atrofida 90° burilgan konus qoʻshing.$md$);

  perform seed.tr_lesson(c, 'Module quiz', 'uz', 'Modul testi',
    '3D va navigatsiya asoslarini tekshiring.', null);
  perform seed.tr_quiz(c, 'Blender basics quiz', 'uz', 'Blender asoslari testi');
  perform seed.tr_question(c, 'Blender basics quiz', 0, 'uz',
    'Blenderda qaysi oʻq **yuqoriga** qaragan?',
    'Blenderda Z oʻqi yuqoriga qaragan.',
    array['X', 'Y', 'Z'],
    array[null, 'Baʼzi boshqa dasturlarda Y oʻqi yuqoriga qaragan — Blenderda emas.', null]);
  perform seed.tr_question(c, 'Blender basics quiz', 1, 'uz',
    'Kubning nechta yogʻi bor?',
    'Kubning 6 ta yogʻi, 12 ta qirrasi va 8 ta uchi bor.',
    array['6', '8', '12'],
    array[null, '8 — uchlar soni.', '12 — qirralar soni.']);
  perform seed.tr_question(c, 'Blender basics quiz', 2, 'uz',
    'Obyektni X oʻqi atrofida aynan 90° aylantirmoqchisiz. Nimani yozasiz?',
    'R aylantirishni boshlaydi, X oʻqni cheklaydi, 90 — burchak.',
    array['G X 90', 'R X 90', 'S X 90'],
    array['G obyektni siljitadi.', null, 'S obyektni masshtablaydi.']);
  perform seed.tr_question(c, 'Blender basics quiz', 3, 'uz',
    'Qaysi tezkor tugmalar Add menyusini ochadi?',
    'Koʻrinish maydonida **Shift + A** Add menyusini ochadi.',
    array['Shift + A', 'Ctrl + A', 'N'],
    array[null, 'Ctrl + A — Apply menyusini ochadi.', 'N yon panelni ochadi va yopadi.']);

  perform seed.tr_lesson(c, 'Giving objects a material', 'uz', 'Obyektlarga material berish',
    'Asosiy rang, gʻadir-budurlik (roughness) va metallik.', null);
  perform seed.tr_lesson(c, 'Lighting and rendering your first image', 'uz', 'Yoritish va birinchi tasviringizni render qilish',
    'EEVEE va Cycles farqi hamda PNG faylni saqlash.', null);
end $tr$;

do $tr$
declare
  c constant text := 'video-editing-fundamentals';
begin
  perform seed.tr_course(c, 'uz', 'Video montaj asoslari',
    'Montajning universal tili — istalgan dasturda',
    $d$Biror montaj dasturini oʻrganishdan oldin **montajning oʻzini** oʻrganing. Bu kursdagi tushunchalar — kliplar, vaqt shkalasi, kesishlar, kadrlar chastotasi va ish jarayoni — Premiere Pro, DaVinci Resolve, Final Cut Pro va CapCut uchun birdek amal qiladi.$d$,
    array['Montajchi nima ish qilishini va kesishlar nega ishlashini tushuntira olasiz',
          'Video va audio treklari boʻlgan vaqt shkalasini oʻqiy olasiz',
          'Loyiha uchun ruxsat, kadrlar chastotasi va tomonlar nisbatini tanlay olasiz',
          'Importdan eksportgacha boʻlgan professional montaj jarayoniga amal qilasiz'],
    array['Talab qilinmaydi']);

  perform seed.tr_module(c, 'The craft of editing', 'uz', 'Montaj hunari',
    'Har bir montajchi foydalanadigan gʻoyalar.');

  perform seed.tr_lesson(c, 'What video editing really is', 'uz', 'Video montaj aslida nima',
    'Hikoya aytish uchun lavhalarni tanlash, tartiblash va vaqtini belgilash.',
$md$## Montaj — bu hikoyachilik

**Video montaj** — yozib olingan materialdan eng yaxshi lahzalarni tanlab, ularni hikoya aytadigan yoki xabar yetkazadigan tarzda tartiblash va davomiyligini belgilash. Montajchi tomoshabin nimani, qancha vaqt va qanday ketma-ketlikda koʻrishini hal qiladi.

Tayyor ikki daqiqalik video bir soatlik materialdan yigʻilgan boʻlishi mumkin. Montajning katta qismi — **nimani tashlab yuborishni tanlash**.

## Asosiy atamalar

- **Footage** (xom material) — yozib olingan, ishlov berilmagan video.
- **Klip** — loyihangizga joylashtirilgan bitta material boʻlagi.
- **Lavha** (*shot*, plan) — bitta kamera rakursidan uzluksiz yozib olingan qism.
- **Kesish** (*cut*) — bir lavha tugab, keyingisi boshlanadigan nuqta.
- **Ketma-ketlik** (*sequence*) — tartib bilan joylashtirilgan kliplar toʻplami.

## Kesishlar nega ishlaydi

Miyamiz kesishlarni tabiiy qabul qiladi, chunki atrofga qaraganimizda diqqatimizni daqiqasiga koʻp marta “kesib” turamiz. Yaxshi kesish koʻpincha sezilmaydi: tomoshabin hikoyani kuzatadi va montajni payqamaydi.

> [!TIP]
> Sevimli filmingizdagi bir sahnani ovozsiz tomosha qiling va kesishlarni sanang. Kutganingizdan ancha koʻp kesish borligini — va ularning aksariyati sezilmaganini payqaysiz.$md$);

  perform seed.tr_lesson(c, 'The timeline, clips and cuts', 'uz', 'Vaqt shkalasi, kliplar va kesishlar',
    'Treklar, kadrlar chastotasi, ruxsat va eng foydali kesish turlari.',
$md$## Vaqt shkalasi

Har bir montaj dasturida **vaqt shkalasi** (*timeline*) bor: vaqt chapdan oʻngga oqadi, kliplar esa gorizontal **treklar**da joylashadi.

- **Video treklar** ustma-ust joylashadi: yuqoridagi treklar pastdagilarning *ustida* koʻrinadi (titrlar va ustki qatlamlar uchun qulay).
- **Audio treklar** pastda joylashadi va birgalikda ijro etiladi.

**Ijro kursori** (*playhead*) — joriy kadrni belgilovchi vertikal chiziq.

## Loyiha sozlamalari

| Sozlama | Keng tarqalgan qiymatlar | Maʼnosi |
| --- | --- | --- |
| **Ruxsat** (*resolution*) | 1920×1080 (Full HD), 3840×2160 (4K) | Har bir kadrdagi piksellar soni |
| **Kadrlar chastotasi** (*frame rate*) | 24, 25, 30, 60 fps | Bir soniyada koʻrsatiladigan tasvirlar soni |
| **Tomonlar nisbati** (*aspect ratio*) | 16:9 (gorizontal), 9:16 (vertikal), 1:1 | Kadrning shakli |

> [!NOTE]
> Kadrlar chastotasini ishni boshlashdan oldin tanlang va butun loyiha davomida oʻzgartirmang. 24 fps kinematografik taassurot beradi, 25 fps koʻplab mamlakatlarda televideniye uchun odatiy, 60 fps esa sport va oʻyinlar uchun silliq harakat beradi.

## Kesish turlari

- **Toʻgʻridan-toʻgʻri kesish** (*hard cut*) — bir lavhadan keyingisiga toʻgʻridan-toʻgʻri oʻtish. Eng koʻp ishlatiladigan montaj usuli.
- **Jump cut** (sakrash) — bitta lavha ichida vaqtni tashlab oʻtuvchi kesish; vloglarda mashhur.
- **J-cut** — keyingi lavhaning *ovozi* uning tasviridan oldin boshlanadi.
- **L-cut** — joriy lavhaning ovozi keyingi lavha tasviri ustida davom etadi.
- **Cutaway** (chetga burilish) — asosiy lavhaga qaytishdan oldin qisqa vaqt boshqa narsani (detal, reaksiya) koʻrsatish.

## Professional ish jarayoni

1. **Tartiblash** — materialni import qiling va papkalarga (*bins*) nomlab joylang.
2. **Yigʻish** (*assembly*) — yaroqli lavhalarni taxminiy tartibda joylashtiring.
3. **Qoralama montaj** (*rough cut*) — hikoyani shakllantiring, tuzilmani toʻgʻri yoʻlga qoʻying.
4. **Yakuniy montaj** (*fine cut*) — har bir kesishning vaqtini mukammallashtiring.
5. **Rang va ovoz** — rang korreksiyasi, rang tusini berish va ovozni aralashtirish.
6. **Eksport** — yakuniy faylni u moʻljallangan joy uchun render qiling.$md$);

  perform seed.tr_lesson(c, 'Check your understanding', 'uz', 'Bilimingizni tekshiring',
    'Montaj atamalari va sozlamalari.', null);
  perform seed.tr_quiz(c, 'Editing fundamentals quiz', 'uz', 'Montaj asoslari testi');
  perform seed.tr_question(c, 'Editing fundamentals quiz', 0, 'uz',
    'Keyingi lavhaning ovozi uning tasviri paydo boʻlishidan **oldin** boshlanadi. Bu nima?',
    'J-cut: vaqt shkalasida audio va video J harfi shaklini hosil qiladi.',
    array['L-cut', 'J-cut', 'Jump cut'],
    array['L-cut usulida *joriy* lavhaning ovozi keyingi tasvir ustida davom etadi.', null, 'Jump cut bitta lavha ichida vaqtni tashlab oʻtadi.']);
  perform seed.tr_question(c, 'Editing fundamentals quiz', 1, 'uz',
    'Telefondagi vertikal videolar uchun qaysi tomonlar nisbati standart hisoblanadi?',
    '9:16 — vertikal; 16:9 — gorizontal.',
    array['16:9', '9:16', '4:3']);
  perform seed.tr_question(c, 'Editing fundamentals quiz', 2, 'uz',
    'Toʻgʻrimi yoki notoʻgʻri: aksariyat montaj dasturlarida yuqoridagi video trekdagi klip pastdagi kliplar ustida koʻrinadi.',
    'Yuqoridagi video treklar pastdagilarning ustiga qatlam sifatida tushadi.',
    array['Toʻgʻri', 'Notoʻgʻri']);
end $tr$;

do $tr$
declare
  c constant text := 'unreal-engine-fundamentals';
begin
  perform seed.tr_course(c, 'uz', 'Unreal Engine asoslari',
    'Oʻyin dvigatellarini tushuning va Unreal Editor’da yoʻlingizni toping',
    $d$Unreal Engine — oʻyinlar, filmlar, arxitektura va simulyatsiyalar uchun ishlatiladigan professional real vaqt 3D dvigateli. Bu kurs oʻyin dvigateli nima ekanini, Unreal Engine’ni qanday xavfsiz oʻrnatishni va muharrir qanday tuzilganini tushuntiradi — bu keyingi barcha Unreal kurslari uchun poydevor.$d$,
    array['Oʻyin dvigateli nimalarni taqdim etishini tushuntira olasiz',
          'Unreal Engine’ni Epic Games Launcher orqali oʻrnata olasiz',
          'Muharrirda harakatlanasiz: Viewport, Outliner, Details va Content Drawer'],
    array['“Kompyuter asoslari: noldan boshlab” kursi', 'Yetarlicha quvvatli kompyuter (2-darsga qarang)']);

  perform seed.tr_module(c, 'Getting started', 'uz', 'Ishni boshlash',
    'Dvigatellar, oʻrnatish va muharrir.');

  perform seed.tr_lesson(c, 'What is a game engine?', 'uz', 'Oʻyin dvigateli nima?',
    'Jamoalarni yillik mehnatdan qutqaradigan umumiy poydevor.',
$md$## Noldan boshlamaslik

Har bir oʻyin tasvirlarni chizishi, tovushlarni ijro etishi, boshqaruv qurilmasini oʻqishi, fizikani simulyatsiya qilishi va darajalarni yuklashi kerak. Bularning barchasini noldan yozish yillar talab qiladi. **Oʻyin dvigateli** (*game engine*) — shu tizimlarni taqdim etadigan tayyor poydevor; u yaratuvchilarga *oʻz* oʻyiniga eʼtibor qaratish imkonini beradi.

## Dvigatel odatda nimalarni taqdim etadi

- **Rendering** — 3D olamlarni real vaqtda, soniyasiga koʻp marta chizish.
- **Fizika** — tortishish kuchi, toʻqnashuvlar, yiqiladigan va sakraydigan obyektlar.
- **Kiritish** — klaviatura, sichqoncha, geympad va sensorli ekran.
- **Audio** — fazoviy tovush va musiqa.
- **Skriptlash** — oʻyin qoidalari va xatti-harakatlarini tavsiflash usullari.
- **Vositalar** — darajalar qurish va resurslarni boshqarish uchun muharrir.

## Aynan Unreal Engine haqida

Unreal Engine’ni Epic Games kompaniyasi ishlab chiqadi. 5-versiyada **Nanite** (juda batafsil geometriya) va **Lumen** (dinamik global yoritish) kabi tizimlar paydo boʻldi. Xatti-harakatlarni tugunlarga asoslangan vizual tizim — **Blueprints** yordamida qurish yoki **C++** tilida yozish mumkin.

> [!NOTE]
> Unreal Engine’ni yuklab olish va oʻrganish bepul. Tijoriy mahsulotlar esa Epic litsenziya shartlariga boʻysunadi — mahsulot chiqarishdan oldin har doim unrealengine.com saytidagi amaldagi EULA (litsenziya kelishuvi)ni oʻqing.$md$);

  perform seed.tr_lesson(c, 'Installing Unreal Engine', 'uz', 'Unreal Engine’ni oʻrnatish',
    'Tizim talablari, Epic Games Launcher va birinchi loyihangiz.', null);
  perform seed.tr_lesson(c, 'A tour of the editor', 'uz', 'Muharrir boʻylab sayohat',
    'Viewport, Outliner, Details paneli va Content Drawer.', null);
end $tr$;

do $tr$
declare
  c constant text := 'design-principles-from-zero';
begin
  perform seed.tr_course(c, 'uz', 'Dizayn tamoyillari: noldan boshlab',
    'Nega baʼzi dizaynlar yengil va tabiiy tuyuladi — va oʻzingiznikini qanday shunday qilish mumkin',
    $d$Yaxshi dizayn — bezak emas, balki muloqot. Bu kurs aniq va chiroyli ishlar ortidagi tamoyillarni — ierarxiya, kontrast, tekislash, yaqinlik, takrorlash va boʻsh joyni oʻrgatadi. Shunda istalgan afisha, slayd, veb-sayt yoki ilovani baholay va yaxshilay olasiz.$d$,
    array['Aniq vizual ierarxiya yarata olasiz',
          'Kontrast, tekislash va yaqinlikdan ongli ravishda foydalanasiz',
          'Maketni aniq atamalar yordamida tanqidiy tahlil qila olasiz'],
    array['Talab qilinmaydi']);

  perform seed.tr_module(c, 'Seeing like a designer', 'uz', 'Dizaynerdek koʻrish',
    'Har bir kuchli maket ortidagi tamoyillar.');

  perform seed.tr_lesson(c, 'Visual hierarchy', 'uz', 'Vizual ierarxiya',
    'Nigohni eng muhim elementdan eng kam muhimigacha yoʻnaltirish.',
$md$## Muhimlik tartibi

**Vizual ierarxiya** — elementlarni odamlar ularni muhimlik tartibida payqaydigan qilib joylashtirish. Yaxshi ishlangan afishada avval sarlavhani, keyin asosiy tafsilotni (sana, narx) va faqat shundan soʻng mayda yozuvni koʻrasiz — hech qanday harakat qilmasdan.

## Ierarxiya yaratuvchi vositalar

- **Oʻlcham** — kattaroq elementlar birinchi koʻrinadi.
- **Qalinlik** — qalin matn oddiy matn fonida ajralib turadi.
- **Rang va kontrast** — vazmin fondagi yorqin urgʻu rang diqqatni tortadi.
- **Joylashuv** — chapdan oʻngga yoziladigan tillarda (masalan, oʻzbek tilida) odamlar odatda yuqori chap burchakdan boshlaydi.
- **Boʻsh joy** — atrofi boʻsh joy bilan oʻralgan element muhim tuyuladi.

> [!TIP]
> **Koʻzni qisib koʻrish sinovi:** dizayningizga u xiralashguncha koʻzingizni qisib qarang. Shunda ham ajralib turgan narsani odamlar birinchi payqaydi. Agar bu eng muhim element boʻlmasa, ierarxiyani oʻzgartiring.

## Bitta asosiy nuqta

Hamma narsa qalin boʻlsa, hech narsa ajralib turmaydi. Har bir ekran yoki sahifa uchun **bitta** asosiy elementni tanlang, uni bir-ikkita ikkinchi darajali element bilan qoʻllab-quvvatlang, qolgan hamma narsani esa vazmin qoldiring.$md$);

  perform seed.tr_lesson(c, 'Contrast, alignment and proximity', 'uz', 'Kontrast, tekislash va yaqinlik',
    'Maketlarni bir zumda puxta oʻylangan koʻrinishga keltiradigan uchta tamoyil.',
$md$## Kontrast

**Kontrast** — bu farq: katta va kichik, toʻq va och, qalin va ingichka. Kontrast qiziqish uygʻotadi va qaysi narsalar bir-biridan farq qilishini koʻrsatadi. Farqlarni **yaqqol** qiling — deyarli bir xil boʻlgan ikki shrift oʻlchami xatodek koʻrinadi.

> [!WARNING]
> Matn oʻqilishi uchun u fon bilan kuchli kontrast hosil qilishi kerak. Foydalanish qulayligi boʻyicha tavsiyalar (WCAG) oddiy asosiy matn uchun kamida **4.5 : 1** kontrast nisbatini tavsiya etadi.

## Tekislash

**Tekislash** (*alignment*) — elementlarni umumiy koʻrinmas chiziqlar boʻylab joylashtirish. Tekislangan elementlar bir-biriga bogʻliq va tartibli koʻrinadi; tartibsiz joylashganlari esa eʼtiborsizlikdek taassurot qoldiradi. Bitta tekislash usulini tanlang (masalan, hamma narsani bir xil chap chetga tekislang) va unga amal qiling.

## Yaqinlik

**Yaqinlik** (*proximity*) — bir-biriga aloqador elementlar yonma-yon, aloqasizlari esa boʻsh joy bilan ajratilgan boʻlishi kerak. Rasm izohi rasmning ostida turadi; yangi boʻlim esa kattaroq boʻsh joydan keyin boshlanadi.

## Takrorlash va boʻsh joy

- **Takrorlash** — dizayn yagona tizimdek tuyulishi uchun bir xil ranglar, shriftlar va oraliqlardan qayta foydalaning.
- **Boʻsh joy** — boʻsh joy behuda sarflangan joy emas. U kontentga “nafas olish” imkonini beradi va hamma narsani oʻqishni osonlashtiradi.$md$);

  perform seed.tr_lesson(c, 'Check your understanding', 'uz', 'Bilimingizni tekshiring',
    'Dizayn atamalari amalda.', null);
  perform seed.tr_quiz(c, 'Design principles quiz', 'uz', 'Dizayn tamoyillari testi');
  perform seed.tr_question(c, 'Design principles quiz', 0, 'uz',
    'Rasm izohi rasmdan uzoqda va unga aloqasi yoʻq xatboshiga yaqin joylashtirilgan. Qaysi tamoyil buzilgan?',
    'Yaqinlik: bir-biriga aloqador elementlar yaqin guruhlanishi kerak.',
    array['Yaqinlik', 'Takrorlash', 'Kontrast']);
  perform seed.tr_question(c, 'Design principles quiz', 1, 'uz',
    'Koʻzni qisib koʻrish sinovi nimani aniqlaydi?',
    'Xiralashtirish mayda tafsilotlarni yoʻqotadi va faqat eng kuchli elementlar — haqiqiy ierarxiyangiz qoladi.',
    array['Imlo xatolarini', 'Ierarxiyada qaysi elementlar ustunlik qilishini', 'Ranglarni chop etish mumkinmi-yoʻqligini']);
  perform seed.tr_question(c, 'Design principles quiz', 2, 'uz',
    'Toʻgʻrimi yoki notoʻgʻri: boʻsh joy — behuda sarflangan joy, uni toʻldirish kerak.',
    'Notoʻgʻri — boʻsh joy oʻqishni osonlashtiradi va diqqatni jamlaydi.',
    array['Toʻgʻri', 'Notoʻgʻri'],
    array['Boʻsh joy odamlarga diqqatni jamlashga yordam beradi.', null]);
end $tr$;

-- Tayyorlanayotgan kurslar (oʻquvchilarga hali koʻrinmaydi) --------------------------------
select seed.tr_course(t.slug, 'uz', t.title, t.subtitle, null, null, null)
from (values
  ('css-from-zero', 'CSS: noldan boshlab', 'Ranglar, joylashuv va moslashuvchan dizayn'),
  ('javascript-from-zero', 'JavaScript: noldan boshlab', 'Veb-sahifalarni interaktiv qiling'),
  ('davinci-resolve-essentials', 'DaVinci Resolve asoslari', 'Montaj, rang va tayyor faylni topshirish'),
  ('blender-modeling-foundations', 'Blenderda modellashtirish asoslari', 'Topologiya, modifikatorlar va qattiq sirtli modellash asoslari')
) as t(slug, title, subtitle);

-- Oʻquv yoʻnalishlari ---------------------------------------------------------------------
select seed.tr_simple('learning_paths', t.slug, 'uz', jsonb_build_object('title', t.title, 'subtitle', t.subtitle, 'description', t.description))
from (values
  ('web-developer', 'Veb-dasturchi', 'Birinchi tegingizdan full-stack ilovalargacha',
   'Kompyuter asoslari, HTML, CSS, JavaScript va undan keyingi bosqichlar boʻylab tuzilgan yoʻl. Yangi kurslar chop etilishi bilan yoʻnalishga qoʻshib boriladi.'),
  ('3d-artist', '3D rassom', 'Uch oʻlchamda fikrlang, studiya darajasida render qiling',
   '3D nima ekanidan boshlang, Blender interfeysini oʻzlashtiring, soʻngra modellashtirish, materiallar, yoritish va animatsiyaga oʻting.'),
  ('game-developer', 'Oʻyin ishlab chiquvchi', 'Interaktiv olamlarni loyihalang va yarating',
   'Dasturlash asoslari, 3D asoslari va Unreal Engine — oʻyin ishlab chiquvchiga kerak boʻladigan koʻnikmalar toʻgʻri tartibda.'),
  ('creator', 'Raqamli kontent yaratuvchi', 'Ishonch bilan dizayn qiling, montaj qiling va eʼlon qiling',
   'Kontent yaratuvchilar uchun dizayn tamoyillari, video montaj va sunʼiy intellektdan amaliy foydalanish.')
) as t(slug, title, subtitle, description);
