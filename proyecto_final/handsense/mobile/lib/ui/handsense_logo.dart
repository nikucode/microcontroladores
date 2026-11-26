import 'package:flutter/material.dart';

class HandSenseLogo extends StatelessWidget {
  const HandSenseLogo({super.key, this.size = 112});
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Logotipo HandSense: dos formas convergen en un punto de contacto',
    child: ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _HandSenseLogoPainter(
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
    ),
  );
}

class _HandSenseLogoPainter extends CustomPainter {
  const _HandSenseLogoPainter(this.primary, this.contact);
  final Color primary;
  final Color contact;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .12
      ..strokeCap = StrokeCap.round;
    final left = Path()
      ..moveTo(size.width * .15, size.height * .78)
      ..cubicTo(
        size.width * .18,
        size.height * .30,
        size.width * .42,
        size.height * .25,
        size.width * .49,
        size.height * .49,
      );
    final right = Path()
      ..moveTo(size.width * .85, size.height * .78)
      ..cubicTo(
        size.width * .82,
        size.height * .30,
        size.width * .58,
        size.height * .25,
        size.width * .51,
        size.height * .49,
      );
    canvas.drawPath(left, stroke);
    canvas.drawPath(right, stroke);
    canvas.drawCircle(
      Offset(size.width * .5, size.height * .5),
      size.width * .085,
      Paint()..color = contact,
    );
  }

  @override
  bool shouldRepaint(_HandSenseLogoPainter oldDelegate) =>
      primary != oldDelegate.primary || contact != oldDelegate.contact;
}
