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

/// A nullable [ValueNotifier] that persists value changes by using
/// [SharedPreferences] as a write-through cache.
class PersistentValueNotifier<T> extends ValueNotifier<T> {
  /// The key to use when storing in SharedPreferences.
  final String sharedPreferencesKey;

  /// A nullable [ValueNotifier] backed by [SharedPreferences].
  /// [sharedPreferencesKey] specifies the key to use when storing the value
  /// in [SharedPreferences]. [initialValue] is the initial value to set the
  /// [ValueNotifier] to.
  PersistentValueNotifier({
    required this.sharedPreferencesKey,

    /// The initial value to set the value to, if there isn't already a value
    /// stored in SharedPreferences for sharedPreferencesKey.
    required T initialValue,
  }) : super(initialValue) {
    if (sharedPreferencesInstance == null) {
      throw 'Need to call `await initPersistentValueNotifier()` before '
          'instantiating PersistentValueNotifier';
    }
    // Initialize value from SharedPreferences, or from initialValue
    // if SharedPreferences doesn't have a value for this key yet
    super.value = switch (this) {
          PersistentValueNotifier<int?>() =>
            sharedPreferencesInstance!.getInt(sharedPreferencesKey) as T?,
          PersistentValueNotifier<bool?>() =>
            sharedPreferencesInstance!.getBool(sharedPreferencesKey) as T?,
          PersistentValueNotifier<double?>() =>
            sharedPreferencesInstance!.getDouble(sharedPreferencesKey) as T?,
          PersistentValueNotifier<String?>() =>
            sharedPreferencesInstance!.getString(sharedPreferencesKey) as T?,
          PersistentValueNotifier<List<String>?>() => sharedPreferencesInstance!
              .getStringList(sharedPreferencesKey) as T?,
          _ => throw Exception('Type parameter not supported: $runtimeType'),
        } ??
        initialValue;
  }

  //// Set value, and asynchronously write through to SharedPreferences
  @override
  set value(T newValue) {
    // Update the `ValueNotifier` superclass with the new value
    super.value = newValue;
    // Asynchronously write the new value through to SharedPreferences
    (switch (newValue) {
      null => sharedPreferencesInstance!.remove(sharedPreferencesKey),
      int() =>
        sharedPreferencesInstance!.setInt(sharedPreferencesKey, newValue),
      bool() =>
        sharedPreferencesInstance!.setBool(sharedPreferencesKey, newValue),
      double() =>
        sharedPreferencesInstance!.setDouble(sharedPreferencesKey, newValue),
      String() =>
        sharedPreferencesInstance!.setString(sharedPreferencesKey, newValue),
      List<String>() => sharedPreferencesInstance!
          .setStringList(sharedPreferencesKey, newValue),
      _ =>
        // Should not happen, checked in constructor
        throw Exception('Type parameter not supported: $runtimeType'),
    })
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
