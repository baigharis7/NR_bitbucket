import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
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
    Future.delayed(const Duration(seconds: 3), () => Navigator.pop(context));

    showDialog(context: context, builder: (ctx) => ConfirmationDialog(
      message: AppLocalizations.of(context)!.password_save_successfully,
    ),).then(
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
                            TextFormField(
                              cursorColor: Colors.white,
                              style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                              decoration: InputDecoration(
                                focusColor: Colors.white,
                                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.whit, width: 1)),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                                hintText: AppLocalizations.of(context)!
                                    .email,
                                hintStyle: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700,),
                                errorMaxLines: 3,
                              ),
                              controller: _emailController,
                              validator: (value) => resolveFormError(
                                context,
                                isEmail(value)
                                    ? null
                                    : FormErrorTypes.emailFormatError,
                              ),
                              onChanged: (value) => _formKey.currentState!.validate(),
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
                              obscureText: !(state.isRepeatPasswordVisible ?? false),
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
                            GenericButton(
                              title:
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
