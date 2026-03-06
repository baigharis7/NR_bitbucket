import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/fiber_detail/bloc/fiber_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fiber_detail_widget.dart';

import '../../../domain/models/dashboard/sugar_&_fiber_model.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../profile/profile/view/profile_screen.dart';
import '../../widgets/custom_bottom_app_bar.dart';

class FiberDetailScreen extends StatefulWidget {
  static const routeName = '/fiber_detail_screen';

  const FiberDetailScreen({super.key});

  @override
  State<FiberDetailScreen> createState() => _FiberDetailScreenState();
}

class _FiberDetailScreenState extends State<FiberDetailScreen> {
  late FiberDetailBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<FiberDetailBloc>(context);
    super.initState();

    final widgetBinding = WidgetsBinding.instance;
    widgetBinding.addPostFrameCallback((timeStamp) {
      if(ModalRoute.of(context)?.settings.arguments != null) {
        final infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived is SugarAndFiberModel?) {
          bloc.add(LoadFiberEventAction(sugarAndFiberModel: infoReceived));
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
          child: BlocConsumer<FiberDetailBloc, FiberDetailState>(
        listener: (ctx, state) {
          if (state.isLoading) {
            LoadingScreen.instance().show(
              context: ctx,
              text: AppLocalizations.of(ctx)!.loading,
            );
          } else {
            LoadingScreen.instance().hide();
          }
          // if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
        },
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                // size: 18,
                color: Colors.black,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () =>
                    Navigator.popAndPushNamed(context, ProfileScreen.routeName)
                        .then((value) {}),
                iconSize: 35.0,
                icon: Image.asset(
                  'assets/icon/profile_icon.png',
                  color: Colors.black,
                  height: 29,
                  width: 29,
                ),
              )
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(Dimens.marginLarge),
                child:
                Text(bloc.getTodayMessage(AppLocalizations.of(context)!.today, Localizations.localeOf(context).languageCode), style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Dimens.fontSizeMedium)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    FiberDetailWidget(sugarAndFiberModel: state.sugarAndFiberModel),
                  ],),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: 0,)
          // CustomBottomAppBar(initStateCallback: () => null),
          // resizeToAvoidBottomInset: true,
          // floatingActionButton: FloatingActionButton(
          //   elevation: 2.0,
          //   backgroundColor: Colors.white,
          //   onPressed: () => Navigator.popAndPushNamed(context, DashboardScreen.routeName),
          //   child: Container(
          //     padding: const EdgeInsets.all(Dimens.paddingSmall),
          //     child: Image.asset(
          //       'assets/images/logo_black.png',
          //       fit: BoxFit.cover,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),
      )),
    );
  }
}
