import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/forgottenpassword/bloc/forgotten_password_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/view/reset_password_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/generic_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/errors/error_types.dart';
import '../../../infrastructure/helpers/app_text_styles.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/validator_utils.dart';
import '../../common/view/loading_screen.dart';

class ForgottenPasswordScreen extends StatefulWidget {
  static const routeName = '/forgotten_password_screen';

  const ForgottenPasswordScreen({super.key});

  @override
  State<ForgottenPasswordScreen> createState() =>
      _ForgottenPasswordScreenState();
}

class _ForgottenPasswordScreenState extends State<ForgottenPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late ForgottenPasswordBloc bloc;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bloc = BlocProvider.of<ForgottenPasswordBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Stack(
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
          //
          // // Blur effect
          // BackdropFilter(
          //   filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
          //   child: Container(
          //     color: AppColors.black59Percent, // Needed to activate the blur
          //   ),
          // ),

          // if (_videoController.value.isInitialized)
          //   SizedBox.expand(
          //     child: FittedBox(
          //       fit: BoxFit.cover,
          //       child: SizedBox(
          //         width: _videoController.value.size.width,
          //         height: _videoController.value.size.height,
          //         child: VideoPlayer(_videoController),
          //       ),
          //     ),
          //   ),

          Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              titleSpacing: Dimens.marginNormal,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 25,),
              ),),
            body: BlocConsumer<ForgottenPasswordBloc, ForgottenPasswordState>(
              listener: (ctx, state) {
                if (state.isLoading) {
                  LoadingScreen.instance().show(
                    context: ctx,
                    text: AppLocalizations.of(ctx)!.loading,
                  );
                } else {
                  LoadingScreen.instance().hide();
                }
                if (state.onError != null) showErrorSnackBar(context, userError(ctx, state.onError!));
              },
              builder: (context, state) {
                return GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(), // Hides the keyboard
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: Dimens.marginXXLarge,
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(Dimens.marginXXLarge),
                                child: Image.asset(
                                  'assets/images/logo_name_white.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: Dimens.marginXXLarge,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.forgotten_password,
                                  style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeXXLarge),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.enter_email_for_link,
                                style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeMedium),
                                textAlign: TextAlign.center,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: Dimens.marginXXLarge),
                                child: TextFormField(
                                  cursorColor: Colors.white,
                                  style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                                  decoration: InputDecoration(
                                    focusColor: Colors.white,
                                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.whit, width: 1)),
                                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                                    prefixIcon: Container(
                                      padding: const EdgeInsets.only(left: 12, bottom: 8, right: 12),// to show container bounds
                                      height: Dimens.heightXXSmall,
                                      width: Dimens.widthXXXXSmall,
                                      child: Image.asset(
                                        'assets/icon/icon_email.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    hintStyle: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                                    hintText:
                                    AppLocalizations.of(context)!.email,
                                    errorMaxLines: 3,
                                  ),
                                  controller: _emailController,
                                  validator: (value) => resolveFormError(
                                      context,
                                      isEmail(value)
                                          ? null
                                          : FormErrorTypes.emailFormatError),
                                  onChanged: (value) => _formKey.currentState!.validate(),
                                ),
                              ),
                              GenericButton(
                                title: AppLocalizations.of(context)!.reset_password,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    bloc.add(ResetPasswordRequestEventAction(
                                        userName: _emailController.text.toString(),
                                        next: () => Navigator.pushNamed(
                                            context, ResetPasswordScreen.routeName)));
                                  }
                                },
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: Dimens.marginXXXXLarge),
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: RichText(text: TextSpan(
                                    text: AppLocalizations.of(context)!.already_have_account + '  ',
                                    style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeMedium),
                                    children: <TextSpan>[
                                      TextSpan(text: AppLocalizations.of(context)!.login, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSizeMedium, decoration: TextDecoration.underline)),
                                    ],
                                  ),),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ] ,
      ),
    );
  }
}
