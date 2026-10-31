import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/system_cubit.dart';
import 'maintenance_view.dart';
import 'no_internet_view.dart';
import 'session_expired_view.dart';
import 'update_required_view.dart';

/// Shows the system screen on top of the whole app. The routes stay alive
/// underneath, so the user returns to the same place once the problem is gone.
class SystemGate extends StatelessWidget {
  const SystemGate({super.key, required this.child, required this.onLogin});

  final Widget child;

  /// Opens the login screen. The router is above this widget's context.
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SystemCubit>();
    return BlocBuilder<SystemCubit, SystemState>(
      builder: (context, state) => Stack(
        fit: StackFit.expand,
        children: [
          child,
          ?switch (state.issue) {
            null => null,
            SystemIssue.offline => NoInternetView(
              onRetry: cubit.retry,
              loading: state.checking,
            ),
            SystemIssue.updateRequired => UpdateRequiredView(
              onCheck: cubit.retry,
              loading: state.checking,
            ),
            SystemIssue.maintenance => MaintenanceView(
              onRefresh: cubit.retry,
              loading: state.checking,
            ),
            SystemIssue.sessionExpired => SessionExpiredView(
              onLogin: () {
                cubit.clear();
                onLogin();
              },
            ),
          },
        ],
      ),
    );
  }
}
