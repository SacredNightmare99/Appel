import 'package:flutter/material.dart';
import 'package:the_project/utils/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset(
                    'assets/lfwa_logo.png',
                    width: width > 600 ? 180 : 120,
                  ),
                  const SizedBox(height: 20),

                  // App Name
                  Text(
                    'Appel',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Smart Attendance & Student Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.text.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Description
                  Text(
                    'Appel is a clean, intuitive platform designed for managing batches, students, and attendance records. '
                    'It combines real-time syncing with a modern UI to help admins and members stay organized effortlessly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.text.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Feature Highlights
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureChip('📋 Attendance Tracking'),
                      _buildFeatureChip('👥 Role Management'),
                      _buildFeatureChip('📊 Batch Insights'),
                      _buildFeatureChip('🗓️ Date Filtering'),
                      _buildFeatureChip('🧠 AI Assistant'),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Footer
                  Text(
                    'v1.0.0 — Made with ❤️ using Flutter',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.text.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: AppColors.secondary,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
