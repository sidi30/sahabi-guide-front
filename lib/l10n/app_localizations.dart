import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('fr')
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
