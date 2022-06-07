import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/generic_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/mixins/show_loading_mixin.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/num_constants.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/provider/login_provider.dart';
import 'package:nutrenaissance_flutter/presentation/registry/view/registry_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_button_1.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login_screen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin, ShowLoadingDialog, GenericProvider<LoginProvider> {

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController(text: '.Holi1621!!');
  final _repeatPasswordController = TextEditingController(text: '.Holi1621!!');
  final _emailController = TextEditingController();
  final _mfaController = TextEditingController();
  AnimationController? _controller;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;

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
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Center(
          child: Text('Cancel registry?'),
        ),
        backgroundColor: Colors.white,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.symmetric(
                horizontal: Dimens.marginLarge,
                vertical: Dimens.marginNormal),
            child: const Text(
                'If you skip this step you will be able to confirm your user further.'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton1(
                message: AppLocalizations.instance.translate('cancel'),
                action: () {
                  Navigator.pop(context);
                },
              ),
              CustomButton1(
                message: AppLocalizations.instance.translate('accept'),
                action: () {
                  Navigator.pop(context, true);
                },
              )
            ],
          )
        ],
      ),
    ).then((exit) {
      if (exit) Navigator.pop(context);
    });
  }

  // TODO: Esto debería ir fuera, pero da error. Revisar.
  void _showMFADialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SimpleDialog(
        title: Center(
          child: Text(
            AppLocalizations.instance.translate('verify_your_account'),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Dimens.paddingSmall,
                horizontal: Dimens.paddingLarge),
            child: Text(
              AppLocalizations.instance
                  .translate('verification_code_explanation'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Dimens.paddingSmall,
                horizontal: Dimens.paddingNormal),
            child: TextField(
              decoration: InputDecoration(
                labelText:
                AppLocalizations.instance.translate('write_here_hint'),
              ),
              controller: _mfaController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimens.paddingXLarge,
                vertical: Dimens.paddingSmall),
            child: CustomButton1(
              message: AppLocalizations.instance.translate('accept'),
              action: () {
                getProvider.sendVerificationCode(_mfaController.text, () {
                  Navigator.of(ctx).popAndPushNamed(RegistryScreen.routeName,
                      result: true);
                });
                _mfaController.text = '';
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimens.paddingXLarge,
                vertical: Dimens.paddingSmall),
            child: CustomButton1(
              message: AppLocalizations.instance
                  .translate('resend_verification_code'),
              action: () => getProvider.resendVerificationCode(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimens.paddingXLarge,
                vertical: Dimens.paddingSmall),
            child: CustomButton1(
                message: AppLocalizations.instance.translate('cancel'),
                action: () {
                  _showExitConfirmationDialog(context);
                }),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: Dimens.paddingLarge),
          )
        ],
      ),
    );
  }

  // TODO: esto podría ser un diálogo genérico si permanece.
  Widget _notConfirmedUserTryingToLogin(BuildContext context) {
    return Container(
      color: const Color.fromARGB(148, 104, 96, 96),
      child: SimpleDialog(
        title: const Center(
          child: Text(
            'Confirmation required',
          ),
        ),
        titleTextStyle: const TextStyle(
            fontSize: Dimens.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: Colors.black),
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
                        bottom: Dimens.marginLarge
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Before you create your profile you need to confirm your email account.',
                      style: TextStyle(
                          fontSize: Dimens.fontSizeNormal,
                          fontStyle: FontStyle.normal),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton1(
                        message:
                        AppLocalizations.instance.translate('cancel'),
                        action: () {
                          getProvider.notConfirmedUserCancelsReceiveConfirmationCode();
                        },
                      ),
                      CustomButton1(
                        message:
                        AppLocalizations.instance.translate('accept'),
                        action: () {
                          getProvider
                              .notConfirmedUserAsksForNewVerificationCode(
                                  () {
                                _showMFADialog();
                              });
                        },
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
  Widget build(BuildContext context) {
    setProvider(Provider.of<LoginProvider>(context));

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
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
                    child: TextField(
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.instance.translate('login_hint'),
                      ),
                      controller: _usernameController,
                    ),
                  ),
                  AnimatedContainer(
                    constraints: BoxConstraints(
                      minHeight: !getProvider.isLogin ? 60 : 0,
                      maxHeight: !getProvider.isLogin ? 120 : 0,
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
                          child: TextField(
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.instance.translate('email'),
                            ),
                            controller: _emailController,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.instance
                            .translate('password_hint'),
                      ),
                      controller: _passwordController,
                      obscureText: true,
                    ),
                  ),
                  if (!getProvider.isLogin)
                    AnimatedContainer(
                      constraints: BoxConstraints(
                        minHeight: !getProvider.isLogin ? 60 : 0,
                        maxHeight: !getProvider.isLogin ? 120 : 0,
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
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: AppLocalizations.instance
                                    .translate('repeat_password'),
                              ),
                              controller: _repeatPasswordController,
                              obscureText: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: CustomButton1(
                        message: getProvider.isLogin
                            ? AppLocalizations.instance.translate('login')
                            : AppLocalizations.instance.translate('register'),
                        action: () => getProvider.submitData(
                            username: _usernameController.text.orEmpty(),
                            email: _emailController.text.orEmpty(),
                            password: _passwordController.text.orEmpty(),
                            repeatPassword:
                                _repeatPasswordController.text.orEmpty(),
                            action: getProvider.isLogin
                                ? () => Navigator.of(context)
                                    .popAndPushNamed(DashboardScreen.routeName)
                                : () => _showMFADialog(),
                            goToRegistry: () => Navigator.of(context)
                                .popAndPushNamed(RegistryScreen.routeName)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            AppLocalizations.instance
                                .translate('have_an_account'),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(),
                              shadowColor: Colors.amber),
                          onPressed: () => getProvider.changeLoginMode(() {
                            _controller!.forward();
                            // _repeatPasswordController.text = '';
                            // _emailController.text = '';
                          }),
                          child: Text(
                            AppLocalizations.instance.translate('register'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: TextButton(
                        style: TextButton.styleFrom(
                            textStyle: const TextStyle(),
                            shadowColor: Colors.amber),
                        onPressed: () {},
                        child: Text(
                          AppLocalizations.instance
                              .translate('forgotten_password'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (getProvider.isLoading) showLoadingDialog(context),
          if (getProvider.getNotConfirmedUserTryingToLogin)
            _notConfirmedUserTryingToLogin(context)
        ],
      ),
    );
  }
}
