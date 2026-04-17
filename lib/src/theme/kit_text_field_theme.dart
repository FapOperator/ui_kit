import 'package:flutter/material.dart';

/// Theme extension that provides default styling and icons for every
/// [KitTextField] in the widget subtree.
///
/// Register it on your [ThemeData] to customize text fields app-wide:
///
/// ```dart
/// ThemeData(
///   extensions: const <ThemeExtension<dynamic>>[
///     KitTextFieldTheme(
///       borderColor: Color(0xFFCCCCCC),
///       focusColor: Colors.deepPurple,
///       errorColor: Colors.redAccent,
///       borderRadius: 12.0,
///       filled: true,
///       fillColor: Color(0xFFF5F5F7),
///     ),
///   ],
/// );
/// ```
///
/// All fields are nullable — any field left as `null` falls back to a sane
/// built-in default inside [KitTextField.build], so you can override only
/// the pieces you care about.
@immutable
class KitTextFieldTheme extends ThemeExtension<KitTextFieldTheme> {
  // ───────── icons ─────────

  /// Icon displayed in the trailing position of the search variant (and
  /// password variant when the controller is non-empty) to let the user
  /// clear the input. Falls back to [Icons.clear].
  final Widget? clearIcon;

  /// Icon displayed in the password suffix while the text is **hidden**,
  /// signalling that tapping will reveal it. Falls back to
  /// [Icons.visibility].
  final Widget? obscureOnIcon;

  /// Icon displayed in the password suffix while the text is **visible**,
  /// signalling that tapping will hide it. Falls back to
  /// [Icons.visibility_off].
  final Widget? obscureOffIcon;

  /// Leading icon for the search variant when no explicit `prefixIcon` is
  /// provided. Falls back to [Icons.search].
  final Widget? searchIcon;

  // ───────── border / colors ─────────

  /// Outline border color in the idle (enabled, not focused, not
  /// erroring) state. Falls back to `Colors.grey.shade400`.
  final Color? borderColor;

  /// Outline border color while the field is focused. Falls back to
  /// `Theme.of(context).primaryColor`.
  final Color? focusColor;

  /// Outline border color used when validation fails. Falls back to
  /// [Colors.red].
  final Color? errorColor;

  /// Outline border color for the disabled state. Falls back to
  /// [borderColor], i.e. no visual difference from idle unless set.
  final Color? disabledBorderColor;

  /// Corner radius applied to the outline border. Falls back to `8.0`.
  final double? borderRadius;

  /// Stroke width for the idle, disabled and error-without-focus borders.
  /// Falls back to `1.0`.
  final double? idleBorderWidth;

  /// Stroke width for the focused and focused-error borders. Falls back
  /// to `2.0`.
  final double? focusedBorderWidth;

  // ───────── fill ─────────

  /// Whether the input is rendered in its filled style (with [fillColor])
  /// instead of pure-outlined. Falls back to `false`.
  final bool? filled;

  /// Background color applied when [filled] is `true`. Falls back to
  /// `null` (lets Material pick its default).
  final Color? fillColor;

  /// Background color applied when [filled] is `true` and the field is
  /// disabled. Falls back to [fillColor].
  final Color? disabledFillColor;

  // ───────── typography / cursor ─────────

  /// Text style of the user's input. Falls back to the ambient
  /// `InputDecorationTheme` default.
  final TextStyle? textStyle;

  /// Style of the [InputDecoration.hintText]. Falls back to the ambient
  /// `InputDecorationTheme` default.
  final TextStyle? hintStyle;

  /// Style of the [InputDecoration.errorText]. Falls back to the ambient
  /// `InputDecorationTheme` default.
  final TextStyle? errorStyle;

  /// Style of the [InputDecoration.helperText] shown below the field as
  /// an informational hint (e.g. "We'll never share your email"). Falls
  /// back to the ambient `InputDecorationTheme` default.
  final TextStyle? helperStyle;

  /// Color of the text-editing cursor. Falls back to the framework default
  /// (platform-dependent).
  final Color? cursorColor;

