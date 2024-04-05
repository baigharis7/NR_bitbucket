import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/error_type_strings.dart';

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
      return stringResolver.uploading_profile_error;
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
    case ErrorTypes.passwordsNotMatchingError:
      return stringResolver.password_matching_error;
    case ErrorTypes.locallySavingWaterEventError:
      return stringResolver.error_saving_event;
    case ErrorTypes.uploadingWaterEventError:
      return stringResolver.error_uploading_event;
    case ErrorTypes.saveFoodFavoriteError:
      return stringResolver.error_uploading_favorite;
    case ErrorTypes.uploadFoodFavoriteError:
      return stringResolver.error_uploading_favorite;
    case ErrorTypes.deleteFoodFavoriteError:
      return stringResolver.delete_favorite_error;
    case ErrorTypes.removeFoodFavoriteError:
      return stringResolver.remove_favorite_error;
    case ErrorTypes.saveSportFavoriteError:
      return stringResolver.save_favorite_error;
    case ErrorTypes.uploadSportFavoriteError:
      return stringResolver.upload_favorite_error;
    case ErrorTypes.deleteSportFavoriteError:
      return stringResolver.delete_favorite_error;
    case ErrorTypes.removeSportFavoriteError:
      return stringResolver.remove_favorite_error;
    case ErrorTypes.saveLiquidFavoriteError:
      return stringResolver.error_saving_favorite;
    case ErrorTypes.uploadLiquidFavoriteError:
      return stringResolver.error_uploading_favorite;
    case ErrorTypes.removeLiquidFavoriteError:
      return stringResolver.error_uploading_favorite;
    case ErrorTypes.deleteLiquidFavoriteError:
      return stringResolver.delete_favorite_error;
    case ErrorTypes.emailAlreadyExistsError:
      return stringResolver.email_already_exists;
    case ErrorTypes.codeExpiredError:
      return stringResolver.code_expired_error;
    case ErrorTypes.signInError:
      return stringResolver.sign_in_error;
    case ErrorTypes.signOutError:
      return stringResolver.sign_out_error;
    case ErrorTypes.synchronizeEventsError:
      return stringResolver.synchronize_events_error;
    case ErrorTypes.emailSendError:
      return stringResolver.email_sent_error;
    case ErrorTypes.confirmationCodeError:
      return stringResolver.incorrect_confirmation_code;
    case ErrorTypes.uploadingSportRoutineError:
      return stringResolver.uploading_sport_routine_error;
    case ErrorTypes.deleteFoodEventError:
      return stringResolver.delete_food_event_error;
    case ErrorTypes.removeFoodEventError:
      return stringResolver.remove_food_event_error;
    case ErrorTypes.deleteSportEventError:
      return stringResolver.delete_sport_event_error;
    case ErrorTypes.removeSportEventError:
      return stringResolver.remove_sport_event_error;
    case ErrorTypes.deleteLiquidEventError:
      return stringResolver.delete_liquid_event_error;
    case ErrorTypes.removeLiquidEventError:
      return stringResolver.remove_liquid_event_error;
    case ErrorTypes.uploadCreatineError:
      return stringResolver.error_uploading_creatine;
    case ErrorTypes.saveCreatineError:
      return stringResolver.error_saving_creatine;
    case ErrorTypes.uploadCollagenError:
      return stringResolver.error_uploading_collagen;
    case ErrorTypes.saveCollagenError:
      return stringResolver.error_saving_collagen;
    case ErrorTypes.limitError:
      return stringResolver.limit_error;
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
    case FormErrorTypes.emptyPasswordError:
      return stringResolver.username_empty_or_null_error;
    case FormErrorTypes.invalidPasswordError:
      return stringResolver.invalid_password_error;
    case FormErrorTypes.emptyRepeatPassword:
      return stringResolver.empty_repeat_password;
    case FormErrorTypes.repeatPasswordError:
      return stringResolver.repeat_password_error;
    case FormErrorTypes.emptyConfirmationCode:
      return stringResolver.error_confirmation_code;
  }
}

String userError(BuildContext context, Object error) {
  final stringResolver = AppLocalizations.of(context)!;
  final catchError = error as dynamic;
  final catchErrorToString = catchError.underlyingException.toString();
  final result = catchErrorToString.subString(' ', ' (');

  // return result;
  switch (result) {
    case ErrorTypStrings.NOT_AUTORIZED_USER:
      return stringResolver.not_authorized_error;
    case ErrorTypStrings.USER_ALREADY_EXISTS:
      return stringResolver.retry_sign_up;
    case ErrorTypStrings.INVALID_CODE:
      return stringResolver.invalid_code;
    default:
      return result;
  }
}
