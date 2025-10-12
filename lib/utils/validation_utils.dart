class ValidationUtils {
  // Email validation
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Phone number validation (international format)
  static final RegExp phoneRegex = RegExp(
    r'^\+?[0-9]{10,14}$',
  );

  // Password validation
  // At least 8 characters
  // Must contain at least one uppercase letter
  // Must contain at least one lowercase letter
  // Must contain at least one number
  // Must contain at least one special character
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  // Validate email
  static bool isValidEmail(String email) {
    return emailRegex.hasMatch(email);
  }

  // Validate phone number
  static bool isValidPhone(String phone) {
    return phoneRegex.hasMatch(phone);
  }

  // Validate password
  static bool isValidPassword(String password) {
    return passwordRegex.hasMatch(password);
  }

  // Check if input is email or phone
  static bool isEmail(String input) {
    return input.contains('@');
  }

  // Get validation message for password
  static String getPasswordValidationMessage(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return '';
  }
}