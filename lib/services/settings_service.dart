import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _aiSummaryEnabledKey = 'ai_summary_enabled';
  static const String _calendarViewEnabledKey = 'calendar_view_enabled';

  Future<void> setAiSummaryEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiSummaryEnabledKey, isEnabled);
  }

  Future<bool> isAiSummaryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_aiSummaryEnabledKey) ?? true; // Default to true
  }

  Future<void> setCalendarViewEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_calendarViewEnabledKey, isEnabled);
  }

  Future<bool> isCalendarViewEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_calendarViewEnabledKey) ?? true; // Default to true
  }
}
