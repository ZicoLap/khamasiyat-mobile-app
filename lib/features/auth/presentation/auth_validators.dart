/// Customer auth OTP length (backend default).
const kAuthOtpLength = 6;

/// UI resend cooldown after a successful OTP send/resend.
const kOtpResendCooldown = Duration(seconds: 60);

/// Minimum password length aligned with backend.
const kMinPasswordLength = 8;

bool isValidPasswordShape(String password) {
  if (password.length < kMinPasswordLength) {
    return false;
  }
  final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
  final hasDigit = RegExp(r'[0-9]').hasMatch(password);
  return hasLetter && hasDigit;
}

bool isValidEmail(String email) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
}
