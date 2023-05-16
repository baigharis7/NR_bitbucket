import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class BaseState {
  final bool isLoading;
  final ErrorTypes? errorTypes;

  BaseState({required this.isLoading, this.errorTypes});
}