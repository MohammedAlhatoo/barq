import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/barq_assets.dart';
import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';
import 'buttons.dart';

/// Field label above inputs (.fl label).
class BarqFieldLabel extends StatelessWidget {
  const BarqFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: BarqText.t.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: BarqPalette.of(context).label)),
      );
}

/// .inp — 58px rounded field. Orange border + ring when focused (.inp.f).
/// Wraps a borderless TextField so it looks exactly like the design.
class BarqInput extends StatefulWidget {
  const BarqInput({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.icon,
    this.prefix,
    this.suffix,
    this.helper,
    this.errorText,
    this.keyboardType,
    this.textDirection,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.inputFormatters,
    this.height = BarqSizes.input,
    this.radius = BarqRadius.input,
    this.maxLines = 1,
    this.focusNode,
    this.textInputAction,
    this.filled,
  });

  final TextEditingController? controller;
  final String? hint;

  /// Shown above the field (uses [BarqFieldLabel]).
  final String? label;

  /// A [BarqIcons] name at the start.
  final String? icon;
  final Widget? prefix;
  final Widget? suffix;

  /// Small grey text under the field ("لتغيير الرقم تواصل مع الدعم").
  final String? helper;
  final String? errorText;
  final TextInputType? keyboardType;

  /// Use LTR for phone numbers / codes.
  final TextDirection? textDirection;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final double height;
  final double radius;
  final int maxLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  /// Grey locked look (read-only phone in profile). Defaults to `!enabled`.
  final bool? filled;

  @override
  State<BarqInput> createState() => _BarqInputState();
}

class _BarqInputState extends State<BarqInput> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final focused = _focus.hasFocus;
    final hasError = widget.errorText != null;
    final grey = widget.filled ?? !widget.enabled;
    final borderColor = hasError
        ? BarqColors.danger
        : (focused ? BarqColors.primary : p.inputBorder);
    final field = AnimatedContainer(
      duration: BarqDurations.fast,
      height: widget.maxLines == 1 ? widget.height : null,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: grey
            ? (p.isDark ? BarqColors.darkChip : const Color(0xFFF8F3F0))
            : p.input,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: focused && !hasError ? BarqShadows.focusRing : null,
      ),
      child: Row(
        children: [
          if (widget.icon != null) ...[
            BarqIcon(widget.icon!,
                size: BarqSizes.iconM,
                color: focused ? BarqColors.primary : p.textMuted),
            const SizedBox(width: 10),
          ],
          if (widget.prefix != null) ...[
            widget.prefix!,
            const SizedBox(width: 10)
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              obscureText: widget.obscureText,
              readOnly: widget.readOnly,
              enabled: widget.enabled,
              onChanged: widget.onChanged,
              onTap: widget.onTap,
              onSubmitted: widget.onSubmitted,
              keyboardType: widget.keyboardType,
              textDirection: widget.textDirection,
              inputFormatters: widget.inputFormatters,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              textInputAction: widget.textInputAction,
              style: BarqText.input.copyWith(
                  color: grey ? p.textMuted : p.text,
                  letterSpacing: widget.obscureText ? 3 : null),
              cursorColor: BarqColors.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle:
                    BarqText.input.copyWith(color: BarqColors.placeholder),
              ),
            ),
          ),
          if (widget.suffix != null) ...[
            const SizedBox(width: 10),
            widget.suffix!
          ],
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) BarqFieldLabel(widget.label!),
        field,
        if (hasError || widget.helper != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 6, start: 4),
            child: Text(
              widget.errorText ?? widget.helper!,
              style: BarqText.xs
                  .copyWith(color: hasError ? BarqColors.danger : p.textMuted),
            ),
          ),
      ],
    );
  }
}

/// .search — rounded white search bar. Use [onTap] to open the search screen,
/// or pass a [controller] to type in place. [active] gives the orange border.
class BarqSearchBar extends StatelessWidget {
  const BarqSearchBar(
      {super.key,
      this.hint = 'ابحث عن منتج أو متجر',
      this.controller,
      this.onTap,
      this.onChanged,
      this.onSubmitted,
      this.onClear,
      this.active = false,
      this.autofocus = false});

  final String hint;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool active;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final editable = controller != null;
    return GestureDetector(
      onTap: editable ? null : onTap,
      child: Container(
        height: BarqSizes.search,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(BarqRadius.pill),
          border:
              active ? Border.all(color: BarqColors.primary, width: 1.5) : null,
          boxShadow: active ? null : BarqShadows.soft,
        ),
        child: Row(
          children: [
            BarqIcon(BarqIconsInternal.search,
                size: BarqSizes.icon,
                color: active ? BarqColors.primary : BarqColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: editable
                  ? TextField(
                      controller: controller,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      textInputAction: TextInputAction.search,
                      autofocus: autofocus,
                      style: BarqText.t.copyWith(fontSize: 15),
                      cursorColor: BarqColors.primary,
                      decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: hint,
                          hintStyle: BarqText.t
                              .copyWith(fontSize: 15, color: BarqColors.muted)),
                    )
                  : Text(hint,
                      style: BarqText.t
                          .copyWith(fontSize: 15, color: BarqColors.muted)),
            ),
            if (onClear != null)
              GestureDetector(
                  onTap: onClear,
                  child: const BarqIcon(BarqIconsInternal.x,
                      size: BarqSizes.iconS, color: BarqColors.muted)),
          ],
        ),
      ),
    );
  }
}

