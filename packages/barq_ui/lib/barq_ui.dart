/// Barq (برق) design system.
///
/// ```dart
/// import 'package:barq_ui/barq_ui.dart';
///
/// MaterialApp(
///   theme: barqLightTheme(),            // customer app
///   // theme: barqDarkTheme(),          // driver app (Barq Captain)
///   locale: const Locale('ar'),
///   ...
/// );
/// ```
///
/// Rules: screens are built ONLY from these widgets + tokens. If something is
/// missing, ask the barq_ui owner to add it here — never draw it inside a screen.
library;

export 'src/dev/barq_gallery.dart';
export 'src/dev/design_overlay.dart';
export 'src/foundation/barq_asset_names.dart';
export 'src/foundation/barq_assets.dart';
export 'src/foundation/barq_theme.dart';
export 'src/foundation/barq_tokens.dart';
export 'src/widgets/account.dart';
export 'src/widgets/buttons.dart' hide BarqIconsInternal;
export 'src/widgets/chat.dart';
export 'src/widgets/driver.dart';
export 'src/widgets/indicators.dart';
export 'src/widgets/inputs.dart';
export 'src/widgets/layout.dart';
export 'src/widgets/misc.dart';
export 'src/widgets/nav_bar.dart';
export 'src/widgets/product.dart';
export 'src/widgets/surfaces.dart';
export 'src/widgets/vendor.dart';
