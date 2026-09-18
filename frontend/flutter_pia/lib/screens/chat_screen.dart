import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/wave_background.dart';
import 'emergency_screen.dart';
import 'menu_sheet.dart';

/// A single chat message.
class Msg {
  final String text;
  final bool fromUser;
  const Msg(this.text, {this.fromUser = false});
}

const List<Msg> kSampleThread = [
  Msg("Hi! I help with home safety and money questions. What's on your mind?"),
  Msg('Is it okay to leave my space heater on overnight?', fromUser: true),
  Msg('Best not to. Switch heaters off when you sleep, and keep them at least 3 ft from anything flammable.'),
  Msg('Good to know. How much should my emergency fund be?', fromUser: true),
  Msg('Aim for 3–6 months of essential expenses in an easy-access savings account.'),
];

/// Screens 1 & 4 — chat with header logo, chatbar, exclamation button,
/// and overflow menu (opens the menu sheet).
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const botName = 'CreatingWings';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AuthService _authService = AuthService();
  late final ApiService _apiService = ApiService(_authService);

  bool _busy = false;

  Future<void> _loginAndFetchUser() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (!await _authService.isLoggedIn()) {
        final token = await _authService.login();
        if (token == null) {
          _show('Login failed');
          return;
        }
      }
      final user = await _apiService.getUser();
      _show(user == null ? 'Could not load user' : 'Signed in as ${user['email'] ?? user['sub'] ?? user}');
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
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const WaveBackground(),
          SafeArea(
            child: Column(
              children: [
                _Header(
                  onMenu: () => showMenuSheet(context),
                  onLogin: _loginAndFetchUser,
                  loginBusy: _busy,
                ),
                const Divider(height: 1, color: Color(0xFFE2ECF3), indent: 20, endIndent: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    children: [
                      const Center(
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontFamily: AppText.fontFamily,
                            fontSize: 11,
                            color: Color(0xFF9AABB6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (final m in kSampleThread) ...[
                        _Bubble(m),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
                const _Composer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onMenu;
  final VoidCallback onLogin;
  final bool loginBusy;
  const _Header({required this.onMenu, required this.onLogin, required this.loginBusy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          _LoginButton(onTap: onLogin, busy: loginBusy),
          Expanded(
            child: Column(
              children: [
                Image.asset('assets/logo.png', width: 52, height: 52, fit: BoxFit.contain),
                const SizedBox(height: 5),
                const Text(
                  ChatScreen.botName,
                  style: TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C4655),
                  ),
                ),
              ],
            ),
          ),
          _OverflowButton(onTap: onMenu),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool busy;
  const _LoginButton({required this.onTap, required this.busy});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: busy ? null : onTap,
      radius: 26,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF5B7382),
                  ),
                )
              : const Icon(
                  Icons.login_rounded,
                  size: 22,
                  color: Color(0xFF5B7382),
                ),
        ),
      ),
    );
  }
}

class _OverflowButton extends StatelessWidget {
  final VoidCallback onTap;
  const _OverflowButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (_) => Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0xFF5B7382),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Msg m;
  const _Bubble(this.m);

  @override
  Widget build(BuildContext context) {
    final user = m.fromUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: user ? AppColors.accent : AppColors.botBubble,
            border: user ? null : Border.all(color: AppColors.botBubbleBorder),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(user ? 18 : 5),
              bottomRight: Radius.circular(user ? 5 : 18),
            ),
          ),
          child: Text(m.text, style: user ? AppText.bubbleUser : AppText.body),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 5, 6, 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.inputBorder, width: 1.5),
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F285A78),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Message ${ChatScreen.botName}…',
                      hintStyle: TextStyle(
                        fontFamily: AppText.fontFamily,
                        fontSize: 14,
                        color: Color(0xFF8CA0AC),
                      ),
                    ),
                    style: TextStyle(fontFamily: AppText.fontFamily, fontSize: 14),
                  ),
                ),
                _SendButton(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // exclamation button — bottom-left, opens emergency screen
          InkResponse(
            onTap: () => showEmergencyDialog(context),
            radius: 30,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.exclamationBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '!',
                  style: TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.exclamationInk,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
    );
  }
}
