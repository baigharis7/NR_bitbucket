import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/login/provider/login_provider_new.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/generic_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../infrastructure/utils/app_color.dart';

class PrivacyPolicy extends StatefulWidget {
  static const routeName = '/privacy_policy';

  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  final loginProvider = LoginProviderNew();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image or gradient
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login_bg.png'), // Your image
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Blur effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
          child: Container(
            color: AppColors.black59Percent, // Needed to activate the blur
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            minimum: const EdgeInsets.all(Dimens.marginLarge,),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Container(
              //   margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge),
              //   child: Text(
              //     AppLocalizations.of(context)!.privacy_title,
              //     textAlign: TextAlign.start,
              //     style: const TextStyle(
              //         color: Colors.white,
              //         fontSize: Dimens.fontSizeXLarge,
              //         fontWeight: FontWeight.w600),
              //   ),
              // ),
                  Expanded(
                child: SingleChildScrollView(
                  child: Html(
                    data: AppLocalizations.of(context)!.privacy_html,
                    style: {
                    "h2": Style(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSize(20),
                    margin: Margins.only(bottom: 10),
                  ),
                    "h3": Style(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: FontSize(18),
                      margin: Margins.only(top: 16, bottom: 8),
                    ),
                    "p": Style(
                      color: Colors.white,
                      margin: Margins.only(bottom: 10),
                    ),
                    "ul": Style(
                      color: Colors.white,
                      margin: Margins.only(left: 16, bottom: 10),
                    ),
                    "li": Style(
                      color: Colors.white,
                      padding: HtmlPaddings.symmetric(vertical: 6),
                    ),
                    "b": Style(fontWeight: FontWeight.w600),
                    "a": Style(color: Colors.blue, textDecoration: TextDecoration.underline),
                  },),
                ),
              ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginSmall),
                    child: GenericButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      title: AppLocalizations.of(context)!.accept_all,
                    ),
                  ),
            ]),
          ),
        ),
      ],
    );
  }
}
