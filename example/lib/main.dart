import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  // One-time localization of the validator set.
  KitValidators.messages = KitValidatorMessages(
    required: 'Обязательное поле',
    email: 'Некорректный email',
    url: 'Некорректный URL',
    phone: 'Некорректный телефон',
    numeric: 'Введите число',
    integer: 'Введите целое число',
    alphaOnly: 'Только буквы',
    alphaNumeric: 'Только буквы и цифры',
    pattern: 'Неверный формат',
    equal: 'Значения не совпадают',
    positive: 'Должно быть больше нуля',
    nonNegative: 'Не может быть отрицательным',
    passwordMissingUppercase: 'Нужна заглавная буква',
    passwordMissingLowercase: 'Нужна строчная буква',
    passwordMissingDigit: 'Нужна цифра',
    passwordMissingSpecial: 'Нужен спецсимвол',
    passwordContainsWhitespace: 'Не должно содержать пробелов',
    minLength: (int n) => 'Минимум $n символов',
    maxLength: (int n) => 'Максимум $n символов',
    lengthRange: (int min, int max) => 'От $min до $max символов',
    exactLength: (int n) => 'Ровно $n символов',
    minValue: (num n) => 'Не меньше $n',
    maxValue: (num n) => 'Не больше $n',
    range: (num min, num max) => 'От $min до $max',
    startsWith: (String p) => 'Должно начинаться с «$p»',
    endsWith: (String s) => 'Должно заканчиваться на «$s»',
    contains: (String s) => 'Должно содержать «$s»',
  );

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final KitButtonTheme buttonTheme = KitButtonTheme(
      primaryColor: const Color(0xFFD07B5F),
      borderRadius: 100.0,
      disabledColor: const Color(0xFFE0E0E0),
      disabledContentColor: Colors.white,
      height: 56.0,
      textStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Color(0xFF141414),
        letterSpacing: -0.43,
      ),
    );

    final KitTextFieldTheme textFieldTheme = KitTextFieldTheme(
      errorColor: Colors.redAccent,
      clearIcon: const Icon(Icons.clear),
      searchIcon: const Icon(Icons.search),
      obscureOnIcon: const Icon(Icons.visibility),
      obscureOffIcon: const Icon(Icons.visibility_off),
      filled: true,
      fillColor: const Color(0xFFF2F2F7),
      disabledFillColor: const Color(0xFFE5E5EA),
      borderColor: Colors.transparent,
      focusColor: Colors.deepPurple,
      idleBorderWidth: 0.0,
      focusedBorderWidth: 2.0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 10,
      defaultMaxLength: 255,
    );

    const KitScaffoldTheme scaffoldTheme = KitScaffoldTheme(
      horizontalPadding: 16.0,
      overlayColor: Colors.black,
      overlayOpacity: 0.35,
      loaderColor: Colors.deepPurple,
    );

    return MaterialApp(
      title: 'UI Kit Demo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
        extensions: <ThemeExtension<dynamic>>[
          buttonTheme,
          textFieldTheme,
          scaffoldTheme,
        ],
      ),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  bool _isLoading = false;
  bool _fieldsEnabled = true;
  bool _blocksAppBar = true;

  String? _emailError;
  String _searchEcho = '';

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleManualLoading() {
    setState(() => _isLoading = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _handleAsyncPress() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Async done')));
  }

  Future<void> _validateEmailOnServer(String value) async {
    setState(() => _emailError = null);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _emailError = value.endsWith('@test.com')
          ? 'Этот email уже занят'
          : null;
    });
  }

  Future<void> _simulateSave() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);
    final bool ok = _formKey.currentState?.validate() ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Сохранено' : 'Исправьте ошибки')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KitScaffold(
      appBar: AppBar(
        title: const Text('UI Kit Showcase'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      isLoading: _isLoading,
      blocksAppBar: _blocksAppBar,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          children: <Widget>[
            // ---------------------------------------------------------------
            //  BUTTONS
            // ---------------------------------------------------------------
            const _SectionHeader(title: 'Primary (manual isLoading)'),
            KitButton.primary(
              text: 'Сохранить изменения',
              isLoading: _isLoading,
              onPressed: _handleManualLoading,
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'Primary (async — auto loader)'),
            KitButton.primary(text: 'Оплатить', onPressed: _handleAsyncPress),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'Secondary + Text'),
            KitButton.secondary(text: 'Отменить', onPressed: () {}),
            const SizedBox(height: 8.0),
            KitButton.text(text: 'Пропустить шаг', onPressed: () {}),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'Disabled'),
            KitButton.primary(text: 'Нет прав доступа', onPressed: null),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'With icon'),
            KitButton.primary(
              text: 'Оплатить Apple Pay',
              icon: const Icon(Icons.apple),
              onPressed: () {},
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'Custom loaderColor'),
            KitButton.primary(
              text: 'С красным лоадером',
              isLoading: _isLoading,
              loaderColor: Colors.red,
              onPressed: _handleManualLoading,
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'isExpanded: false (Row)'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                KitButton.secondary(
                  text: 'Назад',
                  isExpanded: false,
                  onPressed: () {},
                ),
                KitButton.primary(
                  text: 'Продолжить',
                  isExpanded: false,
                  icon: const Icon(Icons.arrow_forward, size: 20),
                  onPressed: () {},
                ),
              ],
            ),

            // ---------------------------------------------------------------
            //  TEXT FIELDS + VALIDATORS
            // ---------------------------------------------------------------
            const SizedBox(height: 32.0),
            const _SectionHeader(title: 'Standard — combine(required + alphaOnly)'),
            KitTextField(
              label: 'Имя пользователя',
              hintText: 'Введите имя',
              helperText: 'Только буквы, не более 30 символов',
              enabled: _fieldsEnabled,
              textCapitalization: TextCapitalization.words,
              maxLength: 30,
              validator: KitValidators.combine(<FormFieldValidator<String>>[
                KitValidators.required(),
                KitValidators.alphaOnly(),
              ]),
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'Email — combine + async errorText'),
            KitTextField.email(
              label: 'Email',
              controller: _emailCtrl,
              hintText: 'name@example.com',
              errorText: _emailError,
              onChanged: _validateEmailOnServer,
              validator: KitValidators.combine(<FormFieldValidator<String>>[
                KitValidators.required(),
                KitValidators.email(),
              ]),
              enabled: _fieldsEnabled,
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'Password — все проверки включены'),
            KitTextField.password(
              label: 'Пароль',
              controller: _passwordCtrl,
              helperText:
                  '8–64 символа, заглавная + строчная + цифра + спецсимвол, без пробелов',
              validator: KitValidators.password(
                minLength: 8,
                maxLength: 64,
                uppercase: true,
                lowercase: true,
                digit: true,
                special: true,
                noWhitespace: true,
              ),
              enabled: _fieldsEnabled,
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'Password confirm — equal(другое поле)'),
            KitTextField.password(
              label: 'Повторите пароль',
              // Equal-валидатор пересобирается на каждой валидации, чтобы
              // читать актуальный _passwordCtrl.text.
              validator: (String? v) =>
                  KitValidators.equal(_passwordCtrl.text)(v),
              enabled: _fieldsEnabled,
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'Website — optional(url)'),
            KitTextField(
              label: 'Сайт',
              hintText: 'https://example.com',
              helperText: 'Опционально; если заполнено — должен быть валидный URL',
              keyboardType: TextInputType.url,
              validator: KitValidators.optional(KitValidators.url()),
              enabled: _fieldsEnabled,
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'Phone — combine(required + phone)'),
            KitTextField(
              label: 'Телефон',
              hintText: '+7 900 123-45-67',
              keyboardType: TextInputType.phone,
              validator: KitValidators.combine(<FormFieldValidator<String>>[
                KitValidators.required(),
                KitValidators.phone(),
              ]),
              enabled: _fieldsEnabled,
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'Search (debounced, flushes on submit)'),
            KitTextField.search(
              label: 'Поиск проектов',
              onChanged: (String v) => setState(() => _searchEcho = v),
              onSubmitted: (String v) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Submit: "$v"')));
              },
              enabled: _fieldsEnabled,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 8.0),
              child: Text(
                'Last debounced value: "$_searchEcho"',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'Number — range(-50, 60) + positive example'),
            KitTextField.number(
              label: 'Температура',
              allowNegative: true,
              prefixText: '≈ ',
              suffixText: '°C',
              helperText: 'Диапазон −50…60',
              validator: KitValidators.combine(<FormFieldValidator<String>>[
                KitValidators.required(),
                KitValidators.range(-50, 60),
              ]),
              enabled: _fieldsEnabled,
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'Multiline — lengthRange(10, 280)'),
            KitTextField.multiline(
              label: 'Описание задачи',
              minLines: 3,
              maxLines: 6,
              maxLength: 280,
              validator: KitValidators.optional(
                KitValidators.lengthRange(10, 280),
              ),
              enabled: _fieldsEnabled,
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'OTP — exactLength(6)'),
            KitTextField.otp(
              label: 'SMS-код',
              length: 6,
              autofocus: false,
              validator: KitValidators.exactLength(6),
              onSubmitted: (String v) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('OTP entered: $v')));
              },
              enabled: _fieldsEnabled,
            ),
            const SizedBox(height: 16.0),

            const _SectionHeader(title: 'ReadOnly + onTap (date picker pattern)'),
            KitTextField(
              label: 'Дата рождения',
              hintText: 'Тапни, чтобы выбрать',
              readOnly: true,
              suffixIcon: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  initialDate: DateTime(2000),
                );
                if (picked != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Picked: ${picked.toIso8601String().split('T').first}',
                      ),
                    ),
                  );
                }
              },
            ),

            // ---------------------------------------------------------------
            //  SCAFFOLD CONTROLS
            // ---------------------------------------------------------------
            const SizedBox(height: 32.0),
            const _SectionHeader(title: 'Scaffold controls'),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fields enabled'),
              value: _fieldsEnabled,
              onChanged: (bool v) => setState(() => _fieldsEnabled = v),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('blocksAppBar'),
              subtitle: const Text(
                'Оверлей накрывает AppBar (иначе back остаётся активным)',
              ),
              value: _blocksAppBar,
              onChanged: (bool v) => setState(() => _blocksAppBar = v),
            ),
            const SizedBox(height: 8.0),
            KitButton.primary(
              text: 'Симулировать сохранение (2 сек)',
              onPressed: _simulateSave,
            ),
            const SizedBox(height: 8.0),
            KitButton.secondary(
              text: 'Validate form',
              onPressed: () {
                final bool ok = _formKey.currentState?.validate() ?? false;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Форма валидна' : 'Есть ошибки')),
                );
              },
            ),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
