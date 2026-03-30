import 'package:flutter/material.dart';

class AppImageCache {
  AppImageCache._();

  static final AppImageCache instance = AppImageCache._();

  static const String _officialLogoAssetPath = 'assets/images/app_icon.png';
  static const String _officialBackgroundAssetPath = 'assets/images/app_background.png';

  Future<void> initialize() async {}

  ImageProvider? get logoImageProvider {
    return const AssetImage(_officialLogoAssetPath);
  }

  ImageProvider? get backgroundImageProvider {
    return const AssetImage(_officialBackgroundAssetPath);
  }
}