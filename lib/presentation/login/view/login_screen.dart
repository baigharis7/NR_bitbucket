import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/show_loading_mixin.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/num_constants.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/provider/login_provider_new.dart';
import 'package:nutrenaissance_flutter/presentation/profile/registry/view/registry_screen.dart';
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
                      child: CustomButton1(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.teal[700],),
                          foregroundColor: MaterialStateProperty.all(Colors.white,),
                        ),
                        message: AppLocalizations.of(context)!.accept,
                        action: () {
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
                      child: CustomButton1(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.teal[700],),
                          foregroundColor: MaterialStateProperty.all(Colors.white,),
                        ),
                        message: AppLocalizations.of(context)!.resend_verification_code,
                        action: () => resendVerificationCode.call(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.paddingXLarge,
                        vertical: Dimens.paddingSmall,
                      ),
                      child: CustomButton1(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.teal[700],),
                          foregroundColor: MaterialStateProperty.all(Colors.white,),
                        ),
                        message: AppLocalizations.of(context)!.cancel,
                        action: () => _showExitConfirmationDialog(context),
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
                        CustomButton1(
                          message:
                          AppLocalizations.of(context)!.cancel,
                          action: () => notConfirmedUserCancelsReceiveConfirmationCode.call(),
                        ),
                        CustomButton1(
                          message:
                          AppLocalizations.of(context)!.accept,
                          action: () => notConfirmedUserAsksForNewVerificationCode.call(),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.initialize((ErrorTypes errorType) => showErrorSnackBar(context, resolveError(context, errorType)));
    });

    return ChangeNotifierProvider<LoginProviderNew>(
      create: (context) => provider,
      child: Consumer<LoginProviderNew>(
        builder: (context, model, _) => SafeArea(
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                body: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(Dimens.marginXLarge),
                          child: Image.asset(
                            'assets/images/logo_name_black.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.login_hint,
                              errorMaxLines: 3,
                            ),
                            controller: _usernameController,
                            validator: (value) => resolveFormError(context, model.validateUsername(value)),
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
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText:
                                    AppLocalizations.of(context)!.email,
                                    errorMaxLines: 3,
                                  ),
                                  controller: _emailController,
                                  validator: (value) => resolveFormError(context, model.validateEmail(value)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.password_hint,
                              suffixIcon: IconButton(
                                  icon: Icon(
                                      model.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () => model.changePasswordVisibility(),
                              ),
                              errorMaxLines: 3,
                            ),
                            controller: _passwordController,
                            obscureText: model.isPasswordVisible,
                            validator: (value) => resolveFormError(context, model.validatePassword(value)),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 20,),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.repeat_password,
                                      suffixIcon: IconButton(
                                          icon: Icon(
                                                model.isRepeatPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                          ),
                                          onPressed: () => model.changeRepeatPasswordVisibility(),
                                      ),
                                      errorMaxLines: 3,
                                    ),
                                    controller: _repeatPasswordController,
                                    obscureText: model.isRepeatPasswordVisible,
                                    validator: (value) => resolveFormError(context, model.validateRepeatPassword(value, _passwordController.text)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.only(top: 20),
                          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                          child: RoundedCustomButton(
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
                                      action: () => Navigator.of(context).popAndPushNamed(RegistryScreen.routeName, result: true,),
                                      alreadyExistsAlias: () => Navigator.pop(context),
                                    ),
                                    resendVerificationCode: () => model.resendVerificationCode(),
                                  ),
                                  goToRegistry: () => Navigator.of(context).popAndPushNamed(RegistryScreen.routeName),
                                );
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  AppLocalizations.of(context)!.dont_have_account,
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  textStyle: const TextStyle(),
                                  shadowColor: Colors.amber,
                                ),
                                onPressed: () => model.changeLoginMode(() {
                                  _controller!.forward();
                                }),
                                child: Text(
                                  AppLocalizations.of(context)!.register,
                                ),
                              ),
                            ],
                          ),
                        ),
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
