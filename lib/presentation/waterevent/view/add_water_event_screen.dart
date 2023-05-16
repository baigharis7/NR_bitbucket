import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/bloc/water_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/bloc/water_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/bloc/water_event_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

class AddWaterEventScreen extends StatefulWidget {
  static const routeName = '/add_water_event';

  const AddWaterEventScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddWaterEventScreesState();
}

class _AddWaterEventScreesState extends State<AddWaterEventScreen> {

  @override
  void initState() {
    final bloc = BlocProvider.of<WaterEventBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<WaterEventBloc>(context);

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<WaterEventBloc, WaterEventState>(
          listener: (ctx, state) {
            if (state.isLoading) {
              LoadingScreen.instance().show(
                context: ctx,
                text: AppLocalizations.of(ctx)!.loading,
              );
            } else {
              LoadingScreen.instance().hide();
            }
            if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
          },
          builder: (ctx, state) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 25,),
                ),
                title: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.liquids,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: Dimens.fontSizeXXLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.asset('assets/icon/drink_icon.png', width: 21, height: 29,)
                  ],
                ),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge,),
                        child: Text(
                          AppLocalizations.of(context)!.add_water,
                          style: const TextStyle(
                            fontSize: Dimens.fontSizeXXLarge,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge*2),
                        child: GridView(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 0,
                            mainAxisExtent: 55.0,
                            childAspectRatio: 3/2,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ...state.waterQuantities!.map((quantity) {
                              return InkWell(
                                child: Card(
                                  color: Colors.grey[100],
                                  child: Container(
                                    alignment: Alignment.center,
                                    color: state.waterEventMaster!.qty! == quantity ? Colors.amber : Colors.grey[100],
                                    child: Text(
                                      '$quantity L',
                                    ),
                                  ),
                                ),
                                onTap: () => ctx.read<WaterEventBloc>().add(ChooseWaterQuantityAction(qty: quantity)),
                              );
                            }).toList()
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: Dimens.marginXLarge,
                      right: Dimens.marginXLarge, bottom: Dimens.fontSizeXXLarge*3,
                    ),
                    child: RoundedCustomButton(
                      onPressed: () {
                        bloc.add(FinishWaterEventAction(onFinish: () {
                          bloc.add(ResetStateAction());
                          Navigator.pop(context);
                        },),);
                      },
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}