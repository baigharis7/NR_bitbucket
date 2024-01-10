import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/bloc/reset_password_bloc.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/errors/error_types.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/validator_utils.dart';
import '../../common/view/confirmation_dialog.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/rounded_custom_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const routeName = '/reset_password_screen';

  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late ResetPasswordBloc bloc;

  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _confirmationCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    bloc = BlocProvider.of<ResetPasswordBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (ctx) => Container(
        height: mediaQuerySize.height,
        width: mediaQuerySize.width,
        color: const Color.fromARGB(148, 104, 96, 96),
        child: ConfirmationDialog(
            message: AppLocalizations.of(context)!.password_save_successfully),
      ),
    ).then(
      (value) => Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (route) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
          listener: (ctx, state) {
            if (state.isLoading) {
              LoadingScreen.instance().show(
                context: ctx,
                text: AppLocalizations.of(ctx)!.loading,
              );
            } else {
              LoadingScreen.instance().hide();
            }
            if (state.onError != null)
              showErrorSnackBar(context, resolveError(ctx, state.onError!));
          },
          builder: (context, state) {
            return Scaffold(
              body: Form(
                key: _formKey,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: Dimens.marginXXLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.reset_your_password,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeXXLarge,
                        ),
                      ),
                      const SizedBox(
                        height: Dimens.heightXSmall,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(Dimens.borderXLarge),
                            ),
                          ),
                          hintText: AppLocalizations.of(context)!
                              .enter_username_or_email,
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
                      const SizedBox(
                        height: Dimens.heightXSmall,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(Dimens.borderXLarge),
                            ),
                          ),
                          hintText: AppLocalizations.of(context)!.new_password,
                          errorMaxLines: 3,
                        ),
                        controller: _newPasswordController,
                        validator: (value) => resolveFormError(
                            context, validatePasswordOrNull(false, value)),
                        onChanged: (value) => _formKey.currentState!.validate(),
                      ),
                      const SizedBox(
                        height: Dimens.heightXSmall,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(Dimens.borderXLarge),
                            ),
                          ),
                          hintText:
                              AppLocalizations.of(context)!.repeat_password,
                          errorMaxLines: 3,
                        ),
                        controller: _repeatPasswordController,
                        validator: (value) => resolveFormError(
                            context,
                            value != _newPasswordController.text
                                ? FormErrorTypes.repeatPasswordError
                                : null),
                        onChanged: (value) => _formKey.currentState!.validate(),
                      ),
                      const SizedBox(
                        height: Dimens.heightXSmall,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(Dimens.borderXLarge),
                            ),
                          ),
                          hintText:
                              AppLocalizations.of(context)!.confirmation_code,
                          errorMaxLines: 3,
                        ),
                        controller: _confirmationCodeController,
                        validator: (value) => resolveFormError(
                            context,
                            value.isEmptyOrNull()
                                ? FormErrorTypes.emptyConfirmationCode
                                : null,),
                        onChanged: (value) => _formKey.currentState!.validate(),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(
                        height: Dimens.heightXSmall,
                      ),
                      RoundedCustomButton(
                        buttonText:
                            AppLocalizations.of(context)!.reset_password,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            bloc.add(
                              ConfirmResetPasswordEventAction(
                                username: _emailController.text,
                                password: _repeatPasswordController.text,
                                confirmationCode:
                                    _confirmationCodeController.text,
                                onFinish: () =>
                                    _showConfirmationDialog(context),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
