# barq_ui — مكتبة واجهة برق

مكتبة Flutter مشتركة فيها **كل الشكل** تبع تطبيق الزبون وتطبيق السائق (برق كابتن):
الألوان، الخطوط، الأيقونات، الرسومات، وكل الـ widgets المتكررة — مطابقة لملفات التصميم في `docs/design`.

> **القاعدة الذهبية:** الشاشات تُبنى فقط من هذه المكتبة. ممنوع تكتب لون أو حجم أو زر أو كرت بإيدك داخل شاشة.
> إذا احتجت شي مش موجود → اطلبه من صاحب المكتبة يضيفه هون، وبيصير متاح للكل.

---

## 1) التركيب (مرة وحدة — القائد)

البنية:
```
barq/
├─ packages/barq_ui/      ← هذا المجلد
├─ apps/customer/
└─ apps/driver/
```

في `apps/customer/pubspec.yaml` و `apps/driver/pubspec.yaml`:
```yaml
dependencies:
  barq_ui:
    path: ../../packages/barq_ui
```
ثم `flutter pub get`.

في `main.dart`:
```dart
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp(
  theme: barqLightTheme(),          // تطبيق الزبون
  // theme: barqDarkTheme(),        // تطبيق السائق
  locale: const Locale('ar'),
  supportedLocales: const [Locale('ar'), Locale('en')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  ...
)
```
(اللغة العربية بتخلي كل شي RTL تلقائيًا.)

الخطوط (Rubik + Lalezar) والأيقونات والرسومات **مضمّنة جوا المكتبة** — ما في داعي تضيفهم بالتطبيق.

---

## 2) معرض المكونات

شاشة فيها كل widget بكل حالاته + اسمه (فاتح وغامق بزر واحد):
```dart
Navigator.push(context, MaterialPageRoute(builder: (_) => const BarqGallery()));
```
افتحها أول ما تبدأ عشان تعرف شو متوفر.

---

## 3) مطابقة الشاشة مع التصميم (DesignOverlay)

1. حط صور التصميم الخاصة بتطبيقك (من `docs/design/overlay/customer` أو `.../driver`) في `apps/<app>/design/` وأضف للـ pubspec:
   ```yaml
   flutter:
     assets:
       - design/
   ```
2. لف شاشتك:
   ```dart
   return DesignOverlay(
     image: 'design/03_checkout_04.png',
     child: BarqScreen(...),
   );
   ```
3. شغّل التطبيق → اضغط زر **«تصميم»** الصغير تحت على اليسار → حرّك السلايدر. أي فرق بيبان مباشرة.
4. الـ overlay ما بيشتغل بنسخة الـ release. قبل النشر احذف `design/` من الـ pubspec.

> جرّب على شاشة عرضها قريب من 390 (مثل Pixel 7 / iPhone 14) عشان المطابقة تكون دقيقة.

---

## 4) خريطة CSS → Widget

