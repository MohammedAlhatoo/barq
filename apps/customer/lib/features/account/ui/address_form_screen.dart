import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/location_repository.dart';
import '../state/address_form_cubit.dart';
import 'widgets/address_map.dart';

/// Adds or edits an address. Closes with the saved address.
class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  late final AddressFormCubit _cubit = context.read<AddressFormCubit>();
  late final _details = TextEditingController(text: _cubit.state.details);
  late final _customLabel = TextEditingController(
    text: _cubit.state.customLabel,
  );

  @override
  void dispose() {
    _details.dispose();
    _customLabel.dispose();
    super.dispose();
  }

  String? _problem(AppLocalizations l10n, AddressFormState state) {
    if (state.locationFailed) return l10n.addressLocateFailed;
    return switch (state.locationProblem) {
      LocationProblem.serviceOff => l10n.welcomeLocationOff,
      LocationProblem.denied => l10n.welcomeLocationDenied,
      null => state.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DesignOverlay(
      image: 'design/06_account_05.png',
      child: BarqScreen(
        body: BlocConsumer<AddressFormCubit, AddressFormState>(
          listenWhen: (previous, current) =>
              previous.saved == null && current.saved != null,
          listener: (context, state) => context.pop(state.saved),
          // LayoutBuilder gives the height left above the keyboard. The sheet
          // takes all but a strip of map, and scrolls inside that space.
          builder: (context, state) => LayoutBuilder(
            builder: (context, box) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AddressMap(
                          lat: state.lat,
                          lng: state.lng,
                          moves: state.mapMoves,
                          hint: l10n.addressMapHint,
                          credit: l10n.addressMapCredit,
                          onMoved: _cubit.pointChanged,
                        ),
                      ),
                      BarqHeader(
                        back: true,
                        trailing: state.locating
                            ? const SizedBox.square(
                                dimension: BarqSizes.iconButton,
                                child: BarqLoadingView(),
                              )
                            : BarqIconButton(
                                icon: BarqIcons.locate,
                                iconColor: BarqColors.primary,
                                onPressed: _cubit.locate,
                              ),
                      ),
                    ],
                  ),
                ),
                // The sheet's round corners sit on the same color as the map.
                ColoredBox(
                  color: BarqColors.mapBg,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: box.maxHeight - BarqSizes.addressMapMin,
                    ),
                    child: SingleChildScrollView(child: _sheet(l10n, state)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheet(AppLocalizations l10n, AddressFormState state) {
    final problem = _problem(l10n, state);
    return BarqSheet(
      gap: 14,
      children: [
        Text(l10n.addressFormTitle, style: BarqText.h2),
        Wrap(
          spacing: BarqSpacing.sm,
          runSpacing: BarqSpacing.sm,
          children: [
            _kindChip(
              state,
              AddressKind.home,
              l10n.addressHome,
              BarqIcons.home,
            ),
            _kindChip(state, AddressKind.work, l10n.addressWork, null),
            _kindChip(state, AddressKind.other, l10n.addressOther, null),
          ],
        ),
        if (state.kind == AddressKind.other)
          BarqInput(
            controller: _customLabel,
            hint: l10n.addressOtherHint,
            onChanged: _cubit.customLabelChanged,
          ),
        _ZoneRow(zone: state.zone),
        BarqInput(
          controller: _details,
          hint: l10n.addressDetailsHint,
          onChanged: _cubit.detailsChanged,
        ),
        // The address that is already the default cannot be switched off:
        // that would leave the user with none.
        if (_cubit.existing?.isDefault != true)
          Row(
            children: [
              BarqToggle(
                value: state.isDefault,
                onChanged: _cubit.defaultChanged,
              ),
              const SizedBox(width: BarqSpacing.md),
              Expanded(child: Text(l10n.addressMakeDefault, style: BarqText.t)),
            ],
          ),
        if (problem != null)
          BarqNote(problem, icon: BarqIcons.alert, tone: BarqNoteTone.danger),
        BarqButton(
          label: l10n.addressSave,
          loading: state.saving,
          onPressed: _cubit.save,
        ),
      ],
    );
  }

  Widget _kindChip(
    AddressFormState state,
    AddressKind kind,
    String label,
    String? icon,
  ) => BarqChip(
    label: label,
    icon: state.kind == kind ? icon : null,
    height: BarqSizes.optionChip + 2,
    selected: state.kind == kind,
    onTap: () => _cubit.kindChanged(kind),
  );
}

class _ZoneRow extends StatelessWidget {
  const _ZoneRow({required this.zone});

  final AddressZone zone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BarqCard(
      shadow: const [],
      borderColor: BarqPalette.of(context).inputBorder,
      child: Row(
        children: [
          const BarqIcon(
            BarqIcons.pin,
            size: BarqSizes.iconM,
            color: BarqColors.primary,
          ),
          const SizedBox(width: BarqSpacing.md),
          Expanded(
            child: Text(
              zone == AddressZone.unknown
                  ? l10n.addressZoneUnknown
                  : l10n.addressZoneLabel,
              style: BarqText.t,
            ),
          ),
          if (zone == AddressZone.inside)
            BarqPill(l10n.addressInZone, tone: BarqPillTone.success),
          if (zone == AddressZone.outside)
            BarqPill(l10n.addressOutOfZone, tone: BarqPillTone.danger),
        ],
      ),
    );
  }
}
