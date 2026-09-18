import 'package:flutter/material.dart';

/// Wavy light-blue texture used across screens.
/// [flip] mirrors it vertically (used on the disclaimer / top-of-screen variant).
class WaveBackground extends StatelessWidget {
  final bool flip;
  const WaveBackground({super.key, this.flip = false});

  @override
  Widget build(BuildContext context) {
    Widget painter = SizedBox(
      height: 300,
      width: double.infinity,
      child: CustomPaint(painter: _WavePainter()),
    );
    if (flip) painter = Transform.flip(flipY: true, child: painter);
    return IgnorePointer(
      child: Align(
        alignment: flip ? Alignment.topCenter : Alignment.bottomCenter,
        child: painter,
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    double sx(double x) => x / 390 * w;
    double sy(double y) => y / 260 * h;

    final back = Paint()..color = const Color(0xFFEAF4FB);
    final front = Paint()..color = const Color(0xFFDCEDF9);

    final p1 = Path()
      ..moveTo(sx(0), sy(120))
      ..cubicTo(sx(70), sy(70), sx(130), sy(170), sx(200), sy(120))
      ..cubicTo(sx(265), sy(75), sx(330), sy(70), sx(390), sy(120))
      ..lineTo(sx(390), sy(260))
      ..lineTo(sx(0), sy(260))
      ..close();
    canvas.drawPath(p1, back);

    final p2 = Path()
      ..moveTo(sx(0), sy(170))
      ..cubicTo(sx(70), sy(130), sx(140), sy(210), sx(210), sy(165))
      ..cubicTo(sx(280), sy(122), sx(330), sy(120), sx(390), sy(165))
      ..lineTo(sx(390), sy(260))
      ..lineTo(sx(0), sy(260))
      ..close();
    canvas.drawPath(p2, front);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
