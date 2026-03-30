import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mrrichar_app/app_links.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppImageCache {
  AppImageCache._();

  static final AppImageCache instance = AppImageCache._();

  static const String _logoFileName = 'logo.png';
  static const String _backgroundFileName = 'fondo-default1.png';

  String? _logoPath;
  String? _backgroundPath;

  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final imagesDir = Directory(p.join(dbPath, 'images'));
    await imagesDir.create(recursive: true);

    _logoPath = await _ensureImage(
      url: AppLinks.appLogoImage,
      fileName: _logoFileName,
      baseDir: imagesDir,
    );

    _backgroundPath = await _ensureImage(
      url: AppLinks.appBackgroundImage,
      fileName: _backgroundFileName,
      baseDir: imagesDir,
    );
  }

  ImageProvider? get logoImageProvider {
    if (_logoPath != null) {
      final logoFile = File(_logoPath!);
      if (logoFile.existsSync()) {
        return FileImage(logoFile);
      }
    }
    return null;
  }

  ImageProvider? get backgroundImageProvider {
    if (_backgroundPath != null) {
      final backgroundFile = File(_backgroundPath!);
      if (backgroundFile.existsSync()) {
        return FileImage(backgroundFile);
      }
    }
    return null;
  }

  Future<String?> _ensureImage({
    required String url,
    required String fileName,
    required Directory baseDir,
  }) async {
    final localPath = p.join(baseDir.path, fileName);
    final localFile = File(localPath);

    if (await localFile.exists() && await localFile.length() > 0) {
      return localPath;
    }

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close().timeout(const Duration(seconds: 15));

      if (response.statusCode != HttpStatus.ok) {
        return null;
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      await localFile.writeAsBytes(bytes, flush: true);
      client.close(force: true);
      return localPath;
    } catch (_) {
      return null;
    }
  }
}