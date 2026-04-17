import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'kit_text_field_variant.dart';

/// Builds an [OutlineInputBorder] for the text field decoration.
OutlineInputBorder kitTextFieldBorder({
  required Color color,
  required double radius,
  double width = 1.0,
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide(color: color, width: width),
  );
}

/// Resolves the effective [TextInputType] for a variant, respecting a
/// caller-supplied [override].
TextInputType kitTextFieldKeyboardType({
  required KitTextFieldVariant variant,
  TextInputType? override,
}) {
  if (override != null) return override;
  switch (variant) {
    case KitTextFieldVariant.number:
      return const TextInputType.numberWithOptions(decimal: true);
    case KitTextFieldVariant.otp:
      return TextInputType.number;
    case KitTextFieldVariant.email:
      return TextInputType.emailAddress;
    case KitTextFieldVariant.multiline:
      return TextInputType.multiline;
    case KitTextFieldVariant.search:
    case KitTextFieldVariant.password:
    case KitTextFieldVariant.standard:
      return TextInputType.text;
  }
}

/// Merges caller-supplied [TextInputFormatter]s with the built-in ones
/// required by the variant:
///
/// - [KitTextFieldVariant.number] — single decimal separator (`.` or `,`),
///   optional leading `-` if [allowNegative] is `true`.
/// - [KitTextFieldVariant.otp] — digits only.
/// - [KitTextFieldVariant.email] — lower-cases every keystroke.
List<TextInputFormatter> kitTextFieldFormatters({
  required KitTextFieldVariant variant,
  List<TextInputFormatter>? custom,
  bool allowNegative = false,
}) {
  final List<TextInputFormatter> formatters = <TextInputFormatter>[...?custom];

  switch (variant) {
    case KitTextFieldVariant.number:
      final RegExp pattern = allowNegative
          ? RegExp(r'^-?\d*[.,]?\d*$')
          : RegExp(r'^\d*[.,]?\d*$');
      formatters.add(
        TextInputFormatter.withFunction((
          TextEditingValue oldValue,
          TextEditingValue newValue,
        ) {
          if (newValue.text.isEmpty) return newValue;
          return pattern.hasMatch(newValue.text) ? newValue : oldValue;
        }),
      );
      break;
    case KitTextFieldVariant.otp:
      formatters.add(FilteringTextInputFormatter.digitsOnly);
      break;
    case KitTextFieldVariant.email:
      formatters.add(
        TextInputFormatter.withFunction((
          TextEditingValue oldValue,
          TextEditingValue newValue,
        ) {
          final String lower = newValue.text.toLowerCase();
          if (lower == newValue.text) return newValue;
          return newValue.copyWith(
            text: lower,
            selection: newValue.selection,
            composing: TextRange.empty,
          );
        }),
      );
      break;
    case KitTextFieldVariant.standard:
    case KitTextFieldVariant.password:
    case KitTextFieldVariant.search:
    case KitTextFieldVariant.multiline:
      break;
  }

  return formatters;
}
