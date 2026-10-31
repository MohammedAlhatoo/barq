import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/profile/state/driver_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';

/// The logged-in part of the app: 4 tabs + the middle button, which opens the
/// current job while online and goes online while offline.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _jobsTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<DriverCubit>().load();
  }

  void _goOnline() {
    widget.shell.goBranch(_jobsTab);
    context.read<DriverCubit>().setOnline(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final online = context.select<DriverCubit, bool>(
      (cubit) => cubit.state.isOnline,
    );
    return BarqScreen(
      body: widget.shell,
      bottomNavigationBar: BarqNavBar(
        items: [
          BarqNavItem(icon: BarqIcons.home, label: l10n.navJobs),
          BarqNavItem(icon: BarqIcons.wallet, label: l10n.navEarnings),
          BarqNavItem(icon: BarqIcons.history, label: l10n.navHistory),
          BarqNavItem(icon: BarqIcons.user, label: l10n.navAccount),
        ],
        currentIndex: widget.shell.currentIndex,
        onTap: (index) => widget.shell.goBranch(
          index,
          initialLocation: index == widget.shell.currentIndex,
        ),
        fabIcon: online ? BarqIcons.bolt : BarqIcons.power,
        fabGradient: online ? null : BarqGradients.green,
        onFab: online ? () => context.push(Routes.task) : _goOnline,
      ),
    );
  }
}
