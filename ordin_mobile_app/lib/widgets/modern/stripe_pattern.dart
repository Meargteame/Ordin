import 'package:flutter/material.dart';
import '../../theme/modern_dark_colors.dart';

/// Stripe Pattern Painter - diagonal stripes for card backgrounds
/// Matches reference design pixel-perfect
class StripePatternPainter extends CustomPainter {
  final Color stripeColor;
  final double stripeWidth;
  final double stripeSpacing;
  final double angle;
  
  StripePatternPainter({
    this.stripeColor = ModernDarkColors.patternStroke,
    this.stripeWidth = 2.0,
    this.stripeSpacing = 8.0,
    this.angle = 45.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripeColor
      ..strokeWidth = stripeWidth
      ..style = PaintingStyle.stroke;
    
    final angleRad = angle * (3.14159 / 180);
    final diagonal = (size.width + size.height) * 1.5;
    final spacing = stripeWidth + stripeSpacing;
    
    canvas.save();
    canvas.translate(0, 0);
    canvas.rotate(angleRad);
    
    for (double i = -diagonal; i < diagonal; i += spacing) {
      canvas.drawLine(
        Offset(i, -diagonal),
        Offset(i, diagonal),
        paint,
      );
    }
    
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stripe Pattern Widget - wraps content with stripe pattern
class StripePattern extends StatelessWidget {
  final Widget child;
  final Color stripeColor;
  final double stripeWidth;
  final double stripeSpacing;
  final double angle;
  
  const StripePattern({
    super.key,
    required this.child,
    this.stripeColor = ModernDarkColors.patternStroke,
    this.stripeWidth = 2.0,
    this.stripeSpacing = 8.0,
    this.angle = 45.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: CustomPaint(
            painter: StripePatternPainter(
              stripeColor: stripeColor,
              stripeWidth: stripeWidth,
              stripeSpacing: stripeSpacing,
              angle: angle,
            ),
          ),
        ),
      ],
    );
  }
}
