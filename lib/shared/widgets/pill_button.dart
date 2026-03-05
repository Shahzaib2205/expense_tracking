import 'package:flutter/material.dart';

import 'package:expence_tracking/app/app_theme.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.width = double.infinity,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final double width;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary
        ? AppColors.primaryMint
        : AppColors.mintInput.withValues(alpha: 0.95);
    final textColor = isPrimary ? AppColors.textPrimary : AppColors.mintDark;

    return SizedBox(
      width: width,
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        child: Text(label),
      ),
    );
  }
}
