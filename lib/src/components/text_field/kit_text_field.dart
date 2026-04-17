import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_kit/src/theme/kit_text_field_theme.dart';

import 'kit_text_field_style.dart';
import 'kit_text_field_suffix.dart';
import 'kit_text_field_variant.dart';

/// Debounce window for [KitTextField.search]'s `onChanged` callback.
const Duration _kSearchDebounce = Duration(milliseconds: 500);

/// Fallback style for the external top label when neither the instance
/// nor the theme provides one.
TextStyle _defaultLabelStyle() => TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.w500,
  color: Colors.grey.shade800,
);

/// A themed, form-aware text field with seven ready-made variants
/// ([KitTextFieldVariant]).
///
/// Every field renders an **external top label** above the input. Its
/// style and the vertical gap to the input are set via
/// [KitTextFieldTheme.labelStyle] / [KitTextFieldTheme.labelGap] and can
/// be overridden per-instance with [labelStyle] / [labelGap].
///
/// ```dart
/// KitTextField(label: 'Name');
/// KitTextField.email(label: 'Email');
/// KitTextField.password(label: 'Password');
/// KitTextField.search(label: 'Search', onChanged: _runQuery);
/// KitTextField.multiline(label: 'Notes', minLines: 3, maxLines: 8);
/// KitTextField.number(label: 'Amount', allowNegative: true);
/// KitTextField.otp(label: 'Code', length: 6);
/// ```
///
/// Each variant wires up the right keyboard, input formatters, autofill
/// hints, suffix icon and (for search) input debouncing.
class KitTextField extends StatefulWidget {
  /// Text rendered as an external label above the input. Always visible;
  /// styling comes from [labelStyle] / [KitTextFieldTheme.labelStyle].
  /// Pass an empty string to omit the label row entirely.
  final String label;

  /// Per-instance override for the label text style. Falls back to
  /// [KitTextFieldTheme.labelStyle] and then to the built-in default.
  final TextStyle? labelStyle;

  /// Per-instance override for the vertical gap between the external
  /// label and the input. Falls back to [KitTextFieldTheme.labelGap] and
  /// then to `8.0`.
  final double? labelGap;

  /// Optional externally-managed controller. When `null`, the widget
  /// creates and disposes its own internal controller.
  ///
  /// Hot-swapping between `null` and a non-`null` controller across
  /// rebuilds is supported: the widget migrates the current text forward
  /// and keeps working.
  final TextEditingController? controller;

  /// Optional externally-managed focus node. When `null`, the widget
  /// creates and disposes its own internal focus node.
  ///
  /// Hot-swapping across rebuilds is supported.
  final FocusNode? focusNode;

  /// Called as the user types. For [KitTextFieldVariant.search] the
  /// invocation is debounced by 500 ms and is also flushed on submit or
  /// on focus loss so the latest value is never dropped.
  final ValueChanged<String>? onChanged;

  /// Called when the user presses the keyboard's action button (Enter,
  /// Search, Done, ...).
  ///
  /// For search variants, any pending debounced `onChanged` is flushed
  /// before `onSubmitted` is invoked.
  final ValueChanged<String>? onSubmitted;

  /// Form validator, invoked by an enclosing [Form.validate].
  final FormFieldValidator<String>? validator;

  /// Overrides the variant's default [TextInputType]. Leave `null` to use
  /// the variant default (e.g. numeric for [KitTextFieldVariant.number]).
  final TextInputType? keyboardType;

  /// Additional input formatters, merged with the variant defaults.
  final List<TextInputFormatter>? inputFormatters;

  /// Leading widget inside the input. For [KitTextFieldVariant.search] it
  /// overrides the built-in search icon.
  final Widget? prefixIcon;

  /// Trailing widget inside the input. Ignored for
  /// [KitTextFieldVariant.password] (slot is used by the visibility
  /// toggle) and for a non-empty [KitTextFieldVariant.search] (slot is
  /// used by the clear button).
  final Widget? suffixIcon;

  /// Inline text shown before the input value (e.g. `$`, `+7`). Rendered
  /// with the hint style.
  final String? prefixText;

  /// Inline text shown after the input value (e.g. `kg`, `%`). Rendered
  /// with the hint style.
  final String? suffixText;

  /// Minimum number of visible lines.
  final int? minLines;

  /// Maximum number of visible lines. Defaults to `1` for single-line
  /// variants and is overridden by [KitTextField.multiline].
  final int? maxLines;

