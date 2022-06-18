import 'package:flutter/material.dart';

abstract class BaseProvider extends ChangeNotifier {

  bool get isLoading => _isLoading;
  Function? get onError => _onError;

  bool _isLoading = false;
  Function? _onError;

  void initialize(Function onError) {
    setOnError(onError);
  }

  void showError({required Function snackBar}) {
    snackBar.call();
  }

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

  void setOnError(Function onError) => _onError = onError;

}