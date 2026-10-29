import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.prefixText,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.suffix,
    this.autofocus = false,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
  });
  final TextEditingController? controller;
  final String? label, hint, prefixText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged, onSubmitted;
  final Widget? suffix;
  final bool autofocus, readOnly;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label != null) ...[Text(label!, style: context.tt.labelMedium!.copyWith(color: p.textSecondary)), const SizedBox(height: 8)],
      TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        autofocus: autofocus,
        readOnly: readOnly,
        onTap: onTap,
        textInputAction: textInputAction,
        style: context.tt.titleSmall!.copyWith(fontWeight: FontWeight.w600),
        cursorColor: p.primary,
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: p.textTertiary) : null,
          prefixText: prefixText,
          prefixStyle: context.tt.titleSmall,
          suffixIcon: suffix,
        ),
      ),
    ]);
  }
}
