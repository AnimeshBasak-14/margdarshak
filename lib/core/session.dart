import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Languages offered for speaking to the assistant. Bhashini covers all 22
/// scheduled languages; these are the ones surfaced first in the picker.
enum AppLanguage {
  english('English', 'English'),
  hindi('Hindi', 'हिन्दी'),
  bengali('Bengali', 'বাংলা'),
  assamese('Assamese', 'অসমীয়া'),
  marathi('Marathi', 'मराठी'),
  tamil('Tamil', 'தமிழ்'),
  telugu('Telugu', 'తెలుగు');

  final String englishName;
  final String nativeName;
  const AppLanguage(this.englishName, this.nativeName);

  bool get needsTranslation => this != AppLanguage.english;
}

/// App-wide settings the screens read and change.
class Session extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  AppLanguage _language = AppLanguage.english;
  String? _stateCode;

  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;

  /// The state the user follows, or null if they haven't picked one yet.
  String? get stateCode => _stateCode;

  static const _stateKey = 'state_code';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _stateCode = prefs.getString(_stateKey);
      notifyListeners();
    } catch (_) {
      // No storage available: the choice just won't survive a restart.
    }
  }

  Future<void> selectState(String? code) async {
    _stateCode = code;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      code == null ? await prefs.remove(_stateKey) : await prefs.setString(_stateKey, code);
    } catch (_) {}
  }

  /// Flips to the opposite of what is on screen right now.
  void toggleTheme(Brightness current) {
    _themeMode =
        current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  set language(AppLanguage value) {
    if (value == _language) return;
    _language = value;
    notifyListeners();
  }
}

class SessionScope extends InheritedNotifier<Session> {
  const SessionScope({
    super.key,
    required Session session,
    required super.child,
  }) : super(notifier: session);

  static Session of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SessionScope>()!.notifier!;
}
