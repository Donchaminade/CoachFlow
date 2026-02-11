import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

/// Base class for app localizations
abstract class AppLocalizations {
  // Auth
  String get signIn;
  String get signUp;
  String get email;
  String get password;
  String get name;
  String get createAccount;
  String get returnWithoutAccount;
  String get passwordTooWeak;
  String get emailInvalid;
  String get loginError;
  String get emailAlreadyUsed;
  String get tooManyAttempts;
  String get invalidCredentials;
  String get passwordRequired;
  String get emailRequired;
  String get nameRequired;
  String get atLeast6Chars;
  String get passwordStrengthTooWeak;
  String get passwordStrengthWeak;
  String get passwordStrengthMedium;
  String get passwordStrengthGood;
  String get passwordStrengthExcellent;
  String get connection;
  
  // Home
  String get myCoaches;
  String get conversations;
  String get settings;
  String get selectCoach;
  String get startConversation;
  String get welcome;
  
  // Chat
  String get typeMessage;
  String get send;
  String get listening;
  String get speaking;
  String get newConversation;
  String get deleteConversation;
  String get shareConversation;
  String get copyLink;
  String get conversationShared;
  
  // Settings
  String get settingsTitle;
  String get language;
  String get theme;
  String get security;
  String get darkMode;
  String get biometricLogin;
  String get logout;
  String get enableBiometric;
  String get disableBiometric;
  String get appearance;
  String get appLanguage;
  String get quickLogin;
  String get biometricEnabled;
  String get biometricDisabled;
  String get biometricNotAvailable;
  
  // Drawer
  String get history;
  String get allConversations;
  String get sharedConversations;
  String get receivedFromOthers;
  String get about;
  String get helpSupport;
  String get user;
  String get appVersion;
  String get appDescription;
  
  // Onboarding
  String get getStarted;
  String get skip;
  String get next;
  String get onboardingTitle1;
  String get onboardingDesc1;
  String get onboardingTitle2;
  String get onboardingDesc2;
  String get onboardingTitle3;
  String get onboardingDesc3;
  
  // Coaches
  String get chooseCoach;
  String get createCoach;
  String get coachName;
  String get coachRole;
  String get coachDescription;
  String get selectEmoji;
  
  // Common
  String get cancel;
  String get confirm;
  String get delete;
  String get save;
  String get edit;
  String get loading;
  String get error;
  String get success;
  String get yes;
  String get no;
  String get ok;
  
  // Static method to get localizations
  static AppLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    
    switch (locale.languageCode) {
      case 'fr':
        return AppLocalizationsFr();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }
  
  // Delegate for MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'fr':
        return AppLocalizationsFr();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
