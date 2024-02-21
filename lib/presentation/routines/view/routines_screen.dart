import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/routines/bloc/routines_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/calender_event_list_item.dart';

import '../../../infrastructure/utils/dimens.dart';

class RoutinesScreen extends StatefulWidget {
  static const routeName = 'routines_screen';

  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  late RoutinesBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<RoutinesBloc>(context);
    bloc.add(RoutinesInitialStateAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
          child: BlocConsumer<RoutinesBloc, RoutinesState>(
        listener: (context, state) {},
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.journal,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: Dimens.fontSizeXXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: Dimens.marginNormal),
                    child: Image.asset('assets/icon/journal_icon.png',
                        height: 28)),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(Dimens.heightSmall),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(
                  vertical: Dimens.marginLarge,
                ),
                child: Text(
                  AppLocalizations.of(context)!.routines,
                  style: const TextStyle(
                    fontSize: Dimens.fontSizeXXLarge,
                  ),
                ),
              ),
            ),
          ),
          body: Column(children: [
            ...state.routines.orEmpty().map((e) => CalenderEventListItem(title: e.sportName.toString(), onEdit: () {}, onDelete: () {})),
          ],),
        ),
      ),),
    );
  }
}
