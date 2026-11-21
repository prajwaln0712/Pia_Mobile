import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'chat_screen.dart';

/// Profile / registration screen — follows the Creating Wings web template.
/// Email + Full Name come pre-filled (read-only, from sign-in).
class ProfileScreen extends StatefulWidget {
  final String sub;
  final String email;
  final String fullName;
  final VoidCallback? onTerms;

  const ProfileScreen({
    super.key,
    required this.sub,
    required this.email,
    required this.fullName,
    this.onTerms,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late final ApiService _apiService = ApiService(_authService);
  bool _busy = false;

  static const _brandBlue = Color(0xFF52BFE8); // Register button
  static const _titleBlue = Color(0xFF1C5A78); // "Profile", links
  static const _readOnlyFill = Color(0xFFF1F1F1);
  static const _border = Color(0xFFD5D9DD);
  static const _required = Color(0xFFE0245E);

  static const _marital = ['Single', 'Married', 'Divorced', 'Separated', 'Widowed', 'Prefer not to say'];
  static const _income = ['Under \$25,000', '\$25,000 – \$49,999', '\$50,000 – \$74,999', '\$75,000 – \$99,999', '\$100,000+', 'Prefer not to say'];
  static const _education = ['High school or less', 'Some college', 'Associate degree', "Bachelor's degree", 'Graduate degree', 'Prefer not to say'];
  static const _employment = ['Employed full-time', 'Employed part-time', 'Self-employed', 'Unemployed', 'Student', 'Retired', 'Prefer not to say'];

  final _formKey = GlobalKey<FormState>();
  final _location = TextEditingController();
  String? _maritalVal, _incomeVal, _educationVal, _employmentVal;
  bool _acceptTerms = false;
  bool _isAdult = false;
  bool _showCheckErrors = false;

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _showCheckErrors = true);
    final ok = _formKey.currentState!.validate() && _acceptTerms && _isAdult;
    if (!ok || _busy) return;

    setState(() => _busy = true);
    try {
      final registered = await _apiService.registerUser(
        sub: widget.sub,
        name: widget.fullName,
        email: widget.email,
        location: _location.text.trim(),
        maritalStatus: _maritalVal,
        householdIncome: _incomeVal,
        educationLevel: _educationVal,
        employmentStatus: _employmentVal,
        acceptedTerms: true,
        is18OrOlder: true,
      );
      if (registered == null) {
        _show("Couldn't save your profile. Please try again.");
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
            children: [
              Center(
                child: Image.asset('assets/logo.png', height: 110, fit: BoxFit.contain),
              ),
              const SizedBox(height: 28),
              const Center(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _titleBlue,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _label('Email', required: true),
              _readOnlyField(widget.email),
              _gap,

              _label('Full Name'),
              _readOnlyField(widget.fullName),
              _gap,

              _label('Location', required: true),
              TextFormField(
                controller: _location,
                style: _inputText,
                decoration: _decoration(hint: 'State, Country'),
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return 'Location is required';
                  final parts = text.split(',');
                  if (parts.length != 2 || parts[0].trim().isEmpty || parts[1].trim().isEmpty) {
                    return 'Invalid format. Type State, Country';
                  }
                  return null;
                },
              ),
              _gap,

              _label('Marital Status'),
              _dropdown(_marital, _maritalVal, (v) => setState(() => _maritalVal = v)),
              _gap,

              _label('Household Income Range'),
              _dropdown(_income, _incomeVal, (v) => setState(() => _incomeVal = v)),
              _gap,

              _label('Education Level'),
              _dropdown(_education, _educationVal, (v) => setState(() => _educationVal = v)),
              _gap,

              _label('Employment Status'),
              _dropdown(_employment, _employmentVal, (v) => setState(() => _employmentVal = v)),
              const SizedBox(height: 14),

              _checkRow(
                value: _acceptTerms,
                onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                error: _showCheckErrors && !_acceptTerms,
                child: Text.rich(
                  TextSpan(
                    style: _checkText,
                    children: [
                      const TextSpan(text: 'I accept the '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: const TextStyle(
                          color: _titleBlue,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = widget.onTerms,
                      ),
                      const TextSpan(text: ' *', style: TextStyle(color: _required)),
                    ],
                  ),
                ),
              ),
              _checkRow(
                value: _isAdult,
                onChanged: (v) => setState(() => _isAdult = v ?? false),
                error: _showCheckErrors && !_isAdult,
                child: const Text.rich(
                  TextSpan(
                    style: _checkText,
                    children: [
                      TextSpan(text: 'I confirm I am 18 or older'),
                      TextSpan(text: ' *', style: TextStyle(color: _required)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _busy ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(
                            fontFamily: AppText.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- helpers ----------

  static const _gap = SizedBox(height: 16);

  static const _inputText = TextStyle(
    fontFamily: AppText.fontFamily,
    fontSize: 14,
    color: Color(0xFF2A2F33),
  );

  static const _checkText = TextStyle(
    fontFamily: AppText.fontFamily,
    fontSize: 14,
    color: Colors.black87,
  );

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontFamily: AppText.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A2F33),
          ),
          children: [
            TextSpan(text: text),
            if (required) const TextSpan(text: '  *', style: TextStyle(color: _required)),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration({String? hint, bool readOnly = false, bool dark = false}) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c, width: w),
        );
    final base = dark ? const Color(0xFF6E757B) : _border;
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: AppText.fontFamily, fontSize: 14, color: Color(0xFF8C949A)),
      filled: true,
      fillColor: readOnly ? _readOnlyFill : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: b(base),
      disabledBorder: b(_border),
      focusedBorder: b(_brandBlue, 1.6),
      errorBorder: b(_required),
      focusedErrorBorder: b(_required, 1.6),
    );
  }

  Widget _readOnlyField(String value) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      style: _inputText.copyWith(color: const Color(0xFF5A6268)),
      decoration: _decoration(readOnly: true),
    );
  }

  Widget _dropdown(List<String> options, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black87),
      style: _inputText,
      hint: const Text('- Select Option -', style: _inputText),
      decoration: _decoration(dark: true),
      borderRadius: BorderRadius.circular(10),
      items: [
        for (final o in options) DropdownMenuItem(value: o, child: Text(o)),
      ],
      onChanged: onChanged,
    );
  }

  Widget _checkRow({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Widget child,
    bool error = false,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: _brandBlue,
                side: BorderSide(color: error ? _required : const Color(0xFF8C949A), width: 1.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
