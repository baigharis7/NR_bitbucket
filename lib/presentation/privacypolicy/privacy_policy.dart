import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/login/provider/login_provider_new.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return SafeArea(
        child: Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Dimens.marginXLarge,
        ),
        child: Column(children: [
          SizedBox(
            height: Dimens.heightSmall,
          ),
          SizedBox(
              width: double.infinity,
              child: Text(
                AppLocalizations.of(context)!.your_privacy,
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: Dimens.fontSizeXLarge,
                    fontWeight: FontWeight.w600),
              )),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: Dimens.marginXLarge),
              child: SingleChildScrollView(
                child: Text(
                    'Lorem ipsum dolor sit amet consectetur. Nascetur lorem elit neque consectetur curabitur semper in nunc maecenas. Eget dignissim turpis tempus ut commodo duis in eu. Quam integer vestibulum a commodo a turpis porta. Integer volutpat nunc sagittis varius enim faucibus aliquet in sed. Non tortor risus nulla ut dignissim leo fringilla aliquam. Non eu volutpat metus aliquam. Turpis pellentesque vitae pharetra id curabitur commodo sit. Imperdiet viverra turpis malesuada scelerisque dolor ut. Scelerisque nulla justo ante pharetra. Mattis senectus eu mauris duis adipiscing volutpat dui sit. Molestie id quis elementum pretium pretium consectetur urna arcu viverra. Amet porttitor pulvinar amet scelerisque sociis senectus quisque. Enim eu amet habitant fringilla augue dapibus nullam aliquam. Facilisi luctus commodo venenatis placerat. Turpis gravida ultrices sed neque id sapien id. Velit praesent a ac mauris pretium purus volutpat. Ultricies pretium aliquam lectus auctor blandit tincidunt faucibus. Adipiscing pulvinar nec nec sit. Consectetur massa at adipiscing quis elementum quam. Morbi tincidunt diam placerat amet. Lobortis semper nunc mi sollicitudin. Nulla viverra gravida sed vulputate at adipiscing tincidunt vulputate in. Sit habitasse duis mi feugiat dui vivamus pharetra ac. Nulla nam parturient velit montes libero. Pellentesque integer aliquam turpis netus purus consectetur nisi. Eget posuere viverra vestibulum sagittis integer bibendum non tincidunt. Egestas cursus elit convallis quis risus sit massa venenatis morbi. Amet morbi ut id faucibus viverra iaculis fermentum egestas. Sagittis ullamcorper vulputate velit massa ipsum adipiscing. Nulla eget consectetur tempor odio felis leo sagittis risus. Velit tempus malesuada nisi felis libero feugiat gravida augue. Sagittis in pharetra pellentesque dolor accumsan sed egestas vitae ac. Dignissim nulla lacus id nec quam dictum id. Ullamcorper tellus viverra tristique ullamcorper leo purus dolor ipsum vel. Habitasse ac et semper ullamcorper condimentum purus in. Volutpat porttitor pulvinar non tincidunt massa. Pulvinar lacus arcu ornare amet. Ante quis ultricies leo ultricies. Et amet in mi gravida quam felis eget sed lacus. Nisl sollicitudin venenatis nulla integer consequat nunc sed vel justo. Velit commodo amet tellus viverra nulla gravida. Vel non cursus enim vitae pellentesque habitant leo. Risus lacus non neque tincidunt. Mattis adipiscing sit purus pellentesque justo purus orci augue. Amet massa etiam feugiat nullam mauris elementum. Turpis tellus mauris at justo a urna turpis vestibulum. Nascetur convallis tellus pellentesque integer orci egestas nisl sed. Egestas at arcu ut maecenas sit neque feugiat sit aliquam. Feugiat tincidunt maecenas fermentum mauris sed. Laoreet faucibus sed posuere elit mattis vel ac. Massa enim risus auctor et scelerisque. Amet sed tincidunt luctus velit turpis libero nascetur in cursus. Consectetur sapien varius ornare ullamcorper suspendisse adipiscing. Nibh rutrum morbi morbi pellentesque est. Duis ac libero sapien ultricies pellentesque. Ullamcorper ut sed vulputate ut odio facilisi quam. Sagittis urna commodo commodo odio enim nisl vulputate. Facilisis lacus dolor diam orci a. Ac nec pellentesque et sed proin scelerisque egestas quis mi. Feugiat aliquam nunc leo orci scelerisque. Lectus viverra adipiscing ut etiam urna. Cras massa a tortor id facilisi vestibulum sed leo eu. Duis viverra urna non eget sapien tincidunt. Sagittis placerat cursus blandit consectetur. Duis integer sollicitudin sem eu nibh molestie. Non interdum aliquam sapien ipsum auctor pharetra. Commodo arcu urna cras tristique sit nibh senectus. Dolor volutpat nunc ornare vel tempor netus vivamus bibendum elementum. Volutpat eget gravida ut ac aliquam tortor vestibulum.'),
              ),
            ),
          )
        ]),
      ),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimens.paddingXXLarge,
              vertical: Dimens.paddingXLarge),
          child: RoundedCustomButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            buttonText: AppLocalizations.of(context)!.accept_all,
          )),
    ));
  }
}
