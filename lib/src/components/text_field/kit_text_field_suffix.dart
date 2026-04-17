import 'package:flutter/material.dart';
import 'package:ui_kit/src/theme/kit_text_field_theme.dart';

import 'kit_text_field_variant.dart';

/// Returns the widget rendered in [InputDecoration.suffixIcon] for the
/// current variant/state, or `null` when no suffix is needed.
///
/// Behavior:
/// - `!enabled` → [customSuffix] (no interactive suffix shown).
/// - [KitTextFieldVariant.password] → visibility toggle button.
/// - `showClearButton && !readOnly` → live clear button driven by the
///   controller (hidden while the field is empty).
/// - Otherwise → [customSuffix] (may be `null`).
Widget? buildKitTextFieldSuffix({
  required KitTextFieldVariant variant,
  required TextEditingController controller,
  required bool showClearButton,
  required bool readOnly,
  required bool enabled,
  required bool isObscured,
  required VoidCallback onToggleObscure,
  required VoidCallback onClear,
  required Widget? customSuffix,
  required KitTextFieldTheme? theme,
}) {
  if (!enabled) return customSuffix;

  if (variant == KitTextFieldVariant.password) {
    return IconButton(
      icon: isObscured
          ? (theme?.obscureOffIcon ?? const Icon(Icons.visibility_off))
          : (theme?.obscureOnIcon ?? const Icon(Icons.visibility)),
      onPressed: onToggleObscure,
    );
  }

  if (showClearButton && !readOnly) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, Widget? child) {
        if (value.text.isEmpty) {
          return customSuffix ?? const SizedBox.shrink();
        }
        final Widget clearIcon = theme?.clearIcon ?? const Icon(Icons.clear);
        return IconButton(icon: clearIcon, onPressed: onClear);
      },
    );
  }

  return customSuffix;
}
