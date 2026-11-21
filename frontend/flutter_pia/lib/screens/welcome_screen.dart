import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/wave_background.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

/// First screen a user sees after the splash disclaimer — log in with Google.
/// Shown on every launch (see splash_screen.dart).
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = AuthService();
  late final ApiService _apiService = ApiService(_authService);

  bool _busy = false;

  void _goToChat() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _continueWithGoogle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final credentials = await _authService.loginWithGoogle();
      if (credentials == null) {
        _show('Login failed');
        return;
      }

      final email = credentials.user.email;
      if (email == null || email.isEmpty) {
        _show('Login succeeded but no email was returned. Please try again.');
        return;
      }

      // Already registered (a saved record exists for this account) — skip
      // the profile form entirely and go straight to chat.
      final existingUser = await _apiService.getUser();
      if (!mounted) return;
      if (existingUser != null) {
        _goToChat();
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProfileScreen(
            sub: credentials.user.sub,
            email: email,
            fullName: credentials.user.name ?? '',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const WaveBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', width: 72, height: 72, fit: BoxFit.contain),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to CreatingWings',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkStrong,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to save your conversation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _continueWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
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
                              'Login',
                              style: TextStyle(
                                fontFamily: AppText.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
