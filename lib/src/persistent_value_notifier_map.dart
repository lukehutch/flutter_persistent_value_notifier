// flutter_persistent_value_notifier library
//
// (C) 2024 Luke Hutchison
//
// Published under MIT license
//
// Source hosted at:
// https://github.com/lukehutch/flutter_persistent_value_notifier

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_persistent_value_notifier/flutter_persistent_value_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MapNotifier {
  final void Function() onChange;
  final Map<String, dynamic> _map = {};

  _MapNotifier(this.onChange);

  Map<String, dynamic> get map => _map;

  void set(Map<String, dynamic> newMap) {
    if (!mapEquals(_map, newMap)) {
      _map.clear();
      _map.addAll(newMap);
      onChange();
    }
  }

  void operator []=(String key, dynamic value) {
    final oldValue = _map[key];
    if (oldValue != value) {
      _map[key] = value;
      onChange();
    }
  }

  void remove(String key) {
    final wasPresent = _map.containsKey(key);
    if (wasPresent) {
      _map.remove(key);
      onChange();
    }
  }
}

/// A nullable [ValueNotifier] that persists a `Map<String, dynamic>` by using
/// [SharedPreferences] as a write-through cache.
class PersistentValueNotifierMap
    extends PersistentValueNotifierJsonEncoded<Map<String, dynamic>> {
  late _MapNotifier _map;

  PersistentValueNotifierMap({
    required super.sharedPreferencesKey,
  }) : super(
          initialValue: {},
          toJson: jsonEncode,
          fromJson: (jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>,
        ) {
    _map = _MapNotifier(notifyListeners);
  }

  /// Set the values in the map to the values in the given map.
  /// This copies all the key/value mappings over, rather than
  /// using the original map object.
  @override
  set value(Map<String, dynamic> map) => _map.set(map);
}
