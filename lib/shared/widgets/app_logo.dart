import 'package:flutter/material.dart';

import 'package:expence_tracking/app/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.textColor = AppColors.textPrimary,
    this.iconColor = AppColors.primaryMint,
    this.iconSize = 78,
    this.fontSize = 42,
  });

  final Color textColor;
  final Color iconColor;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.query_stats_rounded, color: iconColor, size: iconSize),
        const SizedBox(height: 8),
        Text(
          'FinWise',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
