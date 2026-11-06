import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../data/earnings_models.dart';
import '../data/earnings_repository.dart';
import '../state/earnings_cubit.dart';

/// The server has no comparison with the last period, so the design's
/// "+12% عن الماضي" pill is hidden.
class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  String _title(AppLocalizations l10n, EarningsPeriod period) =>
      switch (period) {
        EarningsPeriod.day => l10n.earningsOfDay,
        EarningsPeriod.week => l10n.earningsOfWeek,
        EarningsPeriod.month => l10n.earningsOfMonth,
      };

  /// A letter per weekday, as in the design. A month has too many bars for
  /// that, so every fifth day shows its number.
  String _label(EarningsDay day, EarningsPeriod period, String locale) =>
      switch (period) {
        EarningsPeriod.month => day.date.day % 5 == 0 ? '${day.date.day}' : '',
        _ => DateFormat.EEEEE(locale).format(day.date),
      };

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final cubit = context.read<EarningsCubit>();
    final locale = Localizations.localeOf(context).languageCode;
    return BlocBuilder<EarningsCubit, EarningsState>(
      builder: (context, state) {
        final earnings = state.earnings;
        final cash = state.cash;
        return DesignOverlay(
          image: 'design/09_driver_delivery_02.png',
          child: RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.only(bottom: BarqSpacing.navClearance),
              children: [
                BarqHeader(
                  large: true,
                  title: l10n.navEarnings,
                  bottom: BarqSegmented<EarningsPeriod>(
                    value: state.period,
                    onChanged: cubit.choose,
                    options: [
                      (value: EarningsPeriod.day, label: l10n.periodDay),
                      (value: EarningsPeriod.week, label: l10n.periodWeek),
                      (value: EarningsPeriod.month, label: l10n.periodMonth),
                    ],
                  ),
                ),
                const SizedBox(height: BarqSpacing.section),
                if (state.loading)
                  const _EarningsSkeleton()
                else if (state.error != null)
                  BarqMessageView(
                    title: state.error!,
                    icon: BarqIcons.alert,
                    actionLabel: l10n.commonRetry,
                    onAction: cubit.load,
                  )
                else ...[
                  if (earnings != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: BarqSpacing.page,
                      ),
                      child: BarqCard(
                        padding: const EdgeInsets.all(18),
                        child: BarqGap(
                          gap: BarqSpacing.section,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _title(l10n, state.period),
                                  style: BarqText.xs.copyWith(
                                    color: p.textMuted,
                                  ),
                                ),
                                Text(
                                  earnings.earnings.formatted,
                                  style: BarqText.h0.copyWith(color: p.text),
                                ),
                                Text(
                                  l10n.earningsOrders(earnings.orders),
                                  style: BarqText.xs.copyWith(
                                    color: p.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            BarqBarChart(
                              bars: [
                                for (final day in earnings.series)
                                  BarqBar(
                                    label: _label(day, state.period, locale),
                                    value: day.earnings.amount,
                                    active: _isToday(day.date),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (cash != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        BarqSpacing.page,
                        BarqSpacing.gap,
                        BarqSpacing.page,
                        0,
                      ),
                      child: BarqCard(
                        child: BarqGap(
                          gap: BarqSpacing.md,
                          children: [
                            Row(
                              children: [
                                const BarqIconTile(
                                  BarqIcons.cash,
                                  tone: BarqTileTone.yellow,
                                ),
                                const SizedBox(width: BarqSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.cashOnHand,
                                        style: BarqText.h3.copyWith(
                                          color: p.text,
                                        ),
                                      ),
                                      Text(
                                        l10n.cashLimitMax(
                                          cash.maxCash.formatted,
                                        ),
                                        style: BarqText.xs.copyWith(
                                          color: p.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  cash.cashOnHand.formatted,
                                  style: BarqText.h2.copyWith(color: p.text),
                                ),
                              ],
                            ),
                            BarqProgressBar(value: cash.usedShare),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (cash.remaining != null)
                                  Flexible(
                                    child: Text(
                                      l10n.cashRemaining(
                                        cash.remaining!.formatted,
                                      ),
                                      style: BarqText.xs.copyWith(
                                        color: BarqColors.cashYellow,
                                      ),
                                    ),
                                  ),
                                Flexible(
                                  child: Text(
                                    l10n.cashUnsettled(cash.unsettledOrders),
                                    style: BarqText.xs.copyWith(
                                      color: p.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The earnings while they load: the total with its bar chart, and the cash
/// card with its limit bar.
class _EarningsSkeleton extends StatelessWidget {
  const _EarningsSkeleton();

  static const _bars = [.45, .7, .35, .9, .6, .8, .5];

  @override
  Widget build(BuildContext context) => BarqSkeleton(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
      child: BarqSkeletonColumn(
        children: [
          BarqCardBone(
            padding: const EdgeInsets.all(18),
            child: BarqSkeletonColumn(
              gap: BarqSpacing.section,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BarqTextBone(BarqText.xs, widthFactor: .3),
                    BarqTextBone(BarqText.h0, widthFactor: .45),
                  ],
                ),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < _bars.length; i++) ...[
                        if (i > 0) const SizedBox(width: BarqSpacing.sm),
                        Expanded(
                          child: FractionallySizedBox(
                            heightFactor: _bars[i],
                            alignment: Alignment.bottomCenter,
                            child: const BarqBone(radius: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const BarqCardBone(
            child: BarqSkeletonColumn(
              gap: BarqSpacing.md,
              children: [
                BarqTileRowSkeleton(
                  card: false,
                  padding: EdgeInsets.zero,
                  trailing: BarqTextBone(BarqText.h2, width: 56),
                ),
                BarqBone(height: 8, radius: 9),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
