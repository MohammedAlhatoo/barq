import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../state/proof_cubit.dart';
import '../too_far_screen.dart';

/// What both photo screens do: close when done, explain when too far.
class ProofListener extends StatelessWidget {
  const ProofListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => BlocListener<ProofCubit, ProofState>(
    listenWhen: (previous, current) =>
        current.done || previous.tooFar != current.tooFar,
    listener: (context, state) async {
      final cubit = context.read<ProofCubit>();
      final tooFar = state.tooFar;
      if (state.done) {
        context.pop(true);
      } else if (tooFar != null) {
        final retry = await context.push<bool>(
          Routes.taskTooFar,
          extra: TooFarArgs(cubit.job, tooFar),
        );
        if (retry ?? false) await cubit.send();
      }
    },
    child: child,
  );
}
