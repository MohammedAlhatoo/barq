import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../jobs/data/job_models.dart';
import '../../jobs/data/location_source.dart';
import '../../jobs/ui/widgets/job_map.dart';

class TooFarArgs {
  const TooFarArgs(this.job, this.error);

  final Job job;
  final ApiException error;
}

/// The server refused a step because the driver is outside `geofence_meters`.
/// Pops true for "حاول مرة أخرى", after sending a fresh location: the server
/// measures from the last location it has.
class TooFarScreen extends StatefulWidget {
  const TooFarScreen({super.key, required this.args});

  final TooFarArgs args;

  @override
  State<TooFarScreen> createState() => _TooFarScreenState();
}

class _TooFarScreenState extends State<TooFarScreen> {
  static const _sheetHeight = 340.0;
  static const _alert = 56.0;

  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    final tracker = context.read<AppDependencies>().tracker;
    try {
      await tracker.sendNow();
    } on LocationFailure catch (e) {
      debugPrint('No fresh location before retry: ${e.problem}');
    } on ApiException catch (e) {
      debugPrint('No fresh location before retry: $e');
    }
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = BarqPalette.of(context);
    final job = widget.args.job;
    final next = job.nextAction!;
    final atStore = job.isHeadingToStore;
    final place = atStore ? job.pickup : job.dropoff;
    final name = atStore ? job.storeName : job.customerName ?? '';
    final distance = NextAction.distanceIn(widget.args.error);
    return DesignOverlay(
      image: 'design/08_driver_jobs_07.png',
      child: BarqScreen(
        body: Stack(
          children: [
            Positioned.fill(
              child: JobMap(
                job: job,
                bottomInset: _sheetHeight,
                fence: place,
                fenceMeters: next.geofenceMeters,
              ),
            ),
            const BarqHeader(back: true),
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: BarqSheet(
                  gap: 14,
                  children: [
                    Row(
                      children: [
                        BarqIconTile(
                          BarqIcons.alert,
                          tone: BarqTileTone.red,
                          size: _alert,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                atStore
                                    ? l10n.tooFarStore
                                    : l10n.tooFarCustomer,
                                style: BarqText.h2.copyWith(color: p.text),
                              ),
                              if (distance != null)
                                Text(
                                  l10n.tooFarDistance(distance),
                                  style: BarqText.xs.copyWith(
                                    color: p.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      l10n.tooFarBody(
                        next.label,
                        next.geofenceMeters ?? 0,
                        name,
                      ),
                      style: BarqText.body.copyWith(
                        color: BarqColors.darkSubtle,
                      ),
                    ),
                    if (place.hasLocation)
                      BarqButton(
                        label: l10n.tooFarNavigate,
                        icon: BarqIcons.nav,
                        onPressed: () => context
                            .read<AppDependencies>()
                            .deviceActions
                            .navigate(place.lat!, place.lng!),
                      ),
                    BarqButton(
                      label: l10n.tooFarRetry,
                      icon: BarqIcons.refresh,
                      variant: BarqButtonVariant.white,
                      loading: _retrying,
                      onPressed: _retry,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
