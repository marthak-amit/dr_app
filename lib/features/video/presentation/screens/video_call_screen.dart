import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/utils/app_config.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../widgets/call_chat_sheet.dart';
import '../widgets/call_summary_sheet.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  bool _connected = false, _muted = false, _camOff = false, _ending = false;
  final _seconds = ValueNotifier<int>(0);
  Timer? _timer;
  Offset? _selfPos; // top-left of the self view
  final _chat = <CallMessage>[CallMessage('Hello! Can you hear me clearly?', false), CallMessage('Yes doctor, loud and clear 👍', true)];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      setState(() => _connected = true);
      HapticFeedback.mediumImpact();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _seconds.value++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _seconds.dispose();
    super.dispose();
  }

  String get _clock {
    final s = _seconds.value;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Doctor _doctor() {
    final appts = ref.read(appointmentsProvider).valueOrNull ?? const <Appointment>[];
    final a = appts.where((e) => e.id == widget.appointmentId).firstOrNull;
    return doctorById(a?.doctorId ?? 'd1');
  }

  Future<void> _end(Doctor d) async {
    if (_ending) return;
    final ok = await showConfirmSheet(context, title: 'End consultation?', message: 'You are still connected with ${d.name}. Do you want to end the video call?', confirmLabel: 'End call', destructive: true, icon: Icons.call_end_rounded);
    if (!ok || !mounted) return;
    _ending = true;
    _timer?.cancel();
    final dur = _clock;
    ref.read(appointmentsProvider.notifier).markCompleted(widget.appointmentId);
    final nav = GoRouter.of(context);
    var action = 'done';
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppBottomSheet(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: CallSummarySheet(
          duration: dur,
          doctorName: d.name,
          onViewRx: () {
            action = 'rx';
            Navigator.pop(ctx);
          },
          onDone: () => Navigator.pop(ctx),
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'rx') {
      nav.pushReplacement(Routes.prescriptions);
    } else if (nav.canPop()) {
      nav.pop();
    } else {
      nav.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _doctor();
    final size = MediaQuery.of(context).size;
    final pad = MediaQuery.of(context).padding;
    const selfW = 96.0, selfH = 132.0;
    final defaultPos = Offset(size.width - selfW - 16, pad.top + 76);
    final pos = _selfPos ?? defaultPos;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _end(d);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF071A1E),
        body: Stack(children: [
          Positioned.fill(child: _RemoteVideo(doctor: d)),
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: .55), Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: .75)], stops: const [0, .22, .6, 1])))),
          // top bar
          Positioned(
            top: pad.top + 10,
            left: 16,
            right: 16,
            child: Row(children: [
              _GlassButton(icon: Icons.keyboard_arrow_down_rounded, onTap: () => showAppSnack(context, 'Call minimised — tap return to rejoin', icon: Icons.picture_in_picture_alt_rounded)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.name, style: context.tt.titleMedium!.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Row(children: [
                    Icon(Icons.lock_rounded, size: 11, color: Colors.white.withValues(alpha: .7)),
                    const SizedBox(width: 4),
                    Flexible(child: Text('End-to-end secure · ${AppConfig.appName}', style: context.tt.labelSmall!.copyWith(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ]),
              ),
              const SizedBox(width: 8),
              if (_connected)
                ValueListenableBuilder<int>(
                  valueListenable: _seconds,
                  builder: (_, __, ___) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: .4), borderRadius: AppRadius.rPill),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF4D4F), shape: BoxShape.circle)).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: .3, end: 1, duration: 700.ms),
                      const SizedBox(width: 7),
                      Text(_clock, style: context.tt.labelLarge!.copyWith(color: Colors.white, fontFeatures: const [FontFeature.tabularFigures()])),
                    ]),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.signal_cellular_alt_rounded, color: Color(0xFF5EEAC0), size: 22),
            ]),
          ),
          // self view
          if (_connected)
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: GestureDetector(
                onPanUpdate: (u) => setState(() {
                  final n = (_selfPos ?? defaultPos) + u.delta;
                  _selfPos = Offset(n.dx.clamp(8.0, size.width - selfW - 8), n.dy.clamp(pad.top + 64, size.height - selfH - 180));
                }),
                child: _SelfView(name: ref.read(sessionProvider).profile.name, w: selfW, h: selfH, camOff: _camOff, muted: _muted, onFlip: () => showAppSnack(context, 'Camera flipped', icon: Icons.flip_camera_android_rounded)),
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(.8, .8), curve: Curves.easeOutBack),
            ),
          // connecting overlay
          Positioned.fill(
            child: IgnorePointer(
              ignoring: _connected,
              child: AnimatedOpacity(opacity: _connected ? 0 : 1, duration: const Duration(milliseconds: 500), child: _Connecting(doctor: d)),
            ),
          ),
          // controls
          Positioned(
            left: 0,
            right: 0,
            bottom: pad.bottom + 20,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (_connected)
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: .35), borderRadius: AppRadius.rPill),
                  child: Text('${d.specialty} · ${d.qualification.split(',').first}', style: context.tt.labelMedium!.copyWith(color: Colors.white)),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _CtrlButton(icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded, active: _muted, onTap: () => setState(() => _muted = !_muted)),
                  _CtrlButton(icon: _camOff ? Icons.videocam_off_rounded : Icons.videocam_rounded, active: _camOff, onTap: () => setState(() => _camOff = !_camOff)),
                  _CtrlButton(
                    icon: Icons.chat_bubble_rounded,
                    onTap: () => showAppBottomSheet<void>(context, title: 'In-call chat', scrollable: false, builder: (_) => CallChatSheet(messages: _chat, doctorName: d.shortName)),
                  ),
                  _CtrlButton(icon: Icons.attach_file_rounded, onTap: () => showAppSnack(context, 'Latest reports shared with ${d.shortName}', icon: Icons.folder_shared_rounded)),
                  _CtrlButton(icon: Icons.call_end_rounded, danger: true, onTap: () => _end(d)),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _RemoteVideo extends StatelessWidget {
  const _RemoteVideo({required this.doctor});
  final Doctor doctor;
  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28), child: Image.asset(doctor.photo, fit: BoxFit.cover)),
      Container(color: const Color(0xFF071A1E).withValues(alpha: .35)),
      Align(
        alignment: const Alignment(0, -.15),
        child: LayoutBuilder(builder: (c, cons) {
          final s = cons.maxWidth * 1.15;
          return Image.asset(doctor.photo, width: s, height: s, fit: BoxFit.cover, alignment: Alignment.topCenter)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.025, 1.025), duration: 4.seconds, curve: Curves.easeInOut);
        }),
      ),
    ]);
  }
}

