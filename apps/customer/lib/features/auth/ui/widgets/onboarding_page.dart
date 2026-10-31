import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

/// One slide: illustration, big title and description.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.art,
    required this.title,
    required this.body,
  });

  final Widget art;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          art,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
            child: BarqGap(
              gap: BarqSpacing.md,
              children: [
                Text(title, style: BarqText.h0),
                Text(body, style: BarqText.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
