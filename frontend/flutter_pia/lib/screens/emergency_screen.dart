import 'package:flutter/material.dart';
import '../theme.dart';

/// Screen 2 — emergency alert dialog with Quick Exit.
/// Presented as a modal over the current screen.
Future<void> showEmergencyDialog(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Emergency',
    barrierColor: const Color(0x6B172D3C),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) => const _EmergencyOverlay(),
  );
}

class _EmergencyOverlay extends StatelessWidget {
  const _EmergencyOverlay();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Quick Exit — top-right
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: _QuickExit(
                  onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: _AlertCard(),
                ),
              ),
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}

class _QuickExit extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickExit({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white24,
          border: Border.all(color: Colors.white54, width: 1.5),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close, size: 14, color: Colors.white),
            SizedBox(width: 7),
            Text(
              'Quick Exit',
              style: TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x8C0F2332), blurRadius: 60, offset: Offset(0, 24)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              InkResponse(
                onTap: () => Navigator.of(context).pop(),
                radius: 24,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      size: 16, color: Color(0xFF3A5666)),
                ),
              ),
              const Expanded(
                child: Text(
                  'EMERGENCY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppText.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Color(0xFFC0663F),
                  ),
                ),
              ),
              const SizedBox(width: 38),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'If you are in immediate danger, call 911 or your local emergency number if it is safe.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 17,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkStrong,
            ),
          ),
          const SizedBox(height: 20),
          _PrimaryAction(
            icon: Icons.call,
            label: 'Call 911',
            onTap: () {},
          ),
          const SizedBox(height: 11),
          _SecondaryAction(
            icon: Icons.chat_bubble_outline,
            label: 'Text a Trusted Person',
            onTap: () {},
          ),
          const SizedBox(height: 11),
          _SecondaryAction(
            icon: Icons.verified_user_outlined,
            label: 'Open Safety Plan',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PrimaryAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 19),
        label: Text(label,
            style: const TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SecondaryAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: const Color(0xFF3D6F96), size: 19),
        label: Text(label,
            style: const TextStyle(
                fontFamily: AppText.fontFamily,
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF274B62))),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD3E1EC), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
