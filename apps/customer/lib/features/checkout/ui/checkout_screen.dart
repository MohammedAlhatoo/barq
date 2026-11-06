import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/countdown.dart';
import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../account/ui/widgets/address_label.dart';
import '../../account/ui/widgets/address_picker_sheet.dart';
import '../../cart/ui/widgets/empty_cart_view.dart';
import '../../cart/ui/widgets/out_of_zone_view.dart';
import '../data/checkout_models.dart';
import '../state/checkout_cubit.dart';
import 'widgets/quote_expired_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _coupon = TextEditingController();
  final _note = TextEditingController();
  bool _sheetOpen = false;

  @override
  void dispose() {
    _coupon.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickAddress() async {
    final cubit = context.read<CheckoutCubit>();
    final address = await AddressPickerSheet.show(
      context,
      selectedId: cubit.state.address?.id,
    );
    if (address != null) await cubit.changeAddress(address);
  }

  /// Picking a store there changes the cart, so it is checked again here.
  Future<void> _openCompare() async {
    final cubit = context.read<CheckoutCubit>();
    await context.push(Routes.compare, extra: cubit.state.address);
    if (mounted) await cubit.start();
  }

  Future<void> _showExpired(Repricing repricing) async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    final review = await QuoteExpiredSheet.show(context, repricing);
    _sheetOpen = false;
    if (review == true && mounted) context.pop();
  }

  void _listen(BuildContext context, CheckoutState state) {
    final id = state.placedOrderId;
    final repricing = state.repricing;
    if (id != null) {
      final deps = context.read<AppDependencies>();
      deps.accountRepository.orderPlaced();
      deps.ordersRepository.ordersChanged();
      context.go(Routes.orderOf(id));
    } else if (repricing != null) {
      _showExpired(repricing);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listenWhen: (previous, current) =>
          previous.placedOrderId != current.placedOrderId ||
          previous.repricing != current.repricing,
      listener: _listen,
      builder: (context, state) {
        if (state.emptyCart) return const EmptyCartView();
        if (state.outOfZone) {
          return OutOfZoneView(
            code: '422 out_of_zone',
            onChangeAddress: _pickAddress,
          );
        }
        if (state.storeOutOfZone) {
          return OutOfZoneView(
            onChangeAddress: _pickAddress,
            onCompare: _openCompare,
          );
        }
        final Widget body = switch (state) {
          CheckoutState(loading: true) => const _CheckoutSkeleton(),
          CheckoutState(noAddress: true) => BarqMessageView(
            title: l10n.noAddressTitle,
            message: l10n.checkoutNoAddressBody,
            icon: BarqIcons.pin,
            actionLabel: l10n.noAddressAdd,
            onAction: _pickAddress,
          ),
          CheckoutState(:final error?) => BarqMessageView(
            title: error,
            icon: BarqIcons.alert,
            actionLabel: l10n.commonRetry,
            onAction: context.read<CheckoutCubit>().start,
          ),
          _ => _form(l10n, state),
        };
        return DesignOverlay(
          image: 'design/03_checkout_04.png',
          child: BarqScreen(
            body: state.quote == null || state.loading || state.error != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BarqHeader(title: l10n.checkoutTitle, back: true),
                      Expanded(child: body),
                    ],
                  )
                : body,
          ),
        );
      },
    );
  }

  Widget _form(AppLocalizations l10n, CheckoutState state) {
    final cubit = context.read<CheckoutCubit>();
    final quote = state.quote!;
    final coupons = ConfigScope.of(context).config.hasModule('coupons');
    return BarqFillScroll(
      padding: const EdgeInsets.only(bottom: BarqSpacing.stateBottom),
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(
          BarqSpacing.page,
          BarqSpacing.section,
          BarqSpacing.page,
          0,
        ),
        child: BarqGap(
          gap: BarqSpacing.md,
          children: [
            if (state.placeError case final error?)
              BarqNote(error, icon: BarqIcons.alert, tone: BarqNoteTone.danger),
            _PriceHeld(seconds: state.secondsLeft),
            BarqButton(
              label: l10n.checkoutConfirm(quote.total.formatted),
              loading: state.placing,
              onPressed: state.canPlace ? cubit.confirm : null,
            ),
          ],
        ),
      ),
      children: [
        BarqHeader(title: l10n.checkoutTitle, back: true),
        BarqGap(
          padding: const EdgeInsets.fromLTRB(
            BarqSpacing.page,
            BarqSpacing.section,
            BarqSpacing.page,
            0,
          ),
          children: [
            _AddressCard(state: state, onChange: _pickAddress),
            const _CashCard(),
            BarqGap(
              gap: BarqSpacing.sm,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.checkoutSubstitutions, style: BarqText.h3),
                BarqSegmented<Substitution>(
                  height: BarqSizes.checkoutSegment,
                  value: state.substitution,
                  onChanged: cubit.substitutionChanged,
                  options: [
                    (value: Substitution.callMe, label: l10n.subCallMe),
                    (value: Substitution.similar, label: l10n.subSimilar),
                    (value: Substitution.skip, label: l10n.subSkip),
                  ],
                ),
              ],
            ),
            if (coupons) _couponRow(l10n, state),
            BarqInput(
              controller: _note,
              icon: BarqIcons.chat,
              hint: l10n.checkoutNoteHint,
              height: BarqSizes.inputCompact,
              radius: BarqRadius.iconTile,
              enabled: !state.locked,
              onChanged: cubit.noteChanged,
            ),
            _Totals(quote: quote),
          ],
        ),
      ],
    );
  }

  Widget _couponRow(AppLocalizations l10n, CheckoutState state) {
    final cubit = context.read<CheckoutCubit>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BarqInput(
            controller: _coupon,
            icon: BarqIcons.tag,
            hint: l10n.checkoutCouponHint,
            errorText: state.couponError,
            height: BarqSizes.inputCompact,
            radius: BarqRadius.iconTile,
            enabled: !state.locked,
            textInputAction: TextInputAction.done,
            onChanged: cubit.couponEdited,
            onSubmitted: cubit.applyCoupon,
          ),
        ),
        const SizedBox(width: BarqSpacing.sm),
        SizedBox(
          height: BarqSizes.inputCompact,
          child: Center(
            child: state.coupon != null
                ? BarqPill(
                    l10n.checkoutCouponApplied,
                    tone: BarqPillTone.success,
                    icon: BarqIcons.check,
                  )
                : state.checkingCoupon
                ? const SizedBox.square(
                    dimension: BarqSizes.inputCompact,
                    child: BarqLoadingView(),
                  )
                : BarqLink(
                    l10n.checkoutCouponApply,
                    onPressed: () => cubit.applyCoupon(_coupon.text),
                  ),
          ),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.state, required this.onChange});

  final CheckoutState state;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final address = state.address!;
    final distance = l10n.checkoutDistance(
      state.quote!.distanceKm.toStringAsFixed(1),
    );
    final details = address.details;
    return BarqCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: BarqSizes.checkoutMap,
            child: BarqMapBackground(
              children: [
                Center(
                  child: BarqMapPin(
                    icon: addressIcon(l10n, address),
                    size: BarqSizes.checkoutPin,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BarqSpacing.section,
              vertical: BarqSpacing.gap,
            ),
            child: Row(
              children: [
                Expanded(
                  child: BarqGap(
                    gap: 0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(addressTitle(l10n, address), style: BarqText.h3),
                      Text(
                        details == null || details.isEmpty
                            ? distance
                            : '$details · $distance',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BarqText.xs,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: BarqSpacing.sm),
                if (!state.locked)
                  BarqLink(l10n.checkoutChange, onPressed: onChange),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cash is the only payment method, so it is always the chosen one.
class _CashCard extends StatelessWidget {
  const _CashCard();

  @override
  Widget build(BuildContext context) => BarqCard(
    padding: const EdgeInsets.symmetric(
      horizontal: BarqSpacing.section,
      vertical: BarqSpacing.gap,
    ),
    child: Row(
      children: [
        const BarqRadio(selected: true),
        const SizedBox(width: BarqSpacing.gap),
        const BarqIcon(BarqIcons.cash, color: BarqColors.success),
        const SizedBox(width: BarqSpacing.gap),
        Expanded(
          child: Text(
            AppLocalizations.of(context).checkoutCash,
            style: BarqText.tBold,
          ),
        ),
      ],
    ),
  );
}

class _Totals extends StatelessWidget {
  const _Totals({required this.quote});

  final OrderQuote quote;

  @override
  Widget build(BuildContext context) => BarqCard(
    padding: const EdgeInsets.symmetric(
      horizontal: BarqSpacing.section,
      vertical: BarqSpacing.gap,
    ),
    child: BarqGap(
      gap: BarqSpacing.sm,
      children: [
        for (final line in quote.breakdown)
          BarqSummaryRow(
            line.label,
            line.price.formatted,
            valueColor: line.kind == 'discount' ? BarqColors.successText : null,
          ),
        const BarqDivider(),
        BarqSummaryRow(
          AppLocalizations.of(context).checkoutTotal,
          quote.total.formatted,
          total: true,
        ),
      ],
    ),
  );
}

class _PriceHeld extends StatelessWidget {
  const _PriceHeld({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const BarqIcon(BarqIcons.clock, size: BarqSizes.iconS),
      const SizedBox(width: BarqSpacing.xs),
      Flexible(
        child: Text(
          AppLocalizations.of(context).checkoutPriceHeld,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: BarqText.xs,
        ),
      ),
      const SizedBox(width: BarqSpacing.xs),
      Text(
        formatCountdown(seconds),
        textDirection: TextDirection.ltr,
        style: BarqText.xs.copyWith(
          color: BarqColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

/// The checkout form while the quote loads: the address card with its map,
/// the payment choice, the note field and the totals.
class _CheckoutSkeleton extends StatelessWidget {
  const _CheckoutSkeleton();

  @override
  Widget build(BuildContext context) => const BarqSkeletonPage(
    padding: EdgeInsets.fromLTRB(
      BarqSpacing.page,
      BarqSpacing.section,
      BarqSpacing.page,
      0,
    ),
    children: [
      BarqTextBone(BarqText.h3, widthFactor: .3),
      BarqCardBone(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BarqBone(height: BarqSizes.checkoutMap, radius: 0),
            BarqTileRowSkeleton(card: false, lines: 1),
          ],
        ),
      ),
      BarqTextBone(BarqText.h3, widthFactor: .3),
      BarqTileRowSkeleton(lines: 0, tile: 24),
      BarqBone(height: BarqSizes.inputCompact, radius: BarqRadius.input),
      BarqSummaryCardSkeleton(rows: 3),
    ],
  );
}
