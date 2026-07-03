import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/presentation/forgottenpassword/bloc/forgotten_password_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/bloc/reset_password_bloc.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/errors/error_types.dart';
import '../../../infrastructure/helpers/app_text_styles.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/validator_utils.dart';
import '../../common/view/confirmation_dialog.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/generic_button.dart';
import '../../widgets/rounded_custom_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const routeName = '/reset_password_screen';

  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late ResetPasswordBloc bloc;

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
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    _confirmationCodeController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Auto-dismiss after 2s. Pop through the dialog's own context so
        // that, if the user already dismissed it by tapping the barrier,
        // this timer can't pop whatever route is on top by then.
        Future.delayed(const Duration(seconds: 2), () {
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        });
        return ConfirmationDialog(
          message: AppLocalizations.of(context)!.password_save_successfully,
        );
      },
    ).then((_) {
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Email the reset code was requested for, carried over from
    // ForgottenPasswordScreen so the user never re-types it (AC-6.1).
    final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return BlocProvider.value(
      value: bloc,
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
          if (state.onError != null) showErrorSnackBar(context, userError(ctx, state.onError!));
        },
        builder: (context, state) {
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

              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  titleSpacing: Dimens.marginNormal,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 25,),
                  ),),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: Dimens.padding5Large),
                    child: Form(
                      key: _formKey,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: Dimens.marginXXLarge,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.reset_your_password,
                              style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeXXLarge, fontWeight: FontWeight.w700,),
                            ),
                            const SizedBox(
                              height: Dimens.heightXSmall,
                            ),
                            // Honest feedback: Cognito's anti-enumeration means
                            // we can't tell whether the email had an account,
                            // so the copy is conditional on purpose (AC-2.1).
                            Text(
                              AppLocalizations.of(context)!.reset_code_sent_hint,
                              style: AppTextStyles.merriWeather.copyWith(fontSize: Dimens.fontSizeMedium),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: Dimens.heightXSmall,
                            ),
                            TextFormField(
                              cursorColor: Colors.white,
                              style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                              obscureText: !(state.isPasswordVisible ?? false),
                              decoration: InputDecoration(
                                focusColor: Colors.white,
                                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.whit, width: 1)),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                                hintText: AppLocalizations.of(context)!.new_password,
                                hintStyle: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                                errorMaxLines: 3,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    (state.isPasswordVisible ?? false)
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                  onPressed: () =>
                                      bloc.add(ChangePasswordVisibilityEventAction()),
                                ),
                              ),
                              controller: _newPasswordController,
                              validator: (value) => resolveFormError(
                                context,
                                validatePasswordOrNull(false, value),
                              ),
                              onChanged: (value) => _formKey.currentState!.validate(),
                            ),
                            const SizedBox(
                              height: Dimens.heightXSmall,
                            ),
                            TextFormField(
                              cursorColor: Colors.white,
                              style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                              obscureText: !(state.isRepeatPasswordVisible ?? false),
                              decoration: InputDecoration(
                                focusColor: Colors.white,
                                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.whit, width: 1)),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                                hintText:
                                    AppLocalizations.of(context)!.repeat_password,
                                hintStyle: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                                errorMaxLines: 3,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    (state.isRepeatPasswordVisible ?? false)
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => bloc.add(
                                      ChangeRepeatPasswordVisibilityEventAction(),),
                                ),
                              ),
                              controller: _repeatPasswordController,
                              validator: (value) => resolveFormError(
                                context,
                                value != _newPasswordController.text
                                    ? FormErrorTypes.repeatPasswordError
                                    : null,
                              ),
                              onChanged: (value) => _formKey.currentState!.validate(),
                            ),
                            const SizedBox(
                              height: Dimens.heightXSmall,
                            ),
                            TextFormField(
                              cursorColor: Colors.white,
                              style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                              decoration: InputDecoration(
                                focusColor: Colors.white,
                                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.whit, width: 1)),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                                hintText:
                                    AppLocalizations.of(context)!.confirmation_code,
                                hintStyle: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                                errorMaxLines: 3,
                                counterStyle: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,), // counter color
                              ),
                              controller: _confirmationCodeController,
                              validator: (value) => resolveFormError(
                                context,
                                value.isEmptyOrNull()
                                    ? FormErrorTypes.emptyConfirmationCode
                                    : null,
                              ),
                              onChanged: (value) => _formKey.currentState!.validate(),
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                            ),
                            const SizedBox(
                              height: Dimens.heightXSmall,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Reuses the request flow (and its global
                                  // loading/error listeners) with the carried
                                  // email; success feedback stays honest.
                                  BlocProvider.of<ForgottenPasswordBloc>(context)
                                      .add(ResetPasswordRequestEventAction(
                                    userName: email,
                                    next: () => ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(AppLocalizations.of(context)!
                                          .reset_code_resent),
                                    )),
                                  ));
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.resend_code,
                                  style: AppTextStyles.merriWeather.copyWith(
                                    fontSize: Dimens.fontSizeMedium,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: Dimens.heightXSmall,
                            ),
                            GenericButton(
                              title:
                                  AppLocalizations.of(context)!.reset_password,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  bloc.add(
                                    ConfirmResetPasswordEventAction(
                                      username: email,
                                      password: _newPasswordController.text,
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
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
