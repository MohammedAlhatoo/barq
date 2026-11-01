import 'package:flutter/material.dart';

import '../foundation/barq_asset_names.dart';
import '../foundation/barq_assets.dart';
import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';
import '../widgets/account.dart';
import '../widgets/buttons.dart';
import '../widgets/chat.dart';
import '../widgets/driver.dart';
import '../widgets/indicators.dart';
import '../widgets/inputs.dart';
import '../widgets/layout.dart';
import '../widgets/misc.dart';
import '../widgets/nav_bar.dart';
import '../widgets/product.dart';
import '../widgets/surfaces.dart';
import '../widgets/vendor.dart';

/// Every barq_ui widget on one scrolling page (light or dark).
/// Open it during development: `Navigator.push(context, MaterialPageRoute(builder: (_) => const BarqGallery()))`
/// The class names under each sample are what you use in your screens.
class BarqGallery extends StatefulWidget {
  const BarqGallery({super.key});

  @override
  State<BarqGallery> createState() => _BarqGalleryState();
}

class _BarqGalleryState extends State<BarqGallery> {
  bool dark = false;
  int qty = 2;
  bool toggle = true;
  bool check = true;
  int radio = 0;
  String seg = 'call';
  int chip = 0;
  int nav = 0;
  int stars = 4;
  final chatInput = TextEditingController();

