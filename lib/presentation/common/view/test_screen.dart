import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/test_actions.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/test_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/test_state.dart';

class TestScreen extends StatelessWidget {
  static const routeName = '/test_screen';

  const TestScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<TestBloc>(context);

    return SafeArea(
      child: BlocProvider.value(
        value: bloc,
        child: BlocConsumer<TestBloc, TestState>(
          listener: (ctx, state) {},
          builder: (ctx, state) => Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      bloc.add(SelectOption());
                    },
                    child: const Text('Push'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}