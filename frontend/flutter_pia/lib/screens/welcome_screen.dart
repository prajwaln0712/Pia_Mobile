import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/wave_background.dart';
import 'chat_screen.dart';

/// First screen a new (not logged in, no guest id yet) user sees after the
/// splash disclaimer — choose a real Google account or continue as a guest.
/// Returning users skip this screen entirely (see splash_screen.dart).
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
      final result = await _apiService.loginWithGoogleAndRegister();
      if (result.sub == null) {
        _show(result.error!);
        return;
      }
      // Login itself succeeded even if profile-sync failed — chat still
      // works via the backend's fallback, so just proceed either way.
      _goToChat();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueAsGuest() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final guestId = await _apiService.continueAsGuest();
      if (guestId == null) {
        _show('Could not start a session. Check your connection.');
        return;
      }
      _goToChat();
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
                    'Sign in to save your conversation, or continue without an account.',
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
                              'Continue with Google',
                              style: TextStyle(
                                fontFamily: AppText.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: _busy ? null : _continueAsGuest,
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontFamily: AppText.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkMuted,
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
