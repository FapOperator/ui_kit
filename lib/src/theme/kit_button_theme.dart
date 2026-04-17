import 'package:flutter/material.dart';

/// Theme extension that provides default styling for every [KitButton]
/// in the widget subtree.
///
/// Register it on your [ThemeData] to customize buttons app-wide:
///
/// ```dart
/// ThemeData(
///   extensions: const <ThemeExtension<dynamic>>[
///     KitButtonTheme(primaryColor: Colors.deepPurple, borderRadius: 16.0),
///   ],
/// );
/// ```
///
/// All fields are nullable — any field left as `null` falls back to a sane
/// built-in default inside [KitButton.build], so you can override only the
/// pieces you care about.
@immutable
class KitButtonTheme extends ThemeExtension<KitButtonTheme> {
  /// Brand color used as:
  /// - background of [KitButtonVariant.primary],
  /// - border and content color of [KitButtonVariant.secondary] and
  ///   [KitButtonVariant.text] (when enabled).
  ///
  /// Falls back to `Theme.of(context).primaryColor` when `null`.
  final Color? primaryColor;

  /// Content color (text, icon, loader) drawn on top of [primaryColor] for
  /// [KitButtonVariant.primary]. Analogous to Material 3 `onPrimary`.
  ///
  /// Falls back to [Colors.white] when `null`.
  final Color? onPrimaryColor;

  /// Background color of a disabled [KitButtonVariant.primary] button,
  /// and border color of a disabled [KitButtonVariant.secondary] button.
  ///
  /// Falls back to `Colors.grey.shade400` when `null`.
  final Color? disabledColor;

  /// Content color (text, icon, loader) used while the button is disabled,
  /// regardless of variant.
  ///
  /// Falls back to `Colors.grey.shade500` when `null`.
  final Color? disabledContentColor;

  /// Default color of the [CircularProgressIndicator] shown while the
  /// button is in its loading state.
  ///
  /// Resolution order (highest priority first):
  /// 1. [KitButton.loaderColor] (per-instance override)
  /// 2. [KitButtonTheme.loaderColor] (this field)
  /// 3. The computed content color (same as text/icon color)
  final Color? loaderColor;

  /// Corner radius applied to the button background. Falls back to `12.0`.
  final double? borderRadius;

  /// Fixed height of the button. The loader size is derived from this value
  /// as `(height * 0.5).clamp(16, 28)`. Falls back to `48.0`.
  final double? height;

  /// Base text style for the button label. Font size and weight are taken
  /// from this style; the color is always overridden at paint time so the
  /// label stays in sync with the enabled/disabled/variant state.
  ///
  /// Falls back to `TextStyle(fontSize: 16, fontWeight: FontWeight.w600)`.
  final TextStyle? textStyle;

  const KitButtonTheme({
    this.primaryColor,
    this.onPrimaryColor,
    this.disabledColor,
    this.disabledContentColor,
    this.loaderColor,
    this.borderRadius,
    this.height,
    this.textStyle,
  });

  @override
  KitButtonTheme copyWith({
    Color? primaryColor,
    Color? onPrimaryColor,
    Color? disabledColor,
    Color? disabledContentColor,
    Color? loaderColor,
    double? borderRadius,
    double? height,
    TextStyle? textStyle,
  }) {
    return KitButtonTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      onPrimaryColor: onPrimaryColor ?? this.onPrimaryColor,
      disabledColor: disabledColor ?? this.disabledColor,
      disabledContentColor: disabledContentColor ?? this.disabledContentColor,
      loaderColor: loaderColor ?? this.loaderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      height: height ?? this.height,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  /// Returns a new theme where every non-null field of [other] overrides
  /// the corresponding field of `this`. Returns `this` unchanged when
  /// [other] is `null`. Used by `KitButton.themeOverride` to patch the
  /// ambient theme for a single instance.
  KitButtonTheme merge(KitButtonTheme? other) {
    if (other == null) return this;
    return KitButtonTheme(
      primaryColor: other.primaryColor ?? primaryColor,
      onPrimaryColor: other.onPrimaryColor ?? onPrimaryColor,
      disabledColor: other.disabledColor ?? disabledColor,
      disabledContentColor: other.disabledContentColor ?? disabledContentColor,
      loaderColor: other.loaderColor ?? loaderColor,
      borderRadius: other.borderRadius ?? borderRadius,
      height: other.height ?? height,
      textStyle: other.textStyle ?? textStyle,
    );
  }

  @override
  KitButtonTheme lerp(ThemeExtension<KitButtonTheme>? other, double t) {
    if (other is! KitButtonTheme) {
      return this;
    }
    return KitButtonTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
      onPrimaryColor: Color.lerp(onPrimaryColor, other.onPrimaryColor, t),
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t),
      disabledContentColor: Color.lerp(
        disabledContentColor,
        other.disabledContentColor,
        t,
      ),
      loaderColor: Color.lerp(loaderColor, other.loaderColor, t),
      borderRadius: _lerpDouble(borderRadius, other.borderRadius, t),
      height: _lerpDouble(height, other.height, t),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
    );
  }

  static double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    return (a ?? b!) + ((b ?? a!) - (a ?? b!)) * t;
  }
}
