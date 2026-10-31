import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/widgets.dart';

/// One order status as described by `GET /app/config`.
class StatusInfo {
  const StatusInfo({
    required this.key,
    required this.label,
    required this.color,
    required this.icon,
    required this.step,
    required this.isTerminal,
  });

  factory StatusInfo.fromJson(Map<String, dynamic> json) => StatusInfo(
    key: json['key'] as String,
    label: json['label'] as String,
    color: _parseHex(json['color'] as String),
    icon: json['icon'] as String,
    step: json['step'] as int,
    isTerminal: json['is_terminal'] as bool,
  );

  /// Used for a key the config does not know, so a screen never crashes.
  factory StatusInfo.unknown(String key) => StatusInfo(
    key: key,
    label: key,
    color: BarqColors.placeholder,
    icon: BarqIcons.clock,
    step: 0,
    isTerminal: false,
  );

  final String key;
  final String label;
  final Color color;
  final String icon;
  final int step;
  final bool isTerminal;

  /// Server icon names that barq_ui has under another name.
  static const _iconNames = {
    'badge-check': BarqIcons.check,
    'chef-hat': BarqIcons.package,
    'circle-check': BarqIcons.check,
    'circle-x': BarqIcons.x,
    'map-pin': BarqIcons.pin,
  };

  /// The barq_ui icon for [icon], or a clock for a name we do not know.
  String get barqIcon {
    if (BarqIcons.all.contains(icon)) return icon;
    return _iconNames[icon] ?? BarqIcons.clock;
  }

  static Color _parseHex(String hex) {
    final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    if (value == null) return BarqColors.placeholder;
    return Color(0xFF000000 | value);
  }
}
