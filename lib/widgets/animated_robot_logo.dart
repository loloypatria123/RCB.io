import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AnimatedRobotLogo extends StatefulWidget {
  final double size;
  final bool enableCursorTracking;

  const AnimatedRobotLogo({
    super.key,
    this.size = 120,
    this.enableCursorTracking = true,
  });

  @override
  State<AnimatedRobotLogo> createState() => _AnimatedRobotLogoState();
}

class _AnimatedRobotLogoState extends State<AnimatedRobotLogo>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _eyeController;
  late Animation<double> _blinkAnimation;
  late Animation<Offset> _eyeAnimation;

  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();

    // Blink animation
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.1).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Eye tracking animation
    _eyeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _eyeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _eyeController, curve: Curves.easeOut));

    // Start periodic blinking
    _startBlinking();
  }

  void _startBlinking() {
    Future.delayed(
      Duration(milliseconds: 2000 + (DateTime.now().millisecond % 3000)),
      () {
        if (mounted) {
          _blink();
          _startBlinking();
        }
      },
    );
  }

  void _blink() async {
    if (_isBlinking) return;
    _isBlinking = true;
    await _blinkController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _blinkController.reverse();
    _isBlinking = false;
  }

  void _updateEyePosition(
    Offset globalPosition,
    Size widgetSize,
    Offset widgetPosition,
  ) {
    if (!widget.enableCursorTracking) return;

    final center = Offset(
      widgetPosition.dx + widgetSize.width / 2,
      widgetPosition.dy + widgetSize.height / 2,
    );

    final direction = globalPosition - center;
    final distance = direction.distance;

    // Much more responsive tracking - remove distance limitation
    // Maximum eye movement range (increased for better visibility)
    final maxEyeMovement = widget.size * 0.08; // Increased from 0.15

    // Calculate normalized direction
    final normalizedDirection = distance > 0
        ? direction / distance
        : Offset.zero;

    // Apply movement with better scaling
    final eyeMovement = normalizedDirection * maxEyeMovement;

    // Convert to relative coordinates for painting
    final relativeOffset = Offset(
      eyeMovement.dx / widget.size,
      eyeMovement.dy / widget.size,
    );

    _eyeAnimation = Tween<Offset>(
      begin: _eyeAnimation.value,
      end: relativeOffset,
    ).animate(CurvedAnimation(parent: _eyeController, curve: Curves.easeOut));

    _eyeController.reset();
    _eyeController.forward();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _eyeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        if (widget.enableCursorTracking) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final RenderBox? renderBox =
                context.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final position = renderBox.localToGlobal(Offset.zero);
              final size = renderBox.size;
              _updateEyePosition(event.position, size, position);
            }
          });
        }
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.buttonGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.mediumBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.lightBlue.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([_blinkAnimation, _eyeAnimation]),
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: RobotLogoPainter(
                eyeOffset: _eyeAnimation.value,
                blinkValue: _blinkAnimation.value,
                size: widget.size,
              ),
            );
          },
        ),
      ),
    );
  }
}

class RobotLogoPainter extends CustomPainter {
  final Offset eyeOffset;
  final double blinkValue;
  final double size;

  RobotLogoPainter({
    required this.eyeOffset,
    required this.blinkValue,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = canvasSize.width / 2;

    // Robot body (main circle) - already handled by container gradient

    // Robot face area (inner white area)
    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final faceRadius = radius * 0.7;
    final faceRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius * 0.05),
        width: faceRadius * 1.8,
        height: faceRadius * 1.4,
      ),
      Radius.circular(faceRadius * 0.3),
    );
    canvas.drawRRect(faceRect, facePaint);

    // Eyes
    final eyePaint = Paint()
      ..color = AppColors.mediumBlue
      ..style = PaintingStyle.fill;

    final eyeRadius = radius * 0.12;
    final eyeY = center.dy - radius * 0.15;
    final eyeSpacing = radius * 0.25;

    // Enhanced eye movement - much more visible
    final eyeMovementScale =
        size * 0.25; // Increased from 0.1 for better visibility

    // Left eye
    final leftEyeCenter = Offset(
      center.dx - eyeSpacing + (eyeOffset.dx * eyeMovementScale),
      eyeY + (eyeOffset.dy * eyeMovementScale),
    );
    canvas.drawCircle(leftEyeCenter, eyeRadius * blinkValue, eyePaint);

    // Right eye
    final rightEyeCenter = Offset(
      center.dx + eyeSpacing + (eyeOffset.dx * eyeMovementScale),
      eyeY + (eyeOffset.dy * eyeMovementScale),
    );
    canvas.drawCircle(rightEyeCenter, eyeRadius * blinkValue, eyePaint);

    // Mouth (happy smile)
    final mouthPaint = Paint()
      ..color = AppColors.accentPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.04
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    final mouthY = center.dy + radius * 0.15;
    final mouthWidth = radius * 0.3;

    mouthPath.moveTo(center.dx - mouthWidth / 2, mouthY);
    mouthPath.quadraticBezierTo(
      center.dx,
      mouthY + radius * 0.08,
      center.dx + mouthWidth / 2,
      mouthY,
    );
    canvas.drawPath(mouthPath, mouthPaint);

    // Robot antennas/ears
    final antennaPaint = Paint()
      ..color = AppColors.mediumBlue
      ..style = PaintingStyle.fill;

    // Left antenna
    final leftAntennaRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.8, center.dy - radius * 0.1),
        width: radius * 0.25,
        height: radius * 0.6,
      ),
      Radius.circular(radius * 0.125),
    );
    canvas.drawRRect(leftAntennaRect, antennaPaint);

    // Right antenna
    final rightAntennaRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.8, center.dy - radius * 0.1),
        width: radius * 0.25,
        height: radius * 0.6,
      ),
      Radius.circular(radius * 0.125),
    );
    canvas.drawRRect(rightAntennaRect, antennaPaint);

    // Robot head details (small decorative elements)
    final detailPaint = Paint()
      ..color = AppColors.lightBlue.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Top indicator
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.5),
      radius * 0.05,
      detailPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RobotLogoPainter oldDelegate) {
    return oldDelegate.eyeOffset != eyeOffset ||
        oldDelegate.blinkValue != blinkValue;
  }
}
