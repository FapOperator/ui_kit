/// Visual and behavioral variant of [KitTextField].
enum KitTextFieldVariant {
  /// Standard single-line text field.
  standard,

  /// Password field. Text is obscured by default; a visibility-toggle icon
  /// is rendered as the suffix.
  password,

  /// Search field. Shows a leading search icon and a trailing clear button;
  /// `onChanged` is debounced by 500 ms and flushed on submit / focus loss.
  search,

  /// Multi-line text area with newline input action.
  multiline,

  /// Numeric input. Accepts digits, dot and comma (and optionally a
  /// leading minus); uses a numeric keyboard with decimal support.
  number,

  /// Email input. Lower-cases input automatically, disables autocorrect
  /// and capitalization, and wires up `AutofillHints.email`.
  email,

  /// One-time-code / PIN input. Digits only, fixed length, wires up
  /// `AutofillHints.oneTimeCode` (iOS auto-fills from SMS).
  otp,
}
