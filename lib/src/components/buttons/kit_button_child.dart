import 'package:flutter/material.dart';

import 'kit_button_variant.dart';

class KitButtonChild extends StatelessWidget {
  final KitButtonVariant variant;
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color disabledContentColor;
  final Color? loaderColor;
  final bool isDisabled;
  final bool isLoading;
  final bool isExpanded;
  final double loaderSize;
  final String text;
  final Widget? icon;
  final TextStyle? textStyle;

  const KitButtonChild({
    required this.variant,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.disabledContentColor,
    required this.isDisabled,
    required this.isLoading,
    required this.isExpanded,
    required this.loaderSize,
    required this.text,
    this.loaderColor,
    this.icon,
    this.textStyle,
    super.key,
  });

  Color get _contentColor {
    if (isDisabled) return disabledContentColor;
    return variant == KitButtonVariant.primary ? onPrimaryColor : primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: loaderSize,
        width: loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            loaderColor ?? _contentColor,
          ),
        ),
      );
    }

    final TextStyle finalStyle =
        (textStyle ??
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600))
            .copyWith(color: _contentColor);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          IconTheme.merge(
            data: IconThemeData(color: _contentColor, size: 20.0),
            child: icon!,
          ),
          const SizedBox(width: 8.0),
        ],
        Flexible(
          child: Text(
            text,
            style: finalStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
