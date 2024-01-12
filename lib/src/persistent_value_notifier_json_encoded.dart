// flutter_persistent_value_notifier library
//
// (C) 2024 Luke Hutchison
//
// Published under MIT license
//
// Source hosted at:
// https://github.com/lukehutch/flutter_persistent_value_notifier

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_persistent_value_notifier/src/shared_preferences_instance.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A nullable [ValueNotifier] that persists an object by using
/// [SharedPreferences] as a write-through cache.
class PersistentValueNotifierJsonEncoded<T> extends ChangeNotifier
    implements ValueListenable<T> {
  /// The key to use when storing in SharedPreferences.
  final String sharedPreferencesKey;

  /// The value encoded as Json
  late String _valueJson;

  /// The value, cached, unencoded
  late T _cachedValue;

  final String Function(T) toJson;
  final T Function(String) fromJson;

  /// A nullable [ValueNotifier] backed by [SharedPreferences].
  /// [sharedPreferencesKey] specifies the key to use when storing the value
  /// in [SharedPreferences]. [initialValue] is the initial value to set the
  /// [ValueNotifier] to.
  PersistentValueNotifierJsonEncoded({
    required this.sharedPreferencesKey,
    required T initialValue,
    required this.toJson,
    required this.fromJson,
  }) {
    if (sharedPreferencesInstance == null) {
      throw 'Need to call `await initPersistentValueNotifier()` before '
          'instantiating PersistentValueNotifier';
    }
    // Initialize value from SharedPreferences, or from initialValue
    // if SharedPreferences doesn't have a value for this key yet
    final existingPersitentValueJson =
        sharedPreferencesInstance!.getString(sharedPreferencesKey);

    if (existingPersitentValueJson != null) {
      _valueJson = existingPersitentValueJson;
      try {
        _cachedValue = fromJson(existingPersitentValueJson);
      } catch (e) {
        // Error -- probably there was a schema change
        stderr.writeln(
          'Error decoding value from SharedPreferences '
          '(possible schema change?). Defaulting to initialValue. '
          '$sharedPreferencesKey = $existingPersitentValueJson',
        );
        _cachedValue = initialValue;
      }
    } else {
      _valueJson = toJson(initialValue);
      _cachedValue = initialValue;
    }
  }

  @override
  T get value => _cachedValue;

  /// Set value, and asynchronously write through to SharedPreferences
  /// if the JSON representation of the value has changed.
  set value(T newValue) {
    _cachedValue = newValue;
    final newValueJson = toJson(newValue);
    if (_valueJson == newValueJson) {
      // Check for JSON equality
      return;
    }
    _valueJson = newValueJson;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    // Asynchronously write the new value through to SharedPreferences
    // when a change is notified
    sharedPreferencesInstance!
        .setString(sharedPreferencesKey, _valueJson)
        .then((success) {
      if (!success) {
        // Should not happen (I don't know when the platform backends could
        // return false), but check anyway
        stderr.writeln('Could not write value to SharedPreferences: '
            '$sharedPreferencesKey = $_valueJson');
      }
    });
    super.notifyListeners();
  }
}
