import 'package:flutter/material.dart';

import '../foundation/barq_asset_names.dart';
import '../foundation/barq_assets.dart';
import '../foundation/barq_theme.dart';
import '../foundation/barq_tokens.dart';
import 'buttons.dart';
import 'inputs.dart';
import 'misc.dart';

/// One chat message. The assistant's is a light card at the start of the line,
/// the user's is orange at the end of it. Give [text] for a plain message, or
/// [child] for anything richer.
class BarqChatBubble extends StatelessWidget {
  const BarqChatBubble(
      {super.key, this.text, this.child, this.fromUser = false})
      : assert(text != null || child != null);

  final String? text;
  final Widget? child;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    final p = BarqPalette.of(context);
    const corner = Radius.circular(BarqRadius.bubble);
    const tail = Radius.circular(BarqRadius.bubbleTail);
    return Align(
      alignment: fromUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: BarqSizes.chatBubble),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: BarqSpacing.section, vertical: BarqSpacing.gap),
          decoration: BoxDecoration(
            color: fromUser ? BarqColors.primary : p.card,
            borderRadius: BorderRadiusDirectional.only(
              topStart: corner,
              topEnd: corner,
              bottomStart: fromUser ? corner : tail,
              bottomEnd: fromUser ? tail : corner,
            ),
            boxShadow: fromUser ? BarqShadows.chipOn : p.cardShadow,
          ),
          child: child ??
              Text(text!,
                  style: BarqText.t
                      .copyWith(color: fromUser ? BarqColors.white : p.text)),
        ),
      ),
    );
  }
}

/// The assistant's bubble while it is working: three dots that take turns.
class BarqTypingBubble extends StatefulWidget {
  const BarqTypingBubble({super.key});

  @override
  State<BarqTypingBubble> createState() => _BarqTypingBubbleState();
}

class _BarqTypingBubbleState extends State<BarqTypingBubble>
    with SingleTickerProviderStateMixin {
  static const _dots = 3;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: BarqDurations.typing)
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BarqChatBubble(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final active = (_controller.value * _dots).floor();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _dots; i++) ...[
                  if (i > 0) const SizedBox(width: BarqSpacing.xs),
                  Container(
                    width: BarqSizes.unreadDot,
                    height: BarqSizes.unreadDot,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == active
                          ? BarqColors.primary
                          : BarqColors.primaryBorder,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      );
}

/// The text field and the round send button at the bottom of a chat. It takes
/// several lines, so a list can be written one item per line.
class BarqChatComposer extends StatelessWidget {
  const BarqChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.hint,
    this.focusNode,
    this.enabled = true,
  });

  static const _maxLines = 4;

  final TextEditingController controller;
  final VoidCallback onSend;
  final String? hint;
  final FocusNode? focusNode;

  /// False keeps what is typed, and only stops it from being sent.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // The arrow icon points left, the way a message leaves in Arabic.
    final leftToRight = Directionality.of(context) == TextDirection.ltr;
    return Row(
      children: [
        Expanded(
          child: BarqInput(
            controller: controller,
            focusNode: focusNode,
            hint: hint,
            maxLines: _maxLines,
            keyboardType: TextInputType.multiline,
          ),
        ),
        const SizedBox(width: BarqSpacing.md),
        Transform.flip(
          flipX: leftToRight,
          child: BarqIconButton(
            icon: BarqIcons.arrow,
            background: BarqColors.primary,
            iconColor: BarqColors.white,
            onPressed: enabled ? onSend : null,
          ),
        ),
      ],
    );
  }
}

/// The orange card on the home screen that opens the assistant.
class BarqAssistantBanner extends StatelessWidget {
  const BarqAssistantBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: BarqBanner(
          padding: const EdgeInsets.all(BarqSpacing.section),
          child: Row(
            children: [
              Container(
                width: BarqSizes.iconTile,
                height: BarqSizes.iconTile,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: BarqColors.onOrangePanel,
                ),
                child: const BarqIcon(BarqIcons.bolt,
                    size: BarqSizes.icon, color: BarqColors.white),
              ),
              const SizedBox(width: BarqSpacing.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: BarqText.h3.copyWith(color: BarqColors.white)),
                    Text(subtitle,
                        style: BarqText.xs
                            .copyWith(color: BarqColors.onOrangeMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