  /// Color applied (via [IconTheme.merge]) to every prefix/suffix icon
  /// rendered inside a [KitTextField] — both user-provided icons and the
  /// built-in search/clear/password-toggle icons. When `null`, icons keep
  /// their default Material colors.
  final Color? iconColor;

  // ───────── layout ─────────

  /// Inner padding between the border and the input content (text,
  /// prefix, suffix). Falls back to
  /// `EdgeInsets.symmetric(horizontal: 16, vertical: 16)`.
  final EdgeInsetsGeometry? contentPadding;

  /// App-wide default cap on the number of input characters, applied when
  /// the field itself doesn't specify `maxLength`. Falls back to `255`.
  ///
  /// When this default kicks in (i.e. the field didn't ask for a limit
  /// explicitly), the built-in character counter is hidden — the cap acts
  /// as a silent safety limit rather than user-facing information. Fields
  /// that pass their own `maxLength` still show the counter as usual.
  final int? defaultMaxLength;

  // ───────── label ─────────

  /// Text style of the external top label rendered above the input.
  /// Falls back to `TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
  /// color: Colors.grey.shade800)`.
  final TextStyle? labelStyle;

  /// Vertical gap (in logical pixels) between the external top label and
  /// the input. Falls back to `8.0`.
  final double? labelGap;

  const KitTextFieldTheme({
    this.clearIcon,
    this.obscureOnIcon,
    this.obscureOffIcon,
    this.searchIcon,
    this.borderColor,
    this.focusColor,
    this.errorColor,
    this.disabledBorderColor,
    this.borderRadius,
    this.idleBorderWidth,
    this.focusedBorderWidth,
    this.filled,
    this.fillColor,
    this.disabledFillColor,
    this.textStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
    this.cursorColor,
    this.iconColor,
    this.contentPadding,
    this.defaultMaxLength,
    this.labelStyle,
    this.labelGap,
  });

  @override
  KitTextFieldTheme copyWith({
    Widget? clearIcon,
    Widget? obscureOnIcon,
    Widget? obscureOffIcon,
    Widget? searchIcon,
    Color? borderColor,
    Color? focusColor,
    Color? errorColor,
    Color? disabledBorderColor,
    double? borderRadius,
    double? idleBorderWidth,
    double? focusedBorderWidth,
    bool? filled,
    Color? fillColor,
    Color? disabledFillColor,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    TextStyle? errorStyle,
    TextStyle? helperStyle,
    Color? cursorColor,
    Color? iconColor,
    EdgeInsetsGeometry? contentPadding,
    int? defaultMaxLength,
    TextStyle? labelStyle,
    double? labelGap,
  }) {
    return KitTextFieldTheme(
      clearIcon: clearIcon ?? this.clearIcon,
      obscureOnIcon: obscureOnIcon ?? this.obscureOnIcon,
      obscureOffIcon: obscureOffIcon ?? this.obscureOffIcon,
      searchIcon: searchIcon ?? this.searchIcon,
      borderColor: borderColor ?? this.borderColor,
      focusColor: focusColor ?? this.focusColor,
      errorColor: errorColor ?? this.errorColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      idleBorderWidth: idleBorderWidth ?? this.idleBorderWidth,
      focusedBorderWidth: focusedBorderWidth ?? this.focusedBorderWidth,
      filled: filled ?? this.filled,
      fillColor: fillColor ?? this.fillColor,
      disabledFillColor: disabledFillColor ?? this.disabledFillColor,
      textStyle: textStyle ?? this.textStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      errorStyle: errorStyle ?? this.errorStyle,
      helperStyle: helperStyle ?? this.helperStyle,
      cursorColor: cursorColor ?? this.cursorColor,
      iconColor: iconColor ?? this.iconColor,
      contentPadding: contentPadding ?? this.contentPadding,
      defaultMaxLength: defaultMaxLength ?? this.defaultMaxLength,
      labelStyle: labelStyle ?? this.labelStyle,
      labelGap: labelGap ?? this.labelGap,
    );
  }

