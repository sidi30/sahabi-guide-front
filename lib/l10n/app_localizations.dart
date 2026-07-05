import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ha.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('ha')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Sahabi Guide'**
  String get appTitle;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get common_previous;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_rituals.
  ///
  /// In en, this message translates to:
  /// **'Rituals'**
  String get nav_rituals;

  /// No description provided for @nav_map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get nav_map;

  /// No description provided for @nav_videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get nav_videos;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @nav_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get nav_health;

  /// No description provided for @nav_connectivity.
  ///
  /// In en, this message translates to:
  /// **'Connectivity'**
  String get nav_connectivity;

  /// No description provided for @home_greeting_morning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get home_greeting_morning;

  /// No description provided for @home_greeting_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get home_greeting_afternoon;

  /// No description provided for @home_greeting_evening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get home_greeting_evening;

  /// No description provided for @home_peace_message.
  ///
  /// In en, this message translates to:
  /// **'Peace be upon you'**
  String get home_peace_message;

  /// No description provided for @home_prayers_title.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Prayers'**
  String get home_prayers_title;

  /// No description provided for @home_current_prayer.
  ///
  /// In en, this message translates to:
  /// **'Current prayer'**
  String get home_current_prayer;

  /// No description provided for @home_next_prayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get home_next_prayer;

  /// No description provided for @home_features_title.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get home_features_title;

  /// No description provided for @auth_login_title.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login_title;

  /// No description provided for @auth_passport_number.
  ///
  /// In en, this message translates to:
  /// **'Passport number'**
  String get auth_passport_number;

  /// No description provided for @auth_otp_code.
  ///
  /// In en, this message translates to:
  /// **'OTP code'**
  String get auth_otp_code;

  /// No description provided for @auth_verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get auth_verify;

  /// No description provided for @auth_resend_code.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get auth_resend_code;

  /// No description provided for @auth_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get auth_logout;

  /// No description provided for @auth_login_success.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get auth_login_success;

  /// No description provided for @auth_error.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get auth_error;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_personal_info.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get profile_personal_info;

  /// No description provided for @profile_qr_code.
  ///
  /// In en, this message translates to:
  /// **'My QR Code'**
  String get profile_qr_code;

  /// No description provided for @profile_qr_share.
  ///
  /// In en, this message translates to:
  /// **'Share my information'**
  String get profile_qr_share;

  /// No description provided for @profile_emergency_contact.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get profile_emergency_contact;

  /// No description provided for @health_title.
  ///
  /// In en, this message translates to:
  /// **'Health Profile'**
  String get health_title;

  /// No description provided for @health_medical_profile.
  ///
  /// In en, this message translates to:
  /// **'Medical Profile'**
  String get health_medical_profile;

  /// No description provided for @health_secured_info.
  ///
  /// In en, this message translates to:
  /// **'Secured medical information'**
  String get health_secured_info;

  /// No description provided for @health_encrypted_data.
  ///
  /// In en, this message translates to:
  /// **'Encrypted and synchronized data'**
  String get health_encrypted_data;

  /// No description provided for @health_blood_group.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get health_blood_group;

  /// No description provided for @health_blood_group_required.
  ///
  /// In en, this message translates to:
  /// **'Blood group required'**
  String get health_blood_group_required;

  /// No description provided for @health_allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get health_allergies;

  /// No description provided for @health_allergies_hint.
  ///
  /// In en, this message translates to:
  /// **'List your known allergies'**
  String get health_allergies_hint;

  /// No description provided for @health_conditions.
  ///
  /// In en, this message translates to:
  /// **'Medical conditions'**
  String get health_conditions;

  /// No description provided for @health_medications.
  ///
  /// In en, this message translates to:
  /// **'Current medications'**
  String get health_medications;

  /// No description provided for @health_medications_hint.
  ///
  /// In en, this message translates to:
  /// **'List your current medications'**
  String get health_medications_hint;

  /// No description provided for @health_emergency_contact.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get health_emergency_contact;

  /// No description provided for @health_emergency_contact_required.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact required'**
  String get health_emergency_contact_required;

  /// No description provided for @health_emergency_name.
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get health_emergency_name;

  /// No description provided for @health_emergency_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get health_emergency_phone;

  /// No description provided for @health_emergency_phone_required.
  ///
  /// In en, this message translates to:
  /// **'Phone number required'**
  String get health_emergency_phone_required;

  /// No description provided for @health_notes.
  ///
  /// In en, this message translates to:
  /// **'Medical notes'**
  String get health_notes;

  /// No description provided for @health_notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Additional medical information'**
  String get health_notes_hint;

  /// No description provided for @health_qr_code.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get health_qr_code;

  /// No description provided for @health_qr_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get health_qr_share;

  /// No description provided for @health_emergency_call.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get health_emergency_call;

  /// No description provided for @health_call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get health_call;

  /// No description provided for @health_save_success.
  ///
  /// In en, this message translates to:
  /// **'Medical profile saved successfully'**
  String get health_save_success;

  /// No description provided for @health_save_error.
  ///
  /// In en, this message translates to:
  /// **'Error while saving'**
  String get health_save_error;

  /// No description provided for @health_qr_code_title.
  ///
  /// In en, this message translates to:
  /// **'Medical QR Code'**
  String get health_qr_code_title;

  /// No description provided for @health_qr_code_description.
  ///
  /// In en, this message translates to:
  /// **'This QR code contains your essential medical information for emergencies.'**
  String get health_qr_code_description;

  /// No description provided for @health_emergency_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Emergency Call'**
  String get health_emergency_dialog_title;

  /// No description provided for @health_emergency_dialog_message.
  ///
  /// In en, this message translates to:
  /// **'Do you want to call emergency services?\n\nNumber: 15 (SAMU)'**
  String get health_emergency_dialog_message;

  /// No description provided for @health_add_allergy.
  ///
  /// In en, this message translates to:
  /// **'Add an allergy'**
  String get health_add_allergy;

  /// No description provided for @health_add_condition.
  ///
  /// In en, this message translates to:
  /// **'Add a condition'**
  String get health_add_condition;

  /// No description provided for @health_add_medication.
  ///
  /// In en, this message translates to:
  /// **'Add a medication'**
  String get health_add_medication;

  /// No description provided for @health_no_items.
  ///
  /// In en, this message translates to:
  /// **'No items added'**
  String get health_no_items;

  /// No description provided for @health_privacy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get health_privacy_title;

  /// No description provided for @health_privacy_message.
  ///
  /// In en, this message translates to:
  /// **'Your medical information is stored securely and encrypted. It is only shared in emergencies with your consent.'**
  String get health_privacy_message;

  /// No description provided for @contact_title.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contact_title;

  /// No description provided for @contact_full_name.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get contact_full_name;

  /// No description provided for @contact_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contact_email;

  /// No description provided for @contact_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get contact_category;

  /// No description provided for @contact_subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get contact_subject;

  /// No description provided for @contact_message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contact_message;

  /// No description provided for @contact_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get contact_send;

  /// No description provided for @contact_sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get contact_sending;

  /// No description provided for @contact_success_title.
  ///
  /// In en, this message translates to:
  /// **'Message sent!'**
  String get contact_success_title;

  /// No description provided for @contact_success_message.
  ///
  /// In en, this message translates to:
  /// **'We have received your message. Our team will respond to you as soon as possible.'**
  String get contact_success_message;

  /// No description provided for @contact_category_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get contact_category_general;

  /// No description provided for @contact_category_technical.
  ///
  /// In en, this message translates to:
  /// **'Technical issue'**
  String get contact_category_technical;

  /// No description provided for @contact_category_account.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get contact_category_account;

  /// No description provided for @contact_category_rituals.
  ///
  /// In en, this message translates to:
  /// **'Hajj rituals'**
  String get contact_category_rituals;

  /// No description provided for @contact_category_health.
  ///
  /// In en, this message translates to:
  /// **'Health & Emergency'**
  String get contact_category_health;

  /// No description provided for @contact_category_group.
  ///
  /// In en, this message translates to:
  /// **'My group'**
  String get contact_category_group;

  /// No description provided for @contact_category_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get contact_category_other;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_notifications_description.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get settings_notifications_description;

  /// No description provided for @settings_language_theme.
  ///
  /// In en, this message translates to:
  /// **'Language & Theme'**
  String get settings_language_theme;

  /// No description provided for @settings_language_theme_description.
  ///
  /// In en, this message translates to:
  /// **'Customize interface'**
  String get settings_language_theme_description;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settings_privacy;

  /// No description provided for @settings_privacy_description.
  ///
  /// In en, this message translates to:
  /// **'Protect your data'**
  String get settings_privacy_description;

  /// No description provided for @settings_help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settings_help;

  /// No description provided for @settings_help_description.
  ///
  /// In en, this message translates to:
  /// **'Help center and FAQ'**
  String get settings_help_description;

  /// No description provided for @settings_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get settings_contact;

  /// No description provided for @settings_contact_description.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get settings_contact_description;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_about_description.
  ///
  /// In en, this message translates to:
  /// **'Application information'**
  String get settings_about_description;

  /// No description provided for @settings_theme_mode.
  ///
  /// In en, this message translates to:
  /// **'Display mode'**
  String get settings_theme_mode;

  /// No description provided for @settings_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_theme_system;

  /// No description provided for @settings_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_dark;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_audio_language.
  ///
  /// In en, this message translates to:
  /// **'Audio language'**
  String get settings_audio_language;

  /// No description provided for @settings_language_french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get settings_language_french;

  /// No description provided for @settings_language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_language_english;

  /// No description provided for @settings_language_arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settings_language_arabic;

  /// No description provided for @settings_audio_hausa.
  ///
  /// In en, this message translates to:
  /// **'Hausa'**
  String get settings_audio_hausa;

  /// No description provided for @settings_audio_zarma.
  ///
  /// In en, this message translates to:
  /// **'Zarma'**
  String get settings_audio_zarma;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @notifications_all_enabled.
  ///
  /// In en, this message translates to:
  /// **'All notifications'**
  String get notifications_all_enabled;

  /// No description provided for @notifications_all_enabled_description.
  ///
  /// In en, this message translates to:
  /// **'Enable/disable all notifications'**
  String get notifications_all_enabled_description;

  /// No description provided for @notifications_push.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get notifications_push;

  /// No description provided for @notifications_push_description.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications on your device'**
  String get notifications_push_description;

  /// No description provided for @notifications_sound.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get notifications_sound;

  /// No description provided for @notifications_sound_description.
  ///
  /// In en, this message translates to:
  /// **'Play sound on receipt'**
  String get notifications_sound_description;

  /// No description provided for @notifications_vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibrations'**
  String get notifications_vibration;

  /// No description provided for @notifications_vibration_description.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on receipt'**
  String get notifications_vibration_description;

  /// No description provided for @notifications_emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency alerts'**
  String get notifications_emergency;

  /// No description provided for @notifications_emergency_description.
  ///
  /// In en, this message translates to:
  /// **'Important and urgent alerts'**
  String get notifications_emergency_description;

  /// No description provided for @notifications_prayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminders'**
  String get notifications_prayer;

  /// No description provided for @notifications_prayer_description.
  ///
  /// In en, this message translates to:
  /// **'Prayer time notifications'**
  String get notifications_prayer_description;

  /// No description provided for @notifications_ritual.
  ///
  /// In en, this message translates to:
  /// **'Ritual reminders'**
  String get notifications_ritual;

  /// No description provided for @notifications_ritual_description.
  ///
  /// In en, this message translates to:
  /// **'Hajj ritual notifications'**
  String get notifications_ritual_description;

  /// No description provided for @notifications_group.
  ///
  /// In en, this message translates to:
  /// **'Group messages'**
  String get notifications_group;

  /// No description provided for @notifications_group_description.
  ///
  /// In en, this message translates to:
  /// **'Group message notifications'**
  String get notifications_group_description;

  /// No description provided for @notifications_health.
  ///
  /// In en, this message translates to:
  /// **'Health alerts'**
  String get notifications_health;

  /// No description provided for @notifications_health_description.
  ///
  /// In en, this message translates to:
  /// **'Health-related notifications'**
  String get notifications_health_description;

  /// No description provided for @notifications_updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get notifications_updates;

  /// No description provided for @notifications_updates_description.
  ///
  /// In en, this message translates to:
  /// **'Application update notifications'**
  String get notifications_updates_description;

  /// No description provided for @notifications_do_not_disturb.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb Mode'**
  String get notifications_do_not_disturb;

  /// No description provided for @notifications_do_not_disturb_enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled - Silent notifications'**
  String get notifications_do_not_disturb_enabled;

  /// No description provided for @notifications_do_not_disturb_disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled - Normal notifications'**
  String get notifications_do_not_disturb_disabled;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get error_network;

  /// No description provided for @error_server.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get error_server;

  /// No description provided for @error_authentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get error_authentication;

  /// No description provided for @error_not_found.
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get error_not_found;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get error_unknown;

  /// No description provided for @splash_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splash_loading;

  /// No description provided for @splash_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get splash_skip;

  /// No description provided for @splash_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sahabi Guide'**
  String get splash_welcome;

  /// No description provided for @assistant_title.
  ///
  /// In en, this message translates to:
  /// **'Sahabi Assistant'**
  String get assistant_title;

  /// No description provided for @assistant_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m your Sahabi assistant. How can I help you?'**
  String get assistant_greeting;

  /// No description provided for @assistant_input_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Ask your question...'**
  String get assistant_input_placeholder;

  /// No description provided for @assistant_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get assistant_send;

  /// No description provided for @assistant_thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get assistant_thinking;

  /// Label for the button that reads a bot message aloud
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get bot_listen;

  /// Label for the button that stops the voice playback
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get bot_stop;

  /// Button that opens the related ritual detail page
  ///
  /// In en, this message translates to:
  /// **'View ritual'**
  String get bot_view_ritual;

  /// Label preceding a RAG citation title under a bot answer
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get bot_source;

  /// Subtle note shown when the bot answer is low confidence or abstained
  ///
  /// In en, this message translates to:
  /// **'Uncertain answer — please verify with a scholar.'**
  String get bot_low_confidence;

  /// Placeholder of the bot chat text field
  ///
  /// In en, this message translates to:
  /// **'Ask a question or use the mic'**
  String get bot_input_hint;

  /// Placeholder shown while the mic is capturing speech
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get bot_listening;

  /// Tooltip/label for the assistant language selector
  ///
  /// In en, this message translates to:
  /// **'Assistant language'**
  String get bot_language;

  /// Hausa language display name
  ///
  /// In en, this message translates to:
  /// **'Hausa'**
  String get settings_language_hausa;

  /// Header above the quick-reply chips in the bot chat
  ///
  /// In en, this message translates to:
  /// **'Suggested replies'**
  String get bot_suggested_replies;

  /// Subtle banner shown while the chat history is being translated after a language switch
  ///
  /// In en, this message translates to:
  /// **'Translating the conversation...'**
  String get bot_translating;

  /// Quick reply: ask another question
  ///
  /// In en, this message translates to:
  /// **'Another question'**
  String get qr_other_question;

  /// Quick reply: continue the conversation
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get qr_continue;

  /// Quick reply: acknowledge a help message
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get qr_understood;

  /// Quick reply: retry after a service error
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get qr_retry;

  /// Quick reply: praise at the end of the Hajj flow
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get qr_alhamdulillah;

  /// Quick reply: restart the conversation from the beginning
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get qr_restart;

  /// Notification title when a ritual is due to start
  ///
  /// In en, this message translates to:
  /// **'Hajj Ritual'**
  String get notif_ritual_title;

  /// Notification body when a ritual is due
  ///
  /// In en, this message translates to:
  /// **'It\'s time to begin: {name}'**
  String notif_ritual_start_body(String name);

  /// Notification title for the 30-minute-before reminder
  ///
  /// In en, this message translates to:
  /// **'Reminder - Hajj Ritual'**
  String get notif_ritual_reminder_title;

  /// Notification body for the 30-minute-before reminder
  ///
  /// In en, this message translates to:
  /// **'Get ready for: {name} in 30 minutes'**
  String notif_ritual_reminder_body(String name);

  /// Notification title when a ritual is overdue
  ///
  /// In en, this message translates to:
  /// **'Overdue ritual'**
  String get notif_ritual_overdue_title;

  /// Notification body when a ritual is overdue
  ///
  /// In en, this message translates to:
  /// **'You missed: {name}. Mark it as done if completed.'**
  String notif_ritual_overdue_body(String name);

  /// Immediate notification title when a ritual is active
  ///
  /// In en, this message translates to:
  /// **'Active ritual'**
  String get notif_ritual_active_title;

  /// Immediate notification body when a ritual is active
  ///
  /// In en, this message translates to:
  /// **'You are performing: {name}'**
  String notif_ritual_active_body(String name);

  /// Title of the proactive reminder scheduled after a ritual step's estimated duration
  ///
  /// In en, this message translates to:
  /// **'Reminder: {name}'**
  String notif_ritual_step_reminder_title(String name);

  /// Body of the proactive reminder scheduled after a ritual step's estimated duration
  ///
  /// In en, this message translates to:
  /// **'{name} - Have you completed this ritual? Open the assistant to confirm.'**
  String notif_ritual_step_reminder_body(String name);

  /// Notification title for daily prayer reminders
  ///
  /// In en, this message translates to:
  /// **'Prayer time'**
  String get notif_prayer_title;

  /// Notification body for daily prayer reminders
  ///
  /// In en, this message translates to:
  /// **'{name} — {time}. Have you prayed?'**
  String notif_prayer_body(String name, String time);

  /// Notification title for the morning dua reminder
  ///
  /// In en, this message translates to:
  /// **'Morning dua'**
  String get notif_dua_morning_title;

  /// Notification title for the evening dua reminder
  ///
  /// In en, this message translates to:
  /// **'Evening dua'**
  String get notif_dua_evening_title;

  /// Notification body for daily dua reminders
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to recite: {name}'**
  String notif_dua_body(String name);

  /// Immediate notification title for a recommended dua
  ///
  /// In en, this message translates to:
  /// **'Recommended dua'**
  String get notif_dua_recommended_title;

  /// Immediate notification body for a recommended dua
  ///
  /// In en, this message translates to:
  /// **'Recite now: {name}'**
  String notif_dua_recommended_body(String name);

  /// No description provided for @map_title.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map_title;

  /// No description provided for @map_my_position.
  ///
  /// In en, this message translates to:
  /// **'My position'**
  String get map_my_position;

  /// No description provided for @map_group_position.
  ///
  /// In en, this message translates to:
  /// **'Group position'**
  String get map_group_position;

  /// No description provided for @map_poi.
  ///
  /// In en, this message translates to:
  /// **'Points of interest'**
  String get map_poi;

  /// No description provided for @map_zoom_in.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get map_zoom_in;

  /// No description provided for @map_zoom_out.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get map_zoom_out;

  /// No description provided for @map_center.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get map_center;

  /// No description provided for @rituals_title.
  ///
  /// In en, this message translates to:
  /// **'Hajj Rituals'**
  String get rituals_title;

  /// No description provided for @rituals_in_progress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get rituals_in_progress;

  /// No description provided for @rituals_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get rituals_completed;

  /// No description provided for @rituals_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get rituals_pending;

  /// No description provided for @rituals_mark_complete.
  ///
  /// In en, this message translates to:
  /// **'Mark as complete'**
  String get rituals_mark_complete;

  /// No description provided for @rituals_details.
  ///
  /// In en, this message translates to:
  /// **'Ritual details'**
  String get rituals_details;

  /// No description provided for @videos_title.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos_title;

  /// No description provided for @videos_educational.
  ///
  /// In en, this message translates to:
  /// **'Educational'**
  String get videos_educational;

  /// No description provided for @videos_tutorials.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get videos_tutorials;

  /// No description provided for @videos_play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get videos_play;

  /// No description provided for @videos_pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get videos_pause;

  /// No description provided for @accessibility_logo.
  ///
  /// In en, this message translates to:
  /// **'Sahabi Guide logo'**
  String get accessibility_logo;

  /// No description provided for @accessibility_bot_avatar.
  ///
  /// In en, this message translates to:
  /// **'Assistant avatar'**
  String get accessibility_bot_avatar;

  /// No description provided for @accessibility_user_avatar.
  ///
  /// In en, this message translates to:
  /// **'User avatar'**
  String get accessibility_user_avatar;

  /// No description provided for @accessibility_close_button.
  ///
  /// In en, this message translates to:
  /// **'Close button'**
  String get accessibility_close_button;

  /// No description provided for @accessibility_back_button.
  ///
  /// In en, this message translates to:
  /// **'Back button'**
  String get accessibility_back_button;

  /// No description provided for @accessibility_menu_button.
  ///
  /// In en, this message translates to:
  /// **'Menu button'**
  String get accessibility_menu_button;

  /// No description provided for @accessibility_settings_button.
  ///
  /// In en, this message translates to:
  /// **'Settings button'**
  String get accessibility_settings_button;

  /// No description provided for @accessibility_navigation_home.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get accessibility_navigation_home;

  /// No description provided for @accessibility_navigation_rituals.
  ///
  /// In en, this message translates to:
  /// **'Go to rituals'**
  String get accessibility_navigation_rituals;

  /// No description provided for @accessibility_navigation_map.
  ///
  /// In en, this message translates to:
  /// **'Go to map'**
  String get accessibility_navigation_map;

  /// No description provided for @accessibility_navigation_videos.
  ///
  /// In en, this message translates to:
  /// **'Go to videos'**
  String get accessibility_navigation_videos;

  /// No description provided for @accessibility_navigation_profile.
  ///
  /// In en, this message translates to:
  /// **'Go to profile'**
  String get accessibility_navigation_profile;

  /// No description provided for @accessibility_open_assistant.
  ///
  /// In en, this message translates to:
  /// **'Open assistant'**
  String get accessibility_open_assistant;

  /// No description provided for @accessibility_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get accessibility_loading;

  /// No description provided for @accessibility_image_loading.
  ///
  /// In en, this message translates to:
  /// **'Image loading'**
  String get accessibility_image_loading;

  /// No description provided for @accessibility_video_player.
  ///
  /// In en, this message translates to:
  /// **'Video player'**
  String get accessibility_video_player;

  /// No description provided for @accessibility_qr_code.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get accessibility_qr_code;

  /// No description provided for @accessibility_notification_toggle.
  ///
  /// In en, this message translates to:
  /// **'Toggle notifications'**
  String get accessibility_notification_toggle;

  /// No description provided for @group_title.
  ///
  /// In en, this message translates to:
  /// **'My Group'**
  String get group_title;

  /// No description provided for @group_members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get group_members;

  /// No description provided for @group_guide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get group_guide;

  /// No description provided for @group_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get group_status;

  /// No description provided for @group_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get group_location;

  /// No description provided for @emergency_title.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency_title;

  /// No description provided for @emergency_call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get emergency_call;

  /// No description provided for @emergency_sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get emergency_sos;

  /// No description provided for @emergency_medical.
  ///
  /// In en, this message translates to:
  /// **'Medical emergency'**
  String get emergency_medical;

  /// No description provided for @emergency_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get emergency_security;

  /// No description provided for @connectivity_title.
  ///
  /// In en, this message translates to:
  /// **'Connectivity'**
  String get connectivity_title;

  /// No description provided for @connectivity_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get connectivity_status;

  /// No description provided for @connectivity_connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectivity_connected;

  /// No description provided for @connectivity_disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get connectivity_disconnected;

  /// No description provided for @connectivity_esim.
  ///
  /// In en, this message translates to:
  /// **'eSIM'**
  String get connectivity_esim;

  /// No description provided for @connectivity_plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get connectivity_plans;

  /// No description provided for @bot_app_title.
  ///
  /// In en, this message translates to:
  /// **'Hajj Assistant'**
  String get bot_app_title;

  /// No description provided for @bot_app_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guide'**
  String get bot_app_subtitle;

  /// No description provided for @bot_init_error.
  ///
  /// In en, this message translates to:
  /// **'Initialization error'**
  String get bot_init_error;

  /// No description provided for @bot_initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing assistant...'**
  String get bot_initializing;

  /// Progress badge above the chat
  ///
  /// In en, this message translates to:
  /// **'Progress: {percent}%'**
  String bot_progress_percent(int percent);

  /// No description provided for @bot_hajj_completed.
  ///
  /// In en, this message translates to:
  /// **'🎉 Congratulations! Hajj completed'**
  String get bot_hajj_completed;

  /// No description provided for @bot_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your\nHajj guide! 🕋'**
  String get bot_welcome_title;

  /// No description provided for @bot_welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'I\'ll guide you step by step\nthroughout your pilgrimage'**
  String get bot_welcome_subtitle;

  /// No description provided for @bot_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get bot_start;

  /// No description provided for @bot_restart_title.
  ///
  /// In en, this message translates to:
  /// **'Restart?'**
  String get bot_restart_title;

  /// No description provided for @bot_restart_message.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to restart the conversation from the beginning?'**
  String get bot_restart_message;

  /// No description provided for @bot_restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get bot_restart;

  /// No description provided for @bot_statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get bot_statistics;

  /// No description provided for @bot_stats_title.
  ///
  /// In en, this message translates to:
  /// **'📊 Statistics'**
  String get bot_stats_title;

  /// No description provided for @bot_stats_progress.
  ///
  /// In en, this message translates to:
  /// **'📈 Progress'**
  String get bot_stats_progress;

  /// No description provided for @bot_stats_current_step.
  ///
  /// In en, this message translates to:
  /// **'Current step'**
  String get bot_stats_current_step;

  /// No description provided for @bot_stats_step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get bot_stats_step;

  /// No description provided for @bot_stats_progress_row.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get bot_stats_progress_row;

  /// No description provided for @bot_stats_messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get bot_stats_messages;

  /// No description provided for @bot_stats_gps.
  ///
  /// In en, this message translates to:
  /// **'📍 GPS location'**
  String get bot_stats_gps;

  /// No description provided for @bot_stats_current_location.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get bot_stats_current_location;

  /// No description provided for @bot_stats_not_detected.
  ///
  /// In en, this message translates to:
  /// **'Not detected'**
  String get bot_stats_not_detected;

  /// No description provided for @bot_stats_in_holy_place.
  ///
  /// In en, this message translates to:
  /// **'In a holy place'**
  String get bot_stats_in_holy_place;

  /// No description provided for @bot_stats_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes ✅'**
  String get bot_stats_yes;

  /// No description provided for @bot_stats_suggested_duas.
  ///
  /// In en, this message translates to:
  /// **'Suggested duas'**
  String get bot_stats_suggested_duas;

  /// No description provided for @bot_stats_urgent_reminders.
  ///
  /// In en, this message translates to:
  /// **'Urgent reminders'**
  String get bot_stats_urgent_reminders;

  /// No description provided for @bot_history_title.
  ///
  /// In en, this message translates to:
  /// **'My previous questions'**
  String get bot_history_title;

  /// No description provided for @bot_history_empty.
  ///
  /// In en, this message translates to:
  /// **'No questions asked yet.'**
  String get bot_history_empty;

  /// No description provided for @bot_my_questions.
  ///
  /// In en, this message translates to:
  /// **'My questions'**
  String get bot_my_questions;

  /// No description provided for @bot_more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get bot_more;

  /// No description provided for @bot_handsfree_on_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Hands-free mode on (disable)'**
  String get bot_handsfree_on_tooltip;

  /// No description provided for @bot_handsfree_off_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Enable continuous voice conversation'**
  String get bot_handsfree_off_tooltip;

  /// No description provided for @bot_handsfree_on.
  ///
  /// In en, this message translates to:
  /// **'🎙️ Continuous conversation mode enabled'**
  String get bot_handsfree_on;

  /// No description provided for @bot_handsfree_off.
  ///
  /// In en, this message translates to:
  /// **'Continuous conversation mode disabled'**
  String get bot_handsfree_off;

  /// Snackbar shown when TTS fails
  ///
  /// In en, this message translates to:
  /// **'🔊 Voice playback unavailable: {error}'**
  String bot_tts_unavailable(String error);

  /// No description provided for @bot_stt_no_internet.
  ///
  /// In en, this message translates to:
  /// **'📡 No internet — voice recognition requires a connection (even on an emulator)'**
  String get bot_stt_no_internet;

  /// No description provided for @bot_stt_network_slow.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Network too slow for voice recognition'**
  String get bot_stt_network_slow;

  /// No description provided for @bot_stt_no_match.
  ///
  /// In en, this message translates to:
  /// **'🤔 I didn\'t understand, please try speaking more clearly'**
  String get bot_stt_no_match;

  /// No description provided for @bot_stt_speech_timeout.
  ///
  /// In en, this message translates to:
  /// **'⏱️ No voice detected. Try again by speaking after tapping the mic'**
  String get bot_stt_speech_timeout;

  /// No description provided for @bot_stt_audio.
  ///
  /// In en, this message translates to:
  /// **'🎙️ Mic problem. Check permissions in Android Settings'**
  String get bot_stt_audio;

  /// No description provided for @bot_stt_client.
  ///
  /// In en, this message translates to:
  /// **'❌ Voice recognition client error'**
  String get bot_stt_client;

  /// No description provided for @bot_stt_server.
  ///
  /// In en, this message translates to:
  /// **'❌ Google Speech server unavailable'**
  String get bot_stt_server;

  /// No description provided for @bot_stt_busy.
  ///
  /// In en, this message translates to:
  /// **'Recognition already in progress, please wait...'**
  String get bot_stt_busy;

  /// No description provided for @bot_stt_permission.
  ///
  /// In en, this message translates to:
  /// **'🔒 Mic permission denied. Allow it in Android Settings'**
  String get bot_stt_permission;

  /// Fallback STT error message
  ///
  /// In en, this message translates to:
  /// **'Voice error: {error}'**
  String bot_stt_generic(String error);

  /// No description provided for @bot_stt_device_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice recognition unavailable on this device'**
  String get bot_stt_device_unavailable;

  /// No description provided for @bot_svc_welcome_intro.
  ///
  /// In en, this message translates to:
  /// **'🕋 As-salamu alaykum! I am your personal Hajj assistant.'**
  String get bot_svc_welcome_intro;

  /// Welcome line shown when the pilgrim is at a holy place
  ///
  /// In en, this message translates to:
  /// **'📍 I see that you are at {location}!'**
  String bot_svc_welcome_location(String location);

  /// No description provided for @bot_svc_welcome_guide.
  ///
  /// In en, this message translates to:
  /// **'I\'ll guide you step by step through all the rituals. Just answer the questions and I\'ll be with you! 🤲'**
  String get bot_svc_welcome_guide;

  /// No description provided for @bot_svc_urgent_reminders.
  ///
  /// In en, this message translates to:
  /// **'⚠️ URGENT REMINDERS:'**
  String get bot_svc_urgent_reminders;

  /// No description provided for @bot_svc_recommended_duas.
  ///
  /// In en, this message translates to:
  /// **'🤲 RECOMMENDED DUAS:'**
  String get bot_svc_recommended_duas;

  /// No description provided for @bot_svc_ai_response.
  ///
  /// In en, this message translates to:
  /// **'💡 AI answer'**
  String get bot_svc_ai_response;

  /// No description provided for @bot_svc_ai_enriched.
  ///
  /// In en, this message translates to:
  /// **'💡 Answer enriched by AI'**
  String get bot_svc_ai_enriched;

  /// No description provided for @bot_svc_ai_generated.
  ///
  /// In en, this message translates to:
  /// **'💡 Answer generated by AI'**
  String get bot_svc_ai_generated;

  /// No description provided for @bot_svc_help_more.
  ///
  /// In en, this message translates to:
  /// **'💡 Here is some additional information:'**
  String get bot_svc_help_more;

  /// No description provided for @bot_svc_help_see_rituals.
  ///
  /// In en, this message translates to:
  /// **'Check the Rituals section for more details.'**
  String get bot_svc_help_see_rituals;

  /// No description provided for @bot_svc_end.
  ///
  /// In en, this message translates to:
  /// **'🎉 Masha\'Allah! You have completed all the steps of the Hajj!\n\n✨ Hajj Mabrour wa Sa\'y Mashkour!\n\nMay Allah accept your Hajj and your good deeds. Feel free to come back if you have any questions. 🤲'**
  String get bot_svc_end;

  /// No description provided for @bot_svc_ai_unavailable.
  ///
  /// In en, this message translates to:
  /// **'⚠️ The AI service is temporarily unavailable. Please try again.'**
  String get bot_svc_ai_unavailable;

  /// No description provided for @bot_svc_no_answer.
  ///
  /// In en, this message translates to:
  /// **'🤔 I couldn\'t find an exact answer to your question.\n\nYou can:\n- Rephrase your question\n- Check the \"Rituals\" section\n- Ask a more general question'**
  String get bot_svc_no_answer;

  /// No description provided for @bot_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Bot Settings'**
  String get bot_settings_title;

  /// Generic error snackbar in bot settings
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String bot_settings_error(String error);

  /// No description provided for @bot_settings_llm_saved.
  ///
  /// In en, this message translates to:
  /// **'✅ AI settings saved'**
  String get bot_settings_llm_saved;

  /// No description provided for @bot_settings_notif_saved.
  ///
  /// In en, this message translates to:
  /// **'✅ Notification settings saved'**
  String get bot_settings_notif_saved;

  /// No description provided for @bot_settings_clear_title.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Confirm'**
  String get bot_settings_clear_title;

  /// No description provided for @bot_settings_clear_message.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to erase all conversation history?\n\nThis action is irreversible.'**
  String get bot_settings_clear_message;

  /// No description provided for @bot_settings_clear_action.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get bot_settings_clear_action;

  /// No description provided for @bot_settings_history_cleared.
  ///
  /// In en, this message translates to:
  /// **'✅ History erased'**
  String get bot_settings_history_cleared;

  /// No description provided for @bot_settings_section_ai.
  ///
  /// In en, this message translates to:
  /// **'🤖 Artificial Intelligence (optional)'**
  String get bot_settings_section_ai;

  /// No description provided for @bot_settings_section_notifications.
  ///
  /// In en, this message translates to:
  /// **'🔔 Notifications'**
  String get bot_settings_section_notifications;

  /// No description provided for @bot_settings_section_storage.
  ///
  /// In en, this message translates to:
  /// **'💾 Storage'**
  String get bot_settings_section_storage;

  /// No description provided for @bot_settings_enable_ai.
  ///
  /// In en, this message translates to:
  /// **'Enable enriched AI'**
  String get bot_settings_enable_ai;

  /// No description provided for @bot_settings_enable_ai_desc.
  ///
  /// In en, this message translates to:
  /// **'The copilot sends your question to Google Gemini (Google LLC, USA) via our server, over HTTPS, to generate the answer. No identity data is sent. See the privacy policy.'**
  String get bot_settings_enable_ai_desc;

  /// No description provided for @bot_settings_sources_info.
  ///
  /// In en, this message translates to:
  /// **'Authenticated sources grounded on the server: Quran, Bukhari, Muslim, Tirmidhi, Abu Dawud, Nasai, Ibn Majah, Ibn Hanbal. Islam/Hajj topic filter applied upstream. Google does not retain the request.'**
  String get bot_settings_sources_info;

  /// No description provided for @bot_settings_enable_notifs.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get bot_settings_enable_notifs;

  /// No description provided for @bot_settings_enable_notifs_desc.
  ///
  /// In en, this message translates to:
  /// **'Receive reminders based on your GPS location'**
  String get bot_settings_enable_notifs_desc;

  /// No description provided for @bot_settings_clear_history.
  ///
  /// In en, this message translates to:
  /// **'Erase history'**
  String get bot_settings_clear_history;

  /// No description provided for @bot_settings_clear_history_desc.
  ///
  /// In en, this message translates to:
  /// **'Delete all saved conversations'**
  String get bot_settings_clear_history_desc;

  /// No description provided for @bot_settings_messages_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved messages'**
  String get bot_settings_messages_saved;

  /// No description provided for @bot_settings_preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get bot_settings_preferences;

  /// No description provided for @bot_consent_title.
  ///
  /// In en, this message translates to:
  /// **'Hajj AI Assistant'**
  String get bot_consent_title;

  /// No description provided for @bot_consent_intro.
  ///
  /// In en, this message translates to:
  /// **'The assistant only answers questions related to Hajj, Umrah and Islam. Other topics are filtered upstream.'**
  String get bot_consent_intro;

  /// No description provided for @bot_consent_data_sent.
  ///
  /// In en, this message translates to:
  /// **'Data sent to our server:'**
  String get bot_consent_data_sent;

  /// No description provided for @bot_consent_data_list.
  ///
  /// In en, this message translates to:
  /// **'• The text of your question\n• The chosen language (FR / EN / AR / HA)\n• The last messages of the current conversation'**
  String get bot_consent_data_list;

  /// No description provided for @bot_consent_no_identity.
  ///
  /// In en, this message translates to:
  /// **'No identity data (name, passport, phone, email, GPS location, health) is sent.'**
  String get bot_consent_no_identity;

  /// No description provided for @bot_consent_third_party.
  ///
  /// In en, this message translates to:
  /// **'Processing by a third-party AI service:'**
  String get bot_consent_third_party;

  /// No description provided for @bot_consent_third_party_desc.
  ///
  /// In en, this message translates to:
  /// **'To generate the answer, our server sends the question, over an encrypted HTTPS connection, to Google Gemini (Google LLC, USA). Google processes the request only to produce the answer and does not retain it to train its models (Google\'s commitment for the Gemini API).'**
  String get bot_consent_third_party_desc;

  /// No description provided for @bot_consent_refuse_note.
  ///
  /// In en, this message translates to:
  /// **'If you refuse, the assistant will run in limited local mode (preloaded answers, no AI).'**
  String get bot_consent_refuse_note;

  /// No description provided for @bot_consent_refuse.
  ///
  /// In en, this message translates to:
  /// **'Refuse'**
  String get bot_consent_refuse;

  /// No description provided for @bot_consent_accept.
  ///
  /// In en, this message translates to:
  /// **'I accept'**
  String get bot_consent_accept;

  /// No description provided for @bot_collapsed_hint.
  ///
  /// In en, this message translates to:
  /// **'Assistant tucked away. Tap the handle on the right to bring it back.'**
  String get bot_collapsed_hint;

  /// No description provided for @bot_translate_consent_note.
  ///
  /// In en, this message translates to:
  /// **'Enable the AI assistant to translate the conversation.'**
  String get bot_translate_consent_note;

  /// No description provided for @bot_translate_enable_ai.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get bot_translate_enable_ai;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr', 'ha'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
    case 'ha': return AppLocalizationsHa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
