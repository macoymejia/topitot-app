import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

Rect? insetWalkthroughTargetRect(Rect? rect, EdgeInsets padding) {
  if (rect == null) {
    return null;
  }

  return rect.shift(Offset(-padding.left, -padding.top));
}

class WalkthroughOverlay extends StatelessWidget {
  const WalkthroughOverlay({
    super.key,
    required this.targetRect,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onSkip,
  });

  final Rect? targetRect;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSkip,
              child: CustomPaint(
                painter: _WalkthroughBackdropPainter(targetRect: targetRect),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 8,
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.largeBorder,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.neutral700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          body,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.3,
                            color: AppColors.neutral700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: <Widget>[
                            TextButton(
                              onPressed: onSkip,
                              child: const Text('Skip'),
                            ),
                            const Spacer(),
                            FilledButton(
                              onPressed: onPrimary,
                              child: Text(primaryLabel),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkthroughBackdropPainter extends CustomPainter {
  _WalkthroughBackdropPainter({required this.targetRect});

  final Rect? targetRect;

  @override
  void paint(Canvas canvas, Size size) {
    final scrimPaint = Paint()..color = AppColors.neutral900.withValues(alpha: 0.72);
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, scrimPaint);

    final rect = targetRect;
    if (rect == null) {
      canvas.restore();
      return;
    }

    final highlight = RRect.fromRectAndRadius(
      rect.inflate(10),
      const Radius.circular(24),
    );
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(highlight, clearPaint);
    canvas.restore();

    final outlinePaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(highlight, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _WalkthroughBackdropPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect;
  }
}
