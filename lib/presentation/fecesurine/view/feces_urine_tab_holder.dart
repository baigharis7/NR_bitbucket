import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/feces/view/feces_screen.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/feces_tab.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/urine/view/urine_screen.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/urine_tab.dart';

import '../../../infrastructure/utils/dimens.dart';
import '../../widgets/rounded_custom_button.dart';

class FecesUrineTabHolder extends StatefulWidget {
  static const routeName = '/feces_urine_tab';

  const FecesUrineTabHolder({super.key});

  @override
  State<FecesUrineTabHolder> createState() => _FecesUrineTabHolderState();
}

class _FecesUrineTabHolderState extends State<FecesUrineTabHolder>
    with SingleTickerProviderStateMixin {
  late FecesUrineBloc fecesUrineBloc;
  String? title;
  late TabController _tabController;
  int _selectedTab = 0;

  void _manageTabChange(BuildContext context) {
    setState(() {
      if (_selectedTab == 0) {
        title = AppLocalizations.of(context)!.faeces;
      } else if (_selectedTab == 1) {
        title = AppLocalizations.of(context)!.urine;
      }
    });
  }

  @override
  void initState() {
    fecesUrineBloc = BlocProvider.of<FecesUrineBloc>(context);
    fecesUrineBloc.add(InitializationEventAction());

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
        _manageTabChange(context);
      });
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: Dimens.marginNormal,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.journal,
                style: const TextStyle(
                  fontSize: Dimens.fontSizeXXLarge,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: 28,
                margin: const EdgeInsets.only(left: Dimens.marginNormal),
                child: Image.asset('assets/icon/journal_icon.png'),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            onTap: (index) => _manageTabChange(context),
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.faeces.toUpperCase()),
              Tab(text: AppLocalizations.of(context)!.urine.toUpperCase()),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                // physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: const [
                  FecesTab(),
                  UrineTab(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadiusDirectional.vertical(
                        top: Radius.circular(5.0),),
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 5.0)],),
              child: InkWell(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall, vertical: Dimens.marginXXLarge),
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingSmall),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: AppColors.mountainMeadow,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.add_deposition, style: const TextStyle(color: Colors.white)),
                      const Icon(Icons.add_circle, color: Colors.white),
                    ],
                  ),
                ),
                onTap: () {
                  if (_selectedTab == 0) {
                    Navigator.pushNamed(context, FecesScreen.routeName).then((value) => Navigator.pop(context));
                  } else if (_selectedTab == 1) {
                    Navigator.pushNamed(context, UrineScreen.routeName).then((value) => Navigator.pop(context));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
