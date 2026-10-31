import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const BarqCustomerApp());
}

/// Temporary root for phase 0: shows BarqGallery to prove fonts and icons load.
class BarqCustomerApp extends StatelessWidget {
  const BarqCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barq',
      debugShowCheckedModeBanner: false,
      theme: barqLightTheme(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const BarqGallery(),
    );
  }
}
