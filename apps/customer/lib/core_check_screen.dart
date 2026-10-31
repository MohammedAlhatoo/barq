import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

/// Temporary phase 1 check: shows that barq_core reaches the real server.
/// Phase 2 replaces it with the real app shell.
class CoreCheckScreen extends StatefulWidget {
  const CoreCheckScreen({super.key, required this.store});

  final ConfigStore store;

  @override
  State<CoreCheckScreen> createState() => _CoreCheckScreenState();
}

class _CoreCheckScreenState extends State<CoreCheckScreen> {
  static const _padding = EdgeInsets.fromLTRB(
    BarqSpacing.page,
    BarqSpacing.headerTop,
    BarqSpacing.page,
    BarqSpacing.section,
  );

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.store.load();
    } on ApiException catch (e) {
      _error = '${e.code} (${e.status})\n${e.messageAr}';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => BarqScreen(body: _body());

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final error = _error;
    if (error != null) {
      return ListView(
        padding: _padding,
        children: [
          BarqNote(error),
          const SizedBox(height: BarqSpacing.section),
          BarqButton(label: 'إعادة المحاولة', onPressed: _load),
        ],
      );
    }

    final config = widget.store.config;
    final statuses = config.statuses;
    if (statuses.isEmpty) {
      return const Center(child: Text('لا توجد حالات بالإعدادات'));
    }
    return ListView(
      padding: _padding,
      children: [
        Text('العملة: ${config.currencySymbol}'),
        Text('التسليم: ${config.deliveryConfirmation}'),
        Text('الدفع: ${config.paymentMethods.join('، ')}'),
        Text('التحديث: كل ${config.polling.eventsSeconds} ثانية'),
        const SizedBox(height: BarqSpacing.section),
        Wrap(
          spacing: BarqSpacing.gap,
          runSpacing: BarqSpacing.gap,
          children: [
            for (final status in statuses) OrderStatusPill(status.key),
          ],
        ),
        const SizedBox(height: BarqSpacing.section),
        OrderStatusTimeline(
          keys: OrderTimelines.waiting,
          current: statuses[statuses.length ~/ 2].key,
          currentTrailing: const BarqPill('الآن'),
        ),
      ],
    );
  }
}
