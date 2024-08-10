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

/// A nullable [ValueNotifier] that persists a `Map<String, dynamic>` by using
/// [SharedPreferences] as a write-through cache.
class PersistentValueNotifierMap
    extends PersistentValueNotifierJsonEncoded<Map<String, dynamic>> {
  PersistentValueNotifierMap({
    required super.sharedPreferencesKey,
  }) : super(
          initialValue: {},
          toJson: jsonEncode,
          fromJson: (jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>,
        );

  @override
  get value => throw 'User the [] operator directly on the '
      'PersistentValueNotifierMap object instead';

  @override
  set value(Map<String, dynamic> map) => 'Use the []= operator directly on the '
      'PersistentValueNotifierMap object instead';

  void operator [](String key) => super.value[key];

  void operator []=(String key, dynamic value) {
    final oldValue = super.value[key];
    if (oldValue != value) {
      super.value[key] = value;
      notifyListeners();
    }
  }

  void remove(String key) {
    final wasPresent = super.value.containsKey(key);
    if (wasPresent) {
      super.value.remove(key);
      notifyListeners();
    }
  }

  void clear() {
    if (super.value.isNotEmpty) {
      super.value.clear();
      notifyListeners();
    }
  }

  void addAll(Map<String, dynamic> map) {
    var changed = false;
    for (final key in map.keys) {
      if (!changed) {
        final oldValue = super.value[key];
        if (oldValue != map[key]) {
          super.value[key] = map[key];
          changed = true;
        }
      } else {
        super.value[key] = map[key];
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  bool containsKey(String key) => super.value.containsKey(key);

  bool containsValue(dynamic value) => super.value.containsValue(value);

  int get length => super.value.length;

  bool get isEmpty => super.value.isEmpty;

  bool get isNotEmpty => super.value.isNotEmpty;
}
