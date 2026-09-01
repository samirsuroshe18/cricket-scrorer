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
    return TextFormField(
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
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
