import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

/// Screen 6a — static "Mission & values" / About Creating Wings screen.
/// Content is inside a scroll view so nothing clips on small devices.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _siteUrl = 'https://www.creatingwings.org/';

  static const _values = <List<String>>[
    ['Innovation & Technology', 'cutting-edge AI tools for financial independence.'],
    ['Education', 'empowering people through lifelong learning.'],
    ['Empowerment', 'uplifting women with knowledge, tools, and support.'],
    ['Inclusion', 'serving all women, honoring every story.'],
    ['Resilience', 'strength in adversity; survival and renewal.'],
  ];

  Future<void> _openSite() async {
    final uri = Uri.parse(_siteUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not open $_siteUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // wavy header texture
          const SizedBox(
            height: 230,
            width: double.infinity,
            child: IgnorePointer(
              child: CustomPaint(painter: _TopWavePainter()),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 18),

                // logo + wordmark
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png',
                          width: 58, height: 58, fit: BoxFit.contain),
                      const SizedBox(height: 3),
                      // const Text(
                      //   'Creating Wings',
                      //   style: TextStyle(
                      //     fontFamily: AppText.fontFamily,
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.w700,
                      //     color: Color(0xFF1F3A4D),
                      //     letterSpacing: 0.2,
                      //   ),
                      // ),
                    ],
                  ),
                ),

                // content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _InfoCard(
                          label: 'MISSION',
                          body:
                              'To empower women and girls to achieve financial independence through personalized, AI-driven support, resources, and guidance.',
                          filled: true,
                        ),
                        const SizedBox(height: 9),
                        const _InfoCard(
                          label: 'VISION',
                          body:
                              'A world where every woman has the wings to rise — free from fear, equipped with knowledge, and backed by a community that believes in her.',
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.only(left: 2, bottom: 8),
                          child: Text(
                            'VALUES',
                            style: TextStyle(
                              fontFamily: AppText.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.9,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                        for (final v in _values) ...[
                          _ValueRow(title: v[0], body: v[1]),
                          const SizedBox(height: 4),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // website link
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openSite,
                          icon: const Icon(Icons.public, color: Colors.white, size: 17),
                          label: const Text(
                            'Visit creatingwings.org',
                            style: TextStyle(
                              fontFamily: AppText.fontFamily,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '© 2025 Creating Wings Co. · info@creatingwings.org',
                        style: TextStyle(
                          fontFamily: AppText.fontFamily,
                          fontSize: 11,
                          color: Color(0xFF8A99A3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String body;
  final bool filled;
  const _InfoCard({required this.label, required this.body, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFEAF4FB) : Colors.white,
        border: Border.all(
            color: filled ? const Color(0xFFD3E7F4) : const Color(0xFFDBE8F1)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: filled
            ? null
            : const [
                BoxShadow(
                    color: Color(0x1A285A78),
                    blurRadius: 18,
                    offset: Offset(0, 6)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            style: const TextStyle(
              fontFamily: AppText.fontFamily,
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String title;
  final String body;
  const _ValueRow({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFD),
        border: Border.all(color: const Color(0xFFE3EFF7)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 9),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontFamily: AppText.fontFamily,
                  fontSize: 11.8,
                  height: 1.45,
                  color: AppColors.ink,
                ),
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F3A4D),
                    ),
                  ),
                  TextSpan(text: ' — $body'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wavy light-blue texture anchored to the top of the screen.
class _TopWavePainter extends CustomPainter {
  const _TopWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    double sx(double x) => x / 390 * w;
    double sy(double y) => y / 220 * h;

    final back = Paint()..color = const Color(0xFFEAF4FB);
    final front = Paint()..color = const Color(0xFFDCEDF9);

    final p1 = Path()
      ..moveTo(0, 0)
      ..lineTo(sx(390), 0)
      ..lineTo(sx(390), sy(110))
      ..cubicTo(sx(330), sy(150), sx(250), sy(80), sx(190), sy(120))
      ..cubicTo(sx(130), sy(160), sx(70), sy(160), 0, sy(120))
      ..close();
    canvas.drawPath(p1, back);

    final p2 = Path()
      ..moveTo(0, 0)
      ..lineTo(sx(390), 0)
      ..lineTo(sx(390), sy(80))
      ..cubicTo(sx(320), sy(120), sx(250), sy(55), sx(185), sy(95))
      ..cubicTo(sx(120), sy(135), sx(65), sy(130), 0, sy(90))
      ..close();
    canvas.drawPath(p2, front);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
