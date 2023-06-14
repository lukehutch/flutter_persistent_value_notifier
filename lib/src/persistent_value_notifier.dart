// flutter_persistent_value_notifier library
//
// (C) 2023 Luke Hutchison
//
// Published under MIT license
//
// Source hosted at:
// https://github.com/lukehutch/flutter_persistent_value_notifier

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? _sharedPreferences;

/// Initialize [SharedPreferences] for [PersistentValueNotifier],
/// and read initial persisted values
Future<void> initPersistentValueNotifier() async =>
    _sharedPreferences = await SharedPreferences.getInstance();

/// A nullable [ValueNotifier] that persists value changes by using
/// [SharedPreferences] as a write-through cache.
class PersistentValueNotifier<T> extends ValueNotifier<T> {
  final String sharedPreferencesKey;

  /// A nullable [ValueNotifier] backed by [SharedPreferences].
  /// [sharedPreferencesKey] specifies the key to use when storing the value
  /// in [SharedPreferences]. [initialValue] is the initial value to set the
  /// [ValueNotifier] to.
  PersistentValueNotifier(
      {required this.sharedPreferencesKey, required T initialValue})
      : super(initialValue) {
    assert(_sharedPreferences != null,
        'Need to call `await initPersistentValueNotifier()` first');
    super.value = switch (this) {
          PersistentValueNotifier<int?>() =>
            _sharedPreferences!.getInt(sharedPreferencesKey) as T?,
          PersistentValueNotifier<bool?>() =>
            _sharedPreferences!.getBool(sharedPreferencesKey) as T?,
          PersistentValueNotifier<double?>() =>
            _sharedPreferences!.getDouble(sharedPreferencesKey) as T?,
          PersistentValueNotifier<String?>() =>
            _sharedPreferences!.getString(sharedPreferencesKey) as T?,
          PersistentValueNotifier<List<String>?>() =>
            _sharedPreferences!.getStringList(sharedPreferencesKey) as T?,
          _ => throw Exception('Type parameter not supported'),
        } ??
        initialValue;
  }

  @override
  set value(T newValue) {
    // Update the `ValueNotifier` superclass with the new value
    super.value = newValue;
    // Asynchronously write the new value through to SharedPreferences
    unawaited(switch (newValue) {
      null => _sharedPreferences!.remove(sharedPreferencesKey),
      int() => _sharedPreferences!.setInt(sharedPreferencesKey, newValue),
      bool() => _sharedPreferences!.setBool(sharedPreferencesKey, newValue),
      double() => _sharedPreferences!.setDouble(sharedPreferencesKey, newValue),
      String() => _sharedPreferences!.setString(sharedPreferencesKey, newValue),
      List<String>() =>
        _sharedPreferences!.setStringList(sharedPreferencesKey, newValue),
      _ =>
        // Should not happen, checked in constructor
        throw Exception('Type parameter not supported: $runtimeType'),
    });
  }
}
