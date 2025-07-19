import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_project/utils/colors.dart';
import 'package:the_project/utils/image_paths.dart';
import 'package:the_project/widgets/custom_navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              // Use a ConstrainedBox for better readability on wide screens
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    // --- Header Section ---
                    _AnimatedFadeIn(
                      delay: Duration(milliseconds: 200),
                      child: _buildHeader(),
                    ),
                    SizedBox(height: 30),

                    // --- Description ---
                    _AnimatedFadeIn(
                      delay: Duration(milliseconds: 300),
                      child: Text(
                        'Appel is a clean, intuitive platform designed for managing batches, students, and attendance records with real-time syncing.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.text.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),

                    // --- Feature Highlights ---
                    _AnimatedFadeIn(
                      delay: Duration(milliseconds: 400),
                      child: _buildFeatureList(),
                    ),
                    SizedBox(height: 50),

                    // --- Call-to-Action Button ---
                    _AnimatedFadeIn(
                      delay: Duration(milliseconds: 500),
                      child: _buildCtaButton(),
                    ),
                    SizedBox(height: 50),

                    // --- Footer ---
                    _AnimatedFadeIn(
                      delay: Duration(milliseconds: 600),
                      child: _buildFooter(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(AppImagePaths.logo, width: 140),
        const SizedBox(height: 24),
        Text(
          'Welcome to Appel',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Smart Attendance & Student Management',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.text.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureItem(
          icon: Icons.checklist_rtl_rounded,
          text: 'Real-Time Attendance Tracking',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.groups_2_rounded,
          text: 'Effortless Batch & Student Management',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.bar_chart_rounded,
          text: 'Clear Insights & Date Filtering',
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.smart_toy_rounded,
          text: 'Powerful AI Assistant',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton() {
    return ElevatedButton.icon(
      onPressed: () {
        final navController = Get.find<NavController>();
        navController.updateRoute('/attendance');
        Get.toNamed('/attendance', id: 1);
      },
      icon: const Icon(Icons.dashboard_rounded),
      label: const Text('Mark Attendance'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          color: AppColors.text.withValues(alpha: 0.6),
        ),
        children: [
          const TextSpan(text: 'Made by '),
          TextSpan(
            text: 'Ishaan Jindal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// A simple reusable animation widget
class _AnimatedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedFadeIn({required this.child, required this.delay});

  @override
  State<_AnimatedFadeIn> createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<_AnimatedFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    // Start the animation after the specified delay
    Timer(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: widget.child,
    );
  }
}