import 'package:flutter/material.dart';

import 'package:expence_tracking/app/app_theme.dart';

class SocialIconRow extends StatelessWidget {
  const SocialIconRow({super.key, this.caption = 'or sign up with'});

  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          caption,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _CircleIcon(
              child: Icon(
                Icons.fingerprint,
                size: 18,
                color: AppColors.mintDark,
              ),
            ),
            SizedBox(width: 14),
            _CircleIcon(
              child: Text(
                'G',
                style: TextStyle(
                  color: AppColors.mintDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.mintDark.withValues(alpha: 0.3)),
      ),
      child: Center(child: child),
    );
  }
}
