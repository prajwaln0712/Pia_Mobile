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

const Msg _kGreeting =
    Msg("Hi! I help with home safety and money questions. What's on your mind?");

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

  final List<Msg> _messages = [_kGreeting];
  final TextEditingController _composerController = TextEditingController();

  String? _userId;
  String? _conversationId;
  Future<String?>? _userIdFuture;

  bool _busy = false; // login in flight
  bool _sending = false; // chat send in flight

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  /// Resolves the identity used for `/api/chat`: the real Auth0 sub if
  /// logged in, otherwise a persisted (or freshly minted) guest id.
  /// Memoized so rapid double-taps on send can't mint two guest accounts.
  Future<String?> _ensureUserId() {
    return _userIdFuture ??= _resolveUserId();
  }

  Future<String?> _resolveUserId() async {
    if (_userId != null) return _userId;

    if (await _authService.isLoggedIn()) {
      _userId = await _authService.getUserId();
      if (_userId != null) return _userId;
    }

    _userId = await _apiService.continueAsGuest();
    return _userId;
  }

  Future<void> _login() async {
    if (_busy) return;
    if (await _authService.isLoggedIn()) {
      _show('Already signed in');
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await _apiService.loginWithGoogleAndRegister();
      if (result.sub == null) {
        _show(result.error!);
        return;
      }

      setState(() {
        _userId = result.sub;
        _conversationId = null;
        _userIdFuture = null;
        _messages
          ..clear()
          ..add(_kGreeting);
      });
      _show(result.error ?? 'Signed in as ${result.email}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onSend() async {
    final text = _composerController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final userId = await _ensureUserId();
      if (userId == null) {
        _show('Could not start a session. Check your connection.');
        return;
      }

      setState(() {
        _messages.add(Msg(text, fromUser: true));
        _composerController.clear();
      });

      final result = await _apiService.sendMessage(
        userId: userId,
        conversationId: _conversationId,
        message: text,
      );

      if (result == null) {
        _show('Message failed to send. Please try again.');
        return;
      }

      setState(() {
        _conversationId = result['conversation_id'] as String?;
        _messages.add(Msg(result['response'] as String? ?? ''));
      });
    } finally {
      if (mounted) setState(() => _sending = false);
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
                  onLogin: _login,
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
                      for (final m in _messages) ...[
                        _Bubble(m),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
                _Composer(
                  controller: _composerController,
                  sending: _sending,
                  onSend: _onSend,
                ),
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
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  const _Composer({required this.controller, required this.sending, required this.onSend});

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
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: !sending,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Message ${ChatScreen.botName}…',
                      hintStyle: const TextStyle(
                        fontFamily: AppText.fontFamily,
                        fontSize: 14,
                        color: Color(0xFF8CA0AC),
                      ),
                    ),
                    style: const TextStyle(fontFamily: AppText.fontFamily, fontSize: 14),
                  ),
                ),
                _SendButton(sending: sending, onTap: onSend),
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
  final bool sending;
  final VoidCallback onTap;
  const _SendButton({required this.sending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: sending ? null : onTap,
      radius: 24,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: sending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
