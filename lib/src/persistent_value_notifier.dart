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
    switch (runtimeType) {
      case PersistentValueNotifier<int>:
      case PersistentValueNotifier<int?>:
        super.value = _sharedPreferences!.getInt(sharedPreferencesKey) as T? ??
            initialValue;
        break;
      case PersistentValueNotifier<bool>:
      case PersistentValueNotifier<bool?>:
        super.value = _sharedPreferences!.getBool(sharedPreferencesKey) as T? ??
            initialValue;
        break;
      case PersistentValueNotifier<double>:
      case PersistentValueNotifier<double?>:
        super.value =
            _sharedPreferences!.getDouble(sharedPreferencesKey) as T? ??
                initialValue;
        break;
      case PersistentValueNotifier<String>:
      case PersistentValueNotifier<String?>:
        super.value =
            _sharedPreferences!.getString(sharedPreferencesKey) as T? ??
                initialValue;
        break;
      case PersistentValueNotifier<List<String>>:
      case PersistentValueNotifier<List<String>?>:
        super.value =
            _sharedPreferences!.getStringList(sharedPreferencesKey) as T? ??
                initialValue;
        break;
      default:
        throw Exception('Type parameter not supported: $runtimeType');
    }
  }

  @override
  set value(T newValue) {
    // Update the `ValueNotifier` superclass with the new value
    super.value = newValue;
    // Asynchronously write the new value through to SharedPreferences
    switch (runtimeType) {
      case PersistentValueNotifier<int>:
      case PersistentValueNotifier<int?>:
        if (newValue == null) {
          unawaited(_sharedPreferences!.remove(sharedPreferencesKey));
        } else {
          unawaited(_sharedPreferences!
              .setInt(sharedPreferencesKey, newValue as int));
        }
        break;
      case PersistentValueNotifier<bool>:
      case PersistentValueNotifier<bool?>:
        if (newValue == null) {
          unawaited(_sharedPreferences!.remove(sharedPreferencesKey));
        } else {
          unawaited(_sharedPreferences!
              .setBool(sharedPreferencesKey, newValue as bool));
        }
        break;
      case PersistentValueNotifier<double>:
      case PersistentValueNotifier<double?>:
        if (newValue == null) {
          unawaited(_sharedPreferences!.remove(sharedPreferencesKey));
        } else {
          unawaited(_sharedPreferences!
              .setDouble(sharedPreferencesKey, newValue as double));
        }
        break;
      case PersistentValueNotifier<String>:
      case PersistentValueNotifier<String?>:
        if (newValue == null) {
          unawaited(_sharedPreferences!.remove(sharedPreferencesKey));
        } else {
          unawaited(_sharedPreferences!
              .setString(sharedPreferencesKey, newValue as String));
        }
        break;
      case PersistentValueNotifier<List<String>>:
      case PersistentValueNotifier<List<String>?>:
        if (newValue == null) {
          unawaited(_sharedPreferences!.remove(sharedPreferencesKey));
        } else {
          unawaited(_sharedPreferences!
              .setStringList(sharedPreferencesKey, newValue as List<String>));
        }
        break;
      default:
        // Should not happen, checked in constructor
        throw Exception('Type parameter not supported: $runtimeType');
    }
  }
}