  /// Hard limit on the number of input characters. Flutter shows a
  /// character counter below the field automatically; the counter is
  /// hidden for [KitTextFieldVariant.otp].
  final int? maxLength;

  /// Action label shown on the soft keyboard (Done, Next, Search, ...).
  final TextInputAction? textInputAction;

  /// Auto-capitalization behavior. Defaults to
  /// [TextCapitalization.none]; [KitTextField.multiline] raises it to
  /// [TextCapitalization.sentences].
  final TextCapitalization textCapitalization;

  /// Placeholder shown inside the input when empty and unfocused.
  final String? hintText;

  /// Informational text rendered below the field (e.g. "We'll never share
  /// your email"). Hidden automatically while [errorText] is displayed.
  final String? helperText;

  /// Externally supplied error message. Takes precedence over [validator]
  /// output. Use for asynchronous errors (e.g. "email already in use"
  /// from the server).
  final String? errorText;

  /// Called when the user taps anywhere inside the field.
  ///
  /// Combined with [readOnly] `= true` this is the canonical way to
  /// build picker-style inputs (tap → open a date/country picker, assign
  /// result to the controller).
  final VoidCallback? onTap;

  /// When `true`, blocks editing but keeps the field focusable and
  /// selectable. Contrast with [enabled].
  final bool readOnly;

  /// When `false`, renders the field in its disabled visual state, blocks
  /// focus, hides the suffix toggle/clear buttons, and disables paste.
  final bool enabled;

  /// Requests focus on first build.
  final bool autofocus;

  /// Whether the OS offers autocorrect suggestions. Defaults vary per
  /// variant: text-like variants allow it, password/search/number/email/
  /// otp disable it.
  final bool autocorrect;

  /// Autofill hints passed to the OS (e.g. [AutofillHints.password],
  /// [AutofillHints.email], [AutofillHints.oneTimeCode]). The password,
  /// email and otp factories pre-fill sensible defaults; pass an explicit
  /// value to override, or an empty list to opt out entirely.
  final Iterable<String>? autofillHints;

  /// Per-instance theme patch. Merged on top of the ambient
  /// [KitTextFieldTheme] (via [KitTextFieldTheme.merge]), so you only
  /// specify the fields you want to change for this specific field.
  final KitTextFieldTheme? themeOverride;

  final KitTextFieldVariant _variant;
  final bool _showClearButton;
  final bool _allowNegative;

  const KitTextField._({
    required this.label,
    required KitTextFieldVariant variant,
    this.labelStyle,
    this.labelGap,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.hintText,
    this.helperText,
    this.errorText,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.autocorrect = true,
    this.autofillHints,
    this.themeOverride,
    bool showClearButton = false,
    bool allowNegative = false,
    super.key,
  }) : _variant = variant,
       _showClearButton = showClearButton,
       _allowNegative = allowNegative;

  /// Creates a standard single-line text field.
  factory KitTextField({
    required String label,
    TextStyle? labelStyle,
    double? labelGap,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? prefixText,
    String? suffixText,
    int? maxLength,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? hintText,
    String? errorText,
    bool readOnly = false,
    bool enabled = true,
    bool autofocus = false,
    bool autocorrect = true,
    Iterable<String>? autofillHints,
    String? helperText,
    VoidCallback? onTap,
    KitTextFieldTheme? themeOverride,
    Key? key,
  }) {
    return KitTextField._(
      key: key,
      helperText: helperText,
      onTap: onTap,
      themeOverride: themeOverride,
      label: label,
      labelStyle: labelStyle,
      labelGap: labelGap,
      variant: KitTextFieldVariant.standard,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixText: prefixText,
      suffixText: suffixText,
      maxLength: maxLength,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      hintText: hintText,
      errorText: errorText,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      autocorrect: autocorrect,
      autofillHints: autofillHints,
    );
  }

