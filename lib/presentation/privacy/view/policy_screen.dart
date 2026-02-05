import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/constants.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';

class PolicyScreen extends StatefulWidget {
  static const routeName = '/policy_screen';
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  String _htmlContent = '';

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    String language = Localizations.localeOf(context).languageCode;
    final fileName = language == 'es' ? 'assets/html/es_privacy.html'  : 'assets/html/en_privacy.html';
    final content = await rootBundle.loadString(fileName);
    setState(() {
      _htmlContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadPrivacyPolicy();
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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

      Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.PROFILE),
        body: SafeArea(
          child: Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
              color: AppColors.floralWhite,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double fontScale = constraints.maxWidth * 0.0025;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    vertical: height * 0.02,
                    horizontal: width * 0.06,
                  ),
                  child: Column(children: [
                    Row(
                      children: [
                        InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios_new, color: AppColors.yellowishGreen, size: 20)),
                        // const SizedBox(width: Dimens.height12),
                        const Icon(Icons.person_outlined, color: AppColors.yellowishGreen, size: 22),
                        Text(AppLocalizations.of(context)!.profile, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w500, fontSize: Dimens.fontSize13, color: AppColors.yellowishGreen)),
                      ],
                    ),
                    const SizedBox(height: Dimens.height15),
                    Html(
                      data: _htmlContent,
                      style: {
                        'h2': Style(
                          color: AppColors.yellowishGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize(20),
                          fontFamily: 'MerriWeather',
                          margin: Margins.only(bottom: 10),
                        ),
                        'h3': Style(
                          color: AppColors.yellowishGreen,
                          fontWeight: FontWeight.w500,
                          fontSize: FontSize(18),
                          fontFamily: 'MerriWeather',
                          margin: Margins.only(top: 16, bottom: 8),
                        ),
                        'p': Style(
                          color: AppColors.yellowishGreen,
                          fontFamily: 'MerriWeather',
                          margin: Margins.only(bottom: 10),
                        ),
                        'ul': Style(
                          color: AppColors.yellowishGreen,
                          fontFamily: 'MerriWeather',
                          margin: Margins.only(left: 16, bottom: 10),
                        ),
                        'li': Style(
                          color: AppColors.yellowishGreen,
                          fontFamily: 'MerriWeather',
                          padding: HtmlPaddings.symmetric(vertical: 6),
                        ),
                        'b': Style(fontWeight: FontWeight.w600),
                        'a': Style(color: Colors.blue, textDecoration: TextDecoration.underline),
                      },),
                  ]),
                );
              },
            ),
          ),
        ),
      ),
    ],);
  }
}
