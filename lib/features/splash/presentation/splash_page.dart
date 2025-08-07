import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../main.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/AppSizes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _radiusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Start animation
    _animationController.forward();

    // Request location permission
    //_requestLocationPermission();

    // Navigate to home screen after 5 seconds
    Timer(const Duration(seconds: 3), () {
      // GOROUTER page replacement to home screen
      context.pushReplacement(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with scale animation
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco_outlined,
                        color: AppColors.primary,
                        size: 70,
                      ),
                    ),
                  ),
                ),

                gapH24,

                // App name with fade in animation
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: const Text(
                    'Sahabi Guide',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline with fade in animation
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Text(
                    'Your guide for a blessed and seamless pilgrimage.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                gapH48,

                // Circular loading animation
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating circle
                    Transform.rotate(
                      angle: _rotationAnimation.value * 3.14,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 4,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                          gradient: SweepGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.primary,
                            ],
                            stops: const [0.75, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Inner circle with pulsing animation
                    Container(
                      width: 50 * _radiusAnimation.value,
                      height: 50 * _radiusAnimation.value,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.eco_outlined,
                        color: AppColors.primary,
                        size: 24 * _radiusAnimation.value,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
