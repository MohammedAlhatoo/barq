import 'package:barq_core/barq_core.dart';
import 'package:barq_ui/barq_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../account/ui/widgets/address_picker_sheet.dart';
import '../../cart/state/cart_cubit.dart';
import '../data/assistant_models.dart';
import '../data/quantity_fit.dart';
import '../state/assistant_cubit.dart';
import 'widgets/assistant_store_card.dart';

/// "مساعد برق": the customer writes a list, and the conversation ends at the
/// checkout screen. The answers all come from [AssistantCubit].
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    context.read<AssistantCubit>().send(_input.text);
    _input.clear();
  }

  /// Runs after the frame, when the new bubble has its height.
  void _showNewest() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: BarqDurations.normal,
      curve: Curves.easeOut,
    );
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<AssistantCubit, AssistantState>(
      listener: (_, _) => _showNewest(),
      builder: (context, state) {
        final cubit = context.read<AssistantCubit>();
        return BarqScreen(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BarqHeader(title: l10n.assistantTitle, back: true),
              Expanded(
                child: ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.all(BarqSpacing.page),
                  itemCount: state.messages.length + (state.busy ? 1 : 0),
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: BarqSpacing.gap),
                  itemBuilder: (_, index) => index == state.messages.length
                      ? const BarqTypingBubble()
                      : _Message(state.messages[index], state: state),
                ),
              ),
              BarqChipsRow(
                children: [
                  _SuggestionChip(
                    label: l10n.assistantChipVegetables,
                    onTap: () => cubit.send(l10n.assistantListVegetables),
                  ),
                  _SuggestionChip(
                    label: l10n.assistantChipBreakfast,
                    onTap: () => cubit.send(l10n.assistantListBreakfast),
                  ),
                  _SuggestionChip(
                    label: l10n.assistantChipCooking,
                    onTap: () => cubit.send(l10n.assistantListCooking),
                  ),
                  _SuggestionChip(
                    label: l10n.assistantChipReorder,
                    onTap: () => cubit.reorderLast(l10n.assistantChipReorder),
                  ),
                  _SuggestionChip(
                    label: l10n.assistantChipWrite,
                    onTap: () {
                      cubit.showHint();
                      _focus.requestFocus();
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  BarqSpacing.page,
                  BarqSpacing.xs,
                  BarqSpacing.page,
                  BarqSpacing.stateBottom,
                ),
                child: BarqChatComposer(
                  controller: _input,
                  focusNode: _focus,
                  hint: l10n.assistantInputHint,
                  enabled: !state.busy,
                  onSend: _send,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final busy = context.select<AssistantCubit, bool>((c) => c.state.busy);
    return BarqChip(label: label, onTap: busy ? null : onTap);
  }
}

class _Message extends StatelessWidget {
  const _Message(this.message, {required this.state});

  final AssistantMessage message;
  final AssistantState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAnswer = state.canAnswer(message);
    return switch (message) {
      GreetingMessage() => BarqChatBubble(text: l10n.assistantGreeting),
      HintMessage() => BarqChatBubble(text: l10n.assistantHint),
      UserMessage(:final text) => BarqChatBubble(text: text, fromUser: true),
      final MatchesMessage matches => _MatchesBubble(
        message: matches,
        canAnswer: canAnswer,
      ),
      final StoresMessage stores => _StoresBubble(
        message: stores,
        canAnswer: canAnswer,
      ),
      final ProblemMessage problem => _ProblemBubble(
        message: problem,
        canAnswer: canAnswer,
      ),
    };
  }
}

/// What was found, the notes about it, and the button that confirms it.
class _MatchesBubble extends StatelessWidget {
  const _MatchesBubble({required this.message, required this.canAnswer});

  final MatchesMessage message;
  final bool canAnswer;

  /// "بندورة" reads as "البندورة" at the start of the Arabic sentence.
  static String _subject(AppLocalizations l10n, String name) =>
      l10n.localeName == 'ar' && RegExp(r'^[؀-ۿ]+$').hasMatch(name)
      ? 'ال$name'
      : name;

  static String? _note(AppLocalizations l10n, MatchedItem item) =>
      switch (item.note) {
        QuantityNote.none => null,
        QuantityNote.rounded => l10n.assistantRounded(item.title!, item.qty),
        QuantityNote.soldByKilo => l10n.assistantSoldByKilo(
          _subject(l10n, item.item.name),
          item.qty,
        ),
        QuantityNote.soldByLiter => l10n.assistantSoldByLiter(
          _subject(l10n, item.item.name),
          item.qty,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AssistantCubit>();
    final found = message.items.where((i) => i.product != null).toList();
    final notFound = message.items.where((i) => i.product == null).toList();
    return BarqChatBubble(
      child: BarqGap(
        gap: BarqSpacing.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            found.isEmpty ? l10n.assistantNothingFound : l10n.assistantFound,
            style: BarqText.tBold,
          ),
          for (final item in found)
            if (canAnswer)
              Row(
                children: [
                  Expanded(child: Text(item.title!, style: BarqText.t)),
                  const SizedBox(width: BarqSpacing.sm),
                  BarqQtyStepper(
                    value: item.qty,
                    min: 1,
                    max: context.read<CartCubit>().maxQty,
                    onChanged: (qty) => cubit.changeQty(item, qty),
                  ),
                ],
              )
            else
              Row(
                children: [
                  const BarqIcon(
                    BarqIcons.check,
                    size: BarqSizes.iconS,
                    color: BarqColors.successText,
                  ),
                  const SizedBox(width: BarqSpacing.xxs),
                  Expanded(
                    child: Text(
                      l10n.assistantLine(item.title!, item.qty),
                      style: BarqText.xs,
                    ),
                  ),
                ],
              ),
          for (final item in notFound) ...[
            Text(
              item.alternatives.isEmpty
                  ? l10n.assistantNotFound(item.item.name)
                  : l10n.assistantNotFoundPick(item.item.name),
              style: BarqText.t,
            ),
            if (canAnswer && item.alternatives.isNotEmpty)
              Wrap(
                spacing: BarqSpacing.sm,
                runSpacing: BarqSpacing.sm,
                children: [
                  for (final product in item.alternatives)
                    BarqChip(
                      label: product.name,
                      height: BarqSizes.optionChip,
                      maxLabelWidth: BarqSizes.chatChipLabel,
                      onTap: () => cubit.chooseAlternative(item, product.id),
                    ),
                ],
              ),
          ],
          for (final item in found)
            if (_note(l10n, item) case final note?)
              Text(note, style: BarqText.xs),
          for (final item in found)
            if (item.capped)
              Text(
                l10n.assistantCapped(item.title!, item.qty),
                style: BarqText.xs,
              ),
          if (message.droppedCount > 0)
            Text(
              l10n.assistantTooMany(message.droppedCount),
              style: BarqText.xs,
            ),
          if (canAnswer && message.hasMatches)
            BarqButton(
              label: l10n.assistantCompare,
              small: true,
              onPressed: cubit.compareStores,
            ),
        ],
      ),
    );
  }
}

/// The best store, its alternatives, and the button that goes to checkout.
class _StoresBubble extends StatelessWidget {
  const _StoresBubble({required this.message, required this.canAnswer});

  final StoresMessage message;
  final bool canAnswer;

  /// Replacing a cart the customer filled by hand needs their word.
  Future<void> _continue(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AssistantCubit>();
    if (!context.read<CartCubit>().state.isEmpty) {
      final replace = await showBarqSheet<bool>(
        context,
        children: [
          Text(l10n.assistantReplaceTitle, style: BarqText.h2),
          Text(l10n.assistantReplaceBody, style: BarqText.body),
          BarqButton(
            label: l10n.assistantReplaceConfirm,
            onPressed: () => closeBarqSheet(context, true),
          ),
          BarqButton(
            label: l10n.commonKeepCart,
            variant: BarqButtonVariant.light,
            onPressed: () => closeBarqSheet(context, false),
          ),
        ],
      );
      if (replace != true) return;
    }
    cubit.fillCart();
    if (context.mounted) await context.push(Routes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AssistantCubit>();
    final first = message.options.first;
    final selected = message.selected;
    final total = selected.total ?? selected.store.itemsTotal;
    return BarqGap(
      gap: BarqSpacing.sm,
      children: [
        BarqChatBubble(
          text: first.store.complete
              ? l10n.assistantBest(first.store.vendorName)
              : l10n.assistantNoFullStore,
        ),
        for (final option in message.options)
          AssistantStoreCard(
            option: option,
            best: option == first && option.store.complete,
            selected: canAnswer && option == selected,
            onTap: canAnswer
                ? () => cubit.selectStore(option.store.vendorId)
                : null,
          ),
        if (canAnswer)
          BarqButton(
            label: l10n.assistantContinue(total.formatted),
            onPressed: () => _continue(context),
          ),
      ],
    );
  }
}

class _ProblemBubble extends StatelessWidget {
  const _ProblemBubble({required this.message, required this.canAnswer});

  final ProblemMessage message;
  final bool canAnswer;

  /// The comparison uses the default address, so the chosen one becomes it.
  Future<void> _changeAddress(BuildContext context) async {
    final cubit = context.read<AssistantCubit>();
    final account = context.read<AppDependencies>().accountRepository;
    final address = await AddressPickerSheet.show(context);
    if (address == null) return;
    try {
      if (!address.isDefault) await account.makeDefault(address);
    } on ApiException catch (e) {
      debugPrint('Address not made default: ${e.code}');
    }
    await cubit.compareAgain();
  }

  Future<void> _addAddress(BuildContext context) async {
    final cubit = context.read<AssistantCubit>();
    await context.push(Routes.addressNew);
    await cubit.retry();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AssistantCubit>();
    final text = switch (message.problem) {
      AssistantProblem.notUnderstood => l10n.assistantNotUnderstood,
      AssistantProblem.noLastOrder => l10n.assistantNoLastOrder,
      AssistantProblem.noAddress => l10n.noAddressBody,
      AssistantProblem.outOfZone => l10n.outOfZoneBody,
      AssistantProblem.noStores => l10n.assistantNoStores,
      AssistantProblem.failed => message.error ?? '',
    };
    final (String? label, VoidCallback? action) = switch (message.problem) {
      AssistantProblem.noAddress => (
        l10n.noAddressAdd,
        () => _addAddress(context),
      ),
      AssistantProblem.outOfZone => (
        l10n.outOfZoneChange,
        () => _changeAddress(context),
      ),
      AssistantProblem.failed => (l10n.commonRetry, cubit.retry),
      _ => (null, null),
    };
    return BarqChatBubble(
      child: BarqGap(
        gap: BarqSpacing.sm,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: BarqText.t),
          if (canAnswer && label != null)
            BarqButton(
              label: label,
              small: true,
              variant: BarqButtonVariant.light,
              onPressed: action,
            ),
        ],
      ),
    );
  }
}
