import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'chat_screen.dart';

/// Screen 3 — black disclaimer splash shown for 5 seconds at launch,
/// then routes to the chat screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontFamily: AppText.fontFamily,
                          fontSize: 19,
                          height: 1.55,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        children: const [
                          TextSpan(text: 'If you are in immediate danger, call '),
                          TextSpan(
                            text: '911',
                            style: TextStyle(
                              color: AppColors.dangerText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' or your local emergency number if it is safe to do so.',
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    Container(width: 44, height: 1, color: Colors.white24),
                    const SizedBox(height: 22),
                    const Text(
                      'This tool is not a replacement for emergency services, legal advice, or a trained domestic violence advocate.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppText.fontFamily,
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFFC8CED3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(44, 0, 44, 40),
              child: Column(
                children: [
                  SizedBox(
                    width: 130,
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation(Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'STARTING…',
                    style: TextStyle(
                      fontFamily: AppText.fontFamily,
                      fontSize: 11,
                      letterSpacing: 0.6,
                      color: Color(0xFF7F878D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
