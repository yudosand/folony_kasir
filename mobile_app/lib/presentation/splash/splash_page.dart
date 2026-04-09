import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../shared/widgets/brand_logo_badge.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: BrandLogoBadge(
            width: 260,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
