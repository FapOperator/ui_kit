import 'package:flutter/material.dart';

import 'kit_button_variant.dart';

ButtonStyle kitButtonStyleFor({
  required KitButtonVariant variant,
  required Color primaryColor,
  required Color disabledColor,
  required double radius,
  required bool isDisabled,
}) {
  final RoundedRectangleBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
  );

  switch (variant) {
    case KitButtonVariant.primary:
      return ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        disabledBackgroundColor: disabledColor,
        elevation: 0.0,
        shape: shape,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
      );
    case KitButtonVariant.secondary:
      return ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        elevation: 0.0,
        shape: shape.copyWith(
          side: BorderSide(
            color: isDisabled ? disabledColor : primaryColor,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
      );
    case KitButtonVariant.text:
      return ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        elevation: 0.0,
        shape: shape,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
      );
  }
}
