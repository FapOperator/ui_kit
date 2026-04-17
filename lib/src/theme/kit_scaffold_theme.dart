import 'package:flutter/material.dart';

/// Theme extension that provides defaults for every [KitScaffold] in the
/// widget subtree.
///
/// Register it on your [ThemeData] to customize scaffolds app-wide:
///
/// ```dart
/// ThemeData(
///   extensions: const <ThemeExtension<dynamic>>[
///     KitScaffoldTheme(horizontalPadding: 20.0, overlayOpacity: 0.4),
///   ],
/// );
/// ```
///
/// All fields are nullable — any field left as `null` falls back to a sane
/// built-in default inside [KitScaffold.build], so you can override only
/// the pieces you care about.
@immutable
class KitScaffoldTheme extends ThemeExtension<KitScaffoldTheme> {
  /// Horizontal padding applied to the body when the default (non-`full`)
  /// factory is used. Falls back to `16.0`.
  final double? horizontalPadding;

  /// Scrim color of the loading overlay shown while [KitScaffold.isLoading]
  /// is `true`. The alpha channel is multiplied by [overlayOpacity] at
  /// paint time. Falls back to [Colors.black].
  final Color? overlayColor;

  /// Opacity of the loading overlay scrim. Falls back to `0.3`.
  final double? overlayOpacity;

  /// Color of the [CircularProgressIndicator] drawn inside the loading
  /// overlay. Falls back to `Theme.of(context).primaryColor`.
  final Color? loaderColor;

  const KitScaffoldTheme({
    this.horizontalPadding,
    this.overlayColor,
    this.overlayOpacity,
    this.loaderColor,
  });

  @override
  KitScaffoldTheme copyWith({
    double? horizontalPadding,
    Color? overlayColor,
    double? overlayOpacity,
    Color? loaderColor,
  }) {
    return KitScaffoldTheme(
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      overlayColor: overlayColor ?? this.overlayColor,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      loaderColor: loaderColor ?? this.loaderColor,
    );
  }

  @override
  KitScaffoldTheme lerp(ThemeExtension<KitScaffoldTheme>? other, double t) {
    if (other is! KitScaffoldTheme) return this;
    return KitScaffoldTheme(
      horizontalPadding: _lerpDouble(
        horizontalPadding,
        other.horizontalPadding,
        t,
      ),
      overlayColor: Color.lerp(overlayColor, other.overlayColor, t),
      overlayOpacity: _lerpDouble(overlayOpacity, other.overlayOpacity, t),
      loaderColor: Color.lerp(loaderColor, other.loaderColor, t),
    );
  }

  static double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    return (a ?? b!) + ((b ?? a!) - (a ?? b!)) * t;
  }
}