  /// Creates a password field. Text starts obscured; the trailing icon
  /// toggles visibility. Pre-fills `AutofillHints.password` unless
  /// overridden.
  factory KitTextField.password({
    required String label,
    TextStyle? labelStyle,
    double? labelGap,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    FormFieldValidator<String>? validator,
    Widget? prefixIcon,
    int? maxLength,
    TextInputAction? textInputAction,
    String? hintText,
    String? errorText,
    bool enabled = true,
    bool autofocus = false,
    Iterable<String>? autofillHints,
    String? helperText,
    VoidCallback? onTap,
    KitTextFieldTheme? themeOverride,
    Key? key,
  }) {
    return KitTextField._(
      key: key,
      helperText: helperText,
      onTap: onTap,
      themeOverride: themeOverride,
      label: label,
      labelStyle: labelStyle,
      labelGap: labelGap,
      variant: KitTextFieldVariant.password,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      prefixIcon: prefixIcon,
      maxLines: 1,
      maxLength: maxLength,
      textInputAction: textInputAction,
      hintText: hintText,
      errorText: errorText,
      enabled: enabled,
      autofocus: autofocus,
      autocorrect: false,
      autofillHints:
          autofillHints ?? const <String>[AutofillHints.password],
    );
  }

  /// Creates a search field. Leads with a search icon, trails with a live
  /// clear button, debounces [onChanged] by 500 ms, and flushes pending
  /// changes on submit and on focus loss.
  factory KitTextField.search({
    required String label,
    TextStyle? labelStyle,
    double? labelGap,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    Widget? prefixIcon,
    String? hintText,
    bool enabled = true,
    bool autofocus = false,
    String? helperText,
    VoidCallback? onTap,
    KitTextFieldTheme? themeOverride,
    Key? key,
  }) {
    return KitTextField._(
      key: key,
      helperText: helperText,
      onTap: onTap,
      themeOverride: themeOverride,
      label: label,
      labelStyle: labelStyle,
      labelGap: labelGap,
      variant: KitTextFieldVariant.search,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: prefixIcon,
      textInputAction: TextInputAction.search,
      showClearButton: true,
      hintText: hintText,
      enabled: enabled,
      autofocus: autofocus,
      autocorrect: false,
    );
  }

  /// Creates a multi-line text area.
  ///
  /// Defaults: `minLines: 3`, `maxLines: 5`,
  /// [TextCapitalization.sentences]. Pass `maxLines: null` for an
  /// unbounded area.
  factory KitTextField.multiline({
    required String label,
    TextStyle? labelStyle,
    double? labelGap,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    int minLines = 3,
    int? maxLines = 5,
    int? maxLength,
    String? hintText,
    String? errorText,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    bool enabled = true,
    bool autofocus = false,
    bool autocorrect = true,
    String? helperText,
    VoidCallback? onTap,
    KitTextFieldTheme? themeOverride,
    Key? key,
  }) {
    return KitTextField._(
      key: key,
      helperText: helperText,
      onTap: onTap,
      themeOverride: themeOverride,
      label: label,
      labelStyle: labelStyle,
      labelGap: labelGap,
      variant: KitTextFieldVariant.multiline,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: TextInputAction.newline,
      textCapitalization: textCapitalization,
      hintText: hintText,
      errorText: errorText,
      enabled: enabled,
      autofocus: autofocus,
      autocorrect: autocorrect,
    );
  }

  /// Creates a numeric field. Accepts digits with a single `.` or `,`
  /// decimal separator; when [allowNegative] is `true` a single leading
  /// `-` is also accepted.
  factory KitTextField.number({
    required String label,
    TextStyle? labelStyle,
    double? labelGap,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    FormFieldValidator<String>? validator,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? prefixText,
    String? suffixText,
    String? hintText,
    String? errorText,
    bool allowNegative = false,
    bool enabled = true,
    bool autofocus = false,
    String? helperText,
    VoidCallback? onTap,
    KitTextFieldTheme? themeOverride,
    Key? key,
  }) {
    return KitTextField._(
      key: key,
      helperText: helperText,
      onTap: onTap,
      themeOverride: themeOverride,
      label: label,
      labelStyle: labelStyle,
      labelGap: labelGap,
      variant: KitTextFieldVariant.number,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixText: prefixText,
      suffixText: suffixText,
      hintText: hintText,
      errorText: errorText,
      allowNegative: allowNegative,
      enabled: enabled,
      autofocus: autofocus,
      autocorrect: false,
    );
  }

