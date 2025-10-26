import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../l10n/app_localizations.dart';

/// Extension on BuildContext to easily access localization
///
/// Example:
/// ```dart
/// context.l10n.appTitle
/// ```
extension LocalizationExtension on BuildContext {
  /// Returns the [AppLocalizations] instance for the current context.
  AppLocalizations? get l10n => AppLocalizations.of(this);
}

/// A list of supported locales for the app
const List<Locale> appSupportedLocales = [
  Locale('en'), // English
  Locale('fr'), // French
  Locale('ar'), // Arabic
];

/// The list of localization delegates for the app
final List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
