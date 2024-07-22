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
  late String _valueJsonStr;

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
    final existingPersitentValueJsonStr =
        sharedPreferencesInstance!.getString(sharedPreferencesKey);

    if (existingPersitentValueJsonStr != null) {
      _valueJsonStr = existingPersitentValueJsonStr;
      try {
        _cachedValue = fromJson(existingPersitentValueJsonStr);
      } catch (e) {
        // Error -- probably there was a schema change
        stderr.writeln(
          'Error decoding value from SharedPreferences '
          '(possible schema change?). Defaulting to initialValue. '
          '$sharedPreferencesKey = $existingPersitentValueJsonStr',
        );
        _cachedValue = initialValue;
      }
    } else {
      _valueJsonStr = toJson(initialValue);
      _cachedValue = initialValue;
    }
  }

  @override
  T get value => _cachedValue;

  /// Set value, and asynchronously write through to SharedPreferences
  /// if the JSON representation of the value has changed.
  set value(T newValue) {
    _cachedValue = newValue;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    final newValueJson = toJson(_cachedValue);
    if (_valueJsonStr == newValueJson) {
      // The JSON encoding didn't change -- don't notify listeners
      return;
    }
    // The JSON encoding changed
    _valueJsonStr = newValueJson;

    // Asynchronously write the new value through to SharedPreferences
    sharedPreferencesInstance!
        .setString(sharedPreferencesKey, _valueJsonStr)
        .then((success) {
      if (!success) {
        // Should not happen (I don't know when the platform backends could
        // return false), but check anyway
        stderr.writeln('Could not write value to SharedPreferences: '
            '$sharedPreferencesKey = $_valueJsonStr');
      }
    });
    super.notifyListeners();
  }
}
