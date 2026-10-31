import 'package:flutter/widgets.dart';

import 'config_store.dart';

/// Puts a [ConfigStore] in the widget tree, so widgets such as
/// OrderStatusPill can read it and rebuild when it changes.
class ConfigScope extends InheritedNotifier<ConfigStore> {
  const ConfigScope({
    super.key,
    required ConfigStore store,
    required super.child,
  }) : super(notifier: store);

  static ConfigStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ConfigScope>();
    assert(scope != null, 'Wrap the app with ConfigScope');
    return scope!.notifier!;
  }
}
