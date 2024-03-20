import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/forgottenpassword/bloc/forgotten_password_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/resetpassword/view/reset_password_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/errors/error_types.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
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
      child: SafeArea(
        child: BlocConsumer<ForgottenPasswordBloc, ForgottenPasswordState>(
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
              backgroundColor: Colors.white,
              body: Form(
                key: _formKey,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: Dimens.marginXXLarge,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: Dimens.marginXXLarge,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.forgotten_password,
                          style: const TextStyle(
                            fontSize: Dimens.fontSizeLarge,
                          ),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.enter_email_for_link,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeMedium,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: Dimens.marginSmall,
                        ),
                        width: double.infinity,
                        child: Text(
                          AppLocalizations.of(context)!.email,
                          style: const TextStyle(
                            color: Colors.black45,
                          ),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(Dimens.borderXLarge),
                            ),
                          ),
                          hintText: AppLocalizations.of(context)!
                              .email,
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
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: Dimens.marginSmall,
                        ),
                        child: RoundedCustomButton(
                          buttonText:
                              AppLocalizations.of(context)!.reset_password,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              bloc.add(ResetPasswordRequestEventAction(
                                  userName: _emailController.text.toString(),
                                  next: () => Navigator.pushNamed(
                                      context, ResetPasswordScreen.routeName)));
                            }
                          },
                        ),
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
