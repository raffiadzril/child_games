import 'package:flutter/material.dart';

/// Animated background dengan gradasi warna yang bergerak untuk tampilan yang menyenangkan
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final List<List<Color>> gradients;

  const AnimatedGradientBackground({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 8),
    this.gradients = const [
      [Color(0xFF6B73FF), Color(0xFF9BA3FF)], // gradientPrimary
      [Color(0xFFFF6B9D), Color(0xFFFFB3D1)], // gradientSecondary
      [Color(0xFFFF9F43), Color(0xFFFFD93D)], // gradientSunset
      [Color(0xFF6BCF7F), Color(0xFF4ECDC4)], // gradientNature
    ],
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentGradientIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentGradientIndex =
              (_currentGradientIndex + 1) % widget.gradients.length;
        });
        _controller.reset();
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentGradient = widget.gradients[_currentGradientIndex];
        final nextGradient =
            widget.gradients[(_currentGradientIndex + 1) %
                widget.gradients.length];

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  currentGradient[0],
                  nextGradient[0],
                  _animation.value,
                )!,
                Color.lerp(
                  currentGradient[1],
                  nextGradient[1],
                  _animation.value,
                )!,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floating bubbles untuk efek tambahan
              ...List.generate(6, (index) {
                return Positioned(
                  left: (index * 60.0) % MediaQuery.of(context).size.width,
                  top: (index * 120.0) % MediaQuery.of(context).size.height,
                  child: _FloatingBubble(
                    delay: Duration(milliseconds: index * 500),
                    color:
                        [
                          const Color(0xFFFFD93D).withOpacity(0.1), // accent1
                          const Color(0xFF6BCF7F).withOpacity(0.1), // accent2
                          const Color(0xFFFF9F43).withOpacity(0.1), // accent3
                          const Color(0xFF4ECDC4).withOpacity(0.1), // accent4
                          const Color(0xFFFF6B6B).withOpacity(0.1), // accent5
                          const Color(0xFF6B73FF).withOpacity(0.1), // primary
                        ][index],
                  ),
                );
              }),
              // Content
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

/// Floating bubble animation untuk efek visual tambahan
class _FloatingBubble extends StatefulWidget {
  final Duration delay;
  final Color color;

  const _FloatingBubble({required this.delay, required this.color});

  @override
  State<_FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<_FloatingBubble>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _scaleController;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: 0.0, end: -200.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Start animations with delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _floatController.repeat();
        _scaleController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
