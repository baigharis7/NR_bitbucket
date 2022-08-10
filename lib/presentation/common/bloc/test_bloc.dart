import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/test_actions.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/test_state.dart';

class TestBloc extends Bloc<TestActions, TestState> {
  TestBloc() : super(TestState()) {

  }

}