import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_kit/src/theme/kit_button_theme.dart';

import 'kit_button_child.dart';
import 'kit_button_style.dart';
import 'kit_button_variant.dart';

/// Signature for [KitButton.onPressed].
///
/// May return either `void` or a `Future<void>`. When a `Future` is returned
/// the button automatically enters its loading state for the duration of the
/// future and locks out further taps until it completes.
typedef KitButtonCallback = FutureOr<void> Function();

/// A themed button with three visual variants ([KitButtonVariant]), built-in
/// tap debouncing, haptic feedback, an automatic async loading state, and
/// accessibility semantics.
///
/// Use the named factories instead of the default constructor:
///
/// ```dart
/// KitButton.primary(text: 'Save', onPressed: () => save());
/// KitButton.secondary(text: 'Cancel', onPressed: () => Navigator.pop(context));
/// KitButton.text(text: 'Learn more', onPressed: _openDocs);
/// ```
///
/// Styling is driven by [KitButtonTheme] registered on [ThemeData.extensions].
/// Per-instance overrides are currently limited to [loaderColor]; everything
/// else is resolved from the theme (or its built-in defaults).
class KitButton extends StatefulWidget {
  /// Button label. Rendered in a single line with ellipsis overflow.
  final String text;

  /// Called when the user taps the button.
  ///
  /// If `null`, the button renders in a disabled state.
  ///
  /// The callback may be synchronous or asynchronous; if it returns a
  /// `Future`, the button stays in its loading state until the future
  /// completes (success or error). Exceptions propagate to the caller and
  /// are **not** swallowed.
  final KitButtonCallback? onPressed;

  /// Externally controlled loading state. When `true`, the button hides its
  /// label/icon and shows a centered [CircularProgressIndicator]; taps are
  /// ignored. Combined (OR-ed) with the internal async loading state derived
  /// from [onPressed].
  final bool isLoading;

  /// Optional leading widget (typically an [Icon]) rendered before [text].
  /// Its color and a default size of 20px are applied via [IconTheme.merge],
  /// so a plain `Icon(Icons.add)` will pick up the computed content color.
  final Widget? icon;

  /// Whether the button should stretch to fill the available horizontal
  /// space. Defaults to `true` for [KitButton.primary] and
  /// [KitButton.secondary], and `false` for [KitButton.text].
  final bool isExpanded;

  /// Label exposed to assistive technologies (screen readers, etc.).
  /// When `null`, [text] is used.
  ///
  /// Override this when the visible label is non-descriptive (e.g. an
  /// iconographic "+" button whose semantic meaning is "Add item").
  final String? semanticLabel;

  /// Color of the loading spinner, overriding [KitButtonTheme.loaderColor].
  /// When both are `null`, the spinner inherits the text color computed from
  /// the current variant/enabled state.
  final Color? loaderColor;

  final KitButtonVariant _variant;

  const KitButton._({
    required this.text,
    required KitButtonVariant variant,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isExpanded = true,
    this.semanticLabel,
    this.loaderColor,
    super.key,
  }) : _variant = variant;

  /// Creates a filled primary button — the main call-to-action on a screen.
  ///
  /// Defaults to `isExpanded = true` so it stretches to the parent's width.
  factory KitButton.primary({
    required String text,
    KitButtonCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
    bool isExpanded = true,
    String? semanticLabel,
    Color? loaderColor,
    Key? key,
  }) {
    return KitButton._(
      key: key,
      text: text,
      variant: KitButtonVariant.primary,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      isExpanded: isExpanded,
      semanticLabel: semanticLabel,
      loaderColor: loaderColor,
    );
  }

  /// Creates an outlined secondary button for actions that accompany a
  /// primary action.
  ///
  /// Defaults to `isExpanded = true` to match an adjacent primary button.
  factory KitButton.secondary({
    required String text,
    KitButtonCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
    bool isExpanded = true,
    String? semanticLabel,
    Color? loaderColor,
    Key? key,
  }) {
    return KitButton._(
      key: key,
      text: text,
      variant: KitButtonVariant.secondary,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      isExpanded: isExpanded,
      semanticLabel: semanticLabel,
      loaderColor: loaderColor,
    );
  }

  /// Creates a borderless text-only button for low-emphasis actions.
  ///
  /// Defaults to `isExpanded = false` so it hugs its content rather than
  /// expanding to full width.
  factory KitButton.text({
    required String text,
    KitButtonCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
    bool isExpanded = false,
    String? semanticLabel,
    Color? loaderColor,
    Key? key,
  }) {
    return KitButton._(
      key: key,
      text: text,
      variant: KitButtonVariant.text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      isExpanded: isExpanded,
      semanticLabel: semanticLabel,
      loaderColor: loaderColor,
    );
  }

  @override
  State<KitButton> createState() => _KitButtonState();
}

class _KitButtonState extends State<KitButton> {
  /// Timestamp of the last accepted tap — drives the 400ms debounce window.
  DateTime? _lastTapTime;

  /// `true` while an async [KitButtonCallback] is still in flight.
  /// Merged with [KitButton.isLoading] to produce the effective loading
  /// state used for both visuals and input blocking.
  bool _isProcessing = false;

  Future<void> _handlePress() async {
    if (widget.onPressed == null || widget.isLoading || _isProcessing) {
      return;
    }

    final DateTime now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 400)) {
      return;
    }
    _lastTapTime = now;

    HapticFeedback.lightImpact();

    final FutureOr<void> result = widget.onPressed!();
    if (result is Future<void>) {
      setState(() => _isProcessing = true);
      try {
        await result;
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KitButtonTheme? kitTheme = theme.extension<KitButtonTheme>();

    final Color primaryColor = kitTheme?.primaryColor ?? theme.primaryColor;
    final Color onPrimaryColor = kitTheme?.onPrimaryColor ?? Colors.white;
    final Color disabledColor =
        kitTheme?.disabledColor ?? Colors.grey.shade400;
    final Color disabledContentColor =
        kitTheme?.disabledContentColor ?? Colors.grey.shade500;
    final double radius = kitTheme?.borderRadius ?? 12.0;
    final double height = kitTheme?.height ?? 48.0;
    final double loaderSize = (height * 0.5).clamp(16.0, 28.0);

    final bool isLoading = widget.isLoading || _isProcessing;
    final bool isDisabled = widget.onPressed == null || isLoading;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: widget.semanticLabel ?? widget.text,
      child: SizedBox(
        height: height,
        width: widget.isExpanded ? double.infinity : null,
        child: ElevatedButton(
          style: kitButtonStyleFor(
            variant: widget._variant,
            primaryColor: primaryColor,
            disabledColor: disabledColor,
            radius: radius,
            isDisabled: isDisabled,
          ),
          onPressed: isDisabled ? null : _handlePress,
          child: KitButtonChild(
            variant: widget._variant,
            primaryColor: primaryColor,
            onPrimaryColor: onPrimaryColor,
            disabledContentColor: disabledContentColor,
            loaderColor: widget.loaderColor ?? kitTheme?.loaderColor,
            isDisabled: isDisabled,
            isLoading: isLoading,
            isExpanded: widget.isExpanded,
            loaderSize: loaderSize,
            text: widget.text,
            icon: widget.icon,
            textStyle: kitTheme?.textStyle,
          ),
        ),
      ),
    );
  }
}
