import 'dart:math' show sqrt;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../core/network/token_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routing/app_router.dart';

// Timeline: phase1 (circle expand fill) -> phase2 (show V) -> phase3 (V + erdant slide to center).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  static const _p1End = 0.40; // circle fills screen
  static const _p2End = 0.55; // V appears
  static const _p3End = 0.95; // word assembles

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward().then((_) => _next());
  }

  Future<void> _next() async {
    if (!mounted) return;
    final token = await sl<TokenStorage>().getAccessToken();
    if (!mounted) return;
    final loggedIn = token != null && token.isNotEmpty;
    isAuthenticated = loggedIn;
    context.go(loggedIn ? '/home' : '/login');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static double _seg(AnimationController c, double start, double end) {
    if (c.value >= end) return 1;
    if (c.value <= start) return 0;
    return (c.value - start) / (end - start);
  }

  @override
  Widget build(BuildContext context) {
    final diagonal = sqrt(
      MediaQuery.sizeOf(context).width * MediaQuery.sizeOf(context).width +
          MediaQuery.sizeOf(context).height * MediaQuery.sizeOf(context).height,
    );

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final p1 = Curves.easeInCubic.transform(_seg(_c, 0, _p1End));
          final p2 = _seg(_c, _p1End, _p2End);
          final p3 = Curves.easeOutCubic.transform(_seg(_c, _p2End, _p3End));
          final circleSize = 64 + p1 * diagonal;

          return Stack(
            children: [
              // phase 1: green circle from center dot -> full background
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [AppColors.green600, AppColors.green700],
                      ),
                    ),
                  ),
                ),
              ),
              // Word reveal: V (left part) slides right->left, erdant (right part)
              // slides left->right. Both start at center, end as centered "Verdant".
              Center(
                child: Opacity(
                  opacity: p2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: Offset(170 * (1 - p3), 0),
                        child: const Text(
                          'V',
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(-100 * (1 - p3), 0),
                        child: Opacity(
                          opacity: (p3 * 2).clamp(0.0, 1.0),
                          child: const Text(
                            'erdant',
                            style: TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
