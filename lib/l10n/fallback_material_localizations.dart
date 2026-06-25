import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// flutter_localizations ne fournit PAS de traductions Material/Cupertino pour
/// le haoussa (`ha`). Or notre app supporte `ha` comme langue d'interface.
/// Sans repli, `MaterialApp` lève une assertion au démarrage dès que la locale
/// vaut `ha` (« No GlobalMaterialLocalizations found »).
///
/// Ces délégués comblent le trou : pour la locale `ha`, ils renvoient les
/// localisations Material/Widgets/Cupertino ANGLAISES (les libellés système
/// rares — « OK », « Annuler » du sélecteur de date natif, etc.). Les chaînes
/// propres à l'app restent traduites en haoussa via [AppLocalizations].
///
/// Pour toute autre locale, `isSupported` renvoie `false` afin de laisser les
/// délégués globaux standards (Global*Localizations.delegate) gérer fr/en/ar.

const Locale _ha = Locale('ha');
const Locale _enFallback = Locale('en');

class HaMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const HaMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ha';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    // Charge les libellés Material anglais pour la locale haoussa.
    return GlobalMaterialLocalizations.delegate.load(_enFallback);
  }

  @override
  bool shouldReload(HaMaterialLocalizationsDelegate old) => false;
}

class HaCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const HaCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ha';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return GlobalCupertinoLocalizations.delegate.load(_enFallback);
  }

  @override
  bool shouldReload(HaCupertinoLocalizationsDelegate old) => false;
}

class HaWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const HaWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ha';

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    return GlobalWidgetsLocalizations.delegate.load(_enFallback);
  }

  @override
  bool shouldReload(HaWidgetsLocalizationsDelegate old) => false;
}

/// Liste prête à insérer dans `localizationsDelegates`, AVANT les délégués
/// globaux standards (l'ordre compte : le premier délégué dont `isSupported`
/// renvoie `true` l'emporte).
const List<LocalizationsDelegate<dynamic>> haFallbackLocalizationsDelegates = [
  HaMaterialLocalizationsDelegate(),
  HaWidgetsLocalizationsDelegate(),
  HaCupertinoLocalizationsDelegate(),
];

/// Référence pour éviter un warning « unused » si jamais la locale `_ha` n'est
/// pas utilisée directement ailleurs.
const Locale haLocale = _ha;
