enum ErrorTypes {
  unknownError,
  notAuthorizedError,
  sendVerificationCodeError,
  resendVerificationCodeError,
  usernameExistsError,
  getEmailFromTokenError,
  profileExistenceError,
  saveUserCredentialsError,
  fetchUserCredentialsError,
  downloadProfileError,
  saveProfileInLocalError,
  manageMasterFilesError,
  saveUserInRemoteDatabaseError,

  savingProfileError,
  savingRdasError,
  uploadingProfileError,
  retrievingMasterFileError,
  recommendationError,
  locallySavingFoodEventError,
  uploadingFoodEventError,
  retrieveFoodEventsError,
}

enum FormErrorTypes {
  usernameEmptyOrNullError,
  emailFormatError,
  invalidPasswordError,
  emptyRepeatPassword,
  repeatPasswordError

}