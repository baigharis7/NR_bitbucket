import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/show_loading_mixin.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/num_constants.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/forgottenpassword/view/fogotten_password_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/provider/login_provider_new.dart';
import 'package:nutrenaissance_flutter/presentation/privacypolicy/privacy_policy.dart';
import 'package:nutrenaissance_flutter/presentation/profile/registry/view/registry_screen.dart';
import 'package:nutrenaissance_flutter/presentation/welcome/welcome_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_button_1.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/generic_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/save_button_widget.dart';
import 'package:provider/provider.dart';

import '../../../infrastructure/helpers/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login_screen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin, ShowLoadingDialog {

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _mfaController = TextEditingController();
  AnimationController? _controller;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;
  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Center(
          child: Text(AppLocalizations.of(context)!.cancel_registry),
        ),
        backgroundColor: Colors.white,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.symmetric(
              horizontal: Dimens.marginLarge,
              vertical: Dimens.marginNormal,
            ),
            child: Text(
              AppLocalizations.of(context)!.skip_verification_code_message,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                  child: CustomButton1(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.teal),
                    ),
                    message: AppLocalizations.of(context)!.cancel,
                    action: () => Navigator.pop(context),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                  child: CustomButton1(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.teal),
                    ),
                    message: AppLocalizations.of(context)!.accept,
                    action: () => Navigator.pop(context, true),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    ).then((exit) {
      if (exit) Navigator.pop(context);
    });
  }

  void _showMFADialog({
    required BuildContext context,
    required Function sendVerificationCode,
    required Function resendVerificationCode,
  }) {
    final _mfaController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SimpleDialog(
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.verify_your_account,
            ),
          ),
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimens.paddingSmall,
                        horizontal: Dimens.paddingLarge,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.verification_code_explanation,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimens.paddingSmall,
                        horizontal: Dimens.paddingNormal,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText:
                          AppLocalizations.of(context)!.enter_otp,
                        ),
                        controller: _mfaController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                    ),
                    RoundedCustomButton(
                      verticalMargin: Dimens.marginSmall,
                      horizontalMargin: Dimens.marginLarge,
                      buttonText: AppLocalizations.of(context)!.accept,
                      onPressed: () {
                        if (_mfaController.text.isNotEmpty) sendVerificationCode.call(_mfaController.text);
                        _mfaController.text = '';
                        Navigator.pop(context);
                      },
                    ),
                    RoundedCustomButton(
                      verticalMargin: Dimens.marginSmall,
                      horizontalMargin: Dimens.marginLarge,
                      buttonText: AppLocalizations.of(context)!.resend_verification_code,
                      onPressed: () => resendVerificationCode.call(),
                    ),
                    RoundedCustomButton(
                      verticalMargin: Dimens.marginSmall,
                      horizontalMargin: Dimens.marginLarge,
                      buttonText: AppLocalizations.of(context)!.cancel,
                      onPressed: () => _showExitConfirmationDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          ],
      ),
    );
  }

  Widget _notConfirmedUserTryingToLogin({
    required BuildContext context,
    required Function notConfirmedUserCancelsReceiveConfirmationCode,
    required Function notConfirmedUserAsksForNewVerificationCode,
  }) {
    return Container(
        color: const Color.fromARGB(148, 104, 96, 96),
        child: SimpleDialog(
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.confirmation_required,
            ),
          ),
          titleTextStyle: const TextStyle(
            fontSize: Dimens.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(Dimens.marginNormal),
                alignment: Alignment.centerLeft,
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        left: Dimens.marginNormal,
                        right: Dimens.marginNormal,
                        bottom: Dimens.marginLarge,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.needed_account_confirmation_message,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeNormal,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                            child: RoundedCustomButton(
                              buttonText: AppLocalizations.of(context)!.cancel,
                              onPressed: () => notConfirmedUserCancelsReceiveConfirmationCode.call(),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                            child: RoundedCustomButton(
                              buttonText: AppLocalizations.of(context)!.accept,
                              onPressed: () => notConfirmedUserAsksForNewVerificationCode.call(),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: NumConstants.animDelay,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
    _emailController.dispose();
    _mfaController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = LoginProviderNew();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.initialize((Object object) => showErrorSnackBar(context, userError(context, object)));
    // });

    return ChangeNotifierProvider<LoginProviderNew>(
      create: (context) => provider,
      child: Consumer<LoginProviderNew>(
        builder: (context, model, _) => Stack(
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

            // Blur effect
            // BackdropFilter(
            //   filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
            //   child: Container(
            //     color: AppColors.black59Percent, // Needed to activate the blur
            //   ),
            // ),
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(), // Hides the keyboard
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Dimens.paddingXLarge),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(Dimens.marginXXLarge),
                            child: Image.asset(
                              'assets/images/logo_name_white.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (model.isLogin) Container(
                            margin: const EdgeInsets.symmetric(vertical: Dimens.marginXLarge),
                            child: Text(AppLocalizations.of(context)!.joy_of_science,
                            style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize34,), textAlign: TextAlign.center,),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20,top: 50),
                            child: TextFormField(
                              cursorColor: Colors.white,
                              style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                              decoration: InputDecoration(
                                focusColor: Colors.white,
                                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.whit, width: 1)),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                                prefixIcon: Container(
                                  padding: const EdgeInsets.only(bottom: Dimens.padding10),
                                  height: Dimens.height32,
                                  child: Image.asset(
                                    'assets/icon/icon_user.png',
                                  ),
                                ),
                                hintStyle: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                                hintText: model.isLogin ? AppLocalizations.of(context)!.email : AppLocalizations.of(context)!.name,
                                errorMaxLines: 3,
                              ),
                              controller: _usernameController,
                              validator: (value) => resolveFormError(context, model.validateUsername(value)),
                            // onChanged: (value) => _formKey.currentState!.validate(),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                            ),
                          ),
                          if (!model.isLogin) AnimatedContainer(
                            constraints: BoxConstraints(
                              minHeight: !model.isLogin ? 60 : 0,
                              maxHeight: !model.isLogin ? 120 : 0,
                            ),
                            duration:
                            const Duration(milliseconds: NumConstants.animDelay),
                            curve: Curves.easeInOut,
                            child: FadeTransition(
                              opacity: _opacityAnimation!,
                              child: SlideTransition(
                                position: _slideAnimation!,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
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
                                    validator: (value) => resolveFormError(context, model.validateEmail(value)),
                                    // onChanged: (value) => _formKey.currentState!.validate(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TextFormField(
                            cursorColor: Colors.white,
                            style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                            decoration: InputDecoration(
                              focusColor: Colors.white,
                              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.whit, width: 1)),
                              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                              prefixIcon: Container(
                                padding: const EdgeInsets.only(bottom: Dimens.padding10),
                                height: Dimens.height32,
                                child: Image.asset(
                                  'assets/icon/icon_password.png',
                                ),
                              ),
                              hintStyle: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                              hintText: AppLocalizations.of(context)!.password_hint,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  model.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () => model.changePasswordVisibility(),
                              ),
                              errorMaxLines: 4,
                            ),
                            controller: _passwordController,
                            obscureText: !model.isPasswordVisible,
                            validator: (value) => resolveFormError(context, model.validatePassword(value)),
                            // onChanged: (value) => _formKey.currentState!.validate(),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                          if (!model.isLogin)
                            AnimatedContainer(
                              constraints: BoxConstraints(
                                minHeight: !model.isLogin ? 60 : 0,
                                maxHeight: !model.isLogin ? 120 : 0,
                              ),
                              duration: const Duration(milliseconds: NumConstants.animDelay),
                              curve: Curves.easeInOut,
                              child: FadeTransition(
                                opacity: _opacityAnimation!,
                                child: SlideTransition(
                                  position: _slideAnimation!,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: TextFormField(
                                      cursorColor: Colors.white,
                                      style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                                      decoration: InputDecoration(
                                        focusColor: Colors.white,
                                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.whit, width: 1)),
                                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                                        prefixIcon: Container(
                                          padding: const EdgeInsets.only(bottom: Dimens.padding10),
                                          height: Dimens.height32,
                                          child: Image.asset(
                                            'assets/icon/icon_password.png',
                                          ),
                                        ),
                                        hintStyle: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                                        hintText: AppLocalizations.of(context)!.repeat_password,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            model.isRepeatPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                            color: Colors.white,
                                          ),
                                          onPressed: () => model.changeRepeatPasswordVisibility(),
                                        ),
                                        errorMaxLines: 3,
                                      ),
                                      controller: _repeatPasswordController,
                                      obscureText: !model.isRepeatPasswordVisible,
                                      validator: (value) => resolveFormError(context, model.validateRepeatPassword(value, _passwordController.text)),
                                      // onChanged: (value) => _formKey.currentState!.validate(),
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (!model.isLogin) SizedBox(width: double.infinity, child: Row(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(value: model.isPrivacyPolicyChecked, side: const BorderSide(color: Colors.white, width: 2), activeColor: Colors.transparent, onChanged: (value) {
                                model.setPrivacyPolicyChecked(value!);
                              },),
                              Expanded(
                                child: InkWell(onTap: () async {
                                  Navigator.pushNamed(context, PrivacyPolicy.routeName).then((value) => model.setPrivacyPolicyChecked(value as bool));
                                }, child: Text(AppLocalizations.of(context)!.privacy_policy, textAlign: TextAlign.start, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,fontSize: Dimens.fontSizeSmall),)),
                              ),
                            ],
                          )),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: Dimens.marginXXLarge),
                            child: GenericButton(
                                title: model.isLogin
                                    ? AppLocalizations.of(context)!.login
                                    : AppLocalizations.of(context)!.register,
                              enableButton: model.isLogin ? true : model.isPrivacyPolicyChecked,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  model.submitData(
                                    username: _usernameController.text.trim().orEmpty(),
                                    email: _emailController.text.orEmpty(),
                                    password: _passwordController.text.orEmpty(),
                                    repeatPassword: _repeatPasswordController.text.orEmpty(),
                                    action: model.isLogin
                                        ? () => Navigator.of(context).popAndPushNamed(DashboardScreen.routeName)
                                        : () => _showMFADialog(
                                      context: context,
                                      sendVerificationCode: (confirmationCode) => model.sendVerificationCode(
                                        confirmationCode: confirmationCode,
                                        action: () => Navigator.of(context).popAndPushNamed(WelcomeScreen.routeName, result: true,),
                                        alreadyExistsAlias: () => Navigator.pop(context),
                                      ),
                                      resendVerificationCode: () => model.resendVerificationCode(),
                                    ),
                                    goToRegistry: () => Navigator.of(context).popAndPushNamed(WelcomeScreen.routeName),
                                  );
                                }
                              },
                            ),
                          ),
                          // RoundedCustomButton(
                          //   enableButton: model.isLogin ? true : model.isPrivacyPolicyChecked,
                          //   buttonText: model.isLogin
                          //       ? AppLocalizations.of(context)!.login
                          //       : AppLocalizations.of(context)!.register,
                          //   onPressed: () {
                          //     if (_formKey.currentState!.validate()) {
                          //       model.submitData(
                          //         username: _usernameController.text.trim().orEmpty(),
                          //         email: _emailController.text.orEmpty(),
                          //         password: _passwordController.text.orEmpty(),
                          //         repeatPassword: _repeatPasswordController.text.orEmpty(),
                          //         action: model.isLogin
                          //             ? () => Navigator.of(context).popAndPushNamed(DashboardScreen.routeName)
                          //             : () => _showMFADialog(
                          //           context: context,
                          //           sendVerificationCode: (confirmationCode) => model.sendVerificationCode(
                          //             confirmationCode: confirmationCode,
                          //             action: () => Navigator.of(context).popAndPushNamed(WelcomeScreen.routeName, result: true,),
                          //             alreadyExistsAlias: () => Navigator.pop(context),
                          //           ),
                          //           resendVerificationCode: () => model.resendVerificationCode(),
                          //         ),
                          //         goToRegistry: () => Navigator.of(context).popAndPushNamed(WelcomeScreen.routeName),
                          //       );
                          //     }
                          //   },
                          // ),
                          if (model.isLogin) InkWell(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .forgotten_password,
                              textAlign: TextAlign.start,
                              style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSizeMedium, decoration: TextDecoration.underline,),
                            ),
                            onTap: () => Navigator.pushNamed(context, ForgottenPasswordScreen.routeName),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: Dimens.marginXLarge),
                            child: InkWell(
                              onTap: () {
                                _usernameController.clear();
                                _emailController.clear();
                                _passwordController.clear();
                                _repeatPasswordController.clear();
                                model.changeLoginMode(() { _controller!.forward(); });
                              },
                              child: RichText(text: TextSpan(
                                text: (model.isLogin ? AppLocalizations.of(context)!.dont_have_account : AppLocalizations.of(context)!.already_have_account)  + '  ',
                                style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeMedium),
                                children: <TextSpan>[
                                  TextSpan(text: model.isLogin ? AppLocalizations.of(context)!.register : AppLocalizations.of(context)!.login, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSizeMedium, decoration: TextDecoration.underline),),
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
            ),
            if (model.isLoading) showLoadingDialog(context),
            if (model.getNotConfirmedUserTryingToLogin) _notConfirmedUserTryingToLogin(
              context: context,
              notConfirmedUserCancelsReceiveConfirmationCode: () => model.notConfirmedUserCancelsReceiveConfirmationCode(),
              notConfirmedUserAsksForNewVerificationCode: () => model.notConfirmedUserAsksForNewVerificationCode(() => _showMFADialog(
                context: context,
                sendVerificationCode: (confirmationCode) => model.sendVerificationCode(
                  confirmationCode: confirmationCode,
                  action: () => Navigator.of(context).popAndPushNamed(RegistryScreen.routeName, result: true,),
                  alreadyExistsAlias: () => Navigator.pop(context),
                ),
                resendVerificationCode: () => model.resendVerificationCode(),
              ),),
            ),
          ],
        ),
      ),
    );
  }
}