/// .ob — row of code boxes (OTP login). Type into a hidden field; boxes show digits.
/// Always laid out LTR like the design.
class BarqCodeInput extends StatefulWidget {
  const BarqCodeInput(
      {super.key,
      this.length = 4,
      this.onCompleted,
      this.onChanged,
      this.controller,
      this.autofocus = true,
      this.hasError = false});

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool autofocus;
  final bool hasError;

  @override
  State<BarqCodeInput> createState() => _BarqCodeInputState();
}

class _BarqCodeInputState extends State<BarqCodeInput> {
  late final TextEditingController _c =
      widget.controller ?? TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (widget.controller == null) _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return GestureDetector(
      onTap: () => _focus.requestFocus(),
      child: Stack(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) const SizedBox(width: 14),
                  _box(p, i),
                ],
              ],
            ),
          ),
          // Invisible field on top of the boxes: receives taps + keyboard input.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _c,
                focusNode: _focus,
                autofocus: widget.autofocus,
                showCursor: false,
                keyboardType: TextInputType.number,
                maxLength: widget.length,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    counterText: '', border: InputBorder.none),
                onChanged: (v) {
                  setState(() {});
                  widget.onChanged?.call(v);
                  if (v.length == widget.length) widget.onCompleted?.call(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(BarqPalette p, int i) {
    final text = _c.text;
    final filled = i < text.length;
    final active = filled || (i == text.length && _focus.hasFocus);
    final border = widget.hasError
        ? BarqColors.danger
        : (active ? BarqColors.primary : p.inputBorder);
    return AnimatedContainer(
      duration: BarqDurations.fast,
      width: BarqSizes.otpWidth,
      height: BarqSizes.otpHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.input,
        borderRadius: BorderRadius.circular(BarqRadius.otp),
        border: Border.all(color: border, width: 1.5),
        boxShadow: active && !widget.hasError ? BarqShadows.focusRing : null,
      ),
      child: Text(filled ? text[i] : '',
          style: BarqText.otp.copyWith(color: p.text)),
    );
  }
}

/// .chip — rounded filter/category chip. [selected] = orange (.chip.on).
class BarqChip extends StatelessWidget {
  const BarqChip(
      {super.key,
      required this.label,
      this.selected = false,
      this.onTap,
      this.leading,
      this.icon,
      this.height = BarqSizes.chip,
      this.trailingText});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// e.g. a small [BarqIllustration] (category chips with fruit images).
  final Widget? leading;

  /// A [BarqIcons] name.
  final String? icon;
  final double height;

  /// Small extra text after the label (option price "+₪5").
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    final fg = selected ? Colors.white : p.chipText;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BarqDurations.fast,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? BarqColors.primary : p.chip,
          borderRadius: BorderRadius.circular(BarqRadius.pill),
          boxShadow: selected
              ? BarqShadows.chipOn
              : (p.isDark ? null : BarqShadows.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              SizedBox(width: 20, height: 20, child: leading),
              const SizedBox(width: 6)
            ],
            if (icon != null) ...[
              BarqIcon(icon!, size: BarqSizes.iconS, color: fg),
              const SizedBox(width: 6)
            ],
            Text(label,
                style: BarqText.chip.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w500 : FontWeight.w400)),
            if (trailingText != null) ...[
              const SizedBox(width: 6),
              Text(trailingText!,
                  style: BarqText.xs
                      .copyWith(color: selected ? Colors.white : p.textMuted)),
            ],
          ],
        ),
      ),
    );
  }
}

/// .chips — horizontally scrolling row of chips with page padding.
class BarqChipsRow extends StatelessWidget {
  const BarqChipsRow(
      {super.key,
      required this.children,
      this.gap = 10,
      this.padding = const EdgeInsets.symmetric(
          horizontal: BarqSpacing.page, vertical: 8)});
  final List<Widget> children;
  final double gap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        clipBehavior: Clip.none,
        child: Row(children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            children[i]
          ]
        ]),
      );
}

/// Segmented control (language, "إذا نفد صنف", current/previous orders, day/week/month).
class BarqSegmented<T> extends StatelessWidget {
  const BarqSegmented(
      {super.key,
      required this.options,
      required this.value,
      required this.onChanged,
      this.height = 40,
      this.white = false});

  final List<({T value, String label})> options;
  final T value;
  final ValueChanged<T> onChanged;
  final double height;

