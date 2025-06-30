import 'package:flutter/material.dart';

class DottedRectanglePainter extends CustomPainter {
  final double progress;           // 0.0‒1.0
  final int totalDots;             // how many dots around the box
  final double dotRadius;          // base radius for “inactive” dots
  final Color? activeProgressColor;
  final Color? progressColor;

  DottedRectanglePainter({
    required this.progress,
    this.totalDots = 60,
    this.dotRadius = 3.0,
    this.activeProgressColor,
    this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Keep dots clear of the canvas edge.
    final double padding = dotRadius * 2;
    final Rect rect = Offset(padding, padding) &
        Size(size.width - padding * 2, size.height - padding * 2);

    final double perimeter = 2 * (rect.width + rect.height);
    final double gap = perimeter / totalDots;

    final int activeDots = (progress.clamp(0.0, 1.0) * totalDots).round();
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < totalDots; i++) {
      // Distance travelled along the rectangle’s path.
      final double d = i * gap;
      late Offset p;

      if (d <= rect.width) {
        // ─ top edge ─►
        p = Offset(rect.left + d, rect.top);
      } else if (d <= rect.width + rect.height) {
        // │ right edge │
        p = Offset(rect.right, rect.top + (d - rect.width));
      } else if (d <= 2 * rect.width + rect.height) {
        // ◄─ bottom edge ─
        p = Offset(rect.right - (d - rect.width - rect.height), rect.bottom);
      } else {
        // │ left edge │
        p = Offset(rect.left,
            rect.bottom - (d - 2 * rect.width - rect.height));
      }

      if (i < activeDots) {
        paint.color = activeProgressColor ?? Colors.green;
        canvas.drawCircle(p, dotRadius + 1.5, paint);
      } else {
        paint.color = progressColor ?? Colors.red;
        canvas.drawCircle(p, dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
