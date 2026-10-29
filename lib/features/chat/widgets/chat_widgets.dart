import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/providers.dart';

const kAttachPrefix = '📎 ';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, this.showTime = true});
  final ChatMessage message;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final me = message.fromMe;
    final isAttach = message.text.startsWith(kAttachPrefix);
    final fg = me ? Colors.white : p.textPrimary;
    final maxW = MediaQuery.of(context).size.width * .78;
    final content = isAttach
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: (me ? Colors.white : p.primary).withValues(alpha: .18), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.insert_drive_file_rounded, color: me ? Colors.white : p.primary, size: 20),
            ),
            Gap.h(10),
            Flexible(child: Text(message.text.substring(kAttachPrefix.length), style: context.tt.titleSmall!.copyWith(color: fg), maxLines: 2, overflow: TextOverflow.ellipsis)),
          ])
        : Text(message.text, style: context.tt.bodyLarge!.copyWith(color: fg, fontSize: 15));
    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxW),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          gradient: me ? AppColors.gradientPrimary : null,
          color: me ? null : p.surface,
          border: me ? null : Border.all(color: p.border),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(me ? 20 : 6),
            bottomRight: Radius.circular(me ? 6 : 20),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
          content,
          if (showTime) ...[
            Gap.v(4),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(fmtTime(message.time), style: context.tt.labelSmall!.copyWith(color: me ? Colors.white70 : p.textTertiary, fontSize: 10.5)),
              if (me) ...[Gap.h(4), const Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF9BF0FF))],
            ]),
          ],
        ]),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: .15, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }
}

class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: p.surface, border: Border.all(color: p.border), borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomRight: Radius.circular(20), bottomLeft: Radius.circular(6))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < 3; i++)
            Container(width: 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 2.5), decoration: BoxDecoration(color: p.textTertiary, shape: BoxShape.circle))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 2, end: -3, delay: (160 * i).ms, duration: 420.ms, curve: Curves.easeInOut)
                .fade(begin: .4, end: 1, delay: (160 * i).ms, duration: 420.ms),
        ]),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class DateSeparator extends StatelessWidget {
  const DateSeparator({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: AppRadius.rPill),
        child: Text(label, style: context.tt.labelSmall),
      ),
    );
  }
}
