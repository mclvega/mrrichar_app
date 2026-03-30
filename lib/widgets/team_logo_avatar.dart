import 'package:flutter/material.dart';
import 'package:mrrichar_app/app_theme.dart';

class TeamLogoAvatar extends StatelessWidget {
  const TeamLogoAvatar({
    super.key,
    this.size = 26,
    this.imageUrl,
  });

  final double size;
  // Kept for API compatibility, but the app now uses one official offline logo.
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: AppTheme.buildAppLogo(
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
