import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../data/browse_models.dart';

/// "All" plus one chip per category. Null is the "all" chip.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<Category> categories;
  final int? selected;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) => BarqChipsRow(
    children: [
      BarqChip(
        label: AppLocalizations.of(context).homeAll,
        selected: selected == null,
        onTap: () => onSelected(null),
      ),
      for (final category in categories)
        BarqChip(
          label: category.name,
          selected: selected == category.id,
          onTap: () => onSelected(category.id),
        ),
    ],
  );
}
