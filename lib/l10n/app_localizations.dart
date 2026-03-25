import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_az.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('az'),
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In az, this message translates to:
  /// **'Walvero Partner'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In az, this message translates to:
  /// **'Yüklənir...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In az, this message translates to:
  /// **'Xəta baş verdi'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In az, this message translates to:
  /// **'Yenidən cəhd et'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In az, this message translates to:
  /// **'Ləğv et'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In az, this message translates to:
  /// **'Təsdiqlə'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In az, this message translates to:
  /// **'Saxla'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In az, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In az, this message translates to:
  /// **'Axtar'**
  String get search;

  /// No description provided for @noData.
  ///
  /// In az, this message translates to:
  /// **'Məlumat yoxdur'**
  String get noData;

  /// No description provided for @success.
  ///
  /// In az, this message translates to:
  /// **'Uğurlu!'**
  String get success;

  /// No description provided for @loginTitle.
  ///
  /// In az, this message translates to:
  /// **'Daxil ol'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In az, this message translates to:
  /// **'Hesabınıza daxil olun'**
  String get loginSubtitle;

  /// No description provided for @userName.
  ///
  /// In az, this message translates to:
  /// **'İstifadəçi adı'**
  String get userName;

  /// No description provided for @userNamePlaceholder.
  ///
  /// In az, this message translates to:
  /// **'İstifadəçi adını daxil edin'**
  String get userNamePlaceholder;

  /// No description provided for @phone.
  ///
  /// In az, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// No description provided for @phonePlaceholder.
  ///
  /// In az, this message translates to:
  /// **'Telefon nömrəsi'**
  String get phonePlaceholder;

  /// No description provided for @phoneRequired.
  ///
  /// In az, this message translates to:
  /// **'Telefon nömrəsi tələb olunur'**
  String get phoneRequired;

  /// No description provided for @password.
  ///
  /// In az, this message translates to:
  /// **'Şifrə'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In az, this message translates to:
  /// **'Şifrəni unutdum'**
  String get forgotPassword;

  /// No description provided for @invalidCredentials.
  ///
  /// In az, this message translates to:
  /// **'İstifadəçi adı və ya şifrə yanlışdır!'**
  String get invalidCredentials;

  /// No description provided for @noInternet.
  ///
  /// In az, this message translates to:
  /// **'İnternet bağlantısı yoxdur!'**
  String get noInternet;

  /// No description provided for @accessDenied.
  ///
  /// In az, this message translates to:
  /// **'İcazə yoxdur'**
  String get accessDenied;

  /// No description provided for @accessDeniedMessage.
  ///
  /// In az, this message translates to:
  /// **'Bu səhifəyə çıxış üçün səlahiyyətiniz yoxdur.'**
  String get accessDeniedMessage;

  /// No description provided for @menu.
  ///
  /// In az, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @profile.
  ///
  /// In az, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @statistics.
  ///
  /// In az, this message translates to:
  /// **'Statistika'**
  String get statistics;

  /// No description provided for @customers.
  ///
  /// In az, this message translates to:
  /// **'Müştərilər'**
  String get customers;

  /// No description provided for @logout.
  ///
  /// In az, this message translates to:
  /// **'Çıxış'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In az, this message translates to:
  /// **'Tənzimləmələr'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In az, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @configLoading.
  ///
  /// In az, this message translates to:
  /// **'Konfiqurasiya yüklənir...'**
  String get configLoading;

  /// No description provided for @configFailed.
  ///
  /// In az, this message translates to:
  /// **'UiConfig yüklənmədi'**
  String get configFailed;

  /// No description provided for @balanceUpdated.
  ///
  /// In az, this message translates to:
  /// **'Balans uğurla yeniləndi!'**
  String get balanceUpdated;

  /// No description provided for @enterCode.
  ///
  /// In az, this message translates to:
  /// **'Kod daxil edin'**
  String get enterCode;

  /// No description provided for @otpRequired.
  ///
  /// In az, this message translates to:
  /// **'OTP təsdiqi tələb olunur'**
  String get otpRequired;

  /// No description provided for @smsCode.
  ///
  /// In az, this message translates to:
  /// **'SMS kodu'**
  String get smsCode;

  /// No description provided for @otpEnterCode.
  ///
  /// In az, this message translates to:
  /// **'OTP kodunu daxil edin'**
  String get otpEnterCode;

  /// No description provided for @maxRedeemCount.
  ///
  /// In az, this message translates to:
  /// **'Maksimum çıxıla bilən say'**
  String get maxRedeemCount;

  /// No description provided for @selectProgram.
  ///
  /// In az, this message translates to:
  /// **'Proqram seçin'**
  String get selectProgram;

  /// No description provided for @earn.
  ///
  /// In az, this message translates to:
  /// **'Qazan'**
  String get earn;

  /// No description provided for @spend.
  ///
  /// In az, this message translates to:
  /// **'Xərclə'**
  String get spend;

  /// No description provided for @cash.
  ///
  /// In az, this message translates to:
  /// **'Nağd'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In az, this message translates to:
  /// **'Kart'**
  String get card;

  /// No description provided for @orderId.
  ///
  /// In az, this message translates to:
  /// **'Sifariş ID'**
  String get orderId;

  /// No description provided for @amount.
  ///
  /// In az, this message translates to:
  /// **'Məbləğ'**
  String get amount;

  /// No description provided for @submit.
  ///
  /// In az, this message translates to:
  /// **'Göndər'**
  String get submit;

  /// No description provided for @lookupCustomer.
  ///
  /// In az, this message translates to:
  /// **'Müştərini axtar'**
  String get lookupCustomer;

  /// No description provided for @currentBalance.
  ///
  /// In az, this message translates to:
  /// **'Cari balans'**
  String get currentBalance;

  /// No description provided for @points.
  ///
  /// In az, this message translates to:
  /// **'xal'**
  String get points;

  /// No description provided for @reward.
  ///
  /// In az, this message translates to:
  /// **'mükafat'**
  String get reward;

  /// No description provided for @freeReward.
  ///
  /// In az, this message translates to:
  /// **'Pulsuz mükafat'**
  String get freeReward;

  /// No description provided for @statsTitle.
  ///
  /// In az, this message translates to:
  /// **'Statistika'**
  String get statsTitle;

  /// No description provided for @statsLoadFailed.
  ///
  /// In az, this message translates to:
  /// **'Məlumat yüklənə bilmədi'**
  String get statsLoadFailed;

  /// No description provided for @today.
  ///
  /// In az, this message translates to:
  /// **'Bu gün'**
  String get today;

  /// No description provided for @days7.
  ///
  /// In az, this message translates to:
  /// **'7 gün'**
  String get days7;

  /// No description provided for @days30.
  ///
  /// In az, this message translates to:
  /// **'30 gün'**
  String get days30;

  /// No description provided for @transactions.
  ///
  /// In az, this message translates to:
  /// **'Əməliyyatlar'**
  String get transactions;

  /// No description provided for @pointsEarned.
  ///
  /// In az, this message translates to:
  /// **'Qazanılan Xal'**
  String get pointsEarned;

  /// No description provided for @pointsSpent.
  ///
  /// In az, this message translates to:
  /// **'Xərclənən Xal'**
  String get pointsSpent;

  /// No description provided for @uniqueCustomers.
  ///
  /// In az, this message translates to:
  /// **'Müştərilər'**
  String get uniqueCustomers;

  /// No description provided for @detailedStats.
  ///
  /// In az, this message translates to:
  /// **'Detallı statistika'**
  String get detailedStats;

  /// No description provided for @daily.
  ///
  /// In az, this message translates to:
  /// **'Günlük'**
  String get daily;

  /// No description provided for @monthly.
  ///
  /// In az, this message translates to:
  /// **'Aylıq'**
  String get monthly;

  /// No description provided for @noTransactionsInRange.
  ///
  /// In az, this message translates to:
  /// **'Bu tarix aralığında əməliyyat yoxdur'**
  String get noTransactionsInRange;

  /// No description provided for @transactionShort.
  ///
  /// In az, this message translates to:
  /// **'əməl.'**
  String get transactionShort;

  /// No description provided for @earnedShort.
  ///
  /// In az, this message translates to:
  /// **'qazan.'**
  String get earnedShort;

  /// No description provided for @spentShort.
  ///
  /// In az, this message translates to:
  /// **'xərcl.'**
  String get spentShort;

  /// No description provided for @monthJan.
  ///
  /// In az, this message translates to:
  /// **'Yanvar'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In az, this message translates to:
  /// **'Fevral'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In az, this message translates to:
  /// **'Mart'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In az, this message translates to:
  /// **'Aprel'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In az, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In az, this message translates to:
  /// **'İyun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In az, this message translates to:
  /// **'İyul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In az, this message translates to:
  /// **'Avqust'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In az, this message translates to:
  /// **'Sentyabr'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In az, this message translates to:
  /// **'Oktyabr'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In az, this message translates to:
  /// **'Noyabr'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In az, this message translates to:
  /// **'Dekabr'**
  String get monthDec;

  /// No description provided for @searchByNamePhoneEmail.
  ///
  /// In az, this message translates to:
  /// **'Ad, telefon və ya email ilə axtar...'**
  String get searchByNamePhoneEmail;

  /// No description provided for @noResults.
  ///
  /// In az, this message translates to:
  /// **'Nəticə tapılmadı'**
  String get noResults;

  /// No description provided for @noCustomers.
  ///
  /// In az, this message translates to:
  /// **'Müştəri yoxdur'**
  String get noCustomers;

  /// No description provided for @customerTransactions.
  ///
  /// In az, this message translates to:
  /// **'Əməliyyatlar'**
  String get customerTransactions;

  /// No description provided for @reverseTransaction.
  ///
  /// In az, this message translates to:
  /// **'Əməliyyatı geri qaytar'**
  String get reverseTransaction;

  /// No description provided for @transactionReversed.
  ///
  /// In az, this message translates to:
  /// **'Əməliyyat geri qaytarıldı'**
  String get transactionReversed;

  /// No description provided for @pointsReversed.
  ///
  /// In az, this message translates to:
  /// **'xal geri qaytarıldı'**
  String get pointsReversed;

  /// No description provided for @reverseFailed.
  ///
  /// In az, this message translates to:
  /// **'Geri qaytarma uğursuz oldu'**
  String get reverseFailed;

  /// No description provided for @reverseReason.
  ///
  /// In az, this message translates to:
  /// **'Səbəb *'**
  String get reverseReason;

  /// No description provided for @reverseReasonPlaceholder.
  ///
  /// In az, this message translates to:
  /// **'Geri qaytarma səbəbini daxil edin'**
  String get reverseReasonPlaceholder;

  /// No description provided for @reverseButton.
  ///
  /// In az, this message translates to:
  /// **'Geri qaytar'**
  String get reverseButton;

  /// No description provided for @reverseReasonLabel.
  ///
  /// In az, this message translates to:
  /// **'Geri qaytarma səbəbi:'**
  String get reverseReasonLabel;

  /// No description provided for @noTransactions.
  ///
  /// In az, this message translates to:
  /// **'Əməliyyat yoxdur'**
  String get noTransactions;

  /// No description provided for @firstName.
  ///
  /// In az, this message translates to:
  /// **'Ad'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In az, this message translates to:
  /// **'Soyad'**
  String get lastName;

  /// No description provided for @email.
  ///
  /// In az, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @tenantAdmin.
  ///
  /// In az, this message translates to:
  /// **'Tenant Admin'**
  String get tenantAdmin;

  /// No description provided for @scanCode.
  ///
  /// In az, this message translates to:
  /// **'Kod skan et'**
  String get scanCode;

  /// No description provided for @scanHint.
  ///
  /// In az, this message translates to:
  /// **'QR / barkodu çərçivənin içinə gətirin'**
  String get scanHint;

  /// No description provided for @signUp.
  ///
  /// In az, this message translates to:
  /// **'Qeydiyyat'**
  String get signUp;

  /// No description provided for @signUpSubtitle.
  ///
  /// In az, this message translates to:
  /// **'Yeni hesab yaradın'**
  String get signUpSubtitle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In az, this message translates to:
  /// **'Artıq hesabınız var?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In az, this message translates to:
  /// **'Hesabınız yoxdur?'**
  String get dontHaveAccount;

  /// No description provided for @pay.
  ///
  /// In az, this message translates to:
  /// **'Ödə'**
  String get pay;

  /// No description provided for @bonusAdd.
  ///
  /// In az, this message translates to:
  /// **'Bonus Artır'**
  String get bonusAdd;

  /// No description provided for @paymentMethod.
  ///
  /// In az, this message translates to:
  /// **'Ödəniş üsulu'**
  String get paymentMethod;

  /// No description provided for @spendPoints.
  ///
  /// In az, this message translates to:
  /// **'Xal Xərclə'**
  String get spendPoints;

  /// No description provided for @spendFreeReward.
  ///
  /// In az, this message translates to:
  /// **'Pulsuz Mükafat Xərclə'**
  String get spendFreeReward;

  /// No description provided for @spendCount.
  ///
  /// In az, this message translates to:
  /// **'Say'**
  String get spendCount;

  /// No description provided for @about.
  ///
  /// In az, this message translates to:
  /// **'Haqqında'**
  String get about;

  /// No description provided for @dataLoadFailed.
  ///
  /// In az, this message translates to:
  /// **'Məlumat yüklənə bilmədi'**
  String get dataLoadFailed;

  /// No description provided for @currentPoints.
  ///
  /// In az, this message translates to:
  /// **'Cari xal'**
  String get currentPoints;

  /// No description provided for @lifetimePoints.
  ///
  /// In az, this message translates to:
  /// **'Ömürlük xal'**
  String get lifetimePoints;

  /// No description provided for @currentSteps.
  ///
  /// In az, this message translates to:
  /// **'Cari addım'**
  String get currentSteps;

  /// No description provided for @completedCycles.
  ///
  /// In az, this message translates to:
  /// **'Tamamlanmış dövr'**
  String get completedCycles;

  /// No description provided for @availableRewards.
  ///
  /// In az, this message translates to:
  /// **'Mükafat sayı'**
  String get availableRewards;

  /// No description provided for @cardLabel.
  ///
  /// In az, this message translates to:
  /// **'Kart'**
  String get cardLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'az', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'az':
      return AppLocalizationsAz();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
