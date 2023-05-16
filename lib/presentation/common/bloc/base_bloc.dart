import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseBloc<E, S> extends Bloc<E, S> {
  BaseBloc(super.initialState);
  // TODO: probar convirtiendo a variables E y S.
  // TODO: adaptar esto a BLoC.
  void launchSync({Function? onSuccess, Function? onError, required Function block}) async {
    // if (showLoading) manageLoading(true);
    try {
      dynamic blockResult = await block.call();
      // if (showLoading) manageLoading(false);
      onSuccess?.call(blockResult);
    } catch (error) {
      // if (showLoading) manageLoading(false);
      onError?.call(error);
    }
  }
}