  /// Creates an email field. Email keyboard, lower-case input, autocorrect
  /// and capitalization disabled, `AutofillHints.email` pre-filled.
  factory KitTextField.email({
    required String label,
    TextStyle? labelStyle,
    double? labelGap,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    FormFieldValidator<String>? validator,
    Widget? prefixIcon,
    String? hintText,
    String? errorText,
    bool enabled = true,
    bool autofocus = false,
    Iterable<String>? autofillHints,
    String? helperText,
    VoidCallback? onTap,
    KitTextFieldTheme? themeOverride,
    Key? key,
  }) {
    return KitTextField._(
      key: key,
      helperText: helperText,
      onTap: onTap,
      themeOverride: themeOverride,
      label: label,
      labelStyle: labelStyle,
      labelGap: labelGap,
      variant: KitTextFieldVariant.email,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      prefixIcon: prefixIcon,
      textInputAction: TextInputAction.next,
      hintText: hintText,
      errorText: errorText,
      enabled: enabled,
      autofocus: autofocus,
      autocorrect: false,
      autofillHints: autofillHints ?? const <String>[AutofillHints.email],
    );
  }

  /// Creates a one-time-code / PIN field. Digits only, fixed [length]
  /// (default 6), `AutofillHints.oneTimeCode` pre-filled so iOS can
  /// auto-populate from SMS.
  factory KitTextField.otp({
    required String label,
    int length = 6,
    TextStyle? labelStyle,
    double? labelGap,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    FormFieldValidator<String>? validator,
    String? hintText,
    String? errorText,
    bool enabled = true,
    bool autofocus = true,
    Iterable<String>? autofillHints,
    String? helperText,
    VoidCallback? onTap,
    KitTextFieldTheme? themeOverride,
    Key? key,
  }) {
    return KitTextField._(
      key: key,
      helperText: helperText,
      onTap: onTap,
      themeOverride: themeOverride,
      label: label,
      labelStyle: labelStyle,
      labelGap: labelGap,
      variant: KitTextFieldVariant.otp,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      maxLines: 1,
      maxLength: length,
      textInputAction: TextInputAction.done,
      hintText: hintText,
      errorText: errorText,
      enabled: enabled,
      autofocus: autofocus,
      autocorrect: false,
      autofillHints:
          autofillHints ?? const <String>[AutofillHints.oneTimeCode],
    );
  }

  @override
  State<KitTextField> createState() => _KitTextFieldState();
}

