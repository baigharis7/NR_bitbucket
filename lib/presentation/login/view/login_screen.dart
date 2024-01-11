import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
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
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:provider/provider.dart';

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
                          AppLocalizations.of(context)!.write_here_hint,
                        ),
                        controller: _mfaController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.paddingXLarge,
                        vertical: Dimens.paddingSmall,
                      ),
                      child: RoundedCustomButton(
                        buttonText: AppLocalizations.of(context)!.accept,
                        onPressed: () {
                          sendVerificationCode.call(_mfaController.text);
                          _mfaController.text = '';
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.paddingXLarge,
                        vertical: Dimens.paddingSmall,
                      ),
                      child: RoundedCustomButton(
                        buttonText: AppLocalizations.of(context)!.resend_verification_code,
                        onPressed: () => resendVerificationCode.call(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.paddingXLarge,
                        vertical: Dimens.paddingSmall,
                      ),
                      child: RoundedCustomButton(
                        buttonText: AppLocalizations.of(context)!.cancel,
                        onPressed: () => _showExitConfirmationDialog(context),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: Dimens.paddingLarge),
                    )
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
      begin: const Offset(0, -1.5),
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
      provider.initialize((ErrorTypes errorType) => showErrorSnackBar(context, resolveError(context, errorType)));
    // });

    return ChangeNotifierProvider<LoginProviderNew>(
      create: (context) => provider,
      child: Consumer<LoginProviderNew>(
        builder: (context, model, _) => SafeArea(
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                body: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: Dimens.heightNormal),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(Dimens.marginXLarge),
                          child: Image.asset(
                            height: 140,
                            width: 305,
                            'assets/images/logo_name_black.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20,right: 20,bottom: 20,top: 50),
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(Dimens.borderXLarge))),
                              hintText: AppLocalizations.of(context)!.login_hint,
                              errorMaxLines: 3,
                            ),
                            controller: _usernameController,
                            validator: (value) => resolveFormError(context, model.validateUsername(value)),
                          onChanged: (value) => _formKey.currentState!.validate(),),
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
                                padding: const EdgeInsets.only(left: 20,right: 20,bottom: 20),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    border:  const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(Dimens.borderXLarge))),
                                    hintText:
                                    AppLocalizations.of(context)!.email,
                                    errorMaxLines: 3,
                                  ),
                                  controller: _emailController,
                                  validator: (value) => resolveFormError(context, model.validateEmail(value)),
                                  onChanged: (value) => _formKey.currentState!.validate(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(Dimens.borderXLarge))),
                              hintText: AppLocalizations.of(context)!.password_hint,
                              suffixIcon: IconButton(
                                  icon: Icon(
                                      model.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () => model.changePasswordVisibility(),
                              ),
                              errorMaxLines: 3,
                            ),
                            controller: _passwordController,
                            obscureText: !model.isPasswordVisible,
                            validator: (value) => resolveFormError(context, model.validatePassword(value)),
                            onChanged: (value) => _formKey.currentState!.validate(),
                          ),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(Dimens.borderXLarge))),
                                      hintText: AppLocalizations.of(context)!.repeat_password,
                                      suffixIcon: IconButton(
                                          icon: Icon(
                                                model.isRepeatPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                          ),
                                          onPressed: () => model.changeRepeatPasswordVisibility(),
                                      ),
                                      errorMaxLines: 3,
                                    ),
                                    controller: _repeatPasswordController,
                                    obscureText: !model.isRepeatPasswordVisible,
                                    validator: (value) => resolveFormError(context, model.validateRepeatPassword(value, _passwordController.text)),
                                    onChanged: (value) => _formKey.currentState!.validate(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (model.isLogin) Padding(
                          padding: const EdgeInsets.only(top: Dimens.heightXXSmall,left: Dimens.heightXSmall,right: Dimens.heightXSmall,bottom: Dimens.heightSmall),
                          child: SizedBox(
                              width: double.infinity,
                              child: InkWell(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .forgotten_password,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: AppColors.mountainMeadow,),
                                ),
                                onTap: () => Navigator.pushNamed(context, ForgottenPasswordScreen.routeName),
                              ),),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 20),
                          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                          child: RoundedCustomButton(
                            enableButton: model.isLogin ? true : model.isPrivacyPolicyChecked,
                            buttonText: model.isLogin
                                ? AppLocalizations.of(context)!.login
                                : AppLocalizations.of(context)!.register,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                model.submitData(
                                  username: _usernameController.text.orEmpty(),
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
                        Padding(
                          padding: EdgeInsets.zero,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal, horizontal: Dimens.marginNormal),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    AppLocalizations.of(context)!.dont_have_account,textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: Dimens.marginXSmall,),
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () => model.changeLoginMode(() {
                                      _controller!.forward();
                                    }),
                                    child: Text(
                                      model.isLogin ? AppLocalizations.of(context)!.register : AppLocalizations.of(context)!.login,
                                      style: const TextStyle(color: AppColors.mountainMeadow, fontWeight: FontWeight.w800, fontSize: Dimens.fontSizeLarge),textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!model.isLogin) Padding(padding: const EdgeInsets.symmetric(vertical: Dimens.heightSmall),
                          child: SizedBox(width: double.infinity, child: Row(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(value: model.isPrivacyPolicyChecked, onChanged: (value) {
                                model.setPrivacyPolicyChecked(value!);
                              },),
                              InkWell(onTap: () async {
                                Navigator.pushNamed(context, PrivacyPolicy.routeName).then((value) => model.setPrivacyPolicyChecked(value as bool));
                              },child: Text(AppLocalizations.of(context)!.privacy_policy, textAlign: TextAlign.start, style: const TextStyle(fontSize: Dimens.fontSizeSmall),)),
                            ],
                          )),),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 20),
                        //   child: Center(
                        //     child: TextButton(
                        //       style: TextButton.styleFrom(
                        //         foregroundColor: Colors.amber,
                        //         textStyle: const TextStyle(),
                        //       ),
                        //       onPressed: () {},
                        //       child: Text(
                        //         AppLocalizations.of(context)!.forgotten_password,
                        //         style: const TextStyle(
                        //           color: Colors.black,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
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
      ),
    );
  }
}
