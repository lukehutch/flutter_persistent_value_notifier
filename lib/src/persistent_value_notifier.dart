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

/// Stores the SharedPreferences instance once it is initialized.
final _sharedPreferencesNotifier = ValueNotifier<SharedPreferences?>(null)
  ..addListener(() {});

/// Initialize [SharedPreferences] for [PersistentValueNotifier],
/// and read initial persisted values
Future<void> initPersistentValueNotifier() async =>
    _sharedPreferencesNotifier.value = await SharedPreferences.getInstance();

/// A nullable [ValueNotifier] that persists value changes by using
/// [SharedPreferences] as a write-through cache.
class PersistentValueNotifier<T> extends ValueNotifier<T> {
  /// The key to use when storing in SharedPreferences.
  final String sharedPreferencesKey;

  /// Function that is run when SharedPreferences is initialized, if it's not
  /// initialized yet when the constructor is run. Updates the value.
  void Function()? _updateToLatestValue;

  /// Run when SharedPreferences is initialized, if it's not initialized yet
  /// when the constructor is run
  void _onSharedPreferencesInit() {
    if (_updateToLatestValue != null) {
      _updateToLatestValue!();
      _updateToLatestValue = null;
    }
    _sharedPreferencesNotifier.removeListener(_onSharedPreferencesInit);
  }

  /// A nullable [ValueNotifier] backed by [SharedPreferences].
  /// [sharedPreferencesKey] specifies the key to use when storing the value
  /// in [SharedPreferences]. [initialValue] is the initial value to set the
  /// [ValueNotifier] to.
  PersistentValueNotifier(
      {required this.sharedPreferencesKey, required T initialValue})
      : super(initialValue) {
    if (_sharedPreferencesNotifier.value == null) {
      // SharedPreferences is not initialized yet -- delay update for when
      // it is initialized
      _updateToLatestValue =
          () => _readFromSharedPreferencesAndSetValue(initialValue);
      // Add listner to detect when SharedPreferences is initialized
      _sharedPreferencesNotifier.addListener(_onSharedPreferencesInit);
    } else {
      // Initialize value right now from SharedPreferences, or from initialValue
      // if SharedPreferences doesn't have a value for this key yet
      _readFromSharedPreferencesAndSetValue(initialValue);
    }
  }

  @override
  set value(T newValue) {
    if (_sharedPreferencesNotifier.value == null) {
      // SharedPreferences is not initialized yet -- delay update for when
      // it is initialized
      _updateToLatestValue =
          () => _setValueAndWriteToSharedPreferences(newValue);
    } else {
      // Set value now, and write through to SharedPreferences
      _setValueAndWriteToSharedPreferences(newValue);
    }
  }

  void _readFromSharedPreferencesAndSetValue(T initialValue) {
    final sharedPreferences = _sharedPreferencesNotifier.value!;
    super.value = switch (this) {
          PersistentValueNotifier<int?>() =>
            sharedPreferences.getInt(sharedPreferencesKey) as T?,
          PersistentValueNotifier<bool?>() =>
            sharedPreferences.getBool(sharedPreferencesKey) as T?,
          PersistentValueNotifier<double?>() =>
            sharedPreferences.getDouble(sharedPreferencesKey) as T?,
          PersistentValueNotifier<String?>() =>
            sharedPreferences.getString(sharedPreferencesKey) as T?,
          PersistentValueNotifier<List<String>?>() =>
            sharedPreferences.getStringList(sharedPreferencesKey) as T?,
          _ => throw Exception('Type parameter not supported: $runtimeType'),
        } ??
        initialValue;
  }

  void _setValueAndWriteToSharedPreferences(T newValue) {
    final sharedPreferences = _sharedPreferencesNotifier.value!;
    // Update the `ValueNotifier` superclass with the new value
    super.value = newValue;
    // Asynchronously write the new value through to SharedPreferences
    (switch (newValue) {
      null => sharedPreferences.remove(sharedPreferencesKey),
      int() => sharedPreferences.setInt(sharedPreferencesKey, newValue),
      bool() => sharedPreferences.setBool(sharedPreferencesKey, newValue),
      double() => sharedPreferences.setDouble(sharedPreferencesKey, newValue),
      String() => sharedPreferences.setString(sharedPreferencesKey, newValue),
      List<String>() =>
        sharedPreferences.setStringList(sharedPreferencesKey, newValue),
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
