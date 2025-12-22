class GlobalVariables {
  static String preferredLanguage = 'en';
  static String userRole = 'member';

  static Future<void> initialize(
    Future<String?> Function() getPreferredLanguage,
  ) async {
    try {
      final language = await getPreferredLanguage();
      preferredLanguage = language ?? 'en';
    } catch (e) {
      preferredLanguage = 'en';
    }
  }

  static void setPreferredLanguage(String language) {
    preferredLanguage = language;
  }

  static String getPreferredLanguage() {
    return preferredLanguage;
  }

  static void setUserRole(String role) {
    userRole = role;
  }

  static String getUserRole() {
    return userRole;
  }
}
