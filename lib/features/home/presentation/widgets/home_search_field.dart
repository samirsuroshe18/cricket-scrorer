import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// The search field that replaces a tab's title while its search is open: a
/// back arrow that closes it, a borderless field, and a clear button once
/// there is text. Shared by the Matches and Teams tabs so both behave the
/// same. The owner keeps the controller and focus node, and rebuilds this
/// when the text changes so the clear button appears and disappears.
class HomeSearchField extends StatelessWidget {
  const HomeSearchField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    required this.onClose,
    this.onSubmitted,
    this.maxLength,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onClose;

  /// Longest query the field accepts, or null for no cap.
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: TranslationKeys.cancel.tr,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          onPressed: onClose,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.colorScheme.onSurface,
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            textInputAction: TextInputAction.search,
            inputFormatters: [
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
            ],
            style: context.homeText(16),
            cursorColor: context.colorScheme.onSurface,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: context
                  .homeText(16)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (controller.text.isNotEmpty)
          IconButton(
            tooltip: TranslationKeys.clearSearch.tr,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            onPressed: onClear,
            icon: Icon(
              Icons.close_rounded,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
