import 'package:flutter/material.dart';
import '../theme.dart';

/// Screen 4 — overflow menu with four options.
/// Anchored top-right, dropping down from the header 3-dot button.
Future<void> showMenuSheet(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Menu',
    barrierColor: const Color(0x47142837),
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (_, __, ___) => const _MenuOverlay(),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: child,
    ),
  );
}

class _MenuOverlay extends StatelessWidget {
  const _MenuOverlay();

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
                children: const [
                  _MenuItem(Icons.menu_book_outlined, 'Resources Options'),
                  _MenuDivider(),
                  _MenuItem(Icons.verified_user_outlined, 'Safety Plan'),
                  _MenuDivider(),
                  _MenuItem(Icons.show_chart, 'Progress Indicator'),
                  _MenuDivider(),
                  _MenuItem(Icons.person_outline, 'Account Information'),
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
  const _MenuItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
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
