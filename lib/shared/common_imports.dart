import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter/foundation.dart';

// State Management here
// ... getx, river.., providers

// Network and API
// ❌ SUPPRIMÉ - Package non utilisé
// export 'package:cached_network_image/cached_network_image.dart';

// Constants and Theme
import 'constants/app_sizes.dart';
import '../core/theme/theme_extensions.dart';

// Utilities

// Common Widgets

// ✅ Logger singleton (optimisé pour éviter créations multiples)
final Logger _logger = Logger();

// Extensions
extension ContextExtension on BuildContext {
  // Theme extensions
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // context to ctx
  BuildContext get ctx => this;

  // Media Query extensions
  MediaQueryData get mq => MediaQuery.of(this);
  double get screenHeight => mq.size.height;
  double get screenWidth => mq.size.width;

  // Padding and spacing
  double get defaultSpacing => AppSizes.s16;
  EdgeInsets get defaultPadding => const EdgeInsets.all(AppSizes.s16);

  // Logger (singleton optimisé)
  Logger get logger => _logger;

  // Navigation helpers
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(
        MaterialPageRoute(builder: (context) => page),
      );
  Future<T?> pushNamed<T>(String route, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(route, arguments: arguments);

  // pushReplacement
  Future<T?> noGoPushReplacement<T, TO>(Widget page) =>
      Navigator.of(this).pushReplacement<T, TO>(
        MaterialPageRoute<T>(builder: (context) => page),
      );

  // Snackbar helper
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? errorColor : successColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSizes.s16),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.s16,
          vertical: AppSizes.s12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.s8),
        ),
      ),
    );
  }
}

// Common type definitions
typedef JSON = Map<String, dynamic>;
typedef QueryParams = Map<String, String>;
typedef HeaderParams = Map<String, String>;

// Common constants
const kDefaultAnimationDuration = Duration(milliseconds: 300);

// Common styles - using static colors for compile-time constants
const _textPrimaryColor = Color(0xFF212121);
const _textSecondaryColor = Color(0xFF757575);

const kHeadlineStyle = TextStyle(
  fontSize: AppSizes.s24,
  fontWeight: FontWeight.bold,
  color: _textPrimaryColor,
);

const kTitleStyle = TextStyle(
  fontSize: AppSizes.s18,
  fontWeight: FontWeight.w600,
  color: _textPrimaryColor,
);

const kSubtitleStyle = TextStyle(
  fontSize: AppSizes.s16,
  fontWeight: FontWeight.w500,
  color: _textSecondaryColor,
);

const kBodyStyle = TextStyle(
  fontSize: AppSizes.s14,
  color: _textPrimaryColor,
);

const kBodyStyleBold = TextStyle(
  fontSize: AppSizes.s14,
  fontWeight: FontWeight.bold,
  color: _textPrimaryColor,
);

const kCaptionStyle = TextStyle(
  fontSize: AppSizes.s12,
  color: _textSecondaryColor,
);

// Common decorations - using static colors for runtime constants
const _surfaceColor = Color(0xFFFFFFFF);
const _primaryColor = Color(0xFF2E7D32);

final kDefaultInputDecoration = InputDecoration(
  filled: true,
  fillColor: _surfaceColor,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSizes.s8),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSizes.s8),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSizes.s8),
    borderSide: const BorderSide(color: _primaryColor, width: 2),
  ),
  contentPadding: const EdgeInsets.symmetric(
    horizontal: AppSizes.s16,
    vertical: AppSizes.s12,
  ),
);

// Common button styles
final kDefaultButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: _primaryColor,
  foregroundColor: _textPrimaryColor,
  padding: const EdgeInsets.symmetric(
    horizontal: AppSizes.s24,
    vertical: AppSizes.s12,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSizes.s8),
  ),
);

final kSecondaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: _surfaceColor,
  foregroundColor: _textPrimaryColor,
  padding: const EdgeInsets.symmetric(
    horizontal: AppSizes.s24,
    vertical: AppSizes.s12,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSizes.s8),
    side: const BorderSide(color: _primaryColor, width: 1),
  ),
);