import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/phone_number.dart';
import '../state/edit_profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _onState(BuildContext context, EditProfileState state) {
    final profile = state.profile;
    if (state.done) {
      context.pop();
    } else if (profile != null) {
      if (_name.text != state.name) _name.text = state.name;
      _phone.text = PhoneNumber.display(profile.phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<EditProfileCubit>();
    return DesignOverlay(
      image: 'design/06_account_02.png',
      child: BarqScreen(
        body: BlocConsumer<EditProfileCubit, EditProfileState>(
          listener: _onState,
          builder: (context, state) {
            final loadError = state.loadError;
            final header = BarqHeader(title: l10n.profileTitle, back: true);
            if (state.loading || state.profile == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  Expanded(
                    child: loadError == null
                        ? const BarqLoadingView()
                        : BarqMessageView(
                            title: loadError,
                            icon: BarqIcons.alert,
                            actionLabel: l10n.commonRetry,
                            onAction: cubit.load,
                          ),
                  ),
                ],
              );
            }
            return _ProfileForm(
              header: header,
              state: state,
              name: _name,
              phone: _phone,
            );
          },
        ),
      ),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({
    required this.header,
    required this.state,
    required this.name,
    required this.phone,
  });

  final Widget header;
  final EditProfileState state;
  final TextEditingController name;
  final TextEditingController phone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<EditProfileCubit>();
    final picked = state.picked;
    final error = state.error;
    return BarqFillScroll(
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(
          BarqSpacing.page,
          BarqSpacing.section,
          BarqSpacing.page,
          BarqSpacing.stateBottom,
        ),
        child: BarqGap(
          gap: BarqSpacing.xs,
          children: [
            if (error != null)
              BarqNote(error, icon: BarqIcons.alert, tone: BarqNoteTone.danger),
            BarqButton(
              label: l10n.profileSave,
              loading: state.saving,
              onPressed: state.canSave ? cubit.save : null,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(BarqSpacing.md),
                child: BarqLink(
                  l10n.profileDelete,
                  color: BarqColors.danger,
                  onPressed: () => context.push(Routes.accountDelete),
                ),
              ),
            ),
          ],
        ),
      ),
      children: [
        header,
        SizedBox(
          height: BarqSizes.profileAvatarArea,
          child: Center(
            child: GestureDetector(
              onTap: cubit.pickPhoto,
              child: BarqAvatar(
                state.initial,
                size: BarqSizes.profileAvatarLarge,
                border: 5,
                imageUrl: state.profile?.avatarUrl,
                image: picked == null ? null : FileImage(picked),
                badge: const BarqIconButton(
                  icon: BarqIcons.camera,
                  size: BarqSizes.profileAvatarBadge,
                  background: BarqColors.ink,
                  iconColor: BarqColors.white,
                ),
              ),
            ),
          ),
        ),
        BarqGap(
          gap: BarqSpacing.section,
          padding: const EdgeInsets.symmetric(horizontal: BarqSpacing.page),
          children: [
            BarqInput(
              label: l10n.profileName,
              controller: name,
              textInputAction: TextInputAction.done,
              onChanged: cubit.nameChanged,
            ),
            BarqInput(
              label: l10n.profilePhone,
              controller: phone,
              icon: BarqIcons.lock,
              helper: l10n.profilePhoneHelper,
              enabled: false,
              textDirection: TextDirection.ltr,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BarqFieldLabel(l10n.profileLanguage),
                BarqSegmented<String>(
                  value: state.language,
                  onChanged: cubit.languageChanged,
                  options: const [
                    (value: 'ar', label: 'العربية'),
                    (value: 'en', label: 'English'),
                  ],
                ),
              ],
            ),
            BarqCard(
              onTap: () => context.push(Routes.addresses),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: BarqSpacing.gap,
              ),
              child: BarqListTile(
                title: l10n.accountMyAddresses,
                subtitle: l10n.profileAddressesBody,
                leading: const BarqIconTile(BarqIcons.pin),
                showDivider: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
