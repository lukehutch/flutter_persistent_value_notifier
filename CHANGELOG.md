### 1.0.9

* Add `PersistentValueNotifierJsonEncoded` for persisting arbitrary JSON-serializable objects.

### 1.0.8

* Add support for `SharedPreferences.setPrefix`, by passing a `prefix` parameter to `initPersistentValueNotifier`.

### 1.0.7

* No funcitonal changes, only updates `README.md`, since the version on pub.dev contained an error.

### 1.0.6

* Use `Enum.asNameMap` (which doesn't throw an exception) instead of `Enum.byName` to get enum values from name.

### 1.0.5

* Rename `PersistentValueNotifierEnum.enumValueFromName` to `PersistentValueNotifierEnum.valuesByName` 

### 1.0.4

* Require `initPersistentValueNotifier` to be called before `PersistentValueNotifier` is used (reverts the changes in 1.0.3).
* Add `PersistentValueNotifierEnum` to support enum value storage in `SharedPreferences`.

### 1.0.3

Allow `PersistentValueNotifier` to be used with initial value if `SharedPreferences` has not yet been initialized (in case the user forgets to use `await` with `initPersistentValueNotifier`).

### 1.0.2

Improve code based on [suggestions](https://github.com/dart-lang/language/issues/3143) from core Dart language team.

### 1.0.1

Update docs only (so that pub.dev docs get updated).

### 1.0.0

First pub.dev release.