  @override
  void dispose() {
    chatInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: dark ? barqDarkTheme() : barqLightTheme(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Builder(builder: (context) {
          final p = BarqPalette.of(context);
          Widget label(String t) => Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 22),
                child: Text(t,
                    style: BarqText.xs.copyWith(color: p.textMuted),
                    textDirection: TextDirection.ltr),
              );
          Widget section(String t) => Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Text(t, style: BarqText.h2.copyWith(color: p.text)),
              );
          return BarqScreen(
            bottomNavigationBar: BarqNavBar(
              items: const [
                BarqNavItem(icon: BarqIcons.home, label: 'الرئيسية'),
                BarqNavItem(icon: BarqIcons.grid, label: 'الأقسام'),
                BarqNavItem(icon: BarqIcons.receipt, label: 'طلباتي'),
                BarqNavItem(icon: BarqIcons.user, label: 'حسابي'),
              ],
              currentIndex: nav,
              onTap: (i) => setState(() => nav = i),
              fabIcon: BarqIcons.bag,
              fabBadge: 3,
            ),
            body: ListView(
              padding: const EdgeInsets.only(bottom: 140),
              children: [
                BarqHeader(
                  title: 'barq_ui',
                  back: true,
                  trailing: BarqIconButton(
                      icon: BarqIcons.bell, showDot: true, onPressed: () {}),
                  bottom: Row(children: [
                    Expanded(
                        child: Text(
                            dark
                                ? 'الوضع الغامق (السائق)'
                                : 'الوضع الفاتح (الزبون)',
                            style: BarqText.t.copyWith(color: p.text))),
                    BarqToggle(
                        value: dark,
                        onChanged: (v) => setState(() => dark = v)),
                  ]),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      section('الهوية'),
                      Row(children: [
                        const BarqWordmark(size: 48),
                        const Spacer(),
                        const BarqAvatar('م'),
                        const SizedBox(width: 8),
                        const BarqAvatar('خ', dark: true)
                      ]),
                      label('BarqWordmark · BarqAvatar'),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final c in const [
                          BarqColors.primary,
                          BarqColors.primaryDeep,
                          BarqColors.ink,
                          BarqColors.success,
                          BarqColors.danger,
                          BarqColors.primarySoft,
                          BarqColors.successSoft,
                          BarqColors.chipMuted
                        ])
                          Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                  color: c,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: p.line))),
                      ]),
                      label('BarqColors.*'),
                      Text('عنوان h1',
                          style: BarqText.h1.copyWith(color: p.text)),
                      Text('عنوان h2',
                          style: BarqText.h2.copyWith(color: p.text)),
                      Text('عنوان h3',
                          style: BarqText.h3.copyWith(color: p.text)),
                      Text('نص وصفي .p للشاشات',
                          style: BarqText.body.copyWith(color: p.textMuted)),
                      label('BarqText.h1 / h2 / h3 / body / t / xs'),
                      section('الأزرار'),
                      BarqGap(gap: 10, children: [
                        BarqButton(
                            label: 'متابعة الطلب · ₪53', onPressed: () {}),
                        BarqButton(
                            label: 'اختيار الأوفر · ₪44',
                            variant: BarqButtonVariant.green,
                            icon: BarqIcons.check,
                            onPressed: () {}),
                        BarqButton(
                            label: 'العودة للرئيسية',
                            variant: BarqButtonVariant.white,
                            onPressed: () {}),
                        BarqButton(
                            label: 'مراجعة السلة',
                            variant: BarqButtonVariant.light,
                            onPressed: () {}),
                        BarqButton(
                            label: 'عرض السلة',
                            variant: BarqButtonVariant.dark,
                            icon: BarqIcons.bag,
                            trailing: const Text('₪46'),
                            onPressed: () {}),
                        BarqButton(
                            label: 'إلغاء الطلب',
                            variant: BarqButtonVariant.softRed,
                            onPressed: () {}),
                        BarqButton(
                            label: 'تأكيد الإلغاء',
                            variant: BarqButtonVariant.red,
                            onPressed: () {}),
                        BarqButton(
                            label: 'تحديد موقعي',
                            variant: BarqButtonVariant.outlineDashed,
                            icon: BarqIcons.locate,
                            small: true,
                            onPressed: () {}),
                        const BarqButton(label: 'تأكيد الاستلام (معطّل)'),
                        BarqButton(
                            label: 'تحميل', loading: true, onPressed: () {}),
                      ]),
                      label(
                          'BarqButton(variant: primary/green/white/light/dark/softRed/red/outlineDashed, small, icon, trailing, loading)'),
                      Row(children: [
                        BarqIconButton(icon: BarqIcons.back, onPressed: () {}),
                        const SizedBox(width: 8),
                        BarqIconButton(
                            icon: BarqIcons.bell,
                            showDot: true,
                            onPressed: () {}),
                        const SizedBox(width: 8),
                        BarqPlusButton(onPressed: () {}),
                        const SizedBox(width: 8),
                        BarqPlusButton(onPressed: () {}, small: true, count: 2),
                        const SizedBox(width: 12),
                        BarqLink('عرض الكل', onPressed: () {}),
                      ]),
                      label(
                          'BarqIconButton · BarqPlusButton(count) · BarqLink'),
                      section('الحالات والمؤشرات'),
                      const Wrap(spacing: 6, runSpacing: 6, children: [
                        BarqPill('تم التوصيل', tone: BarqPillTone.success),
                        BarqPill('في الطريق', tone: BarqPillTone.orange),
                        BarqPill('ملغي', tone: BarqPillTone.danger),
                        BarqPill('عرض اليوم −20%', tone: BarqPillTone.dark),
                        BarqPill('−25%', tone: BarqPillTone.successSolid),
                        BarqPill('داخل منطقة الخدمة',
                            tone: BarqPillTone.success, icon: BarqIcons.check),
                        BarqPill('422 out_of_zone', tone: BarqPillTone.neutral),
                        BarqPill('بانتظار المتجر', color: Color(0xFFF59E0B)),
                      ]),
                      label('BarqPill(tone: …)'),
                      const BarqStepProgress(count: 5, current: 2, labels: [
                        'تم القبول',
                        'تم الاستلام',
                        'في الطريق',
                        'السائق وصل',
                        'تم التوصيل'
                      ]),
                      label('BarqStepProgress(count, current, labels)'),
                      BarqTimeline(
                        current: 0,
                        currentTrailing: const BarqPill('الآن'),
                        items: const [
                          (icon: BarqIcons.store, label: 'بانتظار المتجر'),
                          (icon: BarqIcons.package, label: 'قيد التحضير'),
                          (icon: BarqIcons.user, label: 'بانتظار سائق'),
                        ],
                      ),
                      label('BarqTimeline'),
                      Row(children: [
                        const BarqDots(count: 3, index: 1),
                        const Spacer(),
                        BarqStars(
                            value: stars,
                            onChanged: (v) => setState(() => stars = v))
                      ]),
                      label('BarqDots · BarqStars'),
                      BarqLanguageSwitch(isArabic: true, onChanged: (_) {}),
                      label('BarqLanguageSwitch'),
                      const Row(children: [
                        BarqRingBadge(icon: BarqIcons.shield),
                        SizedBox(width: 12),
                        BarqLogoTile(),
                      ]),
                      label('BarqRingBadge · BarqLogoTile'),
                      Container(
                        height: 320,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            gradient: BarqGradients.orangeScreen,
                            borderRadius: BorderRadius.circular(24)),
                        child: const BarqSplashContent(tagline: 'برق'),
                      ),
                      label('BarqSplashContent · BarqDecorCircles'),
                      SizedBox(
                        height: 120,
                        child: BarqFillScroll(
                          footer: BarqButton(label: 'تحت', onPressed: () {}),
                          children: const [Text('محتوى')],
                        ),
                      ),
                      label('BarqFillScroll'),
                      const BarqPrice('₪6', compareAt: '₪8', unit: '/ كغ'),
                      label('BarqPrice(price, compareAt, unit)'),
                      const BarqDivider(dashed: true),
                      label('BarqDivider(dashed)'),
                      section('الإدخال'),
                      const BarqInput(
                          label: 'الاسم',
                          hint: 'اكتب اسمك',
                          icon: BarqIcons.user),
                      label('BarqInput(label, hint, icon, helper, errorText)'),
                      const BarqInput(
                          label: 'رقم الجوال',
                          hint: '059 912 3456',
                          icon: BarqIcons.lock,
                          filled: true,
                          readOnly: true,
                          helper: 'لتغيير الرقم تواصل مع الدعم'),
                      label('BarqInput(filled, readOnly)'),
                      const BarqSearchBar(),
                      label('BarqSearchBar(onTap / controller, active)'),
                      const BarqCodeInput(autofocus: false),
                      label('BarqCodeInput(length: 4, onCompleted)'),
                      BarqSegmented<String>(
                        value: seg,
                        onChanged: (v) => setState(() => seg = v),
                        options: const [
                          (value: 'call', label: 'اتصلوا بي'),
                          (value: 'similar', label: 'بديل مشابه'),
                          (value: 'skip', label: 'احذفوه')
                        ],
                      ),
                      label('BarqSegmented<T>(options, value, onChanged)'),
                      Row(children: [
                        BarqQtyStepper(
                            value: qty,
                            trashAtOne: true,
                            onChanged: (v) => setState(() => qty = v)),
                        const Spacer(),
                        BarqToggle(
                            value: toggle,
                            onChanged: (v) => setState(() => toggle = v)),
                        const SizedBox(width: 12),
                        BarqRadio(
                            selected: radio == 0,
                            onTap: () => setState(() => radio = 0)),
                        const SizedBox(width: 6),
                        BarqRadio(
                            selected: radio == 1,
                            onTap: () => setState(() => radio = 1)),
                        const SizedBox(width: 12),
                        BarqCheckbox(
                            value: check,
                            onChanged: (v) => setState(() => check = v)),
                      ]),
                      label(
                          'BarqQtyStepper · BarqToggle · BarqRadio · BarqCheckbox'),
                    ],
                  ),
                ),
                BarqChipsRow(children: [
                  for (final (i, t) in const [
                    'مختارة لك',
                    'فواكه',
                    'خضار',
                    'ألبان',
                    'بيض'
                  ].indexed)
                    BarqChip(
                      label: t,
                      selected: chip == i,
                      leading: i == 1
                          ? const BarqIllustration(BarqIllustrations.orange)
                          : null,
                      onTap: () => setState(() => chip = i),
                    ),
                ]),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: BarqSpacing.page),
                    child: label('BarqChipsRow + BarqChip(selected, leading)')),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      section('المنتجات'),
                      Row(children: [
                        Expanded(
                          child: BarqProductTile(
                            name: 'برتقال',
                            price: '₪6',
                            compareAtPrice: '₪8',
                            unit: '/ كغ',
                            badge: '−25%',
                            tile: BarqTileColor.peach,
                            isFavorite: true,
                            image: const BarqIllustration(
                                BarqIllustrations.orange),
                            onAdd: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: BarqProductTile(
                            name: 'موز',
                            price: '₪8',
                            unit: '/ كغ',
                            tile: BarqTileColor.yellow,
                            soldOut: true,
                            image: BarqIllustration(BarqIllustrations.banana),
                          ),
                        ),
                      ]),
                      label(
                          'BarqProductTile(name, price, compareAtPrice, badge, soldOut, quantityInCart, tile)'),
                      BarqProductRow(
                        thumb: const BarqThumb(
                            image: BarqIllustration(BarqIllustrations.tomato)),
                        title: 'بندورة بلدية',
                        subtitle: 'ميني ماركت النور · 1.2 كم',
                        price: const BarqPrice('₪3.5',
                            compareAt: '₪4.5', unit: '/ كغ'),
                        trailing: BarqPlusButton(onPressed: () {}),
                      ),
                      label('BarqProductRow + BarqThumb'),
                      section('البطاقات والقوائم'),
                      BarqCard(
                        child: Column(children: [
                          BarqListTile(
                              title: 'عناويني',
                              leading: const BarqIconTile(BarqIcons.pin),
                              onTap: () {}),
                          BarqListTile(
                              title: 'اللغة',
                              value: 'العربية',
                              leading: const BarqIconTile(BarqIcons.globe),
                              onTap: () {}),
                          const BarqListTile(
                              title: 'تسجيل الخروج',
                              leading: BarqIconTile(BarqIcons.logout,
                                  tone: BarqTileTone.neutral),
                              showChevron: false,
                              showDivider: false),
                        ]),
                      ),
                      label('BarqCard · BarqListTile · BarqIconTile(tone)'),
                      BarqProfileCard(
                        initial: 'م',
                        name: 'محمد أحمد',
                        phone: '059 912 3456',
                        onEdit: () {},
                        stats: const [
                          (value: '12', label: 'طلب'),
                          (value: '3', label: 'عناوين'),
                        ],
                      ),
                      label('BarqProfileCard'),
                      BarqAddressCard(
                        icon: BarqIcons.home,
                        title: 'البيت',
                        subtitle: 'قرب مسجد الهدى · ط2',
                        badge: 'الافتراضي',
                        selected: true,
                        onEdit: () {},
                        onDelete: () {},
                      ),
                      label('BarqAddressCard'),
                      const BarqDeleteAccountArt(),
                      label('BarqDeleteAccountArt'),
                      const SizedBox(
                        height: 220,
                        child: BarqMapBackground(children: [
                          BarqMapCenterPin(hint: 'حرّك الخريطة لتحديد الموقع'),
                        ]),
                      ),
                      label('BarqMapCenterPin'),
                      const BarqCard(
                        child: BarqGap(gap: 8, children: [
                          BarqSummaryRow('المنتجات (4)', '₪44'),
                          BarqSummaryRow('التوصيل (1.8 كم)', '₪7'),
                          BarqSummaryRow('خصم الكوبون', '−₪5',
                              valueColor: BarqColors.successText),
                          BarqDivider(),
                          BarqSummaryRow('الإجمالي', '₪46', total: true),
                        ]),
                      ),
                      label('BarqSummaryRow(total)'),
                      const BarqNote(
                          'إذا لم توافق خلال 60 دقيقة، يُلغى الطلب تلقائيًا.',
                          tone: BarqNoteTone.warning),
                      const SizedBox(height: 8),
                      const BarqNote(
                          'السائق بيصوّر الطلب عند بابك كإثبات تسليم',
                          icon: BarqIcons.camera,
                          tone: BarqNoteTone.orange),
                      label('BarqNote(tone)'),
                      BarqBanner(
                        child: Row(children: [
                          Expanded(
                              child: Text('خضار وفواكه طازجة كل يوم',
                                  style: BarqText.h2
                                      .copyWith(color: Colors.white))),
                          const BarqIllustration(BarqIllustrations.orange,
                              width: 90),
                        ]),
                      ),
                      label('BarqBanner(gradient)'),
                      BarqAssistantBanner(
                          title: 'اطلب بسرعة مع مساعد برق',
                          subtitle: 'اكتب قائمتك وبنلاقيلك أوفر متجر',
                          onTap: () {}),
                      label('BarqAssistantBanner'),
                      const BarqChatBubble(text: 'أهلًا! أنا مساعد برق.'),
                      const SizedBox(height: 8),
                      const BarqChatBubble(
                          text: 'كيلو بندورة ولتر حليب', fromUser: true),
                      const SizedBox(height: 8),
                      const BarqTypingBubble(),
                      label('BarqChatBubble(fromUser) · BarqTypingBubble'),
                      BarqChatComposer(
                          controller: chatInput,
                          hint: 'اكتب قائمتك هون…',
                          onSend: () {}),
                      label('BarqChatComposer'),
                      Wrap(spacing: 8, children: [
                        BarqChip(
                            label: 'اسم منتج طويل جدًا جاي من السيرفر',
                            maxLabelWidth: 120,
                            onTap: () {}),
                      ]),
                      label('BarqChip(maxLabelWidth)'),
                      const BarqTileBackground(
                        tile: BarqTileColor.mint,
                        height: 90,
                        child: BarqNetworkImage(
                            url: null,
                            fallback:
                                BarqIllustration(BarqIllustrations.cucumber)),
                      ),
                      label('BarqTileBackground + BarqNetworkImage'),
                      SizedBox(
                        width: 170,
                        child: BarqProductTile(
                          name: 'بندورة',
                          price: '6.00 ₪',
                          vendorName: 'ميني ماركت النور',
                          image:
                              const BarqIllustration(BarqIllustrations.tomato),
                          onAdd: () {},
                        ),
                      ),
                      label('BarqProductTile(vendorName)'),
                      BarqScopeBar(
                        text: 'تتسوّق من: ميني ماركت النور',
                        action: 'كل المتاجر',
                        onAction: () {},
                      ),
                      label('BarqScopeBar'),
                      BarqActiveOrderBar(
                        code: 'BR-000007',
                        hint: 'وصلك عرض السعر',
                        status: const BarqPill('تم التسعير'),
                        more: 2,
                        highlighted: true,
                        onTap: () {},
                      ),
                      label('BarqActiveOrderBar'),
                      SizedBox(
                        width: BarqSizes.homeVendorCard,
                        height: BarqSizes.homeVendorCardHeight,
                        child: BarqVendorCard(
                          logo: const BarqIllustration(
                              BarqIllustrations.storefront),
                          name: 'ميني ماركت النور',
                          meta: const [
                            (
                              icon: BarqIcons.star,
                              text: '4.8 (320)',
                              iconColor: BarqColors.star
                            ),
                            (
                              icon: BarqIcons.clock,
                              text: 'تحضير 15 د',
                              iconColor: null
                            ),
                            (
                              icon: BarqIcons.pin,
                              text: '1.2 كم',
                              iconColor: null
                            ),
                          ],
                          onTap: () {},
                        ),
                      ),
                      label('BarqVendorCard'),
                      BarqVendorRow(
                        logo: const BarqIllustration(
                            BarqIllustrations.storefront),
                        name: 'ميني ماركت النور',
                        subtitle: 'بقالة',
                        meta: const [
                          (
                            icon: BarqIcons.pin,
                            text: '1.2 كم',
                            iconColor: null
                          ),
                        ],
                        trailing:
                            const BarqPill('مفتوح', tone: BarqPillTone.success),
                        onTap: () {},
                      ),
                      label('BarqVendorRow'),
                      const BarqEmptyCartArt(),
                      label('BarqEmptyCartArt'),
                      const BarqOutOfZoneArt(),
                      label('BarqOutOfZoneArt'),
                      const BarqBasketArt(label: 'ناقص أصناف'),
                      label('BarqBasketArt'),
                      const BarqOfferExpiredArt(label: 'انتهت المهلة'),
                      label('BarqOfferExpiredArt'),
                      const BarqWaitingArt(),
                      label('BarqWaitingArt'),
                      const BarqDeliveredArt(),
                      label('BarqDeliveredArt'),
                      const BarqUnreadDot(),
                      label('BarqUnreadDot'),
                      const BarqMessageView(
                          title: 'لا نتائج', actionLabel: 'إعادة المحاولة'),
                      label('BarqMessageView'),
                      const SizedBox(height: 80, child: BarqLoadingView()),
                      label('BarqLoadingView'),
                      BarqButton(
                        label: 'عرض السلة',
                        variant: BarqButtonVariant.dark,
                        leading: const BarqIconTile(BarqIcons.bag,
                            tone: BarqTileTone.darkOrange,
                            size: BarqSizes.cartBarIcon,
                            radius: BarqRadius.pill),
                        trailing: const Text('3 منتجات'),
                        onPressed: () {},
                      ),
                      label('BarqButton(leading, trailing)'),
                      SizedBox(
                        height: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(BarqRadius.card),
                          child: const BarqMapBackground(children: [
                            Positioned(
                                top: 30,
                                left: 60,
                                child: BarqMapPin(icon: BarqIcons.home)),
                            Positioned(
                                top: 80,
                                left: 180,
                                child: BarqMapPin(
                                    icon: BarqIcons.bike,
                                    style: BarqPinStyle.dark)),
                          ]),
                        ),
                      ),
                      label('BarqMapBackground · BarqMapPin(style)'),
                      Row(children: [
                        const BarqIconCard(
                            icon: BarqIcons.clock, size: 90, angle: -8),
                        const SizedBox(width: 16),
                        BarqBlob(
                            size: 90,
                            child: BarqIllustration(BarqIllustrations.pin3d,
                                width: 70)),
                      ]),
                      label('BarqIconCard · BarqBlob'),
                      Wrap(spacing: 10, runSpacing: 10, children: [
                        for (final n in BarqIcons.all)
                          Tooltip(
                              message: n, child: BarqIcon(n, color: p.text)),
                      ]),
                      label(
                          'BarqIcon(BarqIcons.*) — ${BarqIcons.all.length} icons'),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final n in BarqIllustrations.all)
                          Tooltip(
                              message: n,
                              child:
                                  BarqIllustration(n, width: 56, height: 56)),
                      ]),
                      label('BarqIllustration(BarqIllustrations.*)'),
                      BarqButton(
                        label: 'فتح Bottom Sheet',
                        variant: BarqButtonVariant.white,
                        onPressed: () => showBarqSheet(context, children: [
                          Text('إلغاء الطلب؟',
                              style: BarqText.h2.copyWith(color: p.text)),
                          BarqButton(
                              label: 'تأكيد الإلغاء',
                              variant: BarqButtonVariant.red,
                              onPressed: () => Navigator.pop(context)),
                        ]),
                      ),
                      label('showBarqSheet / BarqSheet'),
                      section('السائق'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          BarqOnlineSwitch(
                              online: true,
                              label: 'متصل',
                              onChanged: (_) {}),
                          BarqOnlineSwitch(
                              online: false,
                              label: 'غير متصل',
                              onChanged: (_) {}),
                        ],
                      ),
                      label('BarqOnlineSwitch'),
                      const BarqBanner(
                          child: Row(children: [
                        BarqBannerStat(value: '7', label: 'طلبات'),
                      ])),
                      label('BarqBannerStat'),
                      Center(child: BarqPowerButton(onPressed: () {})),
                      label('BarqPowerButton'),
                      const BarqProgressBar(value: 0.84),
                      label('BarqProgressBar'),
                      BarqNote('سبقك سائق آخر لهذا الطلب',
                          tone: BarqNoteTone.danger, onClose: () {}),
                      label('BarqNote(onClose)'),
                      const BarqCaptainWordmark(label: 'كابتن'),
                      label('BarqCaptainWordmark'),
                      const SizedBox(
                          height: 240,
                          child: BarqCaptainSplash(
                              label: 'كابتن', tagline: 'جاهز لطلبات اليوم')),
                      label('BarqCaptainSplash'),
                      const BarqLogoTile(captainLabel: 'كابتن'),
                      label('BarqLogoTile(captainLabel) · BarqCaptainLogo'),
                      const BarqViewfinder(
                          height: 160,
                          child: BarqIllustration(BarqIllustrations.basket)),
                      label('BarqViewfinder'),
                      Center(child: BarqShutterButton(onPressed: () {})),
                      label('BarqShutterButton'),
                      const BarqBarChart(bars: [
                        BarqBar(label: 'س', value: 3),
                        BarqBar(label: 'ح', value: 5),
                        BarqBar(label: 'ن', value: 8, active: true),
                        BarqBar(label: 'ث', value: 0),
                      ]),
                      label('BarqBarChart'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
