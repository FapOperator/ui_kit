import 'package:flutter/widgets.dart';

import 'kit_validator_messages.dart';

export 'kit_validator_messages.dart';

/// Ready-made set of `FormFieldValidator<String>` factories.
///
/// Every factory returns a pure `String? Function(String?)` compatible
/// with [TextFormField.validator] / [Form.validate], and pulls its error
/// messages from [KitValidators.messages]. Localize the whole set once
/// by assigning a custom [KitValidatorMessages] at app startup — no
/// strings are ever passed into individual factory calls.
///
/// ```dart
/// void main() {
///   KitValidators.messages = KitValidatorMessages(
///     required: 'Обязательное поле',
///     email: 'Неверный email',
///     minLength: (int n) => 'Минимум $n символов',
///   );
///   runApp(const MyApp());
/// }
///
/// KitTextField.email(
///   label: 'Email',
///   validator: KitValidators.combine(<FormFieldValidator<String>>[
///     KitValidators.required(),
///     KitValidators.email(),
///   ]),
/// );
/// ```
class KitValidators {
  KitValidators._();

  /// Globally-configured error messages. Reassign to localize; every
  /// subsequent validator call reads from here.
  static KitValidatorMessages messages = const KitValidatorMessages();

  // ──────────── presence / length ────────────

  /// Requires a non-empty, non-whitespace value.
  static FormFieldValidator<String> required() {
    return (String? v) {
      if (v == null || v.trim().isEmpty) return messages.required;
      return null;
    };
  }

  /// Requires the value to be at least [n] characters long.
  static FormFieldValidator<String> minLength(int n) {
    return (String? v) {
      if ((v?.length ?? 0) < n) return messages.minLength(n);
      return null;
    };
  }

  /// Requires the value to be at most [n] characters long.
  static FormFieldValidator<String> maxLength(int n) {
    return (String? v) {
      if (v != null && v.length > n) return messages.maxLength(n);
      return null;
    };
  }

  /// Requires the value length to fall within `[min, max]` (inclusive).
  static FormFieldValidator<String> lengthRange(int min, int max) {
    return (String? v) {
      final int len = v?.length ?? 0;
      if (len < min || len > max) return messages.lengthRange(min, max);
      return null;
    };
  }

  /// Requires the value to be exactly [n] characters long.
  static FormFieldValidator<String> exactLength(int n) {
    return (String? v) {
      if ((v?.length ?? 0) != n) return messages.exactLength(n);
      return null;
    };
  }

  // ──────────── format ────────────

  /// Validates the value looks like an email address.
  static FormFieldValidator<String> email() {
    final RegExp re = RegExp(r'^[\w.+\-]+@[\w\-]+\.[\w.\-]+$');
    return (String? v) {
      if (v == null || v.isEmpty || !re.hasMatch(v)) return messages.email;
      return null;
    };
  }

  /// Validates the value looks like an HTTP/HTTPS URL.
  static FormFieldValidator<String> url() {
    final RegExp re = RegExp(
      r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\/?#].*)?$',
      caseSensitive: false,
    );
    return (String? v) {
      if (v == null || v.isEmpty || !re.hasMatch(v)) return messages.url;
      return null;
    };
  }

  /// Validates the value looks like a phone number (digits with optional
  /// `+`, spaces, dashes, parentheses; at least 7 digits total).
  static FormFieldValidator<String> phone() {
    final RegExp shape = RegExp(r'^[\d\s+\-().]+$');
    return (String? v) {
      if (v == null || !shape.hasMatch(v)) return messages.phone;
      final int digits = v.replaceAll(RegExp(r'\D'), '').length;
      if (digits < 7) return messages.phone;
      return null;
    };
  }

  /// Validates the value parses as a number (accepts `.` or `,` as the
  /// decimal separator).
  static FormFieldValidator<String> numeric() {
    return (String? v) {
      if (v == null || double.tryParse(v.replaceAll(',', '.')) == null) {
        return messages.numeric;
      }
      return null;
    };
  }

  /// Validates the value parses as a whole integer.
  static FormFieldValidator<String> integer() {
    return (String? v) {
      if (v == null || int.tryParse(v) == null) return messages.integer;
      return null;
    };
  }

  /// Validates the value contains only letters (Latin and Cyrillic).
  static FormFieldValidator<String> alphaOnly() {
    final RegExp re = RegExp(r'^[A-Za-zА-Яа-яЁё]+$');
    return (String? v) {
      if (v == null || v.isEmpty || !re.hasMatch(v)) return messages.alphaOnly;
      return null;
    };
  }

  /// Validates the value contains only letters or digits.
  static FormFieldValidator<String> alphaNumeric() {
    final RegExp re = RegExp(r'^[A-Za-zА-Яа-яЁё0-9]+$');
    return (String? v) {
      if (v == null || v.isEmpty || !re.hasMatch(v)) {
        return messages.alphaNumeric;
      }
      return null;
    };
  }

  /// Validates the value matches the supplied [regExp].
  static FormFieldValidator<String> pattern(RegExp regExp) {
    return (String? v) {
      if (v == null || !regExp.hasMatch(v)) return messages.pattern;
      return null;
    };
  }

  // ──────────── content ────────────

  /// Requires the value to equal [other]. Classic use case: password
  /// confirmation (`KitValidators.equal(_password.text)`).
  static FormFieldValidator<String> equal(String other) {
    return (String? v) {
      if (v != other) return messages.equal;
      return null;
    };
  }

