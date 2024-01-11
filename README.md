# The `flutter_persistent_value_notifier` library

`ReactiveValue` resets to its initial value every time the app is restarted. You can persist values across app restarts by using `PersistentValueNotifier` rather than `ValueNotifier`.

This Flutter library extends [`ValueNotifier<T>`](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) to provide a `PersistentValueNotifier` that stores the `ValueNotifier`'s `value` in [`SharedPreferences`](https://pub.dev/packages/shared_preferences), so that changes in the `value` survive app restarts.

## Usage

(1) Add a dependency upon `flutter_persistent_value_notifier` in your `pubspec.yaml` (replace `any` with the latest version, if you want to control the version), then run `flutter pub get`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_persistent_value_notifier: any
```

(2) Import the package in your Flutter project:

```dart
import 'package:flutter_persistent_value_notifier/'
            'flutter_persistent_value_notifier.dart';
```

(3) In your async `main` method, initialize `WidgetsFlutterBinding`, then initialize the `persistent_value_notifier` library by calling `await initPersistentValueNotifier()`, which starts `SharedPreferences` and loads any persisted values from the `SharedPreferences` backing store.

```dart
void main() async {
  // Both of the following lines are needed, in this order
  WidgetsFlutterBinding.ensureInitialized();
  await initPersistentValueNotifier(prefix: 'com.myapp.');  // A unique SharedPreferences prefix for your app

  runApp(MainPage());
}
```

(4) Use `PersistentValueNotifier` in place of `ValueNotifier` in your code, as shown below.

```dart
final counter = PersistentValueNotifier<int>(
  sharedPreferencesKey: 'counter',
  initialValue: 0,
);
```

`counter.value` will be set to the initial value of `0` if it has never been set before, but if it has been set before in a previous run of the app, the previous value will be recovered from `SharedPreferences` instead, using the shared preferences key `'counter'`.

Whenever `counter.value` is set in future, not only is the underlying `ValueNotifier`'s `value` updated, but the new value is asynchronously written through to `SharedPreferences`, using the same key.

## Variants

You can also use `PersistentValueNotifierEnum` to persistently store enum values:

```dart
enum Fruit { apple, pair, banana };

final fruit = PersistentValueNotifierEnum<Fruit>(
  sharedPreferencesKey: 'fruit',
  initialValue: Fruit.apple,
  nameToValueMap: Fruit.values.asNameMap(),
);
```

Or you can use `PersistentValueNotifierJsonEncoded` to persistently store arbitrary JSON-serializable classes:

```dart
final fruit = PersistentValueNotifierJsonEncoded<UserProfile>(
  sharedPreferencesKey: 'user-profile',
  initialValue: UserProfile(),
  toJson: UserProfile.toJson,
  fromJson: UserProfile.fromJson,
);
```

## Pro-tip

See also my other library, [`flutter_reactive_value`](https://github.com/lukehutch/flutter_reactive_value), as an easy way to add reactive state to your app!

## Author

`flutter_persistent_value_notifier` was written by Luke Hutchison, and is released under the MIT license.
