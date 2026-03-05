import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/midnight_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/feces/view/feces_screen.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/feces_tab.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/urine/view/urine_screen.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/urine_tab.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurinedetails/view/feces_urine_tabs.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/header_add_item_card_section.dart';

import '../../../infrastructure/helpers/app_text_styles.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/screen_top_bar.dart';
import '../../widgets/rounded_custom_button.dart';
import '../../../infrastructure/utils/constants.dart';

class FecesUrineTabHolder extends StatefulWidget {
  static const routeName = '/feces_urine_tab';

  const FecesUrineTabHolder({super.key});

  @override
  State<FecesUrineTabHolder> createState() => _FecesUrineTabHolderState();
}

class _FecesUrineTabHolderState extends State<FecesUrineTabHolder>
    with SingleTickerProviderStateMixin, MidnightToastMixin {
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
    subscribeMidnight();
    fecesUrineBloc = BlocProvider.of<FecesUrineBloc>(context);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final infoReceived = ModalRoute.of(context)?.settings.arguments;
      if (infoReceived is DateTime) {
        fecesUrineBloc.add(InitializeFecesUrineEventAction());
        fecesUrineBloc.add(UpdateCalendarDateFecesUrineEventAction(dateTime: infoReceived));
      } else if (infoReceived is int) {
        _selectedTab = infoReceived;
        _tabController.index = _selectedTab;
        fecesUrineBloc.add(InitializeFecesUrineEventAction());
      } else {
        fecesUrineBloc.add(InitializeFecesUrineEventAction());
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    unsubscribeMidnight();
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
              bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
              body: SafeArea(child: Container(
                margin: const EdgeInsets.all(Dimens.marginSmall),
                child: Column(
                  children: [
                    ScreenTopBar(
                      selectedDate: state.calendarDateTime,
                      onBack: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: Dimens.height12),
                    HeaderAddItemCardSection(
                        title: '${AppLocalizations.of(context)!.faeces_urine} ${AppLocalizations.of(context)!.summary}',
                        image: 'assets/images/feces_urine.png',
                        backgroundImage: 'assets/images/feces_urine_background.png',
                    ),
                    const SizedBox(height: Dimens.height12),
                    TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimens.border15),
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: Dimens.padding6),
                      labelColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      unselectedLabelColor: AppColors.yellowishGreen,
                      tabs: List.generate(_tabs.length, (index) {
                        final isSelected = _tabController.index == index;
                        return Container(
                          height: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimens.border15),
                            color: isSelected ? AppColors.yellowishGreen59 : AppColors.butter59,
                          ),
                          child: Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.margin6), child: Text(_tabs[index], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSize11), textAlign: TextAlign.center)),
                        );
                      }),
                    ),
                    const SizedBox(height: Dimens.height5),
                    const Divider(color: AppColors.yellowishGreen, height: 2, thickness: 2,),
                    const SizedBox(height: Dimens.height12),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          FecesTab(),
                          UrineTab(),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: Dimens.marginSmall, left: Dimens.marginLarge, right: Dimens.marginLarge),
                      child: GeneralButton(
                        title: AppLocalizations.of(context)!.add,
                        onTap: () => Navigator.popAndPushNamed(context, FecesUrineTabs.routeName, arguments: _selectedTab),
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
