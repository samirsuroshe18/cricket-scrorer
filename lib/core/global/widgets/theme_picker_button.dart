import 'package:cricket_scorer/core/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemePickerButton extends StatelessWidget {
  const ThemePickerButton({super.key});

  static const _options = [
    (mode: ThemeMode.light, label: 'Light', icon: Icons.light_mode),
    (mode: ThemeMode.dark, label: 'Dark', icon: Icons.dark_mode),
    (mode: ThemeMode.system, label: 'System', icon: Icons.settings_suggest),
  ];

  void _showPicker(BuildContext context, ThemeService controller) {
    showModalBottomSheet<dynamic>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 16),
                child: Text(
                  'Choose theme',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ..._options.map(
                (option) => _ThemeOptionTile(
                  icon: option.icon,
                  label: option.label,
                  isSelected: controller.themeMode == option.mode,
                  onTap: () {
                    controller.setTheme(option.mode);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeService>();

    return Obx(() {
      final icon = switch (controller.themeMode) {
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
        ThemeMode.system => Icons.settings_suggest,
      };

      return IconButton(
        icon: Icon(icon),
        tooltip: 'Theme',
        onPressed: () => _showPicker(context, controller),
      );
    });
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
          : Colors.transparent,
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : const SizedBox.shrink(),
      onTap: onTap,
    );
  }
}
