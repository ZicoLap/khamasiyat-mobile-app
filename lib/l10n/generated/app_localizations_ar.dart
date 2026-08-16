// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'خماسيات';

  @override
  String get sessionRestoring => 'جاري استعادة جلستك…';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'مرحبًا بعودتك. سجّل الدخول بحساب العميل.';

  @override
  String get loginAction => 'تسجيل الدخول';

  @override
  String get createAccountLink => 'إنشاء حساب';

  @override
  String get haveAccountLink => 'لديك حساب؟ سجّل الدخول';

  @override
  String get forgotPasswordLink => 'نسيت كلمة المرور؟';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'أدخل بياناتك. سنرسل رمز التحقق إلى بريدك.';

  @override
  String get registerContinueAction => 'متابعة';

  @override
  String get registerVerifyTitle => 'تأكيد البريد';

  @override
  String registerVerifySubtitle(String email) {
    return 'أدخل الرمز المرسل إلى $email ثم اختر كلمة مرور.';
  }

  @override
  String get registerVerifyAction => 'تأكيد وإنشاء الحساب';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get forgotPasswordSubtitle => 'أدخل بريدك وسنرسل رمز إعادة التعيين إن وُجد حساب.';

  @override
  String get forgotPasswordAction => 'إرسال رمز إعادة التعيين';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String resetPasswordSubtitle(String email) {
    return 'أدخل الرمز المرسل إلى $email وكلمة المرور الجديدة.';
  }

  @override
  String get resetPasswordAction => 'إعادة التعيين';

  @override
  String get resetPasswordSuccess => 'تم تحديث كلمة المرور. يرجى تسجيل الدخول.';

  @override
  String get changePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get changePasswordSubtitle => 'اختر كلمة مرور جديدة لحسابك.';

  @override
  String get changePasswordAction => 'تحديث كلمة المرور';

  @override
  String get logoutAction => 'تسجيل الخروج';

  @override
  String get homePlaceholderTitle => 'أنت مسجّل الدخول';

  @override
  String get homePlaceholderBody => 'ميزات الكتالوج والحجز تأتي في المرحلة التالية.';

  @override
  String homeSignedInAs(String name, String email) {
    return 'مسجّل الدخول باسم $name ($email)';
  }

  @override
  String get nameLabel => 'الاسم الكامل';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get phoneHint => '0912345678 أو +249912345678';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get currentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get otpLabel => 'رمز التحقق';

  @override
  String get otpResendAction => 'إعادة إرسال الرمز';

  @override
  String otpResendCooldown(int seconds) {
    return 'إعادة الإرسال بعد $seconds ث';
  }

  @override
  String get otpResentInfo => 'إذا كان التسجيل معلّقًا، فقد أُرسل رمز جديد.';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get switchToArabic => 'العربية';

  @override
  String get switchToEnglish => 'English';

  @override
  String get validationEmailRequired => 'البريد مطلوب';

  @override
  String get validationEmailInvalid => 'أدخل بريدًا صالحًا';

  @override
  String get validationPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get validationPasswordWeak => 'استخدم 8 أحرف على الأقل مع حرف ورقم';

  @override
  String get validationPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get validationNameRequired => 'أدخل اسمك (حرفان على الأقل)';

  @override
  String get validationPhoneRequired => 'الهاتف مطلوب';

  @override
  String get validationPhoneInvalid => 'أدخل رقم هاتف سوداني صالحًا';

  @override
  String get validationOtpInvalid => 'أدخل رمز التحقق الرقمي';

  @override
  String get authErrorInvalidCredentials => 'البريد أو كلمة المرور غير صحيحة';

  @override
  String get authErrorAccountSuspended => 'تم تعليق هذا الحساب';

  @override
  String get authErrorInvalidOtp => 'رمز التحقق غير صالح';

  @override
  String get authErrorOtpExpired => 'انتهت صلاحية الرمز. اطلب رمزًا جديدًا';

  @override
  String get authErrorEmailRegistered => 'يوجد حساب بهذا البريد بالفعل';

  @override
  String get authErrorPhoneRegistered => 'يوجد حساب بهذا الهاتف بالفعل';

  @override
  String get authErrorEmailNotVerified => 'البريد غير مؤكد';

  @override
  String get authErrorRateLimited => 'محاولات كثيرة. انتظر ثم أعد المحاولة';

  @override
  String get authErrorPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authErrorWeakPassword => 'كلمة المرور ضعيفة';

  @override
  String get authErrorMailFailed => 'تعذر إرسال البريد. حاول لاحقًا';

  @override
  String get authErrorMustChangePassword => 'يجب تغيير كلمة المرور قبل المتابعة';

  @override
  String get authErrorValidation => 'يرجى التحقق من المدخلات';

  @override
  String get authErrorForbidden => 'غير مسموح بهذا الإجراء';

  @override
  String get authErrorNonCustomer => 'لا يمكن استخدام هذا الحساب في تطبيق العميل';

  @override
  String get authErrorNetwork => 'الشبكة غير متاحة. تحقق من الاتصال وحاول مجددًا';

  @override
  String get authErrorTimeout => 'انتهت مهلة الطلب. حاول مجددًا';

  @override
  String get authErrorUnauthorized => 'جلستك لم تعد صالحة. يرجى تسجيل الدخول';

  @override
  String get authErrorSessionExpired => 'انتهت جلستك. يرجى تسجيل الدخول مجددًا';

  @override
  String get authErrorUnexpected => 'حدث خطأ ما. حاول مجددًا';

  @override
  String get authPasswordChangedRelogin => 'تم تحديث كلمة المرور. يرجى تسجيل الدخول مجددًا';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSearch => 'بحث';

  @override
  String get navBookings => 'حجوزاتي';

  @override
  String get navProfile => 'حسابي';

  @override
  String get brandName => 'خماسيات';

  @override
  String get homeGreetingMorningGeneric => 'صباح الخير 👋';

  @override
  String get homeGreetingAfternoonGeneric => 'مساء الخير 👋';

  @override
  String get homeGreetingEveningGeneric => 'مساء الخير 👋';

  @override
  String homeGreetingMorningNamed(String name) {
    return 'صباح الخير، $name 👋';
  }

  @override
  String homeGreetingAfternoonNamed(String name) {
    return 'مساء الخير، $name 👋';
  }

  @override
  String homeGreetingEveningNamed(String name) {
    return 'مساء الخير، $name 👋';
  }

  @override
  String get homeWelcomeGeneric => 'مرحبًا';

  @override
  String homeWelcomeNamed(String name) {
    return 'أهلًا، $name';
  }

  @override
  String get homeHeadline => 'مباراتك الجاية تبدأ من هنا';

  @override
  String get homeQuestion => 'مباراتك الجاية تبدأ من هنا';

  @override
  String get homeHeroSupport => 'اكتشف واحجز ملاعب كرة القدم في جميع أنحاء السودان';

  @override
  String get homeDiscoverCta => 'ابحث عن ملعب';

  @override
  String get homeQuickFilters => 'تصفية';

  @override
  String get homeStadiumsSection => 'استكشف الملاعب';

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get searchTitle => 'بحث';

  @override
  String get searchSubtitle => 'الولاية أو المدينة أو نوع الملعب';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملاعب',
      one: 'ملعب واحد',
      zero: 'ما في ملاعب',
    );
    return '$_temp0';
  }

  @override
  String get catalogEmptyTitle => 'ما في ملاعب';

  @override
  String get catalogEmptyBody => 'جرّب منطقة أو نوع ملعب ثاني، أو امسح الفلاتر.';

  @override
  String get catalogClearFilters => 'مسح الكل';

  @override
  String get catalogErrorTitle => 'تعذر تحميل الملاعب';

  @override
  String get catalogLoadMoreRetry => 'أعد محاولة التحميل';

  @override
  String get catalogEndOfList => 'وصلت لنهاية القائمة';

  @override
  String get retryAction => 'إعادة المحاولة';

  @override
  String get filtersAction => 'فلاتر';

  @override
  String get filtersSheetTitle => 'الفلاتر';

  @override
  String get filtersApply => 'عرض النتائج';

  @override
  String get filtersReset => 'إعادة ضبط';

  @override
  String get filterState => 'الولاية';

  @override
  String get filterCity => 'المدينة';

  @override
  String get filterPitchType => 'نوع الملعب';

  @override
  String get filterAny => 'الكل';

  @override
  String stadiumActivePitches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملاعب',
      one: 'ملعب واحد',
      zero: 'ما في ملاعب',
    );
    return '$_temp0';
  }

  @override
  String get stadiumPhotoPlaceholder => 'قريبًا';

  @override
  String get stadiumPhotoUnavailable => 'غير متاحة';

  @override
  String get stadiumDetailPlaceholderTitle => 'الملعب';

  @override
  String get stadiumDetailPlaceholderBody => 'تفاصيل الملعب تأتي في المرحلة التالية.';

  @override
  String stadiumDetailIdLabel(String id) {
    return 'معرّف الملعب: $id';
  }

  @override
  String get stadiumDetailAbout => 'نبذة';

  @override
  String get stadiumDetailRules => 'القواعد';

  @override
  String get stadiumDetailPitches => 'الملاعب';

  @override
  String get stadiumDetailFacilities => 'المرافق';

  @override
  String get stadiumDetailLocation => 'الموقع';

  @override
  String get stadiumDetailShowMore => 'عرض المزيد';

  @override
  String get stadiumDetailShowLess => 'عرض أقل';

  @override
  String get stadiumDetailChoosePitch => 'اختر ملعبًا';

  @override
  String get stadiumDetailGetDirections => 'الحصول على الاتجاهات';

  @override
  String get stadiumDetailCallStadium => 'اتصل بالملعب';

  @override
  String get stadiumDetailNoPitches => 'لا توجد ملاعب قابلة للحجز الآن.';

  @override
  String get stadiumDetailErrorBody => 'تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get stadiumDetailErrorTitle => 'تعذّر تحميل الملعب';

  @override
  String get stadiumDetailIndoor => 'داخلي';

  @override
  String get stadiumDetailRoofed => 'مسقوف';

  @override
  String get stadiumDetailSummarySemantic => 'ملخص الملعب';

  @override
  String stadiumDetailPitchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملاعب',
      one: 'ملعب واحد',
      zero: 'لا ملاعب',
    );
    return '$_temp0';
  }

  @override
  String stadiumDetailFacilityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مرافق',
      one: 'مرفق واحد',
      zero: 'لا مرافق',
    );
    return '$_temp0';
  }

  @override
  String stadiumDetailPhotoCount(int current, int total) {
    return '$current / $total';
  }

  @override
  String stadiumDetailPhotoSemantic(String name, int current, int total) {
    return 'صورة $name، $current من $total';
  }

  @override
  String get amenityParking => 'موقف سيارات';

  @override
  String get amenityChangingRooms => 'غرف تبديل';

  @override
  String get amenityToilets => 'دورات مياه';

  @override
  String get amenitySeating => 'مقاعد';

  @override
  String get amenityCafe => 'مقهى';

  @override
  String get amenityPrayerArea => 'مصلى';

  @override
  String get amenityWater => 'مياه للشرب';

  @override
  String get amenityFirstAid => 'إسعافات أولية';

  @override
  String get surfaceNaturalGrass => 'عشب طبيعي';

  @override
  String get surfaceArtificialTurf => 'عشب صناعي';

  @override
  String get surfaceFutsal => 'صالة';

  @override
  String get surfaceOther => 'سطح آخر';

  @override
  String get pitchDetailPlaceholderTitle => 'الملعب الفرعي';

  @override
  String get pitchDetailPlaceholderBody => 'توفر المواعيد يأتي في المرحلة التالية.';

  @override
  String pitchDetailIdLabel(String id) {
    return 'معرّف الملعب: $id';
  }

  @override
  String get pitchDetailErrorTitle => 'تعذر تحميل الملعب';

  @override
  String get pitchDetailErrorBody => 'تحقق من اتصالك ثم أعد المحاولة.';

  @override
  String get pitchDetailShareTooltip => 'مشاركة';

  @override
  String pitchDetailShareText(String pitch, String stadium) {
    return '$pitch في $stadium — خماسيات';
  }

  @override
  String get pitchDetailOutdoor => 'خارجي';

  @override
  String pitchDetailFromPrice(String price) {
    return 'من $price / فترة';
  }

  @override
  String get pitchDetailSelectDate => 'التاريخ';

  @override
  String get pitchDetailCalendarTooltip => 'اختيار تاريخ';

  @override
  String get pitchDetailAvailableTimes => 'الأوقات المتاحة';

  @override
  String get pitchDetailMorning => 'صباح';

  @override
  String get pitchDetailAfternoon => 'بعد الظهر';

  @override
  String get pitchDetailEvening => 'مساء';

  @override
  String get pitchDetailNoSlots => 'لا توجد أوقات متاحة في هذا التاريخ.';

  @override
  String get pitchDetailChooseAnotherDate => 'اختر تاريخًا آخر';

  @override
  String get pitchDetailSlotUnavailable => 'هذا الموعد لم يعد متاحًا. يُرجى اختيار وقت آخر.';

  @override
  String get pitchDetailRefreshFailed => 'تعذر تحديث الأوقات.';

  @override
  String get pitchDetailSlotAvailable => 'متاح';

  @override
  String pitchDetailDurationHoursMinutes(int hours, int minutes) {
    return '$hours س و $minutes د';
  }

  @override
  String pitchDetailDurationHours(int hours) {
    return '$hours س';
  }

  @override
  String pitchDetailDurationMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String pitchDetailTimezoneNote(String timeZone) {
    return 'الأوقات حسب التوقيت المحلي للملعب ($timeZone).';
  }

  @override
  String get pitchDetailContinue => 'متابعة';

  @override
  String get pitchDetailBookingSuccess => 'بدأ الحجز. أكمل الدفع من صفحة الحجوزات.';

  @override
  String pitchDetailPhotoSemantic(String name, int current, int total) {
    return 'صورة $name، $current من $total';
  }

  @override
  String pitchDetailSlotSemantic(String start, String end) {
    return '$start إلى $end';
  }

  @override
  String get bookingReviewTitle => 'مراجعة الحجز';

  @override
  String get bookingReviewYourBooking => 'حجزك';

  @override
  String get bookingReviewCustomer => 'العميل';

  @override
  String get bookingReviewNameLabel => 'الاسم';

  @override
  String get bookingReviewPitchLabel => 'الملعب';

  @override
  String get bookingReviewTypeLabel => 'النوع';

  @override
  String get bookingReviewDateLabel => 'التاريخ';

  @override
  String get bookingReviewTimeLabel => 'الوقت';

  @override
  String get bookingReviewDurationLabel => 'المدة';

  @override
  String get bookingReviewTotalLabel => 'الإجمالي';

  @override
  String get bookingReviewPriceDetails => 'تفاصيل السعر';

  @override
  String get bookingReviewPitchReservation => 'حجز الملعب';

  @override
  String get bookingReviewNotReservedYet => 'موعدك غير محجوز بعد.\nاضغط «احجز هذا الموعد» لحجزه مؤقتًا أثناء إكمال الدفع.';

  @override
  String get bookingReviewCheckDetails => 'يرجى التحقق من تفاصيل حجزك قبل تأكيد هذا الموعد.';

  @override
  String get bookingReviewCancel => 'إلغاء';

  @override
  String get bookingReviewBookSlot => 'احجز هذا الموعد';

  @override
  String get bookingReservedTitle => 'تم حجز الموعد مؤقتًا';

  @override
  String get bookingReservedBody => 'هذا الوقت محجوز لك مؤقتًا. أكمل الدفع قبل انتهاء مدة الحجز لتأكيد حجزك.';

  @override
  String bookingReservedHoldUntil(String time) {
    return 'الحجز ساري حتى $time';
  }

  @override
  String get bookingReservedContinuePayment => 'متابعة إلى الدفع';

  @override
  String get bookingConflictTitle => 'هذا الموعد لم يعد متاحًا.';

  @override
  String get bookingConflictBody => 'حجز شخص آخر هذا الموعد أثناء مراجعتك. يُرجى اختيار وقت آخر.';

  @override
  String get bookingConflictChooseAnother => 'اختر وقتًا آخر';

  @override
  String get paymentTitle => 'الدفع';

  @override
  String get paymentPlaceholderTitle => 'الدفع';

  @override
  String get paymentPlaceholderBody => 'طرق الدفع تأتي في المرحلة التالية.';

  @override
  String paymentBookingIdLabel(String id) {
    return 'معرّف الحجز: $id';
  }

  @override
  String paymentHoldsUntilLabel(String time) {
    return 'الحجز حتى: $time';
  }

  @override
  String paymentStatusPendingLabel(String status) {
    return 'الحالة: $status';
  }

  @override
  String get paymentHoldReservedTitle => 'موعدك محجوز مؤقتًا';

  @override
  String paymentHoldRemaining(String time) {
    return 'متبقي $time';
  }

  @override
  String get paymentHoldHint => 'أكمل الدفع قبل انتهاء مدة الحجز.';

  @override
  String get paymentBookingSummary => 'ملخص الحجز';

  @override
  String paymentAmountLabel(String amount) {
    return 'المبلغ: $amount';
  }

  @override
  String get paymentChooseMethod => 'اختر طريقة الدفع';

  @override
  String get paymentNoMethods => 'لا تتوفر طرق دفع لهذا الملعب حاليًا.';

  @override
  String get paymentMethodsLoadFailed => 'تعذر تحميل طرق الدفع.';

  @override
  String get paymentErrorReceiptStorageUnavailable => 'رفع الإيصال غير متاح مؤقتًا. ادفع نقدًا أو حاول لاحقًا.';

  @override
  String get paymentMethodCash => 'نقدًا في الملعب';

  @override
  String get paymentMethodBankak => 'بنكك';

  @override
  String get paymentMethodBankTransfer => 'تحويل بنكي';

  @override
  String paymentMethodLabel(String method) {
    return 'الطريقة: $method';
  }

  @override
  String get paymentCashInstructions => 'ادفع نقدًا في الملعب وفق تعليمات المكان.';

  @override
  String get paymentAccountHolder => 'اسم الحساب';

  @override
  String get paymentAccountNumber => 'رقم الحساب';

  @override
  String get paymentBankName => 'البنك';

  @override
  String get paymentIban => 'IBAN';

  @override
  String get paymentPhoneNumber => 'الهاتف';

  @override
  String get paymentReferenceLabel => 'مرجع التحويل';

  @override
  String get paymentReferenceHint => 'أدخل مرجع التحويل';

  @override
  String get paymentReceiptTitle => 'الإيصال';

  @override
  String get paymentReceiptHint => 'JPEG أو PNG أو WebP أو PDF حتى 5 ميجابايت.';

  @override
  String get paymentChooseReceipt => 'اختر إيصالًا';

  @override
  String get paymentReplaceReceipt => 'استبدال';

  @override
  String get paymentRemoveReceipt => 'إزالة';

  @override
  String paymentReceiptSize(String size) {
    return 'الحجم: $size';
  }

  @override
  String get paymentUploading => 'جارٍ رفع الإيصال…';

  @override
  String get paymentSubmit => 'إرسال الدفع';

  @override
  String get paymentGenericError => 'حدث خطأ. يُرجى المحاولة مرة أخرى.';

  @override
  String get paymentErrorUnsupportedType => 'نوع الملف غير مدعوم. استخدم JPEG أو PNG أو WebP أو PDF.';

  @override
  String get paymentErrorOversized => 'الملف كبير جدًا. الحد الأقصى 5 ميجابايت.';

  @override
  String get paymentRetryLoad => 'إعادة المحاولة';

  @override
  String get paymentSubmittedTitle => 'تم إرسال الدفع';

  @override
  String get paymentSubmittedBody => 'دفعك بانتظار تأكيد الملعب.';

  @override
  String get paymentSubmittedNotConfirmed => 'الحجز غير مؤكد بعد.';

  @override
  String paymentStatusLabel(String status) {
    return 'الحالة: $status';
  }

  @override
  String get paymentStatusSubmitted => 'مُرسل';

  @override
  String get paymentStatusConfirmed => 'مؤكد';

  @override
  String get paymentStatusRejected => 'مرفوض';

  @override
  String get paymentRejectedTitle => 'الدفع يحتاج إلى مراجعة';

  @override
  String paymentRejectedBody(String reason) {
    return 'رفض الملعب هذا الإيصال:\n\"$reason\"';
  }

  @override
  String get paymentRejectedBodyGeneric => 'رفض الملعب هذا الدفع. يُرجى المحاولة بإيصال جديد.';

  @override
  String get paymentUploadAnotherReceipt => 'رفع إيصال آخر';

  @override
  String get paymentConfirmedTitle => 'تم تأكيد الحجز';

  @override
  String get paymentConfirmedBody => 'تم حجز ملعبك.';

  @override
  String get paymentExpiredTitle => 'انتهت مدة الحجز';

  @override
  String get paymentExpiredBody => 'هذا الموعد لم يعد محجوزًا.';

  @override
  String get paymentExpiredChooseAnother => 'اختر وقتًا آخر';

  @override
  String get paymentSelectMethodToContinue => 'اختر طريقة دفع للمتابعة.';

  @override
  String get paymentAddReferenceAndReceipt => 'أضف مرجعًا وإيصالًا للمتابعة.';

  @override
  String get paymentLeaveForNow => 'المغادرة الآن';

  @override
  String get paymentCancelBooking => 'إلغاء الحجز';

  @override
  String get paymentCancelBookingTitle => 'إلغاء هذا الحجز؟';

  @override
  String get paymentCancelBookingBody => 'سيتم تحرير الموعد المحجوز. لا يمكن التراجع عن هذا للحجز الحالي.';

  @override
  String get paymentCancelBookingConfirm => 'إلغاء الحجز';

  @override
  String get paymentCancelBookingKeep => 'الإبقاء على الحجز';

  @override
  String get paymentCancelledSnackbar => 'تم إلغاء الحجز.';

  @override
  String get paymentBackToHome => 'العودة إلى الرئيسية';

  @override
  String get bookingsPlaceholderTitle => 'حجوزاتك';

  @override
  String get bookingsPlaceholderBody => 'سجل الحجوزات والمباريات القادمة سيظهر هنا قريبًا.';

  @override
  String get myBookingsFilterAll => 'الكل';

  @override
  String get myBookingsFilterPending => 'قيد الانتظار';

  @override
  String get myBookingsFilterConfirmed => 'مؤكد';

  @override
  String get myBookingsFilterCompleted => 'مكتمل';

  @override
  String get myBookingsUpcoming => 'القادمة';

  @override
  String get myBookingsPast => 'السابقة';

  @override
  String get myBookingsEmptyTitle => 'لا حجوزات بعد';

  @override
  String get myBookingsEmptyBody => 'ستظهر مبارياتك القادمة هنا.';

  @override
  String get myBookingsFindPitch => 'ابحث عن ملعب';

  @override
  String get myBookingsEmptyPending => 'لا توجد حجوزات قيد الانتظار';

  @override
  String get myBookingsEmptyConfirmed => 'لا توجد حجوزات مؤكدة';

  @override
  String get myBookingsEmptyCompleted => 'لا توجد حجوزات مكتملة';

  @override
  String get myBookingsLoadFailed => 'تعذر تحميل حجوزاتك.';

  @override
  String get myBookingsTryAgain => 'إعادة المحاولة';

  @override
  String get myBookingsStatusPaymentRequired => 'يلزم الدفع';

  @override
  String get myBookingsStatusWaiting => 'بانتظار التأكيد';

  @override
  String get myBookingsStatusRejected => 'الدفع مرفوض';

  @override
  String get myBookingsStatusConfirmed => 'مؤكد';

  @override
  String get myBookingsStatusCancelled => 'ملغى';

  @override
  String get myBookingsStatusCompleted => 'مكتمل';

  @override
  String get myBookingsStatusExpired => 'منتهٍ';

  @override
  String get myBookingsCompletePayment => 'إكمال الدفع';

  @override
  String get myBookingsRetryPayment => 'إعادة الدفع';

  @override
  String get myBookingsViewPayment => 'عرض الدفع';

  @override
  String get myBookingsViewBooking => 'عرض الحجز';

  @override
  String get myBookingsRejectedHint => 'طلب الملعب دفعة جديدة.';

  @override
  String get myBookingsDetailTitle => 'الحجز';

  @override
  String get bookingDetailLoadFailed => 'تعذر تحميل الحجز.';

  @override
  String get bookingDetailEntryPin => 'رمز الدخول';

  @override
  String get bookingDetailShowPin => 'إظهار الرمز';

  @override
  String get bookingDetailHidePin => 'إخفاء الرمز';

  @override
  String get bookingDetailCopyPin => 'نسخ الرمز';

  @override
  String get bookingDetailPinCopied => 'تم نسخ الرمز';

  @override
  String get bookingDetailPinHint => 'أظهر هذا الرمز عند الوصول.';

  @override
  String get bookingDetailPinLoadFailed => 'تعذر تحميل رمز الدخول.';

  @override
  String get bookingDetailPinHiddenSemantic => 'رمز الدخول مخفي';

  @override
  String get bookingDetailPayment => 'الدفع';

  @override
  String get bookingDetailPaymentConfirmed => 'تم تأكيد الدفع';

  @override
  String get bookingDetailPaymentExpired => 'انتهت صلاحية الدفع';

  @override
  String get bookingDetailPaymentRefunded => 'مسترد';

  @override
  String get bookingDetailWaitingBody => 'تم إرسال الدفع وهو بانتظار مراجعة الملعب.';

  @override
  String get bookingDetailBookingId => 'رقم الحجز';

  @override
  String get bookingDetailContactStadium => 'التواصل مع الملعب';

  @override
  String get bookingDetailPrice => 'السعر';

  @override
  String get bookingDetailMethod => 'الطريقة';

  @override
  String get bookingDetailDimensions => 'الأبعاد';

  @override
  String get bookingDetailSurface => 'السطح';

  @override
  String get bookingDetailCheckedIn => 'تم تسجيل الحضور';

  @override
  String get profileTitle => 'حسابك';

  @override
  String get profileImmutableHint => 'لا يمكن تغيير البريد الإلكتروني أو رقم الهاتف من هنا.';

  @override
  String get profileEditName => 'تعديل الاسم';

  @override
  String get profileEditNameTitle => 'تعديل الاسم';

  @override
  String get profileEditNameSubtitle => 'يظهر هذا الاسم في حجوزاتك وعلى الشاشة الرئيسية.';

  @override
  String get profileSaveName => 'حفظ الاسم';

  @override
  String get profileNameUpdated => 'تم تحديث الاسم.';

  @override
  String get profileEmailVerified => 'موثّق';

  @override
  String get profileEmailUnverified => 'غير موثّق';

  @override
  String get profileEmailStatusLabel => 'حالة البريد';

  @override
  String get profileLanguageArabic => 'العربية';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get pitchTypeFiveASide => 'خماسي';

  @override
  String get pitchTypeSevenASide => 'سباعي';

  @override
  String get pitchTypeElevenASide => 'أحد عشر';

  @override
  String get pitchTypeOther => 'أخرى';

  @override
  String get stateKhartoum => 'الخرطوم';

  @override
  String get stateNorthern => 'الشمالية';

  @override
  String get stateRiverNile => 'نهر النيل';

  @override
  String get stateRedSea => 'البحر الأحمر';

  @override
  String get stateKassala => 'كسلا';

  @override
  String get stateGedaref => 'القضارف';

  @override
  String get stateGezira => 'الجزيرة';

  @override
  String get stateWhiteNile => 'النيل الأبيض';

  @override
  String get stateBlueNile => 'النيل الأزرق';

  @override
  String get stateSennar => 'سنار';

  @override
  String get stateNorthKordofan => 'شمال كردفان';

  @override
  String get stateSouthKordofan => 'جنوب كردفان';

  @override
  String get stateWestKordofan => 'غرب كردفان';

  @override
  String get stateNorthDarfur => 'شمال دارفور';

  @override
  String get stateSouthDarfur => 'جنوب دارفور';

  @override
  String get stateEastDarfur => 'شرق دارفور';

  @override
  String get stateWestDarfur => 'غرب دارفور';

  @override
  String get stateCentralDarfur => 'وسط دارفور';

  @override
  String get cityKhartoumCity => 'الخرطوم';

  @override
  String get cityOmdurman => 'أم درمان';

  @override
  String get cityBahri => 'بحري';

  @override
  String get cityDongola => 'دنقلا';

  @override
  String get cityKarima => 'كريمة';

  @override
  String get cityWadiHalfa => 'وادي حلفا';

  @override
  String get cityAtbara => 'عطبرة';

  @override
  String get cityEdDamer => 'الدامر';

  @override
  String get cityShendi => 'شندي';

  @override
  String get cityBerber => 'بربر';

  @override
  String get cityPortSudan => 'بورتسودان';

  @override
  String get citySuakin => 'سواكن';

  @override
  String get cityTokar => 'طوكر';

  @override
  String get cityKassalaCity => 'كسلا';

  @override
  String get cityNewHalfa => 'حلفا الجديدة';

  @override
  String get cityGedarefCity => 'القضارف';

  @override
  String get cityShowak => 'الشواك';

  @override
  String get cityWadMadani => 'ود مدني';

  @override
  String get cityHasahisa => 'الحصاحيصا';

  @override
  String get cityKamlin => 'الكاملين';

  @override
  String get cityManaqil => 'المناقل';

  @override
  String get cityRabak => 'ربك';

  @override
  String get cityKosti => 'كوستي';

  @override
  String get cityEdDueim => 'الدويم';

  @override
  String get cityDamazin => 'الدمازين';

  @override
  String get cityRoseires => 'الروصيرص';

  @override
  String get citySinnarCity => 'سنار';

  @override
  String get citySinga => 'سنجة';

  @override
  String get cityElObeid => 'الأبيض';

  @override
  String get cityUmRawaba => 'أم روابة';

  @override
  String get cityKadugli => 'كادقلي';

  @override
  String get cityAbuJubaiha => 'أبو جبيهة';

  @override
  String get cityAlFula => 'الفولة';

  @override
  String get cityAnNuhud => 'النهود';

  @override
  String get cityElFasher => 'الفاشر';

  @override
  String get cityKutum => 'كتم';

  @override
  String get cityNyala => 'نيالا';

  @override
  String get cityKass => 'كاس';

  @override
  String get cityEdDaein => 'الضعين';

  @override
  String get cityGeneina => 'الجنينة';

  @override
  String get cityZalingei => 'زالنجي';
}