  /// Returns a new theme where every non-null field of [other] overrides
  /// the corresponding field of `this`. Returns `this` unchanged when
  /// [other] is `null`. Used by `KitTextField.themeOverride` to patch the
  /// ambient theme for a single instance.
  KitTextFieldTheme merge(KitTextFieldTheme? other) {
    if (other == null) return this;
    return KitTextFieldTheme(
      clearIcon: other.clearIcon ?? clearIcon,
      obscureOnIcon: other.obscureOnIcon ?? obscureOnIcon,
      obscureOffIcon: other.obscureOffIcon ?? obscureOffIcon,
      searchIcon: other.searchIcon ?? searchIcon,
      borderColor: other.borderColor ?? borderColor,
      focusColor: other.focusColor ?? focusColor,
      errorColor: other.errorColor ?? errorColor,
      disabledBorderColor: other.disabledBorderColor ?? disabledBorderColor,
      borderRadius: other.borderRadius ?? borderRadius,
      idleBorderWidth: other.idleBorderWidth ?? idleBorderWidth,
      focusedBorderWidth: other.focusedBorderWidth ?? focusedBorderWidth,
      filled: other.filled ?? filled,
      fillColor: other.fillColor ?? fillColor,
      disabledFillColor: other.disabledFillColor ?? disabledFillColor,
      textStyle: other.textStyle ?? textStyle,
      hintStyle: other.hintStyle ?? hintStyle,
      errorStyle: other.errorStyle ?? errorStyle,
      helperStyle: other.helperStyle ?? helperStyle,
      cursorColor: other.cursorColor ?? cursorColor,
      iconColor: other.iconColor ?? iconColor,
      contentPadding: other.contentPadding ?? contentPadding,
      defaultMaxLength: other.defaultMaxLength ?? defaultMaxLength,
      labelStyle: other.labelStyle ?? labelStyle,
      labelGap: other.labelGap ?? labelGap,
    );
  }

  @override
  KitTextFieldTheme lerp(ThemeExtension<KitTextFieldTheme>? other, double t) {
    if (other is! KitTextFieldTheme) return this;
    return KitTextFieldTheme(
      clearIcon: t < 0.5 ? clearIcon : other.clearIcon,
      obscureOnIcon: t < 0.5 ? obscureOnIcon : other.obscureOnIcon,
      obscureOffIcon: t < 0.5 ? obscureOffIcon : other.obscureOffIcon,
      searchIcon: t < 0.5 ? searchIcon : other.searchIcon,
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      focusColor: Color.lerp(focusColor, other.focusColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      disabledBorderColor: Color.lerp(
        disabledBorderColor,
        other.disabledBorderColor,
        t,
      ),
      borderRadius: _lerpDouble(borderRadius, other.borderRadius, t),
      idleBorderWidth: _lerpDouble(idleBorderWidth, other.idleBorderWidth, t),
      focusedBorderWidth: _lerpDouble(
        focusedBorderWidth,
        other.focusedBorderWidth,
        t,
      ),
      filled: t < 0.5 ? filled : other.filled,
      fillColor: Color.lerp(fillColor, other.fillColor, t),
      disabledFillColor: Color.lerp(
        disabledFillColor,
        other.disabledFillColor,
        t,
      ),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      hintStyle: TextStyle.lerp(hintStyle, other.hintStyle, t),
      errorStyle: TextStyle.lerp(errorStyle, other.errorStyle, t),
      helperStyle: TextStyle.lerp(helperStyle, other.helperStyle, t),
      cursorColor: Color.lerp(cursorColor, other.cursorColor, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      contentPadding: EdgeInsetsGeometry.lerp(
        contentPadding,
        other.contentPadding,
        t,
      ),
      defaultMaxLength: t < 0.5 ? defaultMaxLength : other.defaultMaxLength,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t),
      labelGap: _lerpDouble(labelGap, other.labelGap, t),
    );
  }

  static double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    return (a ?? b!) + ((b ?? a!) - (a ?? b!)) * t;
  }
}