class _KitTextFieldState extends State<KitTextField> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;
  Timer? _debounceTimer;

  bool _isObscured = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController!;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    if (widget._variant == KitTextFieldVariant.password) {
      _isObscured = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(KitTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null && widget.controller != null) {
        _internalController?.dispose();
        _internalController = null;
      } else if (oldWidget.controller != null && widget.controller == null) {
        _internalController = TextEditingController(
          text: oldWidget.controller!.text,
        );
      }
    }

    if (oldWidget.focusNode != widget.focusNode) {
      final FocusNode oldFocus = oldWidget.focusNode ?? _internalFocusNode!;
      oldFocus.removeListener(_handleFocusChange);
      if (oldWidget.focusNode == null && widget.focusNode != null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      } else if (oldWidget.focusNode != null && widget.focusNode == null) {
        _internalFocusNode = FocusNode();
      }
      _focusNode.addListener(_handleFocusChange);
    }

    if (oldWidget._variant != KitTextFieldVariant.password &&
        widget._variant == KitTextFieldVariant.password) {
      _isObscured = true;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _flushDebounce();
    }
  }

  void _flushDebounce() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
      widget.onChanged?.call(_controller.text);
    }
  }

  void _handleChanged(String value) {
    if (widget.onChanged == null) return;

    if (widget._variant == KitTextFieldVariant.search) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_kSearchDebounce, () {
        widget.onChanged!(value);
      });
    } else {
      widget.onChanged!(value);
    }
  }

  void _handleSubmitted(String value) {
    _flushDebounce();
    widget.onSubmitted?.call(value);
  }

  void _toggleObscure() => setState(() => _isObscured = !_isObscured);

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call('');
    _focusNode.requestFocus();
  }

  Widget? _buildPrefix(KitTextFieldTheme? kitTheme) {
    if (widget._variant == KitTextFieldVariant.search) {
      return widget.prefixIcon ??
          kitTheme?.searchIcon ??
          const Icon(Icons.search);
    }
    return widget.prefixIcon;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KitTextFieldTheme kitTheme =
        (theme.extension<KitTextFieldTheme>() ?? const KitTextFieldTheme())
            .merge(widget.themeOverride);

    final Color borderColor = kitTheme.borderColor ?? Colors.grey.shade400;
    final Color focusColor = kitTheme.focusColor ?? theme.primaryColor;
    final Color errorColor = kitTheme.errorColor ?? Colors.red;
    final Color disabledBorderColor =
        kitTheme.disabledBorderColor ?? borderColor;
    final double radius = kitTheme.borderRadius ?? 8.0;
    final double idleBorderWidth = kitTheme.idleBorderWidth ?? 1.0;
    final double focusedBorderWidth = kitTheme.focusedBorderWidth ?? 2.0;

    final bool filled = kitTheme.filled ?? false;
    final Color? baseFillColor = kitTheme.fillColor;
    final Color? disabledFillColor =
        kitTheme.disabledFillColor ?? baseFillColor;
    final Color? effectiveFillColor =
        widget.enabled ? baseFillColor : disabledFillColor;

    final EdgeInsetsGeometry contentPadding =
        kitTheme.contentPadding ??
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);

    final TextStyle labelStyle =
        widget.labelStyle ?? kitTheme.labelStyle ?? _defaultLabelStyle();
    final double labelGap =
        widget.labelGap ?? kitTheme.labelGap ?? 8.0;

    // maxLength: explicit per-field → theme default → 255 fallback.
    // When the limit comes from the theme (i.e. the field didn't ask for
    // one), the counter is hidden so the cap behaves as a silent safety
    // limit instead of a user-facing hint.
    final bool maxLengthExplicit = widget.maxLength != null;
    final int effectiveMaxLength =
        widget.maxLength ?? kitTheme.defaultMaxLength ?? 255;
    final bool hideCounter =
        widget._variant == KitTextFieldVariant.otp || !maxLengthExplicit;

    final Color? iconColor = kitTheme.iconColor;

    Widget field = TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      autofillHints: widget.autofillHints,
      textCapitalization: widget.textCapitalization,
      style: kitTheme.textStyle,
      cursorColor: kitTheme.cursorColor,
      onChanged: _handleChanged,
      onFieldSubmitted: _handleSubmitted,
      onTap: widget.onTap,
      validator: widget.validator,
      keyboardType: kitTextFieldKeyboardType(
        variant: widget._variant,
        override: widget.keyboardType,
      ),
      inputFormatters: kitTextFieldFormatters(
        variant: widget._variant,
        custom: widget.inputFormatters,
        allowNegative: widget._allowNegative,
      ),
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: effectiveMaxLength,
      textInputAction: widget.textInputAction,
      obscureText: _isObscured,
      readOnly: widget.readOnly,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: kitTheme.hintStyle,
        helperText: widget.helperText,
        helperStyle: kitTheme.helperStyle,
        errorText: widget.errorText,
        errorStyle: kitTheme.errorStyle,
        prefixIcon: _buildPrefix(kitTheme),
        suffixIcon: buildKitTextFieldSuffix(
          variant: widget._variant,
          controller: _controller,
          showClearButton: widget._showClearButton,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          isObscured: _isObscured,
          onToggleObscure: _toggleObscure,
          onClear: _handleClear,
          customSuffix: widget.suffixIcon,
          theme: kitTheme,
        ),
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        counterText: hideCounter ? '' : null,
        filled: filled,
        fillColor: effectiveFillColor,
        contentPadding: contentPadding,
        border: kitTextFieldBorder(
          color: borderColor,
          radius: radius,
          width: idleBorderWidth,
        ),
        enabledBorder: kitTextFieldBorder(
          color: borderColor,
          radius: radius,
          width: idleBorderWidth,
        ),
        disabledBorder: kitTextFieldBorder(
          color: disabledBorderColor,
          radius: radius,
          width: idleBorderWidth,
        ),
        focusedBorder: kitTextFieldBorder(
          color: focusColor,
          radius: radius,
          width: focusedBorderWidth,
        ),
        errorBorder: kitTextFieldBorder(
          color: errorColor,
          radius: radius,
          width: idleBorderWidth,
        ),
        focusedErrorBorder: kitTextFieldBorder(
          color: errorColor,
          radius: radius,
          width: focusedBorderWidth,
        ),
      ),
    );

    if (iconColor != null) {
      field = IconTheme.merge(
        data: IconThemeData(color: iconColor),
        child: field,
      );
    }

    if (widget.label.isEmpty) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(widget.label, style: labelStyle),
        SizedBox(height: labelGap),
        field,
      ],
    );
  }
}
