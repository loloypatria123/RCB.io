import 'package:flutter/material.dart';

class UIProvider extends ChangeNotifier {
  bool _rememberMe = false;
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _isDarkMode = true;
  String _selectedLanguage = 'English';

  bool get rememberMe => _rememberMe;
  bool get agreeToTerms => _agreeToTerms;
  bool get obscurePassword => _obscurePassword;
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;

  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  void toggleAgreeToTerms() {
    _agreeToTerms = !_agreeToTerms;
    notifyListeners();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void setAgreeToTerms(bool value) {
    _agreeToTerms = value;
    notifyListeners();
  }

  void setObscurePassword(bool value) {
    _obscurePassword = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setSelectedLanguage(String value) {
    _selectedLanguage = value;
    notifyListeners();
  }

  void reset() {
    _rememberMe = false;
    _agreeToTerms = false;
    _obscurePassword = true;
    _isDarkMode = true;
    _selectedLanguage = 'English';
    notifyListeners();
  }
}
