import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // Ensure Flutter framework is initialized before performing async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Get the instance of SharedPreferences
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  // Run the app and pass in the SettingsController and SharedPreferences instance.
  runApp(MyApp(settingsController: settingsController, sharedPreferences: sharedPreferences));
}
