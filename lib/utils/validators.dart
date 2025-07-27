class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    //Regex for email
    final emailRegEx = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegEx.hasMatch(value)) {
      return 'Invalid Email Address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    //Minimum length for password
    if (value.length < 8) {
      return 'Use atleast 8 characters';
    }

    //Regex for strong password
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Include atleast one uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Include atleast one digit';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Include atleast one special character';
    }

    return null;
  }

  static String? isEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    return null;
  }

  static String? hasToken(String? value) {
    if (value == null || value.isEmpty) {
      return 'Reset Token is required';
    }

    return null;
  }

}
