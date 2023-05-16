import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

mixin ShowLoadingDialog {
  // CONDICIONES PARA QUE FUNCIONE:
  // - Se usa en la clase desde donde se llama al método que necesita Loading los mixin del diálogo (éste) y del GenericProvider.
  // - Se confira el GenericProvider, claro.
  // - Se engloba el widget tree desde lo más alto posible en un Stack, y se pone como último elemento del mismo => if (getProvider.isLoading) showLoadingDialog().
  // Haciendo esto cuando se utilice launchSync se pondrá automáticamente un Loading.
  Widget showLoadingDialog(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: const Color.fromARGB(190, 61, 59, 59),
      // color: const Color.fromARGB(50, 232, 222, 222),
      child: const Center(
          child: SpinKitSpinningLines(
            color: Colors.teal,
            duration: Duration(milliseconds: 1000),
          ),
      ),
    );
  }
}