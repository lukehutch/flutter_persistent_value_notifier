// flutter_persistent_value_notifier library
//
// (C) 2023 Luke Hutchison
//
// Published under MIT license
//
// Source hosted at:
// https://github.com/lukehutch/flutter_persistent_value_notifier

import 'package:flutter/foundation.dart';
import 'package:flutter_persistent_value_notifier/src/shared_preferences_instance.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A nullable [ValueNotifier] that persists enum value changes by using
/// [SharedPreferences] as a write-through cache.
class PersistentValueNotifierEnum<T extends Enum> extends ValueNotifier<T> {
  /// The key to use when storing in SharedPreferences.
  final String sharedPreferencesKey;
  final T initialValue;
  final T Function(String) enumValueFromName;

  /// A nullable [ValueNotifier] backed by [SharedPreferences].
  /// [sharedPreferencesKey] specifies the key to use when storing the value
  /// in [SharedPreferences]. [initialValue] is the initial value to set the
  /// [ValueNotifier] to.
  PersistentValueNotifierEnum({
    required this.sharedPreferencesKey,
    required this.initialValue,
    required this.enumValueFromName,
  }) : super(initialValue) {
    if (sharedPreferencesInstance == null) {
      throw 'Need to call `await initPersistentValueNotifier()` before '
          'instantiating PersistentValueNotifier';
    }
    // Initialize value from SharedPreferences, or from initialValue
    // if SharedPreferences doesn't have a value for this key yet
    final enumName = sharedPreferencesInstance!.getString(sharedPreferencesKey);
    try {
      // Use initialValue if no value exists in SharedPreferences for
      // sharedPreferencesKey; otherwise, try parsing initial enum value
      // name from SharedPreferences
      super.value =
          enumName == null ? initialValue : enumValueFromName(enumName);
    } catch (e) {
      // If an enum constant of this name doesn't exist, then fall back on
      // the initial value (an enum value was removed since last time the
      // app was run)
      super.value = initialValue;
    }
  }

  //// Set value, and asynchronously write through to SharedPreferences
  @override
  set value(T newValue) {
    // Update the `ValueNotifier` superclass with the new value
    super.value = newValue;
    // Asynchronously write the new value through to SharedPreferences
    sharedPreferencesInstance!
        .setString(sharedPreferencesKey, newValue.name)
        .then((success) {
      if (!success) {
        // Should not happen (I don't know when the platform backends could
        // return false), but check anyway
        throw Exception('Could not write value to SharedPreferences: '
            '$sharedPreferencesKey = $newValue');
      }
    });
  }
}
