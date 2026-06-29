import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

/// Account-verification dialog content (the signup confirmation code prompt).
///
/// Extracted from LoginScreen so the empty-submit behaviour is unit-testable.
/// Previously, pressing "Accept" with an empty field silently closed the
/// dialog and stranded the user mid-signup — a frequent cause of stuck
/// UNCONFIRMED accounts, since the code often lands in spam and isn't to hand
/// when this appears. Now an empty submit shows an inline error and keeps the
/// dialog open; only a non-empty code triggers [onSubmit].
class MfaVerificationDialog extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final VoidCallback onResend;
  final VoidCallback onCancel;

  const MfaVerificationDialog({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onResend,
    required this.onCancel,
  });

  @override
  State<MfaVerificationDialog> createState() => _MfaVerificationDialogState();
}

class _MfaVerificationDialogState extends State<MfaVerificationDialog> {
  String? _otpError;

  void _accept() {
    if (widget.controller.text.isEmpty) {
      setState(() =>
          _otpError = AppLocalizations.of(context)!.error_confirmation_code);
      return;
    }
    widget.onSubmit(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(
        child: Text(AppLocalizations.of(context)!.verify_your_account),
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
                      labelText: AppLocalizations.of(context)!.enter_otp,
                      errorText: _otpError,
                    ),
                    controller: widget.controller,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (_) {
                      if (_otpError != null) setState(() => _otpError = null);
                    },
                  ),
                ),
                RoundedCustomButton(
                  verticalMargin: Dimens.marginSmall,
                  horizontalMargin: Dimens.marginLarge,
                  buttonText: AppLocalizations.of(context)!.accept,
                  onPressed: _accept,
                ),
                RoundedCustomButton(
                  verticalMargin: Dimens.marginSmall,
                  horizontalMargin: Dimens.marginLarge,
                  buttonText:
                      AppLocalizations.of(context)!.resend_verification_code,
                  onPressed: widget.onResend,
                ),
                RoundedCustomButton(
                  verticalMargin: Dimens.marginSmall,
                  horizontalMargin: Dimens.marginLarge,
                  buttonText: AppLocalizations.of(context)!.cancel,
                  onPressed: widget.onCancel,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
