import 'package:flutter_persistent_value_notifier/flutter_persistent_value_notifier.dart';
import 'package:flutter_persistent_value_notifier/src/shared_preferences_instance.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initialize [SharedPreferences] for [PersistentValueNotifier],
/// and read initial persisted values. Must be called before any
/// [PersistentValueNotifier] or [PersistentValueNotifierEnum]
/// instances are created.
Future<void> initPersistentValueNotifier() async =>
    sharedPreferencesInstance = await SharedPreferences.getInstance();