  /// White track with shadow (orders tabs) instead of beige.
  final bool white;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: white ? Colors.white : p.segment,
        borderRadius: BorderRadius.circular(BarqRadius.pill),
        boxShadow: white ? BarqShadows.chip : null,
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(o.value),
                child: AnimatedContainer(
                  duration: BarqDurations.fast,
                  height: height,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: o.value == value
                        ? BarqColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(BarqRadius.pill),
                    boxShadow: o.value == value ? BarqShadows.chipOn : null,
                  ),
                  child: Text(
                    o.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BarqText.t.copyWith(
                      fontSize: 13.5,
                      color: o.value == value
                          ? Colors.white
                          : (p.isDark ? BarqColors.darkMuted : p.text),
                      fontWeight:
                          o.value == value ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The ع / EN switch on the onboarding screens. [isArabic] picks the dark side.
class BarqLanguageSwitch extends StatelessWidget {
  const BarqLanguageSwitch(
      {super.key, required this.isArabic, required this.onChanged});
  final bool isArabic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget option(String label, bool arabic) {
      final on = arabic == isArabic;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(arabic),
        child: AnimatedContainer(
          duration: BarqDurations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: on ? BarqColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(BarqRadius.pill),
          ),
          child: Text(label,
              style: BarqText.pill
                  .copyWith(color: on ? Colors.white : BarqColors.muted)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BarqRadius.pill),
        boxShadow: BarqShadows.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [option('ع', true), option('EN', false)],
      ),
    );
  }
}

/// .qty — quantity stepper (+ orange, − grey; shows trash at 1 when [trashAtOne]).
class BarqQtyStepper extends StatelessWidget {
  const BarqQtyStepper(
      {super.key,
      required this.value,
      required this.onChanged,
      this.min = 0,
      this.max = 99,
      this.trashAtOne = false,
      this.large = false});

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool trashAtOne;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    Widget btn(String icon, bool on, VoidCallback? tap) => GestureDetector(
          onTap: tap,
          child: Container(
            width: BarqSizes.qtyButton,
            height: BarqSizes.qtyButton,
            decoration: BoxDecoration(
                color: on
                    ? BarqColors.primary
                    : (p.isDark ? BarqColors.darkChip : BarqColors.chipMuted),
                shape: BoxShape.circle),
            alignment: Alignment.center,
            child: BarqIcon(icon,
                size: BarqSizes.iconS, color: on ? Colors.white : p.text),
          ),
        );
    final showTrash = trashAtOne && value <= 1;
    // RTL: + is on the right (start), − on the left — same as the design.
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.input,
        borderRadius: BorderRadius.circular(BarqRadius.pill),
        border: Border.all(
            color: p.isDark ? BarqColors.darkLine : BarqColors.qtyBorder,
            width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(BarqIconsInternal.plus, true,
              value < max ? () => onChanged(value + 1) : null),
          SizedBox(
            width: 34,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: BarqText.tBold
                    .copyWith(fontSize: large ? 18 : 15, color: p.text)),
          ),
          btn(showTrash ? BarqIconsInternal.trash : BarqIconsInternal.minus,
              false, value > min ? () => onChanged(value - 1) : null),
        ],
      ),
    );
  }
}

/// .tg — on/off toggle (orange when on; green variant for the driver "متصل").
class BarqToggle extends StatelessWidget {
  const BarqToggle(
      {super.key,
      required this.value,
      required this.onChanged,
      this.activeColor = BarqColors.primary});
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: BarqDurations.fast,
          width: 50,
          height: 30,
          padding: const EdgeInsets.all(3),
          alignment: value
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          decoration: BoxDecoration(
            color: value
                ? activeColor
                : (BarqPalette.of(context).isDark
                    ? BarqColors.darkLine
                    : BarqColors.toggleOff),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 2),
                    blurRadius: 4)
              ],
            ),
          ),
        ),
      );
}

/// .rad — radio dot.
class BarqRadio extends StatelessWidget {
  const BarqRadio({super.key, required this.selected, this.onTap});
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: BarqDurations.fast,
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? BarqColors.primary
                  : (BarqPalette.of(context).isDark
                      ? const Color(0xFF4A3D36)
                      : BarqColors.radioOff),
              width: selected ? 7 : 2,
            ),
          ),
        ),
      );
}

/// Square checkbox (24px, radius 8) used in cart "تحديد الكل" and delete confirmation.
class BarqCheckbox extends StatelessWidget {
  const BarqCheckbox(
      {super.key,
      required this.value,
      this.onChanged,
      this.activeColor = BarqColors.primary,
      this.size = 24});
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final double size;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: BarqDurations.fast,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: value ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(size / 3),
            border:
                value ? null : Border.all(color: BarqColors.radioOff, width: 2),
          ),
          alignment: Alignment.center,
          child: value
              ? BarqIcon(BarqIconsInternal.check,
                  size: size * .66, color: Colors.white)
              : null,
        ),
      );
}
