### 1.0.20

- Bugfixes for `PersistentValueNotifierMap`

### 1.0.19

- Add missing `notifyListeners` in `PersistentValueNotifierMap`

### 1.0.18

- Add export missing in previous release.

### 1.0.17

- Add `PersistentValueNotifierMap`, which persists a `Map<String, dynamic>` to SharedPreferences as JSON.

### 1.0.16

- Allow for `notifyListeners` to be called for JSON-encoded persistent value notifiers without first calling `set value`, so that you can modify the fields of an object and notify listeners without updating the object reference.

### 1.0.15

- Protect against `initPersistentValueNotifier` being called twice.

### 1.0.14

* Allow `PersistentValueNotifierEnum` to work with nullable enums.

### 1.0.13

* Export `PersistentValueNotifierJsonEncoded`.

### 1.0.12

* For `PersistentValueNotifierJsonEncoded`, notify listeners if the JSON representation of the value has changed, don't check the value reference for changes.

### 1.0.11

* Write through to `SharedPreferences` from `notifyListeners`.

### 1.0.10

* Handle `fromJson` throwing an exception.

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