  /// Requires the value to start with [prefix].
  static FormFieldValidator<String> startsWith(String prefix) {
    return (String? v) {
      if (v == null || !v.startsWith(prefix)) {
        return messages.startsWith(prefix);
      }
      return null;
    };
  }

  /// Requires the value to end with [suffix].
  static FormFieldValidator<String> endsWith(String suffix) {
    return (String? v) {
      if (v == null || !v.endsWith(suffix)) {
        return messages.endsWith(suffix);
      }
      return null;
    };
  }

  /// Requires the value to contain [substring].
  static FormFieldValidator<String> contains(String substring) {
    return (String? v) {
      if (v == null || !v.contains(substring)) {
        return messages.contains(substring);
      }
      return null;
    };
  }

  // ──────────── numeric bounds ────────────

  /// Requires the parsed number to be `>= n`.
  static FormFieldValidator<String> minValue(num n) {
    return (String? v) {
      final num? parsed = v == null
          ? null
          : num.tryParse(v.replaceAll(',', '.'));
      if (parsed == null || parsed < n) return messages.minValue(n);
      return null;
    };
  }

  /// Requires the parsed number to be `<= n`.
  static FormFieldValidator<String> maxValue(num n) {
    return (String? v) {
      final num? parsed = v == null
          ? null
          : num.tryParse(v.replaceAll(',', '.'));
      if (parsed == null || parsed > n) return messages.maxValue(n);
      return null;
    };
  }

  /// Requires the parsed number to fall within `[min, max]` (inclusive).
  static FormFieldValidator<String> range(num min, num max) {
    return (String? v) {
      final num? parsed = v == null
          ? null
          : num.tryParse(v.replaceAll(',', '.'));
      if (parsed == null || parsed < min || parsed > max) {
        return messages.range(min, max);
      }
      return null;
    };
  }

  /// Requires the parsed number to be strictly greater than zero.
  static FormFieldValidator<String> positive() {
    return (String? v) {
      final num? parsed = v == null
          ? null
          : num.tryParse(v.replaceAll(',', '.'));
      if (parsed == null || parsed <= 0) return messages.positive;
      return null;
    };
  }

  /// Requires the parsed number to be zero or greater.
  static FormFieldValidator<String> nonNegative() {
    return (String? v) {
      final num? parsed = v == null
          ? null
          : num.tryParse(v.replaceAll(',', '.'));
      if (parsed == null || parsed < 0) return messages.nonNegative;
      return null;
    };
  }

  // ──────────── password ────────────

  /// Composite password validator with independently toggleable checks.
  ///
  /// Fail order (skipped steps are removed from the chain):
  /// empty → too short → too long → no uppercase → no lowercase → no digit
  /// → no special character → contains whitespace.
  ///
  /// All boolean flags default to the most common "strong password" set:
  /// `minLength: 8`, `uppercase: true`, `digit: true`. Everything else is
  /// off by default — flip the flags you need for a given screen.
  static FormFieldValidator<String> password({
    int minLength = 8,
    int? maxLength,
    bool uppercase = true,
    bool lowercase = false,
    bool digit = true,
    bool special = false,
    bool noWhitespace = false,
  }) {
    final RegExp upper = RegExp(r'[A-Z]');
    final RegExp lower = RegExp(r'[a-z]');
    final RegExp dig = RegExp(r'\d');
    final RegExp spec = RegExp(r'[^\w\s]');
    final RegExp whitespace = RegExp(r'\s');
    return (String? v) {
      if (v == null || v.isEmpty) return messages.required;
      if (v.length < minLength) return messages.minLength(minLength);
      if (maxLength != null && v.length > maxLength) {
        return messages.maxLength(maxLength);
      }
      if (uppercase && !upper.hasMatch(v)) {
        return messages.passwordMissingUppercase;
      }
      if (lowercase && !lower.hasMatch(v)) {
        return messages.passwordMissingLowercase;
      }
      if (digit && !dig.hasMatch(v)) return messages.passwordMissingDigit;
      if (special && !spec.hasMatch(v)) {
        return messages.passwordMissingSpecial;
      }
      if (noWhitespace && whitespace.hasMatch(v)) {
        return messages.passwordContainsWhitespace;
      }
      return null;
    };
  }

  // ──────────── combinators ────────────

  /// Runs [validators] in order and returns the first error, or `null`
  /// if all pass.
  static FormFieldValidator<String> combine(
    List<FormFieldValidator<String>> validators,
  ) {
    return (String? v) {
      for (final FormFieldValidator<String> validator in validators) {
        final String? error = validator(v);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Wraps [validator] so it is skipped when the value is `null` or
  /// empty. Useful for "optional but must be valid if filled" fields
  /// (e.g. an optional website link).
  static FormFieldValidator<String> optional(
    FormFieldValidator<String> validator,
  ) {
    return (String? v) {
      if (v == null || v.isEmpty) return null;
      return validator(v);
    };
  }

  /// Runs [validator] only when [condition] returns `true` at validation
  /// time (late-evaluated, so it reflects current state — e.g. "only
  /// validate billing address when user chose delivery").
  static FormFieldValidator<String> onlyIf(
    bool Function() condition,
    FormFieldValidator<String> validator,
  ) {
    return (String? v) {
      if (!condition()) return null;
      return validator(v);
    };
  }
}
