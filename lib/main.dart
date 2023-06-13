import 'package:flutter/material.dart';

import './src/persistent_value_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPersistentValueNotifier();

  final x = PersistentValueNotifier<int>(
      sharedPreferencesKey: 'hello', initialValue: 5);

  print('${x.value}');

  x.value++;
}
