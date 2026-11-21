import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'account_info_screen.dart';
import 'welcome_screen.dart';

const String _websiteUrl = 'https://www.creatingwings.org/';

Future<void> _openWebsite() async {
  final uri = Uri.parse(_websiteUrl);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not open $_websiteUrl');
  }
}

/// Confirms, then permanently deletes the account and resets the app back
/// to the login/guest choice. Uses `context` captured by [showMenuSheet]
/// (the long-lived ChatScreen context), never a context from inside the
/// menu overlay itself — that overlay's own context is already on its way
/// out by the time this runs, since [_MenuItem] pops the dialog first.
Future<void> _confirmAndDeleteAccount(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Account'),
      content: const Text(
        'This permanently deletes your account and conversation history. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  if (!context.mounted) return;

  final authService = AuthService();
  final apiService = ApiService(authService);
  final success = await apiService.deleteAccount();

  if (!context.mounted) return;
  if (!success) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Could not delete account. Please try again.')));
    return;
  }

  await authService.logout();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    (route) => false,
  );
}

/// Signs out and returns to the login/guest choice. Non-destructive (the
/// account itself is untouched), so unlike delete there's no confirmation.
Future<void> _signOut(BuildContext context) async {
  await AuthService().logout();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    (route) => false,
  );
}

/// Screen 4 — overflow menu with five options (seven when logged in).
/// Anchored top-right, dropping down from the header 3-dot button.
Future<void> showMenuSheet(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Menu',
    barrierColor: const Color(0x47142837),
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (_, __, ___) => _MenuOverlay(
      onAccountInfo: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AccountInfoScreen()),
      ),
      onSignOut: () => _signOut(context),
      onDeleteAccount: () => _confirmAndDeleteAccount(context),
    ),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: child,
    ),
  );
}

class _MenuOverlay extends StatefulWidget {
  final VoidCallback onAccountInfo;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;
  const _MenuOverlay({
    required this.onAccountInfo,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  @override
  State<_MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<_MenuOverlay> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    AuthService().isLoggedIn().then((v) {
      if (mounted) setState(() => _isLoggedIn = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: MediaQuery.of(context).padding.top + 54,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 216,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x800F2332),
                      blurRadius: 44,
                      offset: Offset(0, 18)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _MenuItem(Icons.menu_book_outlined, 'Resources Options'),
                  const _MenuDivider(),
                  const _MenuItem(Icons.verified_user_outlined, 'Safety Plan'),
                  const _MenuDivider(),
                  const _MenuItem(Icons.show_chart, 'Progress Indicator'),
                  const _MenuDivider(),
                  _MenuItem(
                    Icons.person_outline,
                    'Account Information',
                    onTap: widget.onAccountInfo,
                  ),
                  const _MenuDivider(),
                  _MenuItem(Icons.public, 'Visit Our Website', onTap: _openWebsite),
                  if (_isLoggedIn == true) ...[
                    const _MenuDivider(),
                    _MenuItem(
                      Icons.logout,
                      'Sign Out',
                      onTap: widget.onSignOut,
                    ),
                    const _MenuDivider(),
                    _MenuItem(
                      Icons.delete_outline,
                      'Delete Account',
                      onTap: widget.onDeleteAccount,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _MenuItem(this.icon, this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(11),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 19, color: const Color(0xFF3D6F96)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF284C62),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Divider(height: 1, color: Color(0xFFEEF3F7)),
      );
}
