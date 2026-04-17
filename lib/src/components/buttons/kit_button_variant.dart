/// Visual variant of [KitButton].
enum KitButtonVariant {
  /// Filled button with a solid background. Used for the main call-to-action
  /// on a screen. There should typically be only one primary button visible
  /// at a time.
  primary,

  /// Outlined button with a transparent background and a 1.5px border.
  /// Used for secondary actions that live alongside a primary button.
  secondary,

  /// Borderless, transparent button. Used for low-emphasis actions
  /// (e.g. "Cancel", inline links). Defaults to hugging its content
  /// instead of expanding to full width.
  text,
}
