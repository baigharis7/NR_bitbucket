import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/feces/view/feces_screen.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/urine/view/urine_screen.dart';

import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../fecesurine/bloc/feces_urine_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/date_picker_bar.dart';
import '../../widgets/header_add_item_card_section.dart';

class FecesUrineTabs extends StatefulWidget {
  static const routeName = '/feces_urine_tabs';
  const FecesUrineTabs({super.key});

  @override
  State<FecesUrineTabs> createState() => _FecesUrineTabsState();
}

class _FecesUrineTabsState extends State<FecesUrineTabs> with SingleTickerProviderStateMixin {
  late FecesUrineBloc fecesUrineBloc;
  late TabController _tabController;
  int _selectedTab = 0;

  List<String> _tabs = ['', ''];

  @override
  void didChangeDependencies() {
    _tabs = [AppLocalizations.of(context)!.faeces.toUpperCase(), AppLocalizations.of(context)!.urine.toUpperCase()];
    super.didChangeDependencies();
  }

  @override
  void initState() {
    fecesUrineBloc = BlocProvider.of<FecesUrineBloc>(context);
    fecesUrineBloc.add(InitializeFecesUrineEventAction());
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        var infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is int?) {
            _selectedTab = infoReceived as int;
            _tabController.index = _selectedTab;
          }
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: fecesUrineBloc,
      child: BlocConsumer<FecesUrineBloc, FecesUrineState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Stack(children: [
            // Background image or gradient
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'), // Your image
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0), // Needed to activate the blur
              ),
            ),

            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(child: Container(
                margin: const EdgeInsets.all(Dimens.marginSmall),
                child: Column(
                  children: [
                    DatePickerBar(selectedDateTime: state.calendarDateTime, onChangeDate: (dateTime) {
                      fecesUrineBloc.add(UpdateCalendarDateFecesUrineEventAction(dateTime: dateTime,));
                    },),
                    const SizedBox(height: Dimens.height12),
                    HeaderAddItemCardSection(
                        title: '${AppLocalizations.of(context)!.add} ${AppLocalizations.of(context)!.faeces_urine}',
                        onBackTap: () => Navigator.pop(context),
                        image: 'assets/images/feces_urine.png',
                        backgroundImage: 'assets/images/feces_urine_background.png',
                    ),
                    const SizedBox(height: Dimens.height12),
                    TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimens.borderNormal),
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: Dimens.padding10),
                      labelColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      unselectedLabelColor: AppColors.yellowishGreen,
                      tabs: List.generate(_tabs.length, (index) {
                        final isSelected = _tabController.index == index;
                        return Container(
                          height: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimens.borderNormal),
                            color: isSelected ? AppColors.yellowishGreen : AppColors.butter59,
                          ),
                          child: Text(_tabs[index]),
                        );
                      }),
                      // tabs: [
                      //   Tab(text: AppLocalizations.of(context)!.faeces.toUpperCase()),
                      //   Tab(text: AppLocalizations.of(context)!.urine.toUpperCase()),
                      // ],
                    ),
                    const SizedBox(height: Dimens.height5),
                    const Divider(color: AppColors.yellowishGreen, height: 2, thickness: 2,),
                    const SizedBox(height: Dimens.height12),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          FecesScreen(),
                          UrineScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ],);
        },),);
  }
}