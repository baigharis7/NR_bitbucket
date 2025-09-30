import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/view/supplements_screen.dart';
import 'package:nutrenaissance_flutter/presentation/supplementsdetail/bloc/supplements_detail_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/item_info_card.dart';

import '../../../infrastructure/helpers/app_text_styles.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../widgets/date_picker_bar.dart';
import '../../widgets/general_button.dart';
import '../../widgets/header_add_item_card_section.dart';

class SupplementsDetailScreen extends StatefulWidget {
  static const routeName = '/supplements_detail_screen';

  const SupplementsDetailScreen({super.key});

  @override
  State<SupplementsDetailScreen> createState() => _SupplementsDetailScreen();
}

class _SupplementsDetailScreen extends State<SupplementsDetailScreen> {
  late SupplementsDetailBloc supplementsDetailBloc;

  @override
  void initState() {
    supplementsDetailBloc = BlocProvider.of<SupplementsDetailBloc>(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: supplementsDetailBloc,
      child: BlocConsumer<SupplementsDetailBloc, SupplementsDetailState>(
        listener: (context, state) {},
        builder: (context, state) => Stack(
          children: [
            // Background image or gradient
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  // Your image
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color:
                Colors.black.withOpacity(0), // Needed to activate the blur
              ),
            ),

            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.paddingSmall,
                    vertical: Dimens.paddingLarge,
                  ),
                  child: Column(children: [
                    DatePickerBar(
                      selectedDateTime: state.eventDate,
                      onChangeDate: (dateTime) => supplementsDetailBloc.add(UpdateEventsDateSupplementsDetailEvent(dateTime: dateTime)),
                    ),
                    const SizedBox(height: Dimens.height12),
                    HeaderAddItemCardSection(
                      onBackTap: () => Navigator.pop(context),
                      title: AppLocalizations.of(context)!.supplements,
                      image: 'assets/images/supplement.png',
                    ),
                    const SizedBox(height: Dimens.height12),
                    ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return ItemInfoCard(
                            title: 'Vitamin B12',
                          trailingSrc: 'assets/images/delete_icon.png',
                          subtitle: '12 grams',
                          trailingTap: () {},
                        );
                      },
                    ),
                    const SizedBox(height: Dimens.height32),
                    ListTile(
                      onTap: () => Navigator.popAndPushNamed(context, SupplementsScreen.routeName),
                      leading: Image.asset('assets/images/add_items.png', height: Dimens.height37, width: Dimens.width37),
                      title: Text(
                        AppLocalizations.of(context)!.add + ' ' +AppLocalizations.of(context)!.supplements,
                        style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
