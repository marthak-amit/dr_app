import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Titled rounded card containing a list of [SettingsTile]s.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) rows.add(Divider(height: 1, indent: 68, color: p.border));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(title.toUpperCase(), style: context.tt.labelSmall!.copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w700)),
      ),
      AppCard(padding: EdgeInsets.zero, child: ClipRRect(borderRadius: AppRadius.rLg, child: Column(children: rows))),
    ]);
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.icon, required this.label, this.subtitle, this.trailingText, this.trailing, this.onTap, this.color, this.danger = false});
  final IconData icon;
  final String label;
  final String? subtitle, trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final c = danger ? p.danger : (color ?? p.primary);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: c.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: c),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: context.tt.titleSmall!.copyWith(color: danger ? p.danger : p.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (subtitle != null) Text(subtitle!, style: context.tt.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
          if (trailingText != null)
            Flexible(child: Padding(padding: const EdgeInsets.only(left: 8), child: Text(trailingText!, style: context.tt.labelMedium!.copyWith(color: p.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis))),
          if (trailing != null) Padding(padding: const EdgeInsets.only(left: 8), child: trailing!),
          if (trailing == null && onTap != null) Icon(Icons.chevron_right_rounded, color: p.textTertiary),
        ]),
      ),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({super.key, required this.icon, required this.label, this.subtitle, required this.value, required this.onChanged, this.color});
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: icon,
      label: label,
      subtitle: subtitle,
      color: color,
      onTap: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );
  }
}

/// Initials avatar.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.initials, this.size = 56, this.bg, this.fg});
  final String initials;
  final double size;
  final Color? bg, fg;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg ?? p.primarySoft, shape: BoxShape.circle),
      child: Text(initials, style: context.tt.titleMedium!.copyWith(color: fg ?? p.primary, fontSize: size * .34, fontWeight: FontWeight.w800)),
    );
  }
}

String initialsOf(String name) => name.split(' ').where((e) => e.isNotEmpty).take(2).map((e) => e[0]).join().toUpperCase();
