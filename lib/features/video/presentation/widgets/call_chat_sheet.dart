import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';

class CallMessage {
  CallMessage(this.text, this.fromMe);
  final String text;
  final bool fromMe;
}

/// In-call chat panel. Mutates the shared [messages] list so history persists.
class CallChatSheet extends StatefulWidget {
  const CallChatSheet({super.key, required this.messages, required this.doctorName});
  final List<CallMessage> messages;
  final String doctorName;

  @override
  State<CallChatSheet> createState() => _CallChatSheetState();
}

class _CallChatSheetState extends State<CallChatSheet> {
  final _c = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _c.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    setState(() => widget.messages.add(CallMessage(t, true)));
    _c.clear();
    _toEnd();
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => widget.messages.add(CallMessage('Got it, thanks for sharing.', false)));
      _toEnd();
    });
  }

  void _toEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent + 80, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SizedBox(
      height: 360,
      child: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            itemCount: widget.messages.length,
            itemBuilder: (_, i) {
              final m = widget.messages[i];
              return Align(
                alignment: m.fromMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .72),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: m.fromMe ? p.primary : p.surfaceAlt,
                    borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(m.fromMe ? 16 : 4), bottomRight: Radius.circular(m.fromMe ? 4 : 16)),
                  ),
                  child: Text(m.text, style: context.tt.bodyMedium!.copyWith(color: m.fromMe ? p.onPrimary : p.textPrimary)),
                ),
              );
            },
          ),
        ),
        Row(children: [
          Expanded(child: AppTextField(controller: _c, hint: 'Message ${widget.doctorName}', textInputAction: TextInputAction.send, onSubmitted: (_) => _send())),
          const SizedBox(width: 10),
          AppIconButton(icon: Icons.send_rounded, size: 50, bg: p.primary, color: p.onPrimary, onTap: _send),
        ]),
      ]),
    );
  }
}
