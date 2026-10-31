import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/cart/state/cart_cubit.dart';
import '../features/notifications/state/unread_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import 'di.dart';
import 'router.dart';

/// The logged-in part of the app: 4 tabs + the cart button in the middle.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _ordersTab = 2;

  late final UnreadCubit _unread;

  @override
  void initState() {
    super.initState();
    _startPush();
    final deps = context.read<AppDependencies>();
    deps.scope.loadName();
    _unread = deps.unread..start();
  }

  @override
  void dispose() {
    _unread.stop();
    super.dispose();
  }

  /// Only after login, because the token is saved on the user's account.
  Future<void> _startPush() async {
    final deps = context.read<AppDependencies>();
    if (!await deps.authRepository.notificationsEnabled()) return;
    await deps.push.init();
    await deps.push.registerToken();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cartCount = context.select<CartCubit, int>(
      (cart) => cart.state.count,
    );
    return BarqScreen(
      body: widget.shell,
      bottomNavigationBar: BarqNavBar(
        items: [
          BarqNavItem(icon: BarqIcons.home, label: l10n.navHome),
          BarqNavItem(icon: BarqIcons.grid, label: l10n.navCategories),
          BarqNavItem(icon: BarqIcons.receipt, label: l10n.navOrders),
          BarqNavItem(icon: BarqIcons.user, label: l10n.navAccount),
        ],
        currentIndex: widget.shell.currentIndex,
        onTap: (index) {
          if (index == _ordersTab) {
            context.read<AppDependencies>().ordersRepository.ordersChanged();
          }
          widget.shell.goBranch(
            index,
            initialLocation: index == widget.shell.currentIndex,
          );
        },
        fabIcon: BarqIcons.bag,
        fabBadge: cartCount,
        onFab: () => context.push(Routes.cart),
      ),
    );
  }
}
