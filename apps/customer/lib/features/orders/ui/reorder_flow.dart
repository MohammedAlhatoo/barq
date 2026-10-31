import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../cart/state/cart_cubit.dart';

/// Asks before replacing a full cart, runs [rebuild], says what is missing and
/// opens the cart. [rebuild] answers the missing count, or null if it failed.
Future<void> reorderToCart(
  BuildContext context,
  Future<int?> Function() rebuild,
) async {
  final l10n = AppLocalizations.of(context);
  final router = GoRouter.of(context);
  if (!context.read<CartCubit>().state.isEmpty) {
    final replace = await showBarqSheet<bool>(
      context,
      children: [
        Text(l10n.reorderReplaceTitle, style: BarqText.h2),
        Text(l10n.reorderReplaceBody, style: BarqText.body),
        BarqButton(
          label: l10n.reorderReplaceConfirm,
          onPressed: () => closeBarqSheet(context, true),
        ),
        BarqButton(
          label: l10n.commonKeepCart,
          variant: BarqButtonVariant.light,
          onPressed: () => closeBarqSheet(context, false),
        ),
      ],
    );
    if (replace != true) return;
  }
  final missing = await rebuild();
  if (missing == null || !context.mounted) return;
  if (missing > 0) {
    await showBarqSheet<void>(
      context,
      children: [
        Text(l10n.reorderMissing(missing), style: BarqText.h3),
        BarqButton(
          label: l10n.commonOk,
          onPressed: () => closeBarqSheet<void>(context),
        ),
      ],
    );
  }
  router
    ..go(Routes.home)
    ..push(Routes.cart);
}
