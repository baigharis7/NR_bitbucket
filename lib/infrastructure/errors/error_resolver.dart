import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

String resolveError(BuildContext context, ErrorTypes errorType) {
  final stringResolver = AppLocalizations.of(context)!;

  switch (errorType) {
    case ErrorTypes.unknownError:
      return stringResolver.generic_error;
    case ErrorTypes.notAuthorizedError:
      return stringResolver.not_authorized_error;
    case ErrorTypes.sendVerificationCodeError:
      return stringResolver.send_verification_code_error;
    case ErrorTypes.resendVerificationCodeError:
      return stringResolver.resend_verification_code_error;
    case ErrorTypes.usernameExistsError:
      return stringResolver.username_exists_error;
    case ErrorTypes.getEmailFromTokenError:
      return stringResolver.get_email_from_token_error;
    case ErrorTypes.profileExistenceError:
      return stringResolver.profile_existence_error;
    case ErrorTypes.saveUserCredentialsError:
      return stringResolver.save_user_credentials_error;
    case ErrorTypes.fetchUserCredentialsError:
      return stringResolver.fetch_user_credentials_error;
    case ErrorTypes.downloadProfileError:
      return stringResolver.download_profile_error;
    case ErrorTypes.saveProfileInLocalError:
      return stringResolver.save_profile_in_local_error;
    case ErrorTypes.manageMasterFilesError:
      return stringResolver.manage_master_files_error;
    case ErrorTypes.saveUserInRemoteDatabaseError:
      return stringResolver.save_user_in_remote_database_error;
    case ErrorTypes.savingProfileError:
      return stringResolver.saving_profile_error;
    case ErrorTypes.savingRdasError:
      return stringResolver.saving_rdas_error;
    case ErrorTypes.uploadingProfileError:
      return stringResolver.uploading_food_event_error;
    case ErrorTypes.retrievingMasterFileError:
      return stringResolver.retrieving_master_file_error;
    case ErrorTypes.recommendationError:
      return stringResolver.recommendation_error;
    case ErrorTypes.locallySavingFoodEventError:
      return stringResolver.locally_saving_food_event_error;
    case ErrorTypes.uploadingFoodEventError:
      return stringResolver.uploading_food_event_error;
    case ErrorTypes.retrieveFoodEventsError:
      return stringResolver.retrieve_food_events_error;
    case ErrorTypes.locallySavingSportEventError:
      return stringResolver.locally_saving_sport_event_error;
    case ErrorTypes.uploadingSportEventError:
      return stringResolver.uploading_sport_event_error;
    case ErrorTypes.retrieveSportEventsError:
      return stringResolver.retrieve_sport_events_error;
    case ErrorTypes.sportEventTimeStartError:
      return stringResolver.sport_event_time_start_error;
    case ErrorTypes.sportEventDateStartError:
      return stringResolver.sport_event_date_start_error;
    case ErrorTypes.sportEventSportIdError:
      return stringResolver.sport_event_sport_id_error;
    case ErrorTypes.sportEventIntensityStartError:
      return stringResolver.sport_event_intensity_start_error;
    case ErrorTypes.sportEventMinutesStartError:
      return stringResolver.sport_event_minutes_start_error;
  }
}

String? resolveFormError(BuildContext context, FormErrorTypes? formErrorTypes) {
  if (formErrorTypes == null) return null;
  final stringResolver = AppLocalizations.of(context)!;

  switch (formErrorTypes) {
    case FormErrorTypes.usernameEmptyOrNullError:
      return stringResolver.username_empty_or_null_error;
    case FormErrorTypes.emailFormatError:
      return stringResolver.email_format_error;
    case FormErrorTypes.invalidPasswordError:
      return stringResolver.invalid_password_error;
    case FormErrorTypes.emptyRepeatPassword:
      return stringResolver.empty_repeat_password;
    case FormErrorTypes.repeatPasswordError:
      return stringResolver.repeat_password_error;
  }
}
