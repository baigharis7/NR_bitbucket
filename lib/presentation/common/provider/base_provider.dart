import 'package:flutter/material.dart';

abstract class BaseProvider extends ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void manageLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void launchSync({Function? onSuccess, Function? onError, required Function block}) async {
    manageLoading(true);
    try {
      dynamic blockResult = await block.call();
      manageLoading(false);
      onSuccess?.call(blockResult);
    } catch (error) {
      manageLoading(false);
      onError?.call(error);
    }
  }

}