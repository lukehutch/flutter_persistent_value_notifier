// flutter_persistent_value_notifier library
//
// (C) 2023 Luke Hutchison
//
// Published under MIT license
//
// Source hosted at:
// https://github.com/lukehutch/flutter_persistent_value_notifier

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_persistent_value_notifier/src/shared_preferences_instance.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A nullable [ValueNotifier] that persists enum value changes by using
/// [SharedPreferences] as a write-through cache.
class PersistentValueNotifierEnum<T extends Enum?> extends ValueNotifier<T> {
  /// The key to use when storing in SharedPreferences.
  final String sharedPreferencesKey;

  /// The initial value to set the value to, if there isn't already a value
  /// stored in SharedPreferences for sharedPreferencesKey.
  final T initialValue;

  /// Pass in the enum's values.byName function, e.g. `MyEnum.values.byName`.
  final Map<String, T> nameToValueMap;

  /// A nullable [ValueNotifier] backed by [SharedPreferences].
  /// [sharedPreferencesKey] specifies the key to use when storing the value
  /// in [SharedPreferences]. [initialValue] is the initial value to set the
  /// [ValueNotifier] to.
  PersistentValueNotifierEnum({
    required this.sharedPreferencesKey,
    required this.initialValue,
    required this.nameToValueMap,
  }) : super(initialValue) {
    if (sharedPreferencesInstance == null) {
      throw 'Need to call `await initPersistentValueNotifier()` before '
          'instantiating PersistentValueNotifier';
    }
    // Initialize value from SharedPreferences, or from initialValue
    // if SharedPreferences doesn't have a value for this key yet
    final enumName = sharedPreferencesInstance!.getString(sharedPreferencesKey);
    // Use initialValue if no value exists in SharedPreferences for
    // sharedPreferencesKey; otherwise, try parsing initial enum value
    // name from SharedPreferences. If the name is not a valid enum
    // value name, use initialValue.
    super.value = enumName == null
        ? initialValue
        : nameToValueMap[enumName] ?? initialValue;
  }

  @override
  void notifyListeners() {
    // Asynchronously write the changed value through to SharedPreferences
    if (value == null) {
      // If the value is null, delete the key from SharedPreferences
      sharedPreferencesInstance!.remove(sharedPreferencesKey);
    } else {
      // Otherwise, write the value to SharedPreferences
      sharedPreferencesInstance!
          .setString(sharedPreferencesKey, value!.name)
          .then((success) {
        if (!success) {
          // Should not happen (I don't know when the platform backends could
          // return false), but check anyway
          stderr.writeln('Could not write value to SharedPreferences: '
              '$sharedPreferencesKey = $value');
        }
      });
      // Notify listeners
      super.notifyListeners();
    }
  }
}
