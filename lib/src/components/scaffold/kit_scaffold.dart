import 'package:flutter/material.dart';
import 'package:ui_kit/src/theme/kit_scaffold_theme.dart';

/// Base screen scaffold for the UI kit.
///
/// Thin wrapper around [Scaffold] that bundles four opinionated behaviors:
/// a horizontal gutter, a smart [SafeArea], keyboard-dismiss-on-outside-tap
/// and a full-screen loading overlay. Register [KitScaffoldTheme] on
/// [ThemeData.extensions] to tune padding/overlay colors globally.
///
/// ```dart
/// KitScaffold(
///   appBar: AppBar(title: const Text('Profile')),
///   body: ListView(children: const <Widget>[...]),
///   isLoading: _saving,
/// );
/// ```
class KitScaffold extends StatelessWidget {
  /// Main content of the screen.
  final Widget body;

  /// Top app bar.
  final PreferredSizeWidget? appBar;

  /// Persistent bottom navigation bar. When set, the built-in [SafeArea]
  /// skips its bottom inset to avoid a double-padded footer.
  final Widget? bottomNavigationBar;

  /// Floating action button anchored to the scaffold.
  final Widget? floatingActionButton;

  /// When `true`, renders a scrim + [CircularProgressIndicator] on top of
  /// the scaffold and blocks taps. Fades in/out over 200 ms.
  final bool isLoading;

  /// When `true` (default), a tap on empty space inside the scaffold
  /// dismisses the on-screen keyboard.
  final bool unfocusOnTap;

  /// Mirrors [Scaffold.resizeToAvoidBottomInset]. Defaults to `true` — the
  /// body shrinks when the software keyboard appears, which is what forms
  /// usually want.
  final bool resizeToAvoidBottomInset;

  /// When `true` (default), the loading overlay covers the entire screen
  /// including the [appBar]. Set to `false` to keep the app bar
  /// interactive (e.g. back button) while the body is loading.
  final bool blocksAppBar;

  /// Scaffold background color. Falls back to
  /// `Theme.of(context).scaffoldBackgroundColor`.
  final Color? backgroundColor;

  /// Per-instance theme patch. Merged on top of the ambient
  /// [KitScaffoldTheme] (via [KitScaffoldTheme.merge]), so you only
  /// specify the fields you want to change for this specific screen.
  final KitScaffoldTheme? themeOverride;

  final bool _useHorizontalPadding;
  final bool _useSafeArea;

  const KitScaffold._({
    required this.body,
    required bool useHorizontalPadding,
    required bool useSafeArea,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.isLoading = false,
    this.unfocusOnTap = true,
    this.resizeToAvoidBottomInset = true,
    this.blocksAppBar = true,
    this.backgroundColor,
    this.themeOverride,
    super.key,
  }) : _useHorizontalPadding = useHorizontalPadding,
       _useSafeArea = useSafeArea;

  /// Standard screen: applies the horizontal gutter and [SafeArea].
  /// Suitable for settings, profile, forms.
  factory KitScaffold({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    bool isLoading = false,
    bool unfocusOnTap = true,
    bool resizeToAvoidBottomInset = true,
    bool useSafeArea = true,
    bool blocksAppBar = true,
    Color? backgroundColor,
    KitScaffoldTheme? themeOverride,
    Key? key,
  }) {
    return KitScaffold._(
      themeOverride: themeOverride,
      key: key,
      body: body,
      useHorizontalPadding: true,
      useSafeArea: useSafeArea,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      isLoading: isLoading,
      unfocusOnTap: unfocusOnTap,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      blocksAppBar: blocksAppBar,
      backgroundColor: backgroundColor,
    );
  }

  /// Full-bleed screen: no horizontal gutter. Suitable for feeds,
  /// edge-to-edge lists, maps.
  factory KitScaffold.full({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    bool isLoading = false,
    bool unfocusOnTap = true,
    bool resizeToAvoidBottomInset = true,
    bool useSafeArea = true,
    bool blocksAppBar = true,
    Color? backgroundColor,
    KitScaffoldTheme? themeOverride,
    Key? key,
  }) {
    return KitScaffold._(
      themeOverride: themeOverride,
      key: key,
      body: body,
      useHorizontalPadding: false,
      useSafeArea: useSafeArea,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      isLoading: isLoading,
      unfocusOnTap: unfocusOnTap,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      blocksAppBar: blocksAppBar,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final KitScaffoldTheme kitTheme =
        (theme.extension<KitScaffoldTheme>() ?? const KitScaffoldTheme())
            .merge(themeOverride);

    final double horizontalPadding = kitTheme.horizontalPadding ?? 16.0;
    final Color overlayColor = kitTheme.overlayColor ?? Colors.black;
    final double overlayOpacity = kitTheme.overlayOpacity ?? 0.3;
    final Color loaderColor = kitTheme.loaderColor ?? theme.primaryColor;

    Widget content = body;

    if (_useHorizontalPadding) {
      content = Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: content,
      );
    }

    if (_useSafeArea) {
      content = SafeArea(
        bottom: bottomNavigationBar == null,
        child: content,
      );
    }

    if (!blocksAppBar) {
      content = _wrapWithOverlay(
        child: content,
        color: overlayColor,
        opacity: overlayOpacity,
        loaderColor: loaderColor,
      );
    }

    Widget rootWidget = Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );

    if (unfocusOnTap) {
      rootWidget = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: rootWidget,
      );
    }

    if (blocksAppBar) {
      rootWidget = _wrapWithOverlay(
        child: rootWidget,
        color: overlayColor,
        opacity: overlayOpacity,
        loaderColor: loaderColor,
      );
    }

    return rootWidget;
  }

  Widget _wrapWithOverlay({
    required Widget child,
    required Color color,
    required double opacity,
    required Color loaderColor,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isLoading,
            child: AnimatedOpacity(
              opacity: isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: ColoredBox(
                color: color.withValues(alpha: opacity),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
