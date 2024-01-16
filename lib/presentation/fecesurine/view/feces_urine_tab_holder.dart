import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/feces_tab.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/view/urine_tab.dart';

import '../../../infrastructure/utils/dimens.dart';

class FecesUrineTabHolder extends StatefulWidget {
  static const routeName = '/feces_urine_tab';
  const FecesUrineTabHolder({super.key});

  @override
  State<FecesUrineTabHolder> createState() => _FecesUrineTabHolderState();
}

class _FecesUrineTabHolderState extends State<FecesUrineTabHolder> with SingleTickerProviderStateMixin {
  String? title;
  late TabController _tabController;
  int _selectedTab = 0;

  void _manageTabChange(BuildContext context) {
    setState(() {
      if (_selectedTab == 0) {
        title = AppLocalizations.of(context)!.feces;
      } else if (_selectedTab == 1) {
        title = AppLocalizations.of(context)!.urine;
      }
    });
  }

  @override
  void initState() {
    final fecesUrineBloc = BlocProvider.of<FecesUrineBloc>(context);
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
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: Dimens.marginNormal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black,),
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
            Tab(text: AppLocalizations.of(context)!.feces.toUpperCase()),
            Tab(text: AppLocalizations.of(context)!.urine.toUpperCase()),
          ],
        ),
      ),
      body: TabBarView(
        // physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          FecesTab(),
          UrineTab(),
        ],
      ),
    ));
  }
}