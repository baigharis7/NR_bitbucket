import 'package:flutter/material.dart';

abstract class BaseProvider extends ChangeNotifier {

  bool get isLoading => _isLoading;
  bool _isLoading = false;

  void manageLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void launchSync({Function? onSuccess, Function? onError, required Function block, bool showLoading = true}) async {
    if (showLoading) manageLoading(true);
    try {
      dynamic blockResult = await block.call();
      if (showLoading) manageLoading(false);
      onSuccess?.call(blockResult);
    } catch (error) {
      if (showLoading) manageLoading(false);
      onError?.call(error);
    }
  }

}