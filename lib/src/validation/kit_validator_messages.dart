/// Error-message strings used by [KitValidators].
///
/// The static validators pull all messages from [KitValidators.messages].
/// Configure once at app startup to localize the entire set:
///
/// ```dart
/// KitValidators.messages = KitValidatorMessages(
///   required: 'Обязательное поле',
///   email: 'Неверный email',
///   minLength: (int n) => 'Минимум $n символов',
///   // ... остальные останутся английскими дефолтами
/// );
/// ```
///
/// Parameterized messages (e.g. [minLength], [range]) are functions so you
/// can inject the parameter into the string naturally.
class KitValidatorMessages {
  /// Required field is empty or whitespace-only.
  final String required;

  /// Value does not look like an email address.
  final String email;

  /// Value does not look like an HTTP(S) URL.
  final String url;

  /// Value does not look like a phone number.
  final String phone;

  /// Value is not parseable as a number.
  final String numeric;

  /// Value is not a whole integer.
  final String integer;

  /// Value contains characters other than letters.
  final String alphaOnly;

  /// Value contains characters other than letters and digits.
  final String alphaNumeric;

  /// Value does not match the supplied regular expression.
  final String pattern;

  /// Value does not match the expected string (e.g. password confirmation).
  final String equal;

  /// Numeric value must be strictly greater than zero.
  final String positive;

  /// Numeric value must be zero or greater.
  final String nonNegative;

  /// Password has no uppercase letter.
  final String passwordMissingUppercase;

  /// Password has no lowercase letter.
  final String passwordMissingLowercase;

  /// Password has no digit.
  final String passwordMissingDigit;

  /// Password has no special (non-word, non-whitespace) character.
  final String passwordMissingSpecial;

  /// Password contains whitespace characters (space, tab, newline).
  final String passwordContainsWhitespace;

  /// String is shorter than the minimum length.
  final String Function(int n) minLength;

  /// String is longer than the maximum length.
  final String Function(int n) maxLength;

  /// String length is outside `[min, max]`.
  final String Function(int min, int max) lengthRange;

  /// String length is not exactly `n`.
  final String Function(int n) exactLength;

  /// Numeric value is below the lower bound.
  final String Function(num n) minValue;

  /// Numeric value is above the upper bound.
  final String Function(num n) maxValue;

  /// Numeric value is outside `[min, max]`.
  final String Function(num min, num max) range;

  /// Value does not start with the required prefix.
  final String Function(String prefix) startsWith;

  /// Value does not end with the required suffix.
  final String Function(String suffix) endsWith;

  /// Value does not contain the required substring.
  final String Function(String substring) contains;

  const KitValidatorMessages({
    this.required = 'This field is required',
    this.email = 'Enter a valid email',
    this.url = 'Enter a valid URL',
    this.phone = 'Enter a valid phone number',
    this.numeric = 'Enter a valid number',
    this.integer = 'Enter a whole number',
    this.alphaOnly = 'Letters only',
    this.alphaNumeric = 'Letters and digits only',
    this.pattern = 'Invalid format',
    this.equal = 'Values do not match',
    this.positive = 'Must be greater than zero',
    this.nonNegative = 'Must be zero or greater',
    this.passwordMissingUppercase = 'Must include an uppercase letter',
    this.passwordMissingLowercase = 'Must include a lowercase letter',
    this.passwordMissingDigit = 'Must include a digit',
    this.passwordMissingSpecial = 'Must include a special character',
    this.passwordContainsWhitespace = 'Must not contain spaces',
    this.minLength = _defaultMinLength,
    this.maxLength = _defaultMaxLength,
    this.lengthRange = _defaultLengthRange,
    this.exactLength = _defaultExactLength,
    this.minValue = _defaultMinValue,
    this.maxValue = _defaultMaxValue,
    this.range = _defaultRange,
    this.startsWith = _defaultStartsWith,
    this.endsWith = _defaultEndsWith,
    this.contains = _defaultContains,
  });
}

String _defaultMinLength(int n) =>
    'At least $n character${n == 1 ? '' : 's'}';

String _defaultMaxLength(int n) =>
    'At most $n character${n == 1 ? '' : 's'}';

String _defaultLengthRange(int min, int max) =>
    'Must be $min–$max characters';

String _defaultExactLength(int n) =>
    'Must be exactly $n character${n == 1 ? '' : 's'}';

String _defaultMinValue(num n) => 'Must be ≥ $n';

String _defaultMaxValue(num n) => 'Must be ≤ $n';

String _defaultRange(num min, num max) => 'Must be between $min and $max';

String _defaultStartsWith(String prefix) => "Must start with '$prefix'";

String _defaultEndsWith(String suffix) => "Must end with '$suffix'";

String _defaultContains(String substring) => "Must contain '$substring'";
