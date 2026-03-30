import 'package:flutter/material.dart';
import 'package:mrrichar_app/app_theme.dart';

class TeamLogoAvatar extends StatelessWidget {
  const TeamLogoAvatar({
    super.key,
    this.size = 26,
    this.imageUrl,
  });

  final double size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final safeImageUrl = imageUrl?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: (safeImageUrl != null && safeImageUrl.isNotEmpty)
          ? Image.network(
              safeImageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return AppTheme.buildAppLogo(
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                );
              },
            )
          : AppTheme.buildAppLogo(
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
    );
  }
}
