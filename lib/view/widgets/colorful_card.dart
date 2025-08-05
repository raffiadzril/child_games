import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/radius.dart';
import '../../core/constants/dimensions.dart';

/// Colorful card dengan animasi hover untuk tampilan yang menyenangkan
class ColorfulCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final List<Color>? gradient;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool enableHoverAnimation;
  final double? elevation;

  const ColorfulCard({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.gradient,
    this.padding,
    this.onTap,
    this.enableHoverAnimation = true,
    this.elevation,
  }) : super(key: key);

  @override
  State<ColorfulCard> createState() => _ColorfulCardState();
}

class _ColorfulCardState extends State<ColorfulCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableHoverAnimation) {
      setState(() => _isHovered = true);
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableHoverAnimation) {
      setState(() => _isHovered = false);
      _scaleController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableHoverAnimation) {
      setState(() => _isHovered = false);
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: Container(
              padding:
                  widget.padding ??
                  const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                gradient:
                    widget.gradient != null
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.gradient!,
                        )
                        : null,
                color:
                    widget.gradient == null
                        ? (widget.backgroundColor ?? AppColors.backgroundCard)
                        : null,
                borderRadius: BorderRadius.circular(AppRadius.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: widget.elevation ?? (_isHovered ? 12 : 8),
                    offset: Offset(0, widget.elevation ?? (_isHovered ? 6 : 4)),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shimmer effect untuk sparkle
                  if (widget.enableHoverAnimation && _isHovered)
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppRadius.radiusL,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(
                                    -1.0 + _shimmerAnimation.value,
                                    0.0,
                                  ),
                                  end: Alignment(
                                    1.0 + _shimmerAnimation.value,
                                    0.0,
                                  ),
                                  colors: const [
                                    Colors.transparent,
                                    Colors.white24,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  // Content
                  widget.child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
