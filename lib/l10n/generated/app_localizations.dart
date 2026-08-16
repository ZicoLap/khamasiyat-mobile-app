import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en')
  ];

  /// Application brand name
  ///
  /// In en, this message translates to:
  /// **'Khamasiyat'**
  String get appTitle;

  /// No description provided for @sessionRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring your session…'**
  String get sessionRestoring;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back. Sign in with your customer account.'**
  String get loginSubtitle;

  /// No description provided for @loginAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginAction;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccountLink;

  /// No description provided for @haveAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccountLink;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your details. We will email you a verification code.'**
  String get registerSubtitle;

  /// No description provided for @registerContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get registerContinueAction;

  /// No description provided for @registerVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get registerVerifyTitle;

  /// No description provided for @registerVerifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {email}, then choose a password.'**
  String registerVerifySubtitle(String email);

  /// No description provided for @registerVerifyAction.
  ///
  /// In en, this message translates to:
  /// **'Verify and create account'**
  String get registerVerifyAction;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send a reset code if an account exists.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Send reset code'**
  String get forgotPasswordAction;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {email} and your new password.'**
  String resetPasswordSubtitle(String email);

  /// No description provided for @resetPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordAction;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Please sign in.'**
  String get resetPasswordSuccess;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account.'**
  String get changePasswordSubtitle;

  /// No description provided for @changePasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get changePasswordAction;

  /// No description provided for @logoutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logoutAction;

  /// No description provided for @homePlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re signed in'**
  String get homePlaceholderTitle;

  /// No description provided for @homePlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Catalog and booking features arrive in the next phase.'**
  String get homePlaceholderBody;

  /// No description provided for @homeSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name} ({email})'**
  String homeSignedInAs(String name, String email);

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get nameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'0912345678 or +249912345678'**
  String get phoneHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpLabel;

  /// No description provided for @otpResendAction.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResendAction;

  /// No description provided for @otpResendCooldown.
  ///
  /// In en, this message translates to:
  /// **'Resend available in {seconds}s'**
  String otpResendCooldown(int seconds);

  /// No description provided for @otpResentInfo.
  ///
  /// In en, this message translates to:
  /// **'If registration is pending, a new code has been sent.'**
  String get otpResentInfo;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @switchToArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get switchToArabic;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get switchToEnglish;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordWeak.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters with a letter and a number'**
  String get validationPasswordWeak;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordMismatch;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name (at least 2 characters)'**
  String get validationNameRequired;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Sudanese mobile number'**
  String get validationPhoneInvalid;

  /// No description provided for @validationOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the numeric verification code'**
  String get validationOtpInvalid;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorAccountSuspended.
  ///
  /// In en, this message translates to:
  /// **'This account has been suspended'**
  String get authErrorAccountSuspended;

  /// No description provided for @authErrorInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get authErrorInvalidOtp;

  /// No description provided for @authErrorOtpExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification code expired. Request a new one'**
  String get authErrorOtpExpired;

  /// No description provided for @authErrorEmailRegistered.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists'**
  String get authErrorEmailRegistered;

  /// No description provided for @authErrorPhoneRegistered.
  ///
  /// In en, this message translates to:
  /// **'An account with this phone already exists'**
  String get authErrorPhoneRegistered;

  /// No description provided for @authErrorEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email is not verified'**
  String get authErrorEmailNotVerified;

  /// No description provided for @authErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait and try again'**
  String get authErrorRateLimited;

  /// No description provided for @authErrorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authErrorPasswordMismatch;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorMailFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send email. Try again later'**
  String get authErrorMailFailed;

  /// No description provided for @authErrorMustChangePassword.
  ///
  /// In en, this message translates to:
  /// **'You must change your password before continuing'**
  String get authErrorMustChangePassword;

  /// No description provided for @authErrorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check your input'**
  String get authErrorValidation;

  /// No description provided for @authErrorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to perform this action'**
  String get authErrorForbidden;

  /// No description provided for @authErrorNonCustomer.
  ///
  /// In en, this message translates to:
  /// **'This account cannot use the Customer app'**
  String get authErrorNonCustomer;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network unavailable. Check your connection and try again'**
  String get authErrorNetwork;

  /// No description provided for @authErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again'**
  String get authErrorTimeout;

  /// No description provided for @authErrorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session is no longer valid. Please sign in'**
  String get authErrorUnauthorized;

  /// No description provided for @authErrorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again'**
  String get authErrorSessionExpired;

  /// No description provided for @authErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again'**
  String get authErrorUnexpected;

  /// No description provided for @authPasswordChangedRelogin.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Please sign in again'**
  String get authPasswordChangedRelogin;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @brandName.
  ///
  /// In en, this message translates to:
  /// **'Khamasiyat'**
  String get brandName;

  /// No description provided for @homeGreetingMorningGeneric.
  ///
  /// In en, this message translates to:
  /// **'Good morning 👋'**
  String get homeGreetingMorningGeneric;

  /// No description provided for @homeGreetingAfternoonGeneric.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon 👋'**
  String get homeGreetingAfternoonGeneric;

  /// No description provided for @homeGreetingEveningGeneric.
  ///
  /// In en, this message translates to:
  /// **'Good evening 👋'**
  String get homeGreetingEveningGeneric;

  /// No description provided for @homeGreetingMorningNamed.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name} 👋'**
  String homeGreetingMorningNamed(String name);

  /// No description provided for @homeGreetingAfternoonNamed.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name} 👋'**
  String homeGreetingAfternoonNamed(String name);

  /// No description provided for @homeGreetingEveningNamed.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name} 👋'**
  String homeGreetingEveningNamed(String name);

  /// No description provided for @homeWelcomeGeneric.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get homeWelcomeGeneric;

  /// No description provided for @homeWelcomeNamed.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeWelcomeNamed(String name);

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your next game starts here.'**
  String get homeHeadline;

  /// No description provided for @homeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Your next game starts here.'**
  String get homeQuestion;

  /// No description provided for @homeHeroSupport.
  ///
  /// In en, this message translates to:
  /// **'Discover and book football pitches across Sudan.'**
  String get homeHeroSupport;

  /// No description provided for @homeDiscoverCta.
  ///
  /// In en, this message translates to:
  /// **'Find a stadium'**
  String get homeDiscoverCta;

  /// No description provided for @homeQuickFilters.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get homeQuickFilters;

  /// No description provided for @homeStadiumsSection.
  ///
  /// In en, this message translates to:
  /// **'Explore stadiums'**
  String get homeStadiumsSection;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'State, city, or pitch type'**
  String get searchSubtitle;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No stadiums} one{1 stadium} other{{count} stadiums}}'**
  String searchResultsCount(int count);

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No stadiums found'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try another area or pitch type, or clear your filters.'**
  String get catalogEmptyBody;

  /// No description provided for @catalogClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get catalogClearFilters;

  /// No description provided for @catalogErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load stadiums'**
  String get catalogErrorTitle;

  /// No description provided for @catalogLoadMoreRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry loading more'**
  String get catalogLoadMoreRetry;

  /// No description provided for @catalogEndOfList.
  ///
  /// In en, this message translates to:
  /// **'You’re all caught up'**
  String get catalogEndOfList;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @filtersAction.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersAction;

  /// No description provided for @filtersSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersSheetTitle;

  /// No description provided for @filtersApply.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get filtersApply;

  /// No description provided for @filtersReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filtersReset;

  /// No description provided for @filterState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get filterState;

  /// No description provided for @filterCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get filterCity;

  /// No description provided for @filterPitchType.
  ///
  /// In en, this message translates to:
  /// **'Pitch type'**
  String get filterPitchType;

  /// No description provided for @filterAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get filterAny;

  /// No description provided for @stadiumActivePitches.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No pitches} one{1 pitch} other{{count} pitches}}'**
  String stadiumActivePitches(int count);

  /// No description provided for @stadiumPhotoPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Photo soon'**
  String get stadiumPhotoPlaceholder;

  /// No description provided for @stadiumPhotoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get stadiumPhotoUnavailable;

  /// No description provided for @stadiumDetailPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Stadium'**
  String get stadiumDetailPlaceholderTitle;

  /// No description provided for @stadiumDetailPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Stadium details arrive in the next phase.'**
  String get stadiumDetailPlaceholderBody;

  /// No description provided for @stadiumDetailIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Stadium ID: {id}'**
  String stadiumDetailIdLabel(String id);

  /// No description provided for @stadiumDetailAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get stadiumDetailAbout;

  /// No description provided for @stadiumDetailRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get stadiumDetailRules;

  /// No description provided for @stadiumDetailPitches.
  ///
  /// In en, this message translates to:
  /// **'Pitches'**
  String get stadiumDetailPitches;

  /// No description provided for @stadiumDetailFacilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get stadiumDetailFacilities;

  /// No description provided for @stadiumDetailLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get stadiumDetailLocation;

  /// No description provided for @stadiumDetailShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get stadiumDetailShowMore;

  /// No description provided for @stadiumDetailShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get stadiumDetailShowLess;

  /// No description provided for @stadiumDetailChoosePitch.
  ///
  /// In en, this message translates to:
  /// **'Choose a pitch'**
  String get stadiumDetailChoosePitch;

  /// No description provided for @stadiumDetailGetDirections.
  ///
  /// In en, this message translates to:
  /// **'Get directions'**
  String get stadiumDetailGetDirections;

  /// No description provided for @stadiumDetailCallStadium.
  ///
  /// In en, this message translates to:
  /// **'Call stadium'**
  String get stadiumDetailCallStadium;

  /// No description provided for @stadiumDetailNoPitches.
  ///
  /// In en, this message translates to:
  /// **'No bookable pitches available right now.'**
  String get stadiumDetailNoPitches;

  /// No description provided for @stadiumDetailErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get stadiumDetailErrorBody;

  /// No description provided for @stadiumDetailErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load stadium'**
  String get stadiumDetailErrorTitle;

  /// No description provided for @stadiumDetailIndoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get stadiumDetailIndoor;

  /// No description provided for @stadiumDetailRoofed.
  ///
  /// In en, this message translates to:
  /// **'Roofed'**
  String get stadiumDetailRoofed;

  /// No description provided for @stadiumDetailSummarySemantic.
  ///
  /// In en, this message translates to:
  /// **'Stadium summary'**
  String get stadiumDetailSummarySemantic;

  /// No description provided for @stadiumDetailPitchCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No pitches} one{1 pitch} other{{count} pitches}}'**
  String stadiumDetailPitchCount(int count);

  /// No description provided for @stadiumDetailFacilityCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No facilities} one{1 facility} other{{count} facilities}}'**
  String stadiumDetailFacilityCount(int count);

  /// No description provided for @stadiumDetailPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String stadiumDetailPhotoCount(int current, int total);

  /// No description provided for @stadiumDetailPhotoSemantic.
  ///
  /// In en, this message translates to:
  /// **'Photo of {name}, {current} of {total}'**
  String stadiumDetailPhotoSemantic(String name, int current, int total);

  /// No description provided for @amenityParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get amenityParking;

  /// No description provided for @amenityChangingRooms.
  ///
  /// In en, this message translates to:
  /// **'Changing rooms'**
  String get amenityChangingRooms;

  /// No description provided for @amenityToilets.
  ///
  /// In en, this message translates to:
  /// **'Toilets'**
  String get amenityToilets;

  /// No description provided for @amenitySeating.
  ///
  /// In en, this message translates to:
  /// **'Seating'**
  String get amenitySeating;

  /// No description provided for @amenityCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get amenityCafe;

  /// No description provided for @amenityPrayerArea.
  ///
  /// In en, this message translates to:
  /// **'Prayer area'**
  String get amenityPrayerArea;

  /// No description provided for @amenityWater.
  ///
  /// In en, this message translates to:
  /// **'Drinking water'**
  String get amenityWater;

  /// No description provided for @amenityFirstAid.
  ///
  /// In en, this message translates to:
  /// **'First aid'**
  String get amenityFirstAid;

  /// No description provided for @surfaceNaturalGrass.
  ///
  /// In en, this message translates to:
  /// **'Natural grass'**
  String get surfaceNaturalGrass;

  /// No description provided for @surfaceArtificialTurf.
  ///
  /// In en, this message translates to:
  /// **'Artificial turf'**
  String get surfaceArtificialTurf;

  /// No description provided for @surfaceFutsal.
  ///
  /// In en, this message translates to:
  /// **'Futsal'**
  String get surfaceFutsal;

  /// No description provided for @surfaceOther.
  ///
  /// In en, this message translates to:
  /// **'Other surface'**
  String get surfaceOther;

  /// No description provided for @pitchDetailPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get pitchDetailPlaceholderTitle;

  /// No description provided for @pitchDetailPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Pitch availability arrives in the next phase.'**
  String get pitchDetailPlaceholderBody;

  /// No description provided for @pitchDetailIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Pitch ID: {id}'**
  String pitchDetailIdLabel(String id);

  /// No description provided for @pitchDetailErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load pitch'**
  String get pitchDetailErrorTitle;

  /// No description provided for @pitchDetailErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get pitchDetailErrorBody;

  /// No description provided for @pitchDetailShareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get pitchDetailShareTooltip;

  /// No description provided for @pitchDetailShareText.
  ///
  /// In en, this message translates to:
  /// **'{pitch} at {stadium} — Khamasiyat'**
  String pitchDetailShareText(String pitch, String stadium);

  /// No description provided for @pitchDetailOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get pitchDetailOutdoor;

  /// No description provided for @pitchDetailFromPrice.
  ///
  /// In en, this message translates to:
  /// **'From {price} / slot'**
  String pitchDetailFromPrice(String price);

  /// No description provided for @pitchDetailSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get pitchDetailSelectDate;

  /// No description provided for @pitchDetailCalendarTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get pitchDetailCalendarTooltip;

  /// No description provided for @pitchDetailAvailableTimes.
  ///
  /// In en, this message translates to:
  /// **'Available times'**
  String get pitchDetailAvailableTimes;

  /// No description provided for @pitchDetailMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get pitchDetailMorning;

  /// No description provided for @pitchDetailAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get pitchDetailAfternoon;

  /// No description provided for @pitchDetailEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get pitchDetailEvening;

  /// No description provided for @pitchDetailNoSlots.
  ///
  /// In en, this message translates to:
  /// **'No available times for this date.'**
  String get pitchDetailNoSlots;

  /// No description provided for @pitchDetailChooseAnotherDate.
  ///
  /// In en, this message translates to:
  /// **'Choose another date'**
  String get pitchDetailChooseAnotherDate;

  /// No description provided for @pitchDetailSlotUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This time is no longer available. Please choose another slot.'**
  String get pitchDetailSlotUnavailable;

  /// No description provided for @pitchDetailRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh times.'**
  String get pitchDetailRefreshFailed;

  /// No description provided for @pitchDetailSlotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get pitchDetailSlotAvailable;

  /// No description provided for @pitchDetailDurationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String pitchDetailDurationHoursMinutes(int hours, int minutes);

  /// No description provided for @pitchDetailDurationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String pitchDetailDurationHours(int hours);

  /// No description provided for @pitchDetailDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String pitchDetailDurationMinutes(int minutes);

  /// No description provided for @pitchDetailTimezoneNote.
  ///
  /// In en, this message translates to:
  /// **'Times are shown in stadium local time ({timeZone}).'**
  String pitchDetailTimezoneNote(String timeZone);

  /// No description provided for @pitchDetailContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get pitchDetailContinue;

  /// No description provided for @pitchDetailBookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking started. Complete payment from Bookings.'**
  String get pitchDetailBookingSuccess;

  /// No description provided for @pitchDetailPhotoSemantic.
  ///
  /// In en, this message translates to:
  /// **'Photo of {name}, {current} of {total}'**
  String pitchDetailPhotoSemantic(String name, int current, int total);

  /// No description provided for @pitchDetailSlotSemantic.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String pitchDetailSlotSemantic(String start, String end);

  /// No description provided for @bookingReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review booking'**
  String get bookingReviewTitle;

  /// No description provided for @bookingReviewYourBooking.
  ///
  /// In en, this message translates to:
  /// **'Your booking'**
  String get bookingReviewYourBooking;

  /// No description provided for @bookingReviewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get bookingReviewCustomer;

  /// No description provided for @bookingReviewNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get bookingReviewNameLabel;

  /// No description provided for @bookingReviewPitchLabel.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get bookingReviewPitchLabel;

  /// No description provided for @bookingReviewTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get bookingReviewTypeLabel;

  /// No description provided for @bookingReviewDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get bookingReviewDateLabel;

  /// No description provided for @bookingReviewTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get bookingReviewTimeLabel;

  /// No description provided for @bookingReviewDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get bookingReviewDurationLabel;

  /// No description provided for @bookingReviewTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get bookingReviewTotalLabel;

  /// No description provided for @bookingReviewPriceDetails.
  ///
  /// In en, this message translates to:
  /// **'Price details'**
  String get bookingReviewPriceDetails;

  /// No description provided for @bookingReviewPitchReservation.
  ///
  /// In en, this message translates to:
  /// **'Pitch reservation'**
  String get bookingReviewPitchReservation;

  /// No description provided for @bookingReviewNotReservedYet.
  ///
  /// In en, this message translates to:
  /// **'Your slot isn\'t reserved yet.\nTap Book this slot to reserve it while you complete payment.'**
  String get bookingReviewNotReservedYet;

  /// No description provided for @bookingReviewCheckDetails.
  ///
  /// In en, this message translates to:
  /// **'Please check your booking details before confirming this slot.'**
  String get bookingReviewCheckDetails;

  /// No description provided for @bookingReviewCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get bookingReviewCancel;

  /// No description provided for @bookingReviewBookSlot.
  ///
  /// In en, this message translates to:
  /// **'Book this slot'**
  String get bookingReviewBookSlot;

  /// No description provided for @bookingReservedTitle.
  ///
  /// In en, this message translates to:
  /// **'Slot reserved'**
  String get bookingReservedTitle;

  /// No description provided for @bookingReservedBody.
  ///
  /// In en, this message translates to:
  /// **'This time is temporarily reserved for you. Complete your payment before the reservation expires to confirm your booking.'**
  String get bookingReservedBody;

  /// No description provided for @bookingReservedHoldUntil.
  ///
  /// In en, this message translates to:
  /// **'Reservation held until {time}'**
  String bookingReservedHoldUntil(String time);

  /// No description provided for @bookingReservedContinuePayment.
  ///
  /// In en, this message translates to:
  /// **'Continue to payment'**
  String get bookingReservedContinuePayment;

  /// No description provided for @bookingConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'This time is no longer available.'**
  String get bookingConflictTitle;

  /// No description provided for @bookingConflictBody.
  ///
  /// In en, this message translates to:
  /// **'Someone else booked this slot while you were reviewing your booking. Please choose another time.'**
  String get bookingConflictBody;

  /// No description provided for @bookingConflictChooseAnother.
  ///
  /// In en, this message translates to:
  /// **'Choose another time'**
  String get bookingConflictChooseAnother;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// No description provided for @paymentPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentPlaceholderTitle;

  /// No description provided for @paymentPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Payment methods arrive in the next phase.'**
  String get paymentPlaceholderBody;

  /// No description provided for @paymentBookingIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Booking ID: {id}'**
  String paymentBookingIdLabel(String id);

  /// No description provided for @paymentHoldsUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Hold until: {time}'**
  String paymentHoldsUntilLabel(String time);

  /// No description provided for @paymentStatusPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String paymentStatusPendingLabel(String status);

  /// No description provided for @paymentHoldReservedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your slot is reserved'**
  String get paymentHoldReservedTitle;

  /// No description provided for @paymentHoldRemaining.
  ///
  /// In en, this message translates to:
  /// **'{time} remaining'**
  String paymentHoldRemaining(String time);

  /// No description provided for @paymentHoldHint.
  ///
  /// In en, this message translates to:
  /// **'Complete your payment before the reservation expires.'**
  String get paymentHoldHint;

  /// No description provided for @paymentBookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Booking summary'**
  String get paymentBookingSummary;

  /// No description provided for @paymentAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}'**
  String paymentAmountLabel(String amount);

  /// No description provided for @paymentChooseMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose a payment method'**
  String get paymentChooseMethod;

  /// No description provided for @paymentNoMethods.
  ///
  /// In en, this message translates to:
  /// **'No payment methods are available for this stadium right now.'**
  String get paymentNoMethods;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash at stadium'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodBankak.
  ///
  /// In en, this message translates to:
  /// **'Bankak'**
  String get paymentMethodBankak;

  /// No description provided for @paymentMethodBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get paymentMethodBankTransfer;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method: {method}'**
  String paymentMethodLabel(String method);

  /// No description provided for @paymentCashInstructions.
  ///
  /// In en, this message translates to:
  /// **'Pay in cash at the stadium according to the venue instructions.'**
  String get paymentCashInstructions;

  /// No description provided for @paymentAccountHolder.
  ///
  /// In en, this message translates to:
  /// **'Account holder'**
  String get paymentAccountHolder;

  /// No description provided for @paymentAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get paymentAccountNumber;

  /// No description provided for @paymentBankName.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get paymentBankName;

  /// No description provided for @paymentIban.
  ///
  /// In en, this message translates to:
  /// **'IBAN'**
  String get paymentIban;

  /// No description provided for @paymentPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get paymentPhoneNumber;

  /// No description provided for @paymentReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction reference'**
  String get paymentReferenceLabel;

  /// No description provided for @paymentReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the transfer reference'**
  String get paymentReferenceHint;

  /// No description provided for @paymentReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get paymentReceiptTitle;

  /// No description provided for @paymentReceiptHint.
  ///
  /// In en, this message translates to:
  /// **'JPEG, PNG, WebP, or PDF up to 5 MB.'**
  String get paymentReceiptHint;

  /// No description provided for @paymentChooseReceipt.
  ///
  /// In en, this message translates to:
  /// **'Choose receipt'**
  String get paymentChooseReceipt;

  /// No description provided for @paymentReplaceReceipt.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get paymentReplaceReceipt;

  /// No description provided for @paymentRemoveReceipt.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get paymentRemoveReceipt;

  /// No description provided for @paymentReceiptSize.
  ///
  /// In en, this message translates to:
  /// **'Size: {size}'**
  String paymentReceiptSize(String size);

  /// No description provided for @paymentUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading receipt…'**
  String get paymentUploading;

  /// No description provided for @paymentSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit payment'**
  String get paymentSubmit;

  /// No description provided for @paymentGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get paymentGenericError;

  /// No description provided for @paymentErrorUnsupportedType.
  ///
  /// In en, this message translates to:
  /// **'This file type is not supported. Use JPEG, PNG, WebP, or PDF.'**
  String get paymentErrorUnsupportedType;

  /// No description provided for @paymentErrorOversized.
  ///
  /// In en, this message translates to:
  /// **'This file is too large. Maximum size is 5 MB.'**
  String get paymentErrorOversized;

  /// No description provided for @paymentRetryLoad.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get paymentRetryLoad;

  /// No description provided for @paymentSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment submitted'**
  String get paymentSubmittedTitle;

  /// No description provided for @paymentSubmittedBody.
  ///
  /// In en, this message translates to:
  /// **'Your payment is waiting for stadium confirmation.'**
  String get paymentSubmittedBody;

  /// No description provided for @paymentSubmittedNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'The booking is not yet confirmed.'**
  String get paymentSubmittedNotConfirmed;

  /// No description provided for @paymentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String paymentStatusLabel(String status);

  /// No description provided for @paymentStatusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get paymentStatusSubmitted;

  /// No description provided for @paymentStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get paymentStatusConfirmed;

  /// No description provided for @paymentStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get paymentStatusRejected;

  /// No description provided for @paymentRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment needs attention'**
  String get paymentRejectedTitle;

  /// No description provided for @paymentRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'The stadium rejected this receipt:\n\"{reason}\"'**
  String paymentRejectedBody(String reason);

  /// No description provided for @paymentRejectedBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'The stadium rejected this payment. Please try again with a new receipt.'**
  String get paymentRejectedBodyGeneric;

  /// No description provided for @paymentUploadAnotherReceipt.
  ///
  /// In en, this message translates to:
  /// **'Upload another receipt'**
  String get paymentUploadAnotherReceipt;

  /// No description provided for @paymentConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get paymentConfirmedTitle;

  /// No description provided for @paymentConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'Your pitch is booked.'**
  String get paymentConfirmedBody;

  /// No description provided for @paymentExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Reservation expired'**
  String get paymentExpiredTitle;

  /// No description provided for @paymentExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'This slot is no longer reserved.'**
  String get paymentExpiredBody;

  /// No description provided for @paymentExpiredChooseAnother.
  ///
  /// In en, this message translates to:
  /// **'Choose another time'**
  String get paymentExpiredChooseAnother;

  /// No description provided for @bookingsPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your bookings'**
  String get bookingsPlaceholderTitle;

  /// No description provided for @bookingsPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Booking history and upcoming matches will appear here soon.'**
  String get bookingsPlaceholderBody;

  /// No description provided for @profilePlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profilePlaceholderTitle;

  /// No description provided for @profilePlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Profile settings arrive in a later phase. You can sign out below.'**
  String get profilePlaceholderBody;

  /// No description provided for @pitchTypeFiveASide.
  ///
  /// In en, this message translates to:
  /// **'5-a-side'**
  String get pitchTypeFiveASide;

  /// No description provided for @pitchTypeSevenASide.
  ///
  /// In en, this message translates to:
  /// **'7-a-side'**
  String get pitchTypeSevenASide;

  /// No description provided for @pitchTypeElevenASide.
  ///
  /// In en, this message translates to:
  /// **'11-a-side'**
  String get pitchTypeElevenASide;

  /// No description provided for @pitchTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pitchTypeOther;

  /// No description provided for @stateKhartoum.
  ///
  /// In en, this message translates to:
  /// **'Khartoum'**
  String get stateKhartoum;

  /// No description provided for @stateNorthern.
  ///
  /// In en, this message translates to:
  /// **'Northern'**
  String get stateNorthern;

  /// No description provided for @stateRiverNile.
  ///
  /// In en, this message translates to:
  /// **'River Nile'**
  String get stateRiverNile;

  /// No description provided for @stateRedSea.
  ///
  /// In en, this message translates to:
  /// **'Red Sea'**
  String get stateRedSea;

  /// No description provided for @stateKassala.
  ///
  /// In en, this message translates to:
  /// **'Kassala'**
  String get stateKassala;

  /// No description provided for @stateGedaref.
  ///
  /// In en, this message translates to:
  /// **'Gedaref'**
  String get stateGedaref;

  /// No description provided for @stateGezira.
  ///
  /// In en, this message translates to:
  /// **'Gezira'**
  String get stateGezira;

  /// No description provided for @stateWhiteNile.
  ///
  /// In en, this message translates to:
  /// **'White Nile'**
  String get stateWhiteNile;

  /// No description provided for @stateBlueNile.
  ///
  /// In en, this message translates to:
  /// **'Blue Nile'**
  String get stateBlueNile;

  /// No description provided for @stateSennar.
  ///
  /// In en, this message translates to:
  /// **'Sennar'**
  String get stateSennar;

  /// No description provided for @stateNorthKordofan.
  ///
  /// In en, this message translates to:
  /// **'North Kordofan'**
  String get stateNorthKordofan;

  /// No description provided for @stateSouthKordofan.
  ///
  /// In en, this message translates to:
  /// **'South Kordofan'**
  String get stateSouthKordofan;

  /// No description provided for @stateWestKordofan.
  ///
  /// In en, this message translates to:
  /// **'West Kordofan'**
  String get stateWestKordofan;

  /// No description provided for @stateNorthDarfur.
  ///
  /// In en, this message translates to:
  /// **'North Darfur'**
  String get stateNorthDarfur;

  /// No description provided for @stateSouthDarfur.
  ///
  /// In en, this message translates to:
  /// **'South Darfur'**
  String get stateSouthDarfur;

  /// No description provided for @stateEastDarfur.
  ///
  /// In en, this message translates to:
  /// **'East Darfur'**
  String get stateEastDarfur;

  /// No description provided for @stateWestDarfur.
  ///
  /// In en, this message translates to:
  /// **'West Darfur'**
  String get stateWestDarfur;

  /// No description provided for @stateCentralDarfur.
  ///
  /// In en, this message translates to:
  /// **'Central Darfur'**
  String get stateCentralDarfur;

  /// No description provided for @cityKhartoumCity.
  ///
  /// In en, this message translates to:
  /// **'Khartoum'**
  String get cityKhartoumCity;

  /// No description provided for @cityOmdurman.
  ///
  /// In en, this message translates to:
  /// **'Omdurman'**
  String get cityOmdurman;

  /// No description provided for @cityBahri.
  ///
  /// In en, this message translates to:
  /// **'Bahri'**
  String get cityBahri;

  /// No description provided for @cityDongola.
  ///
  /// In en, this message translates to:
  /// **'Dongola'**
  String get cityDongola;

  /// No description provided for @cityKarima.
  ///
  /// In en, this message translates to:
  /// **'Karima'**
  String get cityKarima;

  /// No description provided for @cityWadiHalfa.
  ///
  /// In en, this message translates to:
  /// **'Wadi Halfa'**
  String get cityWadiHalfa;

  /// No description provided for @cityAtbara.
  ///
  /// In en, this message translates to:
  /// **'Atbara'**
  String get cityAtbara;

  /// No description provided for @cityEdDamer.
  ///
  /// In en, this message translates to:
  /// **'Ed Damer'**
  String get cityEdDamer;

  /// No description provided for @cityShendi.
  ///
  /// In en, this message translates to:
  /// **'Shendi'**
  String get cityShendi;

  /// No description provided for @cityBerber.
  ///
  /// In en, this message translates to:
  /// **'Berber'**
  String get cityBerber;

  /// No description provided for @cityPortSudan.
  ///
  /// In en, this message translates to:
  /// **'Port Sudan'**
  String get cityPortSudan;

  /// No description provided for @citySuakin.
  ///
  /// In en, this message translates to:
  /// **'Suakin'**
  String get citySuakin;

  /// No description provided for @cityTokar.
  ///
  /// In en, this message translates to:
  /// **'Tokar'**
  String get cityTokar;

  /// No description provided for @cityKassalaCity.
  ///
  /// In en, this message translates to:
  /// **'Kassala'**
  String get cityKassalaCity;

  /// No description provided for @cityNewHalfa.
  ///
  /// In en, this message translates to:
  /// **'New Halfa'**
  String get cityNewHalfa;

  /// No description provided for @cityGedarefCity.
  ///
  /// In en, this message translates to:
  /// **'Gedaref'**
  String get cityGedarefCity;

  /// No description provided for @cityShowak.
  ///
  /// In en, this message translates to:
  /// **'Showak'**
  String get cityShowak;

  /// No description provided for @cityWadMadani.
  ///
  /// In en, this message translates to:
  /// **'Wad Madani'**
  String get cityWadMadani;

  /// No description provided for @cityHasahisa.
  ///
  /// In en, this message translates to:
  /// **'Hasahisa'**
  String get cityHasahisa;

  /// No description provided for @cityKamlin.
  ///
  /// In en, this message translates to:
  /// **'Kamlin'**
  String get cityKamlin;

  /// No description provided for @cityManaqil.
  ///
  /// In en, this message translates to:
  /// **'Manaqil'**
  String get cityManaqil;

  /// No description provided for @cityRabak.
  ///
  /// In en, this message translates to:
  /// **'Rabak'**
  String get cityRabak;

  /// No description provided for @cityKosti.
  ///
  /// In en, this message translates to:
  /// **'Kosti'**
  String get cityKosti;

  /// No description provided for @cityEdDueim.
  ///
  /// In en, this message translates to:
  /// **'Ed Dueim'**
  String get cityEdDueim;

  /// No description provided for @cityDamazin.
  ///
  /// In en, this message translates to:
  /// **'Damazin'**
  String get cityDamazin;

  /// No description provided for @cityRoseires.
  ///
  /// In en, this message translates to:
  /// **'Roseires'**
  String get cityRoseires;

  /// No description provided for @citySinnarCity.
  ///
  /// In en, this message translates to:
  /// **'Sinnar'**
  String get citySinnarCity;

  /// No description provided for @citySinga.
  ///
  /// In en, this message translates to:
  /// **'Singa'**
  String get citySinga;

  /// No description provided for @cityElObeid.
  ///
  /// In en, this message translates to:
  /// **'El Obeid'**
  String get cityElObeid;

  /// No description provided for @cityUmRawaba.
  ///
  /// In en, this message translates to:
  /// **'Um Rawaba'**
  String get cityUmRawaba;

  /// No description provided for @cityKadugli.
  ///
  /// In en, this message translates to:
  /// **'Kadugli'**
  String get cityKadugli;

  /// No description provided for @cityAbuJubaiha.
  ///
  /// In en, this message translates to:
  /// **'Abu Jubaiha'**
  String get cityAbuJubaiha;

  /// No description provided for @cityAlFula.
  ///
  /// In en, this message translates to:
  /// **'Al Fula'**
  String get cityAlFula;

  /// No description provided for @cityAnNuhud.
  ///
  /// In en, this message translates to:
  /// **'An Nuhud'**
  String get cityAnNuhud;

  /// No description provided for @cityElFasher.
  ///
  /// In en, this message translates to:
  /// **'El Fasher'**
  String get cityElFasher;

  /// No description provided for @cityKutum.
  ///
  /// In en, this message translates to:
  /// **'Kutum'**
  String get cityKutum;

  /// No description provided for @cityNyala.
  ///
  /// In en, this message translates to:
  /// **'Nyala'**
  String get cityNyala;

  /// No description provided for @cityKass.
  ///
  /// In en, this message translates to:
  /// **'Kass'**
  String get cityKass;

  /// No description provided for @cityEdDaein.
  ///
  /// In en, this message translates to:
  /// **'Ed Daein'**
  String get cityEdDaein;

  /// No description provided for @cityGeneina.
  ///
  /// In en, this message translates to:
  /// **'Geneina'**
  String get cityGeneina;

  /// No description provided for @cityZalingei.
  ///
  /// In en, this message translates to:
  /// **'Zalingei'**
  String get cityZalingei;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
