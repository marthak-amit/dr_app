import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../widgets/chat_widgets.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;
  bool _hasText = false;

  static const _quick = ['Reschedule appointment', 'Queue status', 'Share reports', 'Billing query'];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent + 80, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    });
  }

  void _send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    ref.read(chatProvider.notifier).send(t);
    _ctrl.clear();
    setState(() {
      _hasText = false;
      _typing = true;
    });
    _toBottom();
  }

  void _attach() {
    showAppBottomSheet<void>(context, title: 'Attach', builder: (ctx) {
      final p = ctx.pal;
      Widget opt(IconData i, String l, Color c, Color bg, String file) => Expanded(
            child: TapScale(
              onTap: () {
                Navigator.pop(ctx);
                _send('$kAttachPrefix$file');
              },
              child: Column(children: [
                Container(width: 60, height: 60, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(i, color: c, size: 28)),
                Gap.v(8),
                Text(l, style: ctx.tt.labelMedium),
              ]),
            ),
          );
      return Row(children: [
        opt(Icons.photo_camera_rounded, 'Camera', p.accent, p.accentSoft, 'IMG_2026_camera.jpg'),
        opt(Icons.photo_library_rounded, 'Gallery', p.primary, p.primarySoft, 'ECG_report_photo.jpg'),
        opt(Icons.description_rounded, 'Document', p.warning, p.warningSoft, 'Lipid_Profile.pdf'),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final msgs = ref.watch(chatProvider);
    ref.listen<List<ChatMessage>>(chatProvider, (prev, next) {
      if (next.isNotEmpty && !next.last.fromMe && _typing) setState(() => _typing = false);
      _toBottom();
    });
    final clinic = mockClinics.first;
    final items = <Widget>[const DateSeparator(label: 'Today')];
    for (var i = 0; i < msgs.length; i++) {
      items.add(MessageBubble(key: ValueKey(msgs[i].id), message: msgs[i]));
    }
    if (_typing) items.add(const TypingBubble());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 68,
        automaticallyImplyLeading: false,
        titleSpacing: 8,
        leadingWidth: 58,
        leading: Padding(padding: const EdgeInsets.only(left: 16), child: Center(child: AppIconButton(icon: Icons.arrow_back_rounded, size: 42, onTap: () => context.canPop() ? context.pop() : null))),
        title: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset(clinic.image, width: 44, height: 44, fit: BoxFit.cover, cacheWidth: 200)),
          Gap.h(12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(clinic.name, style: context.tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: p.success, shape: BoxShape.circle)),
                Gap.h(6),
                Text('Online · replies in minutes', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ]),
          ),
        ]),
        actions: [
          AppIconButton(icon: Icons.call_rounded, size: 42, onTap: () => showAppSnack(context, 'Calling ${clinic.phone}…', icon: Icons.call_rounded)),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: items,
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _quick.length,
            separatorBuilder: (_, __) => Gap.h(8),
            itemBuilder: (_, i) => ChoicePill(label: _quick[i], selected: false, onTap: () => _send(_quick[i])),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.border))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            AppIconButton(icon: Icons.attach_file_rounded, size: 46, onTap: _attach, bg: p.surfaceAlt),
            Gap.h(8),
            Expanded(
              child: TextField(
                controller: _ctrl,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                onChanged: (v) => setState(() => _hasText = v.trim().isNotEmpty),
                style: context.tt.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  filled: true,
                  fillColor: p.surfaceAlt,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
              ),
            ),
            Gap.h(8),
            TapScale(
              onTap: () => _hasText ? _send(_ctrl.text) : showAppSnack(context, 'Hold to record a voice note (mock)', icon: Icons.mic_rounded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(gradient: _hasText ? AppColors.gradientAccent : null, color: _hasText ? null : p.primarySoft, shape: BoxShape.circle),
                child: Icon(_hasText ? Icons.send_rounded : Icons.mic_rounded, color: _hasText ? Colors.white : p.primary, size: 22),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
