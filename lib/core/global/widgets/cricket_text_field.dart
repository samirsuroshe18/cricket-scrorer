import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CricketTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final int? maxLength;

  /// Keeps [maxLength] enforced but drops the "n/max" counter under the field.
  final bool hideCounter;
  final int maxLines;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool isRequired;

  /// Null everywhere except an actual credential field — a text field with
  /// no hint is invisible to a password manager, which is exactly what left
  /// every email/password field in this app unfillable and unsaveable. See
  /// each call site for which [AutofillHints] constant(s) apply; a login
  /// field wants `email`+`username`, a new-password field wants
  /// `newPassword`, and so on.
  final Iterable<String>? autofillHints;

  const CricketTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.hideCounter = false,
    this.maxLines = 1,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.isRequired = false,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    // A multi-line field is tall enough that Material's default centering
    // of the label/hint and prefixIcon reads as misplaced — both sit in
    // the middle of the box instead of beside the first line.
    // `alignLabelWithHint` fixes the label/hint. The icon has no public
    // equivalent — InputDecorator always centers `prefixIcon` across the
    // *whole* field height, multi-line or not (a long-standing Flutter
    // limitation, not a config flag) — so a multi-line field with an icon
    // draws the icon manually, top-left, over a `contentPadding` that
    // leaves room for it, instead of handing it to `prefixIcon`.
    final isMultiline = maxLines > 1;
    final hasIcon = prefixIcon != null;
    final manualIcon = isMultiline && hasIcon;

    final field = TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        counterText: hideCounter ? '' : null,
        label: RichText(
          text: TextSpan(
            text: labelText,
            style: context.textTheme.bodyMedium,
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        alignLabelWithHint: isMultiline,
        prefixIcon: manualIcon ? null : prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: manualIcon
            ? const EdgeInsets.only(
                left: 44,
                right: 16,
                top: 14,
                bottom: 14,
              )
            : const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
      ),
    );

    if (!manualIcon) return field;

    return Stack(
      children: [
        field,
        Positioned(
          top: 14,
          left: 16,
          child: IgnorePointer(
            child: IconTheme.merge(
              data: IconThemeData(color: context.colorScheme.onSurfaceVariant),
              child: prefixIcon!,
            ),
          ),
        ),
      ],
    );
  }
}
