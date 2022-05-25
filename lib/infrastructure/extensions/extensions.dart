import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

extension NullableStringExtensions on String? {
  bool isNotEmptyOrNull() {
    if (this != null && this != '') {
      return true;
    } else {
      return false;
    }
  }

  bool isEmptyOrNull() {
    if (this == null || this == '') {
      return true;
    } else {
      return false;
    }
  }

  String orEmpty() {
    if (this == null) {
      return '';
    } else {
      return this!;
    }
  }

  bool isNull() {
    if (this == null) {
      return true;
    } else {
      return false;
    }
  }

  bool isNotNull() {
    if (this == null) {
      return false;
    } else {
      return true;
    }
  }
}

extension StringExtensions on String {
  bool isNotEmpty() {
    if (this != '') {
      return true;
    } else {
      return false;
    }
  }

  bool isEmpty() {
    if (this == '') {
      return true;
    } else {
      return false;
    }
  }

}

extension ListExtensions<T> on List<T> {
  List<T> orEmpty() {
    if (isEmpty) {
      return <T>[];
    } else {
      return this;
    }
  }

  String convertToBinary(int binarySize) {
    String binary = '';
    for (int i = 0; i < binarySize; i++) {
      if (contains(i)) {
        binary += '1';
      } else {
        binary += '0';
      }
    }
    return binary;
  }
}

extension NullableListExtensions<T> on List<T>? {
  List<T> orEmpty() {
    if (this == null) {
      return <T>[];
    } else {
      return this!;
    }
  }

}

extension PrefsKeysExtensions on PrefsKeys {
  String getKey() => name.orEmpty();
}

extension IntExtensions on int? {
  int getHiveKey() => this!~/(1000000);
}

extension ObjectExtensions on Object? {
  bool isNull() {
    if (this == null) {
      return true;
    } else {
      return false;
    }
  }

  bool aintNull(Function action) {
    if (this == null) {
      return false;
    } else {
      return true;
    }
  }

  void doIfNull(Function action) {
    if (this == null) {
      action.call();
    }
  }

  void doIfAintNull(Function action) {
    if (this != null) {
      action.call();
    }
  }

}