class _Connecting extends StatelessWidget {
  const _Connecting({required this.doctor});
  final Doctor doctor;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF071A1E),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(alignment: Alignment.center, children: [
              for (var i = 0; i < 3; i++)
                Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryLight.withValues(alpha: .5), width: 2)))
                    .animate(onPlay: (c) => c.repeat(), delay: (i * 500).ms)
                    .scale(begin: const Offset(1, 1), end: const Offset(1.8, 1.8), duration: 1500.ms)
                    .fadeOut(duration: 1500.ms),
              DoctorAvatar(doctor: doctor, size: 112, radius: 56, hero: false),
            ]),
          ),
          const SizedBox(height: 24),
          Text('Connecting to ${doctor.name}…', style: context.tt.titleMedium!.copyWith(color: Colors.white)),
          const SizedBox(height: 6),
          Text('Checking camera & microphone', style: context.tt.bodySmall!.copyWith(color: Colors.white60)),
        ]),
      ),
    );
  }
}

class _SelfView extends StatelessWidget {
  const _SelfView({required this.w, required this.h, required this.camOff, required this.muted, required this.onFlip, required this.name});
  final String name;
  final double w, h;
  final bool camOff, muted;
  final VoidCallback onFlip;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .7), width: 2),
        gradient: camOff ? const LinearGradient(colors: [Color(0xFF1B2D33), Color(0xFF10222A)]) : const LinearGradient(colors: [Color(0xFF3D8F98), Color(0xFF0E5A63)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Stack(alignment: Alignment.center, children: [
        Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(radius: 24, backgroundColor: Colors.white.withValues(alpha: .22), child: Text(name.isEmpty ? 'Y' : name[0].toUpperCase(), style: context.tt.titleLarge!.copyWith(color: Colors.white))),
          if (camOff) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Camera off', style: context.tt.labelSmall!.copyWith(color: Colors.white70))),
        ]),
        Positioned(left: 6, bottom: 6, child: Icon(muted ? Icons.mic_off_rounded : Icons.mic_rounded, size: 16, color: muted ? const Color(0xFFFF8A8A) : Colors.white)),
        Positioned(right: 4, top: 4, child: GestureDetector(onTap: onFlip, child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.flip_camera_android_rounded, size: 18, color: Colors.white.withValues(alpha: .9))))),
      ]),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => TapScale(onTap: onTap, child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.black.withValues(alpha: .4), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 24)));
}

class _CtrlButton extends StatelessWidget {
  const _CtrlButton({required this.icon, required this.onTap, this.active = false, this.danger = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool active, danger;
  @override
  Widget build(BuildContext context) {
    final bg = danger ? const Color(0xFFE5484D) : (active ? Colors.white : Colors.white.withValues(alpha: .18));
    final fg = danger ? Colors.white : (active ? const Color(0xFF10303A) : Colors.white);
    return TapScale(
      onTap: onTap,
      haptic: true,
      scale: .9,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: danger ? 62 : 54,
        height: danger ? 62 : 54,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: danger ? [BoxShadow(color: const Color(0xFFE5484D).withValues(alpha: .5), blurRadius: 16, offset: const Offset(0, 6))] : null),
        child: Icon(icon, color: fg, size: danger ? 28 : 24),
      ),
    );
  }
}
