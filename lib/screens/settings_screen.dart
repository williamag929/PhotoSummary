import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  bool _isAiSummaryEnabled = true;
  bool _isCalendarViewEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isAiEnabled = await _settingsService.isAiSummaryEnabled();
    final isCalendarEnabled = await _settingsService.isCalendarViewEnabled();
    setState(() {
      _isAiSummaryEnabled = isAiEnabled;
      _isCalendarViewEnabled = isCalendarEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Enable AI Summary Generation'),
            value: _isAiSummaryEnabled,
            onChanged: (bool value) {
              setState(() {
                _isAiSummaryEnabled = value;
              });
              _settingsService.setAiSummaryEnabled(value);
            },
            subtitle: Text(
              _isAiSummaryEnabled
                  ? 'The AI will generate a structured summary from your notes.'
                  : 'A simple report will be generated with the raw text from your notes.',
            ),
          ),
          SwitchListTile(
            title: Text('Enable Calendar View (Premium)'),
            value: _isCalendarViewEnabled,
            onChanged: (bool value) {
              setState(() {
                _isCalendarViewEnabled = value;
              });
              _settingsService.setCalendarViewEnabled(value);
            },
            subtitle: Text('View reports in a calendar view.'),
          ),
        ],
      ),
    );
  }
}