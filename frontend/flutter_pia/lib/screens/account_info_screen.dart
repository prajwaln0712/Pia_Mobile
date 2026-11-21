import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';

/// Read-only account details — follows the same visual style as
/// ProfileScreen (logo header, title, grey read-only fields). Opened from
/// the "Account Information" item in the overflow menu.
class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  static const _titleBlue = Color(0xFF1C5A78);

  final AuthService _authService = AuthService();
  late final ApiService _apiService = ApiService(_authService);

  bool _loading = true;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await _apiService.getUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  /// The database stores one combined full name, not separate first/last
  /// fields — this just splits on the first space for display. A multi-word
  /// first or last name (e.g. "Mary Jane Smith") won't split perfectly;
  /// this is a display approximation, not a second source of stored data.
  List<String> _splitName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return ['', ''];
    final spaceIndex = trimmed.indexOf(' ');
    if (spaceIndex == -1) return [trimmed, ''];
    return [trimmed.substring(0, spaceIndex), trimmed.substring(spaceIndex + 1)];
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final nameParts = user != null ? _splitName(user['name'] as String? ?? '') : ['', ''];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: _titleBlue),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Center(
              child: Image.asset('assets/logo.png', height: 110, fit: BoxFit.contain),
            ),
            const SizedBox(height: 28),
            const Center(
              child: Text(
                'Account Information',
                style: TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _titleBlue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (user == null)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'No account information available. Log in to view your details.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
              )
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _plainField('First Name', nameParts[0])),
                  const SizedBox(width: 16),
                  Expanded(child: _plainField('Last Name', nameParts[1])),
                ],
              ),
              _gap,
              _plainField('Gmail ID', user['email'] as String? ?? ''),
              _gap,
              _plainField('Location', (user['location'] as String?) ?? 'Not provided'),
            ],
          ],
        ),
      ),
    );
  }

  // ---------- helpers (mirrors ProfileScreen's style) ----------

  static const _gap = SizedBox(height: 16);

  static const _inputText = TextStyle(
    fontFamily: AppText.fontFamily,
    fontSize: 14,
    color: Color(0xFF2A2F33),
  );

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppText.fontFamily,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2A2F33),
        ),
      ),
    );
  }

  Widget _plainField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Text(
          value,
          style: _inputText.copyWith(color: const Color(0xFF5A6268)),
        ),
      ],
    );
  }
}
