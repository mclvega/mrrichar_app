import 'package:flutter/material.dart';
import 'package:mrrichar_app/data/app_image_cache.dart';

class AppTheme {
  const AppTheme._();

  static const Color primaryColor = Color(0xFF011EA0);
  static const Color secondaryColor = Color(0xFF42A5F5);
  static const Color accentColor = Color(0xFFFFD700);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);

  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onError: Colors.white,
    ),
    textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 3,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: primaryColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: backgroundColor,
      selectedColor: primaryColor,
      labelStyle: const TextStyle(color: Colors.black87),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.black,
      unselectedLabelColor: Colors.white,
      indicator: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: primaryColor,
      indicatorColor: Colors.white24,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: Colors.white, fontWeight: FontWeight.w700);
        }
        return const TextStyle(color: Colors.white70);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white);
        }
        return const IconThemeData(color: Colors.white70);
      }),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _LoadingPageTransitionsBuilder(),
        TargetPlatform.iOS: _LoadingPageTransitionsBuilder(),
        TargetPlatform.linux: _LoadingPageTransitionsBuilder(),
        TargetPlatform.macOS: _LoadingPageTransitionsBuilder(),
        TargetPlatform.windows: _LoadingPageTransitionsBuilder(),
        TargetPlatform.fuchsia: _LoadingPageTransitionsBuilder(),
      },
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.grey,
      thickness: 1,
      space: 16,
    ),
    useMaterial3: true,
  );

  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  static const Map<String, Color> positionColors = {
    'GK': Color(0xFFFFB300),
    'DEF': Color(0xFF1976D2),
    'MID': Color(0xFF388E3C),
    'FW': Color(0xFFD32F2F),
    'ATT': Color(0xFFD32F2F),
  };

  static BoxDecoration get backgroundDecoration {
    final imageProvider = AppImageCache.instance.backgroundImageProvider;

    return BoxDecoration(
      color: primaryColor,
      image: imageProvider == null
          ? null
          : DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              opacity: 1.0,
            ),
    );
  }

  static BoxDecoration get prominentBackgroundDecoration {
    final imageProvider = AppImageCache.instance.backgroundImageProvider;

    return BoxDecoration(
      color: primaryColor,
      image: imageProvider == null
          ? null
          : DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              opacity: 1.0,
            ),
    );
  }

  static Widget buildAppLogo({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    ImageProvider? imageProvider,
  }) {
    final provider = imageProvider ?? AppImageCache.instance.logoImageProvider;
    if (provider == null) {
      return _buildFallbackLogo(width, height);
    }

    return Image(
      image: provider,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackLogo(width, height);
      },
    );
  }

  static Widget _buildFallbackLogo(double? width, double? height) {
    return Container(
      width: width ?? 48,
      height: height ?? 48,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.sports_soccer,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );
}

class _LoadingPageTransitionsBuilder extends PageTransitionsBuilder {
  const _LoadingPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.22, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic,
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        animation.status == AnimationStatus.reverse
            ? child
            : SlideTransition(
                position: slideAnimation,
                child: child,
              ),
        _TimedLoadingOverlay(
          primaryAnimation: animation,
          secondaryAnimation: secondaryAnimation,
        ),
      ],
    );
  }
}

class _TimedLoadingOverlay extends StatefulWidget {
  const _TimedLoadingOverlay({
    required this.primaryAnimation,
    required this.secondaryAnimation,
  });

  final Animation<double> primaryAnimation;
  final Animation<double> secondaryAnimation;

  @override
  State<_TimedLoadingOverlay> createState() => _TimedLoadingOverlayState();
}

class _TimedLoadingOverlayState extends State<_TimedLoadingOverlay> {
  bool _visible = true;
  int _hideToken = 0;

  @override
  void initState() {
    super.initState();
    widget.primaryAnimation.addStatusListener(_onPrimaryStatusChanged);
    widget.secondaryAnimation.addStatusListener(_onSecondaryStatusChanged);
    _showForOneSecond();
  }

  @override
  void didUpdateWidget(covariant _TimedLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.primaryAnimation != widget.primaryAnimation) {
      oldWidget.primaryAnimation.removeStatusListener(_onPrimaryStatusChanged);
      widget.primaryAnimation.addStatusListener(_onPrimaryStatusChanged);
    }
    if (oldWidget.secondaryAnimation != widget.secondaryAnimation) {
      oldWidget.secondaryAnimation.removeStatusListener(_onSecondaryStatusChanged);
      widget.secondaryAnimation.addStatusListener(_onSecondaryStatusChanged);
    }
  }

  @override
  void dispose() {
    widget.primaryAnimation.removeStatusListener(_onPrimaryStatusChanged);
    widget.secondaryAnimation.removeStatusListener(_onSecondaryStatusChanged);
    super.dispose();
  }

  void _onPrimaryStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.reverse) {
      _showForOneSecond();
    }
  }

  void _onSecondaryStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.reverse) {
      _showForOneSecond();
    }
  }

  void _showForOneSecond() {
    _hideToken += 1;
    final currentToken = _hideToken;
    if (!_visible) {
      setState(() {
        _visible = true;
      });
    }

    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (!mounted || currentToken != _hideToken) {
        return;
      }
      setState(() {
        _visible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: ColoredBox(
        color: AppTheme.primaryColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTheme.buildAppLogo(
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