| بالتصميم (HTML/CSS) | بالكود |
|---|---|
| `.ph` خلفية الشاشة | `BarqScreen(background: light/dark/orange/white)` |
| `.top` الهيدر | `BarqHeader(title, back: true, trailing, bottom, large)` |
| `.btn` `.btn.w` `.btn.lt` `.btn.dk` `.btn.gr` `.btn.rd` | `BarqButton(variant: primary/white/light/dark/green/softRed/red/outlineDashed)` |
| `.icb` زر دائري | `BarqIconButton(icon: BarqIcons.back, showDot)` |
| `.plus` زر الإضافة | `BarqPlusButton(count)` |
| `.lnk` رابط | `BarqLink('عرض الكل')` |
| صفحة نموذج: المحتوى بيسكرول والزر تحت (`margin-top:auto`) | `BarqFillScroll(children, footer)` |
| الدوائر البيضاء على الخلفية البرتقالية | `BarqDecorCircles` |
| شعار داخل مربع (بداية / تحديث) · محتوى شاشة البداية | `BarqLogoTile(glass)` · `BarqSplashContent(tagline)` |
| دائرة بيضاء وجواها أيقونة برتقالية (رمز التحقق) | `BarqRingBadge(icon)` |
| مبدّل ع / EN | `BarqLanguageSwitch(isArabic, onChanged)` |
| `.card` / `.card.gl` | `BarqCard(borderColor, glass, clip)` |
| `.sheet` + `.grab` + `.scrim` | `BarqSheet` / `showBarqSheet()` / `BarqScrim` |
| `.pill.ok/.or/.no/.dk/.wh` | `BarqPill(tone: success/orange/danger/dark/white/successSolid/neutral)` |
| `.chip` / `.chip.on` + `.chips` | `BarqChip(selected)` داخل `BarqChipsRow` |
| خيارات مقسومة (اللغة، إذا نفد صنف، الحالية/السابقة) | `BarqSegmented<T>` |
| `.inp` / `.inp.f` + label | `BarqInput(label, hint, icon, helper, errorText, filled)` |
| `.search` | `BarqSearchBar(onTap / controller, active)` |
| `.ob` خانات الرمز | `BarqCodeInput(length: 4, onCompleted)` |
| `.qty` `.qb` | `BarqQtyStepper(value, onChanged, trashAtOne)` |
| صورة من السيرفر مع بديل · خلفية بلون المنتج | `BarqNetworkImage(url, fallback)` · `BarqTileBackground(tile, height, radius)` |
| تحميل / رسالة صغيرة داخل قائمة | `BarqLoadingView` · `BarqMessageView(title, message, actionLabel)` |
| رسومات السلة الفارغة · خارج المنطقة · ناقص أصناف | `BarqEmptyCartArt` · `BarqOutOfZoneArt` · `BarqBasketArt(label)` |
| شريط «تتسوّق من» فوق القوائم | `BarqScopeBar(text, action, onAction)` |
| كرت متجر أفقي · صف متجر بقائمة | `BarqVendorCard(logo, name, meta)` · `BarqVendorRow(logo, name, subtitle, meta, trailing)` |
| `.tg` / `.rad` / مربع الاختيار | `BarqToggle` / `BarqRadio` / `BarqCheckbox` |
| `.pc` + `.gls` كرت المنتج | `BarqProductTile(name, price, compareAtPrice, vendorName, vendorMuted, badge, soldOut, tile)` |
| صف منتج داخل كرت | `BarqProductRow(thumb: BarqThumb(...))` |
| `.ti` مربع الأيقونة | `BarqIconTile(icon, tone)` |
| `.li` صف قائمة | `BarqListTile(title, leading, value)` |
| شريط المراحل (5 خطوات) | `BarqStepProgress(count: 5, current, labels)` |
| مراحل عمودية | `BarqTimeline` |
| `.dots` | `BarqDots` |
| `.hr` / خط متقطع | `BarqDivider(dashed)` |
| صفوف المجموع والإجمالي | `BarqSummaryRow(label, value, total)` |
| صف ملاحظة ملون | `BarqNote(text, icon, tone)` |
| `.nb` شريط التنقل المنحني + `.fab` | `BarqNavBar(items, currentIndex, fabIcon, fabBadge)` |
| `.map` + `.mpin` | `BarqMapBackground` + `BarqMapPin(style)` |
| `.blob` + `.ill` | `BarqBlob` / `BarqIllustrationArea` |
| `.wm` شعار "برق" | `BarqWordmark(size)` |
| صورة الحرف (م / خ) | `BarqAvatar('م', dark)` |
| شاشات الحالات (خارج المنطقة، فارغ، صيانة…) | `BarqStateView(...)` + `BarqIconCard` |
| بانر ملون (عرض، أرباح، النقد) | `BarqBanner(gradient: BarqGradients.orange/green/cash)` |
| `.i.i-NAME` | `BarqIcon(BarqIcons.NAME, size: BarqSizes.iconM)` |
| `.im.im-NAME` | `BarqIllustration(BarqIllustrations.NAME)` |
| `.h0 .h1 .h2 .h3 .p .t .xs` | `BarqText.h0/h1/h2/h3/body/t/xs` |
| الألوان | `BarqColors.*` أو `BarqPalette.of(context)` (فاتح/غامق) |
| المسافات | `BarqSpacing.page` (22) · `BarqSpacing.headerTop` (52) |

---

## 5) مثال شاشة كاملة (السلة)

```dart
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DesignOverlay(
      image: 'design/03_checkout_01.png',
      child: BarqScreen(
        body: ListView(
          padding: const EdgeInsets.only(bottom: 220),
          children: [
            BarqHeader(
              title: 'سلتي',
              back: true,
              trailing: BarqIconButton(icon: BarqIcons.trash, onPressed: () {}),
              bottom: const Row(children: [
                BarqPill('ميني ماركت النور', tone: BarqPillTone.white, icon: BarqIcons.store),
                SizedBox(width: 8),
                Text('4 منتجات', style: BarqText.xs),
              ]),
            ),
            BarqGap(
              padding: const EdgeInsets.fromLTRB(BarqSpacing.page, 12, BarqSpacing.page, 0),
              gap: 8,
              children: [
                BarqProductRow(
                  thumb: const BarqThumb(size: 52, radius: 16, image: BarqIllustration(BarqIllustrations.tomato)),
                  title: 'بندورة بلدية',
                  price: const BarqPrice('₪7', unit: '· 2 كغ'),
                  trailing: BarqQtyStepper(value: 2, onChanged: (_) {}),
                ),
              ],
            ),
          ],
        ),
        bottomSheet: BarqSheet(showGrab: false, gap: 12, children: [
          const BarqSummaryRow('المجموع', '₪53', total: true),
          const BarqSummaryRow('التوصيل', 'يُحسب عند تأكيد الطلب'),
          BarqButton(label: 'متابعة الطلب · ₪53', onPressed: () {}),
        ]),
      ),
    );
  }
}
```

---

## 6) إضافة / تعديل مكوّن (صاحب المكتبة فقط)
- كل widget بملف حسب نوعه داخل `lib/src/widgets/`.
- أي مكوّن جديد: يضاف للتصدير في `lib/barq_ui.dart` + يضاف مثال له في `BarqGallery`.
- الألوان والأحجام الجديدة تضاف في `barq_tokens.dart` بس.
- بعد أي تعديل: `flutter analyze` لازم يطلع نظيف، وبعدين commit برسالة واضحة: `barq_ui: add BarqXxx`.
