import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a bundled Lucide-style SVG from the icons folder, tinted with [color].
class SvgIcon extends StatelessWidget {
  const SvgIcon(this.name, {super.key, this.size = 24, this.color});
  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color ?? IconTheme.of(context).color ?? Colors.black, BlendMode.srcIn),
    );
  }
}
