// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Khamasiyat';

  @override
  String get sessionRestoring => 'Restoring your session…';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Welcome back. Sign in with your customer account.';

  @override
  String get loginAction => 'Sign in';

  @override
  String get createAccountLink => 'Create an account';

  @override
  String get haveAccountLink => 'Already have an account? Sign in';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Enter your details. We will email you a verification code.';

  @override
  String get registerContinueAction => 'Continue';

  @override
  String get registerVerifyTitle => 'Verify email';

  @override
  String registerVerifySubtitle(String email) {
    return 'Enter the code sent to $email, then choose a password.';
  }

  @override
  String get registerVerifyAction => 'Verify and create account';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordSubtitle => 'Enter your email and we will send a reset code if an account exists.';

  @override
  String get forgotPasswordAction => 'Send reset code';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String resetPasswordSubtitle(String email) {
    return 'Enter the code sent to $email and your new password.';
  }

  @override
  String get resetPasswordAction => 'Reset password';

  @override
  String get resetPasswordSuccess => 'Password updated. Please sign in.';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordSubtitle => 'Choose a new password for your account.';

  @override
  String get changePasswordAction => 'Update password';

  @override
  String get logoutAction => 'Sign out';

  @override
  String get homePlaceholderTitle => 'You\'re signed in';

  @override
  String get homePlaceholderBody => 'Catalog and booking features arrive in the next phase.';

  @override
  String homeSignedInAs(String name, String email) {
    return 'Signed in as $name ($email)';
  }

  @override
  String get nameLabel => 'Full name';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get phoneHint => '0912345678 or +249912345678';

  @override
  String get passwordLabel => 'Password';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get otpLabel => 'Verification code';

  @override
  String get otpResendAction => 'Resend code';

  @override
  String otpResendCooldown(int seconds) {
    return 'Resend available in ${seconds}s';
  }

  @override
  String get otpResentInfo => 'If registration is pending, a new code has been sent.';

  @override
  String get languageLabel => 'Language';

  @override
  String get switchToArabic => 'العربية';

  @override
  String get switchToEnglish => 'English';

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationEmailInvalid => 'Enter a valid email';

  @override
  String get validationPasswordRequired => 'Password is required';

  @override
  String get validationPasswordWeak => 'Use at least 8 characters with a letter and a number';

  @override
  String get validationPasswordMismatch => 'Passwords do not match';

  @override
  String get validationNameRequired => 'Enter your name (at least 2 characters)';

  @override
  String get validationPhoneRequired => 'Phone is required';

  @override
  String get validationPhoneInvalid => 'Enter a valid Sudanese mobile number';

  @override
  String get validationOtpInvalid => 'Enter the numeric verification code';

  @override
  String get authErrorInvalidCredentials => 'Invalid email or password';

  @override
  String get authErrorAccountSuspended => 'This account has been suspended';

  @override
  String get authErrorInvalidOtp => 'Invalid verification code';

  @override
  String get authErrorOtpExpired => 'Verification code expired. Request a new one';

  @override
  String get authErrorEmailRegistered => 'An account with this email already exists';

  @override
  String get authErrorPhoneRegistered => 'An account with this phone already exists';

  @override
  String get authErrorEmailNotVerified => 'Email is not verified';

  @override
  String get authErrorRateLimited => 'Too many attempts. Please wait and try again';

  @override
  String get authErrorPasswordMismatch => 'Passwords do not match';

  @override
  String get authErrorWeakPassword => 'Password is too weak';

  @override
  String get authErrorMailFailed => 'Could not send email. Try again later';

  @override
  String get authErrorMustChangePassword => 'You must change your password before continuing';

  @override
  String get authErrorValidation => 'Please check your input';

  @override
  String get authErrorForbidden => 'You are not allowed to perform this action';

  @override
  String get authErrorNonCustomer => 'This account cannot use the Customer app';

  @override
  String get authErrorNetwork => 'Network unavailable. Check your connection and try again';

  @override
  String get authErrorTimeout => 'The request timed out. Please try again';

  @override
  String get authErrorUnauthorized => 'Your session is no longer valid. Please sign in';

  @override
  String get authErrorSessionExpired => 'Your session expired. Please sign in again';

  @override
  String get authErrorUnexpected => 'Something went wrong. Please try again';

  @override
  String get authPasswordChangedRelogin => 'Password updated. Please sign in again';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navProfile => 'Profile';

  @override
  String get brandName => 'Khamasiyat';

  @override
  String get homeGreetingMorningGeneric => 'Good morning 👋';

  @override
  String get homeGreetingAfternoonGeneric => 'Good afternoon 👋';

  @override
  String get homeGreetingEveningGeneric => 'Good evening 👋';

  @override
  String homeGreetingMorningNamed(String name) {
    return 'Good morning, $name 👋';
  }

  @override
  String homeGreetingAfternoonNamed(String name) {
    return 'Good afternoon, $name 👋';
  }

  @override
  String homeGreetingEveningNamed(String name) {
    return 'Good evening, $name 👋';
  }

  @override
  String get homeWelcomeGeneric => 'Welcome';

  @override
  String homeWelcomeNamed(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeHeadline => 'Your next game starts here.';

  @override
  String get homeQuestion => 'Your next game starts here.';

  @override
  String get homeHeroSupport => 'Discover and book football pitches across Sudan.';

  @override
  String get homeDiscoverCta => 'Find a stadium';

  @override
  String get homeQuickFilters => 'Filter';

  @override
  String get homeStadiumsSection => 'Explore stadiums';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchSubtitle => 'State, city, or pitch type';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stadiums',
      one: '1 stadium',
      zero: 'No stadiums',
    );
    return '$_temp0';
  }

  @override
  String get catalogEmptyTitle => 'No stadiums found';

  @override
  String get catalogEmptyBody => 'Try another area or pitch type, or clear your filters.';

  @override
  String get catalogClearFilters => 'Clear all';

  @override
  String get catalogErrorTitle => 'Couldn’t load stadiums';

  @override
  String get catalogLoadMoreRetry => 'Retry loading more';

  @override
  String get catalogEndOfList => 'You’re all caught up';

  @override
  String get retryAction => 'Retry';

  @override
  String get filtersAction => 'Filters';

  @override
  String get filtersSheetTitle => 'Filters';

  @override
  String get filtersApply => 'Show results';

  @override
  String get filtersReset => 'Reset';

  @override
  String get filterState => 'State';

  @override
  String get filterCity => 'City';

  @override
  String get filterPitchType => 'Pitch type';

  @override
  String get filterAny => 'Any';

  @override
  String stadiumActivePitches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pitches',
      one: '1 pitch',
      zero: 'No pitches',
    );
    return '$_temp0';
  }

  @override
  String get stadiumPhotoPlaceholder => 'Photo soon';

  @override
  String get stadiumPhotoUnavailable => 'Unavailable';

  @override
  String get stadiumDetailPlaceholderTitle => 'Stadium';

  @override
  String get stadiumDetailPlaceholderBody => 'Stadium details arrive in the next phase.';

  @override
  String stadiumDetailIdLabel(String id) {
    return 'Stadium ID: $id';
  }

  @override
  String get stadiumDetailAbout => 'About';

  @override
  String get stadiumDetailRules => 'Rules';

  @override
  String get stadiumDetailPitches => 'Pitches';

  @override
  String get stadiumDetailFacilities => 'Facilities';

  @override
  String get stadiumDetailLocation => 'Location';

  @override
  String get stadiumDetailShowMore => 'Show more';

  @override
  String get stadiumDetailShowLess => 'Show less';

  @override
  String get stadiumDetailChoosePitch => 'Choose a pitch';

  @override
  String get stadiumDetailGetDirections => 'Get directions';

  @override
  String get stadiumDetailCallStadium => 'Call stadium';

  @override
  String get stadiumDetailNoPitches => 'No bookable pitches available right now.';

  @override
  String get stadiumDetailErrorBody => 'Check your connection and try again.';

  @override
  String get stadiumDetailErrorTitle => 'Couldn\'t load stadium';

  @override
  String get stadiumDetailIndoor => 'Indoor';

  @override
  String get stadiumDetailRoofed => 'Roofed';

  @override
  String get stadiumDetailSummarySemantic => 'Stadium summary';

  @override
  String stadiumDetailPitchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pitches',
      one: '1 pitch',
      zero: 'No pitches',
    );
    return '$_temp0';
  }

  @override
  String stadiumDetailFacilityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count facilities',
      one: '1 facility',
      zero: 'No facilities',
    );
    return '$_temp0';
  }

  @override
  String stadiumDetailPhotoCount(int current, int total) {
    return '$current / $total';
  }

  @override
  String stadiumDetailPhotoSemantic(String name, int current, int total) {
    return 'Photo of $name, $current of $total';
  }

  @override
  String get amenityParking => 'Parking';

  @override
  String get amenityChangingRooms => 'Changing rooms';

  @override
  String get amenityToilets => 'Toilets';

  @override
  String get amenitySeating => 'Seating';

  @override
  String get amenityCafe => 'Cafe';

  @override
  String get amenityPrayerArea => 'Prayer area';

  @override
  String get amenityWater => 'Drinking water';

  @override
  String get amenityFirstAid => 'First aid';

  @override
  String get surfaceNaturalGrass => 'Natural grass';

  @override
  String get surfaceArtificialTurf => 'Artificial turf';

  @override
  String get surfaceFutsal => 'Futsal';

  @override
  String get surfaceOther => 'Other surface';

  @override
  String get pitchDetailPlaceholderTitle => 'Pitch';

  @override
  String get pitchDetailPlaceholderBody => 'Pitch availability arrives in the next phase.';

  @override
  String pitchDetailIdLabel(String id) {
    return 'Pitch ID: $id';
  }

  @override
  String get bookingsPlaceholderTitle => 'Your bookings';

  @override
  String get bookingsPlaceholderBody => 'Booking history and upcoming matches will appear here soon.';

  @override
  String get profilePlaceholderTitle => 'Your profile';

  @override
  String get profilePlaceholderBody => 'Profile settings arrive in a later phase. You can sign out below.';

  @override
  String get pitchTypeFiveASide => '5-a-side';

  @override
  String get pitchTypeSevenASide => '7-a-side';

  @override
  String get pitchTypeElevenASide => '11-a-side';

  @override
  String get pitchTypeOther => 'Other';

  @override
  String get stateKhartoum => 'Khartoum';

  @override
  String get stateNorthern => 'Northern';

  @override
  String get stateRiverNile => 'River Nile';

  @override
  String get stateRedSea => 'Red Sea';

  @override
  String get stateKassala => 'Kassala';

  @override
  String get stateGedaref => 'Gedaref';

  @override
  String get stateGezira => 'Gezira';

  @override
  String get stateWhiteNile => 'White Nile';

  @override
  String get stateBlueNile => 'Blue Nile';

  @override
  String get stateSennar => 'Sennar';

  @override
  String get stateNorthKordofan => 'North Kordofan';

  @override
  String get stateSouthKordofan => 'South Kordofan';

  @override
  String get stateWestKordofan => 'West Kordofan';

  @override
  String get stateNorthDarfur => 'North Darfur';

  @override
  String get stateSouthDarfur => 'South Darfur';

  @override
  String get stateEastDarfur => 'East Darfur';

  @override
  String get stateWestDarfur => 'West Darfur';

  @override
  String get stateCentralDarfur => 'Central Darfur';

  @override
  String get cityKhartoumCity => 'Khartoum';

  @override
  String get cityOmdurman => 'Omdurman';

  @override
  String get cityBahri => 'Bahri';

  @override
  String get cityDongola => 'Dongola';

  @override
  String get cityKarima => 'Karima';

  @override
  String get cityWadiHalfa => 'Wadi Halfa';

  @override
  String get cityAtbara => 'Atbara';

  @override
  String get cityEdDamer => 'Ed Damer';

  @override
  String get cityShendi => 'Shendi';

  @override
  String get cityBerber => 'Berber';

  @override
  String get cityPortSudan => 'Port Sudan';

  @override
  String get citySuakin => 'Suakin';

  @override
  String get cityTokar => 'Tokar';

  @override
  String get cityKassalaCity => 'Kassala';

  @override
  String get cityNewHalfa => 'New Halfa';

  @override
  String get cityGedarefCity => 'Gedaref';

  @override
  String get cityShowak => 'Showak';

  @override
  String get cityWadMadani => 'Wad Madani';

  @override
  String get cityHasahisa => 'Hasahisa';

  @override
  String get cityKamlin => 'Kamlin';

  @override
  String get cityManaqil => 'Manaqil';

  @override
  String get cityRabak => 'Rabak';

  @override
  String get cityKosti => 'Kosti';

  @override
  String get cityEdDueim => 'Ed Dueim';

  @override
  String get cityDamazin => 'Damazin';

  @override
  String get cityRoseires => 'Roseires';

  @override
  String get citySinnarCity => 'Sinnar';

  @override
  String get citySinga => 'Singa';

  @override
  String get cityElObeid => 'El Obeid';

  @override
  String get cityUmRawaba => 'Um Rawaba';

  @override
  String get cityKadugli => 'Kadugli';

  @override
  String get cityAbuJubaiha => 'Abu Jubaiha';

  @override
  String get cityAlFula => 'Al Fula';

  @override
  String get cityAnNuhud => 'An Nuhud';

  @override
  String get cityElFasher => 'El Fasher';

  @override
  String get cityKutum => 'Kutum';

  @override
  String get cityNyala => 'Nyala';

  @override
  String get cityKass => 'Kass';

  @override
  String get cityEdDaein => 'Ed Daein';

  @override
  String get cityGeneina => 'Geneina';

  @override
  String get cityZalingei => 'Zalingei';
}
