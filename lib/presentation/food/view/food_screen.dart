import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/food/bloc/food_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

class FoodScreen extends StatefulWidget {
  static const routeName = '/food_screen';

  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  TextEditingController _foodInputController = TextEditingController();

  @override
  void initState() {
    final bloc = BlocProvider.of<FoodBloc>(context);
    bloc.add(InitializeStateEventAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<FoodBloc>(context);
    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
          body: BlocConsumer<FoodBloc, FoodEventState> (listener: (context, state) {

          },builder: (context, state) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: Dimens.marginNormal),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // bloc.add(ResetFoodEventInfoAction());
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios, size: 24),
                      ),
                      Text(
                        AppLocalizations.of(context)!.journal,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: Dimens.fontSizeXXLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 28,
                        margin: const EdgeInsets.only(left: Dimens.marginNormal),
                        child: Image.asset('assets/icon/journal_icon.png'),
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(
                    vertical: Dimens.marginLarge,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.add_food,
                    style: const TextStyle(
                      fontSize: Dimens.fontSizeXXLarge,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: Dimens.marginNormal),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.paddingNormal,
                        vertical: Dimens.paddingSmall),
                    child: TextField(
                          decoration: InputDecoration(
                            fillColor: Colors.black,
                            labelText:
                            AppLocalizations.of(context)!.write_here_hint,
                            suffixIcon: IconButton(
                              icon: _foodInputController.text != ''
                                  ? const Icon(
                                Icons.highlight_remove,
                                color: Colors.black,
                              )
                                  : Container(),
                              onPressed: () =>
                                  setState(() => _foodInputController.text = ''),
                            ),
                          ),
                          controller: _foodInputController,
                          onChanged: (value) => setState(() {
                            _foodInputController;
                            bloc.add(OnChangeEditTextStateAction(value.toString()));
                          }),
                    ),
                  ),
                ),
                if (state.filteredFood!.isNotEmpty) Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                    child: GridView(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: Dimens.marginNormal,
                        mainAxisExtent: 55.0,
                        childAspectRatio: 3/1,
                      ),
                      shrinkWrap: true,
                      children: [
                        ...state.filteredFood!.map((food) => Card(
                          elevation: 3.00,
                          shadowColor: Colors.black,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: InkWell(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              onTap: () => Navigator.pushNamed(context, AddFoodEventScreen.routeName, arguments: food),
                              child: Center(
                                child: Text(
                                  food.en.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: Dimens.fontSizeSmall,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          },),
        ),
      ),
    );
  }
}
