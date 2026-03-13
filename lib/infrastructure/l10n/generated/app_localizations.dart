import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @nutrenaissance.
  ///
  /// In en, this message translates to:
  /// **'NutreNaissance'**
  String get nutrenaissance;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// No description provided for @login_hint.
  ///
  /// In en, this message translates to:
  /// **'Username or email'**
  String get login_hint;

  /// No description provided for @password_hint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_hint;

  /// No description provided for @have_an_account.
  ///
  /// In en, this message translates to:
  /// **'Do you have an account?'**
  String get have_an_account;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @forgotten_password.
  ///
  /// In en, this message translates to:
  /// **'Have you forgotten your password?'**
  String get forgotten_password;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @remove_item_title.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get remove_item_title;

  /// No description provided for @repeat_password.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeat_password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enter_username_or_email.
  ///
  /// In en, this message translates to:
  /// **'Username or email'**
  String get enter_username_or_email;

  /// No description provided for @write_here_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter...'**
  String get write_here_hint;

  /// No description provided for @enter_otp.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get enter_otp;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirm_password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have an account yet?'**
  String get dont_have_account;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get already_have_account;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get sign_up;

  /// No description provided for @enter_email_for_link.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email and we will send you a link so that you can change your password.'**
  String get enter_email_for_link;

  /// No description provided for @reset_password.
  ///
  /// In en, this message translates to:
  /// **'Restore password'**
  String get reset_password;

  /// No description provided for @reset_your_password.
  ///
  /// In en, this message translates to:
  /// **'Reset your password:'**
  String get reset_your_password;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @enter_verification_code.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enter_verification_code;

  /// No description provided for @write_verification_code.
  ///
  /// In en, this message translates to:
  /// **'Write here your verification code'**
  String get write_verification_code;

  /// No description provided for @resend_verification_code.
  ///
  /// In en, this message translates to:
  /// **'Send another code'**
  String get resend_verification_code;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @joy_of_science.
  ///
  /// In en, this message translates to:
  /// **'The joy of science, the power of nutrition.'**
  String get joy_of_science;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get start;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @weekly_evolution.
  ///
  /// In en, this message translates to:
  /// **'Weekly evolution'**
  String get weekly_evolution;

  /// No description provided for @diary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diary;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @verify_your_account.
  ///
  /// In en, this message translates to:
  /// **'Account verification'**
  String get verify_your_account;

  /// No description provided for @verification_code_explanation.
  ///
  /// In en, this message translates to:
  /// **'A verification code has been sent to your email. Please, enter it below to confirm your account.'**
  String get verification_code_explanation;

  /// No description provided for @verification_code_success.
  ///
  /// In en, this message translates to:
  /// **'Verification successful. Welcome to Nutrenaissance!'**
  String get verification_code_success;

  /// No description provided for @verification_code_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error verifying the code. Please try again.'**
  String get verification_code_error;

  /// No description provided for @password_format_error.
  ///
  /// In en, this message translates to:
  /// **'The password must be 8 characters long at least, and contain one lower case letter, one uppercase letter and one number at least.'**
  String get password_format_error;

  /// No description provided for @password_matching_error.
  ///
  /// In en, this message translates to:
  /// **'Passwords must match.'**
  String get password_matching_error;

  /// No description provided for @login_successful.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get login_successful;

  /// No description provided for @user_already_exists.
  ///
  /// In en, this message translates to:
  /// **'User already exists. Choose another name and try again please.'**
  String get user_already_exists;

  /// No description provided for @too_many_attempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try it again tomorrow.'**
  String get too_many_attempts;

  /// No description provided for @name_you_want_to_be_called_by.
  ///
  /// In en, this message translates to:
  /// **'Tell us the name you want us to call you by'**
  String get name_you_want_to_be_called_by;

  /// No description provided for @write_your_name_here.
  ///
  /// In en, this message translates to:
  /// **'Write your name here'**
  String get write_your_name_here;

  /// No description provided for @birthday_question.
  ///
  /// In en, this message translates to:
  /// **'Tell us your birth date'**
  String get birthday_question;

  /// No description provided for @birthday_button.
  ///
  /// In en, this message translates to:
  /// **'Choose your birthdate'**
  String get birthday_button;

  /// No description provided for @sex_question.
  ///
  /// In en, this message translates to:
  /// **'What\'s your biological sex?'**
  String get sex_question;

  /// No description provided for @masculine.
  ///
  /// In en, this message translates to:
  /// **'Masculine'**
  String get masculine;

  /// No description provided for @feminine.
  ///
  /// In en, this message translates to:
  /// **'Feminine'**
  String get feminine;

  /// No description provided for @occupation_question.
  ///
  /// In en, this message translates to:
  /// **'What\'s your job?'**
  String get occupation_question;

  /// No description provided for @location_question.
  ///
  /// In en, this message translates to:
  /// **'Where are you at?'**
  String get location_question;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @common_name_mandatory.
  ///
  /// In en, this message translates to:
  /// **'The name field can\'t be empty'**
  String get common_name_mandatory;

  /// No description provided for @birthdate_mandatory.
  ///
  /// In en, this message translates to:
  /// **'You have to enter your birth date'**
  String get birthdate_mandatory;

  /// No description provided for @sex_mandatory.
  ///
  /// In en, this message translates to:
  /// **'You have to select your sex'**
  String get sex_mandatory;

  /// No description provided for @height_question.
  ///
  /// In en, this message translates to:
  /// **'Height?'**
  String get height_question;

  /// No description provided for @weight_question.
  ///
  /// In en, this message translates to:
  /// **'Weight?'**
  String get weight_question;

  /// No description provided for @height_mandatory.
  ///
  /// In en, this message translates to:
  /// **'Entering your height is mandatory'**
  String get height_mandatory;

  /// No description provided for @weight_mandatory.
  ///
  /// In en, this message translates to:
  /// **'Entering your weight is mandatory'**
  String get weight_mandatory;

  /// No description provided for @body_fat_question.
  ///
  /// In en, this message translates to:
  /// **'Body fat %'**
  String get body_fat_question;

  /// No description provided for @waist_measurement_question.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waist_measurement_question;

  /// No description provided for @body_fat_mandatory.
  ///
  /// In en, this message translates to:
  /// **'The body fat is a mandatory parameter'**
  String get body_fat_mandatory;

  /// No description provided for @waist_measurement_mandatory.
  ///
  /// In en, this message translates to:
  /// **'The waist measurement fat is a mandatory parameter'**
  String get waist_measurement_mandatory;

  /// No description provided for @regularity_period_question.
  ///
  /// In en, this message translates to:
  /// **'How is your period?'**
  String get regularity_period_question;

  /// No description provided for @regular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get regular;

  /// No description provided for @irregular.
  ///
  /// In en, this message translates to:
  /// **'Irregular'**
  String get irregular;

  /// No description provided for @menopause.
  ///
  /// In en, this message translates to:
  /// **'Menopause'**
  String get menopause;

  /// No description provided for @without_period.
  ///
  /// In en, this message translates to:
  /// **'Without period'**
  String get without_period;

  /// No description provided for @menstruation.
  ///
  /// In en, this message translates to:
  /// **'Menstruation'**
  String get menstruation;

  /// No description provided for @cold.
  ///
  /// In en, this message translates to:
  /// **'Cold'**
  String get cold;

  /// No description provided for @period_duration_question.
  ///
  /// In en, this message translates to:
  /// **'How many days does your menstrual cycle consist of?'**
  String get period_duration_question;

  /// No description provided for @menstruation_regularity_error.
  ///
  /// In en, this message translates to:
  /// **'You have to choose your period\'s regularity'**
  String get menstruation_regularity_error;

  /// No description provided for @period_duration_error.
  ///
  /// In en, this message translates to:
  /// **'You have to select a period\'s duration'**
  String get period_duration_error;

  /// No description provided for @last_period_duration_error.
  ///
  /// In en, this message translates to:
  /// **'You have to choose your last period\'s start date'**
  String get last_period_duration_error;

  /// No description provided for @last_period_question.
  ///
  /// In en, this message translates to:
  /// **'What was the date of your last menstrual period ?'**
  String get last_period_question;

  /// No description provided for @choose_last_period_date.
  ///
  /// In en, this message translates to:
  /// **'Choose the date'**
  String get choose_last_period_date;

  /// No description provided for @repose.
  ///
  /// In en, this message translates to:
  /// **'Very sedentary'**
  String get repose;

  /// No description provided for @very_light_activity.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get very_light_activity;

  /// No description provided for @light_activity.
  ///
  /// In en, this message translates to:
  /// **'Light activity'**
  String get light_activity;

  /// No description provided for @moderated_activity.
  ///
  /// In en, this message translates to:
  /// **'Moderated activity'**
  String get moderated_activity;

  /// No description provided for @intense_activity.
  ///
  /// In en, this message translates to:
  /// **'Intense activity'**
  String get intense_activity;

  /// No description provided for @very_intense_activity.
  ///
  /// In en, this message translates to:
  /// **'Very intense activity'**
  String get very_intense_activity;

  /// No description provided for @repose_explanation.
  ///
  /// In en, this message translates to:
  /// **'No daily activity. Resting or sitting all day.'**
  String get repose_explanation;

  /// No description provided for @very_light_activity_explanation.
  ///
  /// In en, this message translates to:
  /// **'Low daily activity. Office work, driving, cooking, using the computer.'**
  String get very_light_activity_explanation;

  /// No description provided for @light_activity_explanation.
  ///
  /// In en, this message translates to:
  /// **'Work standing or job that involves occasional walking.'**
  String get light_activity_explanation;

  /// No description provided for @moderated_activity_explanation.
  ///
  /// In en, this message translates to:
  /// **'Active standing job, predominantly involving walking.'**
  String get moderated_activity_explanation;

  /// No description provided for @intense_activity_explanation.
  ///
  /// In en, this message translates to:
  /// **'Physically demanding and active job.'**
  String get intense_activity_explanation;

  /// No description provided for @very_intense_activity_explanation.
  ///
  /// In en, this message translates to:
  /// **'Physically very demanding and active job.'**
  String get very_intense_activity_explanation;

  /// No description provided for @occupation_mandatory.
  ///
  /// In en, this message translates to:
  /// **'You have to select an activity according to your occupation'**
  String get occupation_mandatory;

  /// No description provided for @high_blood_pressure.
  ///
  /// In en, this message translates to:
  /// **'High blood pressure'**
  String get high_blood_pressure;

  /// No description provided for @arteriosclerosis.
  ///
  /// In en, this message translates to:
  /// **'Arteriosclerosis'**
  String get arteriosclerosis;

  /// No description provided for @type_1_diabetes.
  ///
  /// In en, this message translates to:
  /// **'Type 1 diabetes'**
  String get type_1_diabetes;

  /// No description provided for @type_2_diabetes.
  ///
  /// In en, this message translates to:
  /// **'Type 2 diabetes'**
  String get type_2_diabetes;

  /// No description provided for @high_sugar_level.
  ///
  /// In en, this message translates to:
  /// **'High levels of sugar'**
  String get high_sugar_level;

  /// No description provided for @high_cholesterol.
  ///
  /// In en, this message translates to:
  /// **'High cholesterol'**
  String get high_cholesterol;

  /// No description provided for @high_triglycerides.
  ///
  /// In en, this message translates to:
  /// **'High triglycerides'**
  String get high_triglycerides;

  /// No description provided for @other_diseases.
  ///
  /// In en, this message translates to:
  /// **'Other disease'**
  String get other_diseases;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None / Raw'**
  String get none;

  /// No description provided for @common_diseases_question.
  ///
  /// In en, this message translates to:
  /// **'Do you have any of these diseases?'**
  String get common_diseases_question;

  /// No description provided for @medication_question.
  ///
  /// In en, this message translates to:
  /// **'Are you under pharmaceutical treatment?'**
  String get medication_question;

  /// No description provided for @omnivorous.
  ///
  /// In en, this message translates to:
  /// **'Omnivorous'**
  String get omnivorous;

  /// No description provided for @ovolactovegetarian.
  ///
  /// In en, this message translates to:
  /// **'Ovolactovegetarian'**
  String get ovolactovegetarian;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// No description provided for @halal.
  ///
  /// In en, this message translates to:
  /// **'Halal'**
  String get halal;

  /// No description provided for @diet_type_question.
  ///
  /// In en, this message translates to:
  /// **'If any, what kind of diet are you following?'**
  String get diet_type_question;

  /// No description provided for @diet_type_mandatory.
  ///
  /// In en, this message translates to:
  /// **'You have to select a diet type.'**
  String get diet_type_mandatory;

  /// No description provided for @crustaceans.
  ///
  /// In en, this message translates to:
  /// **'Crustaceans'**
  String get crustaceans;

  /// No description provided for @gluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten'**
  String get gluten;

  /// No description provided for @eggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get eggs;

  /// No description provided for @fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get fish;

  /// No description provided for @peanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get peanuts;

  /// No description provided for @soy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get soy;

  /// No description provided for @milk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get milk;

  /// No description provided for @nuts.
  ///
  /// In en, this message translates to:
  /// **'Nuts'**
  String get nuts;

  /// No description provided for @celery.
  ///
  /// In en, this message translates to:
  /// **'Celery'**
  String get celery;

  /// No description provided for @mustard.
  ///
  /// In en, this message translates to:
  /// **'Mustard'**
  String get mustard;

  /// No description provided for @sesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get sesame;

  /// No description provided for @sulfites.
  ///
  /// In en, this message translates to:
  /// **'Sulfites'**
  String get sulfites;

  /// No description provided for @lupins.
  ///
  /// In en, this message translates to:
  /// **'Lupins'**
  String get lupins;

  /// No description provided for @mollusks.
  ///
  /// In en, this message translates to:
  /// **'Mollusks'**
  String get mollusks;

  /// No description provided for @allergens_question.
  ///
  /// In en, this message translates to:
  /// **'Do you have any allergies?'**
  String get allergens_question;

  /// No description provided for @lactose.
  ///
  /// In en, this message translates to:
  /// **'Lactose'**
  String get lactose;

  /// No description provided for @fructose.
  ///
  /// In en, this message translates to:
  /// **'Fructose'**
  String get fructose;

  /// No description provided for @sorbitol.
  ///
  /// In en, this message translates to:
  /// **'Sorbitol'**
  String get sorbitol;

  /// No description provided for @intolerances_question.
  ///
  /// In en, this message translates to:
  /// **'Do you have any intolerance?'**
  String get intolerances_question;

  /// No description provided for @aversions_question.
  ///
  /// In en, this message translates to:
  /// **'Do you have any aversion about food?'**
  String get aversions_question;

  /// No description provided for @choose_aversions.
  ///
  /// In en, this message translates to:
  /// **'Choose your aversions'**
  String get choose_aversions;

  /// No description provided for @error_uploading_profile.
  ///
  /// In en, this message translates to:
  /// **'There was an error uploading the profile. Please try again.'**
  String get error_uploading_profile;

  /// No description provided for @error_saving_profile.
  ///
  /// In en, this message translates to:
  /// **'There was an error saving the profile to local storage. Please try again.'**
  String get error_saving_profile;

  /// No description provided for @stomach_acidity.
  ///
  /// In en, this message translates to:
  /// **'Stomach acidity'**
  String get stomach_acidity;

  /// No description provided for @diarrhea.
  ///
  /// In en, this message translates to:
  /// **'Diarrhea'**
  String get diarrhea;

  /// No description provided for @constipation.
  ///
  /// In en, this message translates to:
  /// **'Constipation'**
  String get constipation;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @creatine.
  ///
  /// In en, this message translates to:
  /// **'Creatine'**
  String get creatine;

  /// No description provided for @collagen.
  ///
  /// In en, this message translates to:
  /// **'Collagen'**
  String get collagen;

  /// No description provided for @error_getting_user_id.
  ///
  /// In en, this message translates to:
  /// **'There was an error retrieving your user id.'**
  String get error_getting_user_id;

  /// No description provided for @error_getting_recommendation.
  ///
  /// In en, this message translates to:
  /// **'There was an error getting your recommendations'**
  String get error_getting_recommendation;

  /// No description provided for @error_uploading_creatine.
  ///
  /// In en, this message translates to:
  /// **'There was an error while uploading creatine.'**
  String get error_uploading_creatine;

  /// No description provided for @error_saving_creatine.
  ///
  /// In en, this message translates to:
  /// **'There was an error while saving creatine.'**
  String get error_saving_creatine;

  /// No description provided for @error_uploading_collagen.
  ///
  /// In en, this message translates to:
  /// **'There was an error while uploading collagen.'**
  String get error_uploading_collagen;

  /// No description provided for @error_saving_collagen.
  ///
  /// In en, this message translates to:
  /// **'There was an error while saving collagen.'**
  String get error_saving_collagen;

  /// No description provided for @food_event.
  ///
  /// In en, this message translates to:
  /// **'Food event'**
  String get food_event;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @profile_creation.
  ///
  /// In en, this message translates to:
  /// **'Profile creation'**
  String get profile_creation;

  /// No description provided for @profile_creation_description.
  ///
  /// In en, this message translates to:
  /// **'Let us ask you some questions about you and your habits.'**
  String get profile_creation_description;

  /// No description provided for @general_questions.
  ///
  /// In en, this message translates to:
  /// **'General questions'**
  String get general_questions;

  /// No description provided for @health_questions.
  ///
  /// In en, this message translates to:
  /// **'Questions related to health'**
  String get health_questions;

  /// No description provided for @women_questions.
  ///
  /// In en, this message translates to:
  /// **'Questions about your period'**
  String get women_questions;

  /// No description provided for @diet_questions.
  ///
  /// In en, this message translates to:
  /// **'Questions related to diet'**
  String get diet_questions;

  /// No description provided for @objectives.
  ///
  /// In en, this message translates to:
  /// **'Objectives'**
  String get objectives;

  /// No description provided for @temporary_objectives.
  ///
  /// In en, this message translates to:
  /// **'Temporary needs'**
  String get temporary_objectives;

  /// No description provided for @metabolic_objectives.
  ///
  /// In en, this message translates to:
  /// **'Metabolic objectives'**
  String get metabolic_objectives;

  /// No description provided for @body_composition_objectives.
  ///
  /// In en, this message translates to:
  /// **'Body composition objectives'**
  String get body_composition_objectives;

  /// No description provided for @other_objectives.
  ///
  /// In en, this message translates to:
  /// **'Other objectives'**
  String get other_objectives;

  /// No description provided for @objectives_question.
  ///
  /// In en, this message translates to:
  /// **'Choose your objectives'**
  String get objectives_question;

  /// No description provided for @select_objective.
  ///
  /// In en, this message translates to:
  /// **'You must select at least one objective!'**
  String get select_objective;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @generic_error.
  ///
  /// In en, this message translates to:
  /// **'An error has happened'**
  String get generic_error;

  /// No description provided for @not_authorized_error.
  ///
  /// In en, this message translates to:
  /// **'Either email or password is incorrect'**
  String get not_authorized_error;

  /// No description provided for @send_verification_code_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error sending your verification code. Please try again.'**
  String get send_verification_code_error;

  /// No description provided for @email_already_exists.
  ///
  /// In en, this message translates to:
  /// **'The email you used already exists. Choose another one.'**
  String get email_already_exists;

  /// No description provided for @resend_verification_code_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error resending your verification code. Please try again.'**
  String get resend_verification_code_error;

  /// No description provided for @limit_error.
  ///
  /// In en, this message translates to:
  /// **'Number of allowed operations has exceeded. Please wait a while before re-attempting.'**
  String get limit_error;

  /// No description provided for @username_exists_error.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken. Please enter a new one.'**
  String get username_exists_error;

  /// No description provided for @get_email_from_token_error.
  ///
  /// In en, this message translates to:
  /// **'The was an error getting your email address. Please try again in a while.'**
  String get get_email_from_token_error;

  /// No description provided for @profile_existence_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error checking your profile.'**
  String get profile_existence_error;

  /// No description provided for @save_user_credentials_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error saving your credentials.'**
  String get save_user_credentials_error;

  /// No description provided for @fetch_user_credentials_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error fetching your credentials.'**
  String get fetch_user_credentials_error;

  /// No description provided for @download_profile_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error downloading your profile'**
  String get download_profile_error;

  /// No description provided for @save_profile_in_local_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error saving your profile'**
  String get save_profile_in_local_error;

  /// No description provided for @manage_master_files_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error downloading some files. Try again in a while.'**
  String get manage_master_files_error;

  /// No description provided for @save_user_in_remote_database_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error uploading your user. Try again later.'**
  String get save_user_in_remote_database_error;

  /// No description provided for @recipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get recipe;

  /// No description provided for @saving_profile_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error saving your profile. Try again later.'**
  String get saving_profile_error;

  /// No description provided for @saving_rdas_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error saving some files. Try again later.'**
  String get saving_rdas_error;

  /// No description provided for @uploading_profile_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error uploading your profile. Try again later.'**
  String get uploading_profile_error;

  /// No description provided for @retrieving_master_file_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error loading some info. Try again later.'**
  String get retrieving_master_file_error;

  /// No description provided for @recommendation_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error getting your recommendation. Try again later.'**
  String get recommendation_error;

  /// No description provided for @locally_saving_food_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error saving your food event. Try again later.'**
  String get locally_saving_food_event_error;

  /// No description provided for @uploading_food_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error uploading the food event. Try again later.'**
  String get uploading_food_event_error;

  /// No description provided for @uploading_food_routine_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error uploading the food routine event. Try again later.'**
  String get uploading_food_routine_event_error;

  /// No description provided for @save_food_routine_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error saving the food routine event. Try again later.'**
  String get save_food_routine_event_error;

  /// No description provided for @retrieve_food_events_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error getting your food events. Try again later.'**
  String get retrieve_food_events_error;

  /// No description provided for @delete_food_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error to delete food event. Try again later.'**
  String get delete_food_event_error;

  /// No description provided for @remove_food_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error to remove food event. Try again later.'**
  String get remove_food_event_error;

  /// No description provided for @delete_food_routine_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error to delete food routine. Try again later.'**
  String get delete_food_routine_error;

  /// No description provided for @remove_food_routine_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error to remove food routine. Try again later.'**
  String get remove_food_routine_error;

  /// No description provided for @delete_sport_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error to delete sport event. Try again later.'**
  String get delete_sport_event_error;

  /// No description provided for @remove_sport_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error to remove sport event. Try again later.'**
  String get remove_sport_event_error;

  /// No description provided for @delete_liquid_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error to delete liquid event. Try again later.'**
  String get delete_liquid_event_error;

  /// No description provided for @remove_liquid_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error to remove liquid event. Try again later.'**
  String get remove_liquid_event_error;

  /// No description provided for @upload_liquid_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error in uploading liquid event. Try again later.'**
  String get upload_liquid_event_error;

  /// No description provided for @upload_water_event_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to update water record. Please try again.'**
  String get upload_water_event_error;

  /// No description provided for @upload_supplement_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error in uploading supplement event. Try again later.'**
  String get upload_supplement_event_error;

  /// No description provided for @save_supplement_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error in saving supplement event. Try again later.'**
  String get save_supplement_event_error;

  /// No description provided for @delete_supplement_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error in deleting supplement event. Try again later.'**
  String get delete_supplement_event_error;

  /// No description provided for @remove_supplement_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error in removing supplement event. Try again later.'**
  String get remove_supplement_event_error;

  /// No description provided for @upload_supplement_favorite_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error in Uploading favorite supplement event. Try again later.'**
  String get upload_supplement_favorite_event_error;

  /// No description provided for @save_supplement_favorite_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error in saving favorite supplement event. Try again later.'**
  String get save_supplement_favorite_event_error;

  /// No description provided for @upload_supplement_routine_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error in uploading supplement routine event. Try again later.'**
  String get upload_supplement_routine_error;

  /// No description provided for @save_supplement_routine_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error in saving supplement routine event. Try again later.'**
  String get save_supplement_routine_error;

  /// No description provided for @delete_supplement_routine_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error in deleting supplement routine. Try again later.'**
  String get delete_supplement_routine_error;

  /// No description provided for @remove_supplement_routine_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error in removing supplement routine. Try again later.'**
  String get remove_supplement_routine_error;

  /// No description provided for @save_liquid_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error in saving liquid event. Try again later.'**
  String get save_liquid_event_error;

  /// No description provided for @invalid_password_error.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 8 characters long and contain at least one lowercase letter, one uppercase letter, one number, and one special character (e.g. !@#\$%^&*-_=+).'**
  String get invalid_password_error;

  /// No description provided for @username_empty_or_null_error.
  ///
  /// In en, this message translates to:
  /// **'This field doesn\'t have the right format'**
  String get username_empty_or_null_error;

  /// No description provided for @username_contains_spaces_error.
  ///
  /// In en, this message translates to:
  /// **'Username cannot contain spaces'**
  String get username_contains_spaces_error;

  /// No description provided for @retry_sign_up.
  ///
  /// In en, this message translates to:
  /// **'Retry operation and enter another username or email.'**
  String get retry_sign_up;

  /// No description provided for @invalid_code.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code provided, please try again.'**
  String get invalid_code;

  /// No description provided for @operation_not_completed.
  ///
  /// In en, this message translates to:
  /// **'Operation couldn\'t be completed'**
  String get operation_not_completed;

  /// No description provided for @email_format_error.
  ///
  /// In en, this message translates to:
  /// **'The email doesn\'t have the right format'**
  String get email_format_error;

  /// No description provided for @empty_repeat_password.
  ///
  /// In en, this message translates to:
  /// **'This field can\'t be empty'**
  String get empty_repeat_password;

  /// No description provided for @must_complete_field.
  ///
  /// In en, this message translates to:
  /// **'You must complete this field'**
  String get must_complete_field;

  /// No description provided for @select_gender.
  ///
  /// In en, this message translates to:
  /// **'Select a gender option that helps us understand how your body behaves.'**
  String get select_gender;

  /// No description provided for @repeat_password_error.
  ///
  /// In en, this message translates to:
  /// **'Your password does not match!'**
  String get repeat_password_error;

  /// No description provided for @chosen_sport.
  ///
  /// In en, this message translates to:
  /// **'Sport chosen'**
  String get chosen_sport;

  /// No description provided for @sport_date_start.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get sport_date_start;

  /// No description provided for @sport_time_start.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get sport_time_start;

  /// No description provided for @intensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensity;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @locally_saving_sport_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error saving your food event. Try again later.'**
  String get locally_saving_sport_event_error;

  /// No description provided for @uploading_sport_event_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error uploading the sport event. Try again later.'**
  String get uploading_sport_event_error;

  /// No description provided for @uploading_sport_routine_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error uploading the sport routine. Try again later.'**
  String get uploading_sport_routine_error;

  /// No description provided for @locally_saving_sport_routine_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error saving the sport routine. Try again later.'**
  String get locally_saving_sport_routine_error;

  /// No description provided for @delete_sport_routine_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error deleting the sport routine. Try again later.'**
  String get delete_sport_routine_error;

  /// No description provided for @remove_sport_routine_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error removing the sport routine. Try again later.'**
  String get remove_sport_routine_error;

  /// No description provided for @retrieve_sport_events_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error getting your food events. Try again later.'**
  String get retrieve_sport_events_error;

  /// No description provided for @sport_event_time_start_error.
  ///
  /// In en, this message translates to:
  /// **'You have to select the time'**
  String get sport_event_time_start_error;

  /// No description provided for @sport_event_date_start_error.
  ///
  /// In en, this message translates to:
  /// **'You have to select the date'**
  String get sport_event_date_start_error;

  /// No description provided for @sport_event_sport_id_error.
  ///
  /// In en, this message translates to:
  /// **'You have to select the sport'**
  String get sport_event_sport_id_error;

  /// No description provided for @sport_event_intensity_start_error.
  ///
  /// In en, this message translates to:
  /// **'You have to select the intensity'**
  String get sport_event_intensity_start_error;

  /// No description provided for @sport_event_minutes_start_error.
  ///
  /// In en, this message translates to:
  /// **'You have to select the duration'**
  String get sport_event_minutes_start_error;

  /// No description provided for @advice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get advice;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @errorContent.
  ///
  /// In en, this message translates to:
  /// **'You have just experienced an error. Too bad huh?'**
  String get errorContent;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weight;

  /// No description provided for @body_fat.
  ///
  /// In en, this message translates to:
  /// **'Body fat (%)'**
  String get body_fat;

  /// No description provided for @waist.
  ///
  /// In en, this message translates to:
  /// **'Waist (cm)'**
  String get waist;

  /// No description provided for @diet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get diet;

  /// No description provided for @diet_specification.
  ///
  /// In en, this message translates to:
  /// **'Set your diet specifications.'**
  String get diet_specification;

  /// No description provided for @diet_desc.
  ///
  /// In en, this message translates to:
  /// **'Work activity type, not counting sport or training.'**
  String get diet_desc;

  /// No description provided for @diet_type.
  ///
  /// In en, this message translates to:
  /// **'Diet type'**
  String get diet_type;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @intolerances.
  ///
  /// In en, this message translates to:
  /// **'Intolerances'**
  String get intolerances;

  /// No description provided for @allergens.
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get allergens;

  /// No description provided for @aversions.
  ///
  /// In en, this message translates to:
  /// **'Aversions'**
  String get aversions;

  /// No description provided for @medical_history.
  ///
  /// In en, this message translates to:
  /// **'Medical history'**
  String get medical_history;

  /// No description provided for @physical_activity.
  ///
  /// In en, this message translates to:
  /// **'Physical Activity'**
  String get physical_activity;

  /// No description provided for @body_measurements.
  ///
  /// In en, this message translates to:
  /// **'Body Measurements'**
  String get body_measurements;

  /// No description provided for @other_diseases_info.
  ///
  /// In en, this message translates to:
  /// **'Enter the diseases you want separated by commas'**
  String get other_diseases_info;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @faeces_urine.
  ///
  /// In en, this message translates to:
  /// **'Faeces and Urine'**
  String get faeces_urine;

  /// No description provided for @evolution_14_days.
  ///
  /// In en, this message translates to:
  /// **'Evolution of the last 14 days'**
  String get evolution_14_days;

  /// No description provided for @faeces.
  ///
  /// In en, this message translates to:
  /// **'Faeces'**
  String get faeces;

  /// No description provided for @urine.
  ///
  /// In en, this message translates to:
  /// **'urine'**
  String get urine;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @liquids.
  ///
  /// In en, this message translates to:
  /// **'Liquids'**
  String get liquids;

  /// No description provided for @food_favs.
  ///
  /// In en, this message translates to:
  /// **'Favorite foods'**
  String get food_favs;

  /// No description provided for @sport_favs.
  ///
  /// In en, this message translates to:
  /// **'Favorite sports'**
  String get sport_favs;

  /// No description provided for @sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @add_food.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get add_food;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @create_dish.
  ///
  /// In en, this message translates to:
  /// **'Create Dish'**
  String get create_dish;

  /// No description provided for @create_routine.
  ///
  /// In en, this message translates to:
  /// **'Create Routine'**
  String get create_routine;

  /// No description provided for @routines.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get routines;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get day;

  /// No description provided for @add_new_ingredient.
  ///
  /// In en, this message translates to:
  /// **'Add new ingredient'**
  String get add_new_ingredient;

  /// No description provided for @add_new.
  ///
  /// In en, this message translates to:
  /// **'Add new'**
  String get add_new;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @grames.
  ///
  /// In en, this message translates to:
  /// **'Grames'**
  String get grames;

  /// No description provided for @cooking_method.
  ///
  /// In en, this message translates to:
  /// **'Cooking method'**
  String get cooking_method;

  /// No description provided for @conversion_factor.
  ///
  /// In en, this message translates to:
  /// **'Preparation Method'**
  String get conversion_factor;

  /// No description provided for @oil_used.
  ///
  /// In en, this message translates to:
  /// **'Oil used'**
  String get oil_used;

  /// No description provided for @no_cooking_methods.
  ///
  /// In en, this message translates to:
  /// **'This food does not have cooking methods.'**
  String get no_cooking_methods;

  /// No description provided for @missing_fieds_food_event.
  ///
  /// In en, this message translates to:
  /// **'You have to fill all the fields'**
  String get missing_fieds_food_event;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @no_foods_in_event.
  ///
  /// In en, this message translates to:
  /// **'You need to enter foods'**
  String get no_foods_in_event;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'AND'**
  String get and;

  /// No description provided for @food_event_successfully_saved.
  ///
  /// In en, this message translates to:
  /// **'Your food has been successfully saved!'**
  String get food_event_successfully_saved;

  /// No description provided for @food_routine_successfully_saved.
  ///
  /// In en, this message translates to:
  /// **'Your food routine has been successfully saved!'**
  String get food_routine_successfully_saved;

  /// No description provided for @food_favorite_successfully_saved.
  ///
  /// In en, this message translates to:
  /// **'Your food favorite has been successfully saved!'**
  String get food_favorite_successfully_saved;

  /// No description provided for @sport_event_successfully_saved.
  ///
  /// In en, this message translates to:
  /// **'Your sport has been successfully saved!'**
  String get sport_event_successfully_saved;

  /// No description provided for @sport_favorite_successfully_saved.
  ///
  /// In en, this message translates to:
  /// **'Your sport favorite has been successfully saved!'**
  String get sport_favorite_successfully_saved;

  /// No description provided for @sport_routine_successfully_saved.
  ///
  /// In en, this message translates to:
  /// **'Your sport routine has been successfully saved!'**
  String get sport_routine_successfully_saved;

  /// No description provided for @liquid_event_successfully_saved.
  ///
  /// In en, this message translates to:
  /// **'Your liquid has been successfully saved!'**
  String get liquid_event_successfully_saved;

  /// No description provided for @supplement_event_successfully_saved.
  ///
  /// In en, this message translates to:
  /// **'Your Supplement has been successfully saved!'**
  String get supplement_event_successfully_saved;

  /// No description provided for @supplement_favorite_successfully_saved.
  ///
  /// In en, this message translates to:
  /// **'Your Supplement favorite has been successfully saved!'**
  String get supplement_favorite_successfully_saved;

  /// No description provided for @supplement_routine_successfully_saved.
  ///
  /// In en, this message translates to:
  /// **'Your Supplement routine has been successfully saved!'**
  String get supplement_routine_successfully_saved;

  /// No description provided for @feces_event_successfully_saved.
  ///
  /// In en, this message translates to:
  /// **'Your Faeces has been successfully saved!'**
  String get feces_event_successfully_saved;

  /// No description provided for @urine_event_successfully_saved.
  ///
  /// In en, this message translates to:
  /// **'Your Urine has been successfully saved!'**
  String get urine_event_successfully_saved;

  /// No description provided for @remove_food.
  ///
  /// In en, this message translates to:
  /// **'Do you want to remove this food from your list?'**
  String get remove_food;

  /// No description provided for @removed_food.
  ///
  /// In en, this message translates to:
  /// **'Your food has been successfully removed!'**
  String get removed_food;

  /// No description provided for @delete_liquid.
  ///
  /// In en, this message translates to:
  /// **'Your liquid has been successfully deleted!'**
  String get delete_liquid;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @my_recipes.
  ///
  /// In en, this message translates to:
  /// **'My Recipes'**
  String get my_recipes;

  /// No description provided for @micronutrients.
  ///
  /// In en, this message translates to:
  /// **'Micronutrients associated with objectives'**
  String get micronutrients;

  /// No description provided for @temporary_micronutrients.
  ///
  /// In en, this message translates to:
  /// **'Related to your Temporary Needs'**
  String get temporary_micronutrients;

  /// No description provided for @related_objectives.
  ///
  /// In en, this message translates to:
  /// **'Related to objectives'**
  String get related_objectives;

  /// No description provided for @deficiency_micronutrients.
  ///
  /// In en, this message translates to:
  /// **'Related to your nutritional deficiencies'**
  String get deficiency_micronutrients;

  /// No description provided for @micronutrientss.
  ///
  /// In en, this message translates to:
  /// **'Micronutrients'**
  String get micronutrientss;

  /// No description provided for @other_micronutrientss.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other_micronutrientss;

  /// No description provided for @objectives_related.
  ///
  /// In en, this message translates to:
  /// **'Objectives Related'**
  String get objectives_related;

  /// No description provided for @other_temp_needs.
  ///
  /// In en, this message translates to:
  /// **'Other temporary needs'**
  String get other_temp_needs;

  /// No description provided for @micronutrients_achieve_object.
  ///
  /// In en, this message translates to:
  /// **'Micronutrients to achieve your objectives'**
  String get micronutrients_achieve_object;

  /// No description provided for @update_your_data.
  ///
  /// In en, this message translates to:
  /// **'Update your data'**
  String get update_your_data;

  /// No description provided for @update_data.
  ///
  /// In en, this message translates to:
  /// **'Update data'**
  String get update_data;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Man'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Woman'**
  String get female;

  /// No description provided for @years_old.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get years_old;

  /// No description provided for @imp_info.
  ///
  /// In en, this message translates to:
  /// **'Important information'**
  String get imp_info;

  /// No description provided for @update_goals.
  ///
  /// In en, this message translates to:
  /// **'Update goals'**
  String get update_goals;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @update_desc.
  ///
  /// In en, this message translates to:
  /// **'To track correctly and be able to meet your goals'**
  String get update_desc;

  /// No description provided for @workout_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Your Workout starts in %s hours!'**
  String get workout_dialog_title;

  /// No description provided for @after_workout_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'After the Workout'**
  String get after_workout_dialog_title;

  /// No description provided for @workout_dialog_desc.
  ///
  /// In en, this message translates to:
  /// **'To reach your goal of improving sports performance, introduce foods rich in nitrates (vasodilators) before training.\n\nExamples: \nArugula, lettuce, beet, spinach, pumpkin, endive, zucchini, leek, carrot...'**
  String get workout_dialog_desc;

  /// No description provided for @after_workout_dialog_desc.
  ///
  /// In en, this message translates to:
  /// **'Remember to eat food rich in antioxidants: \n\nExamples: \nRed fruits, broccoli, citrus fruits, tomato, green tea, turmeric, ginger, cocoa, spinach, apple, nuts...'**
  String get after_workout_dialog_desc;

  /// No description provided for @improve_recovery_title.
  ///
  /// In en, this message translates to:
  /// **'Improve your recovery'**
  String get improve_recovery_title;

  /// No description provided for @improve_recovery_desc.
  ///
  /// In en, this message translates to:
  /// **'Remember to eat food rich in antioxidants: \n\nExamples: \nRed fruits, broccoli, citrus fruits, tomato, green tea, turmeric, ginger, cocoa, spinach, apple, nuts...'**
  String get improve_recovery_desc;

  /// No description provided for @item_found.
  ///
  /// In en, this message translates to:
  /// **'Item found'**
  String get item_found;

  /// No description provided for @items_found.
  ///
  /// In en, this message translates to:
  /// **'Items found'**
  String get items_found;

  /// No description provided for @macronutrients.
  ///
  /// In en, this message translates to:
  /// **'Macronutrients'**
  String get macronutrients;

  /// No description provided for @weekly_nutrients.
  ///
  /// In en, this message translates to:
  /// **'Weekly Nutrient Follow-up'**
  String get weekly_nutrients;

  /// No description provided for @no_food_events.
  ///
  /// In en, this message translates to:
  /// **'You need to introduce food events'**
  String get no_food_events;

  /// No description provided for @no_sport_events.
  ///
  /// In en, this message translates to:
  /// **'You need to introduce sport events'**
  String get no_sport_events;

  /// No description provided for @energy_balance_title.
  ///
  /// In en, this message translates to:
  /// **'Energy balance (net Kcal)'**
  String get energy_balance_title;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @combo.
  ///
  /// In en, this message translates to:
  /// **'Combo'**
  String get combo;

  /// No description provided for @raw_kcal_title.
  ///
  /// In en, this message translates to:
  /// **'Raw kcal (taken)'**
  String get raw_kcal_title;

  /// No description provided for @spent_kcal_title.
  ///
  /// In en, this message translates to:
  /// **'Kcal spent'**
  String get spent_kcal_title;

  /// No description provided for @spent_kcal_two_line.
  ///
  /// In en, this message translates to:
  /// **'Kcal\nspent'**
  String get spent_kcal_two_line;

  /// No description provided for @kcal_ingested.
  ///
  /// In en, this message translates to:
  /// **'Kcal ingested'**
  String get kcal_ingested;

  /// No description provided for @kcal_ingested_two_line.
  ///
  /// In en, this message translates to:
  /// **'Kcal\ningested'**
  String get kcal_ingested_two_line;

  /// No description provided for @average_spent_kcal.
  ///
  /// In en, this message translates to:
  /// **'Average kcal spent'**
  String get average_spent_kcal;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'out of'**
  String get from;

  /// No description provided for @sugar.
  ///
  /// In en, this message translates to:
  /// **'Free Sugar'**
  String get sugar;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @frequent.
  ///
  /// In en, this message translates to:
  /// **'Frequent'**
  String get frequent;

  /// No description provided for @touch_here.
  ///
  /// In en, this message translates to:
  /// **'Touch here'**
  String get touch_here;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @event_saved_successfully.
  ///
  /// In en, this message translates to:
  /// **'Event saved successfully'**
  String get event_saved_successfully;

  /// No description provided for @add_sport_event.
  ///
  /// In en, this message translates to:
  /// **'Add sport event'**
  String get add_sport_event;

  /// No description provided for @add_physical_activity.
  ///
  /// In en, this message translates to:
  /// **'Add Physical Activity'**
  String get add_physical_activity;

  /// No description provided for @activity_log.
  ///
  /// In en, this message translates to:
  /// **'Activity Log'**
  String get activity_log;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @physical_summary_exp.
  ///
  /// In en, this message translates to:
  /// **'A summary of your logged physical activity will be displayed here. Add a physical activity to see how it works.'**
  String get physical_summary_exp;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @liquid_event.
  ///
  /// In en, this message translates to:
  /// **'Liquid event'**
  String get liquid_event;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @liters.
  ///
  /// In en, this message translates to:
  /// **'liters'**
  String get liters;

  /// No description provided for @feeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// No description provided for @depositions.
  ///
  /// In en, this message translates to:
  /// **'Depositions'**
  String get depositions;

  /// No description provided for @this_week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get this_week;

  /// No description provided for @days_of_week.
  ///
  /// In en, this message translates to:
  /// **'Days of the week'**
  String get days_of_week;

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get weekdays;

  /// No description provided for @weekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get weekend;

  /// No description provided for @no_liquid_events.
  ///
  /// In en, this message translates to:
  /// **'You need to introduce liquid events'**
  String get no_liquid_events;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @hydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get hydration;

  /// No description provided for @coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get coming_soon;

  /// No description provided for @ingested_water.
  ///
  /// In en, this message translates to:
  /// **'Ingested Water'**
  String get ingested_water;

  /// No description provided for @add_water.
  ///
  /// In en, this message translates to:
  /// **'Add water'**
  String get add_water;

  /// No description provided for @glass.
  ///
  /// In en, this message translates to:
  /// **'A glass'**
  String get glass;

  /// No description provided for @error_uploading_event.
  ///
  /// In en, this message translates to:
  /// **'There was an error uploading the event. Please try again.'**
  String get error_uploading_event;

  /// No description provided for @error_uploading_favorite.
  ///
  /// In en, this message translates to:
  /// **'There was an error uploading the favorite. Please try again.'**
  String get error_uploading_favorite;

  /// No description provided for @error_saving_event.
  ///
  /// In en, this message translates to:
  /// **'There was an error saving the event. Please try again.'**
  String get error_saving_event;

  /// No description provided for @error_saving_favorite.
  ///
  /// In en, this message translates to:
  /// **'There was an error saving the favorite. Please try again.'**
  String get error_saving_favorite;

  /// No description provided for @food_favorites.
  ///
  /// In en, this message translates to:
  /// **'Food favorites'**
  String get food_favorites;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @see_more.
  ///
  /// In en, this message translates to:
  /// **'See more...'**
  String get see_more;

  /// No description provided for @add_comment.
  ///
  /// In en, this message translates to:
  /// **'Add comment'**
  String get add_comment;

  /// No description provided for @add_favorite.
  ///
  /// In en, this message translates to:
  /// **'Add favorite'**
  String get add_favorite;

  /// No description provided for @make_favorite.
  ///
  /// In en, this message translates to:
  /// **'Make it favorite'**
  String get make_favorite;

  /// No description provided for @save_as_favorite.
  ///
  /// In en, this message translates to:
  /// **'Save as favorite'**
  String get save_as_favorite;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @food_name.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get food_name;

  /// No description provided for @spor_name.
  ///
  /// In en, this message translates to:
  /// **'Sport name'**
  String get spor_name;

  /// No description provided for @no_food_favorites.
  ///
  /// In en, this message translates to:
  /// **'There are no favorites of this meal time'**
  String get no_food_favorites;

  /// No description provided for @remove_favorite_question.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the favorite'**
  String get remove_favorite_question;

  /// No description provided for @remove_item.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove\n\"{itemName}\"?'**
  String remove_item(Object itemName);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @choose_meal_time.
  ///
  /// In en, this message translates to:
  /// **'Choose meal time'**
  String get choose_meal_time;

  /// No description provided for @meal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get meal;

  /// No description provided for @save_favorite_error.
  ///
  /// In en, this message translates to:
  /// **'There was a problem saving your favorite. Please try again.'**
  String get save_favorite_error;

  /// No description provided for @upload_favorite_error.
  ///
  /// In en, this message translates to:
  /// **'There was a problem uploading your favorite. Please try again.'**
  String get upload_favorite_error;

  /// No description provided for @delete_favorite_error.
  ///
  /// In en, this message translates to:
  /// **'There was a problem deleting your favorite. Please try again.'**
  String get delete_favorite_error;

  /// No description provided for @remove_favorite_error.
  ///
  /// In en, this message translates to:
  /// **'There was a problem removing your favorite. Please try again.'**
  String get remove_favorite_error;

  /// No description provided for @favorite_name_required.
  ///
  /// In en, this message translates to:
  /// **'You have to enter the name'**
  String get favorite_name_required;

  /// No description provided for @meal_time_required.
  ///
  /// In en, this message translates to:
  /// **'You have to choose the meal time'**
  String get meal_time_required;

  /// No description provided for @required_kcal.
  ///
  /// In en, this message translates to:
  /// **'Required Kcal'**
  String get required_kcal;

  /// No description provided for @sport_name.
  ///
  /// In en, this message translates to:
  /// **'Sport\'s name'**
  String get sport_name;

  /// No description provided for @alternatives.
  ///
  /// In en, this message translates to:
  /// **'Alternatives'**
  String get alternatives;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @add_more.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get add_more;

  /// No description provided for @add_more_options.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get add_more_options;

  /// No description provided for @cooked.
  ///
  /// In en, this message translates to:
  /// **'Cooked'**
  String get cooked;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @foods_list.
  ///
  /// In en, this message translates to:
  /// **'Foods list'**
  String get foods_list;

  /// No description provided for @no_recipes.
  ///
  /// In en, this message translates to:
  /// **'There are no recipes, mark your recipe as favorite from discover.'**
  String get no_recipes;

  /// No description provided for @no_discovers.
  ///
  /// In en, this message translates to:
  /// **'There are no recipes matching the foods you selected.'**
  String get no_discovers;

  /// No description provided for @recommended_recipes.
  ///
  /// In en, this message translates to:
  /// **'Recommended recipes'**
  String get recommended_recipes;

  /// No description provided for @selected_foods.
  ///
  /// In en, this message translates to:
  /// **'Selected foods'**
  String get selected_foods;

  /// No description provided for @my_foods_list.
  ///
  /// In en, this message translates to:
  /// **'My foods list'**
  String get my_foods_list;

  /// No description provided for @see_recipes.
  ///
  /// In en, this message translates to:
  /// **'Go to recipes'**
  String get see_recipes;

  /// No description provided for @back_to_tips.
  ///
  /// In en, this message translates to:
  /// **'Back to tips'**
  String get back_to_tips;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @liquid_favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorite liquids'**
  String get liquid_favorites;

  /// No description provided for @dashboard_explaining_card.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Here you have the diary journal of the different nutritional constants you need to fulfill according to your profile. You can see from the micronutrients and macronutrients you need, to the daily energy balance, the sugar, the liquids taken and the steps you\'ve taken.'**
  String get dashboard_explaining_card;

  /// No description provided for @journal_general_explaining_card.
  ///
  /// In en, this message translates to:
  /// **'From your Diary, you can record all your meals and beverages, as well as the physical activity you have done throughout the day. You can include your favorite foods and exercise routines to streamline the daily data entry process.'**
  String get journal_general_explaining_card;

  /// No description provided for @journal_calendar_explaining_card.
  ///
  /// In en, this message translates to:
  /// **'In the Calendar, you can check all the records made by day.'**
  String get journal_calendar_explaining_card;

  /// No description provided for @journal_foods_explaining_card.
  ///
  /// In en, this message translates to:
  /// **'From here you can view your meals recorded today and add a new one by clicking on the button on the right.'**
  String get journal_foods_explaining_card;

  /// No description provided for @journal_liquids_explaining_card.
  ///
  /// In en, this message translates to:
  /// **'From here you can view the liquids ingested today and add a new one by clicking on the button on the right.'**
  String get journal_liquids_explaining_card;

  /// No description provided for @journal_sports_explaining_card.
  ///
  /// In en, this message translates to:
  /// **'From here you can view the exercise performed today and the weekly progress, as well as add a new one by clicking on the button on the upper right.'**
  String get journal_sports_explaining_card;

  /// No description provided for @add_new_food_button_text.
  ///
  /// In en, this message translates to:
  /// **'Add new food'**
  String get add_new_food_button_text;

  /// No description provided for @add_new_liquid_button_text.
  ///
  /// In en, this message translates to:
  /// **'Add new beverage'**
  String get add_new_liquid_button_text;

  /// No description provided for @add_new_sport_button_text.
  ///
  /// In en, this message translates to:
  /// **'Add new sport'**
  String get add_new_sport_button_text;

  /// No description provided for @food_add_new_event_upper_text.
  ///
  /// In en, this message translates to:
  /// **'Here you can add your meals by clicking the button on the upper right.'**
  String get food_add_new_event_upper_text;

  /// No description provided for @food_add_new_event_lower_text.
  ///
  /// In en, this message translates to:
  /// **'Below you will see your food history for today.'**
  String get food_add_new_event_lower_text;

  /// No description provided for @sport_add_new_event_upper_text.
  ///
  /// In en, this message translates to:
  /// **'Here you can add the exercise you performed by clicking the button on the upper right.'**
  String get sport_add_new_event_upper_text;

  /// No description provided for @sport_add_new_event_lower_text.
  ///
  /// In en, this message translates to:
  /// **'Below you will see today\'s exercise history.'**
  String get sport_add_new_event_lower_text;

  /// No description provided for @liquid_add_new_event_upper_text.
  ///
  /// In en, this message translates to:
  /// **'Here you can add the liquids ingested by clicking the button on the upper right.'**
  String get liquid_add_new_event_upper_text;

  /// No description provided for @liquid_add_new_event_lower_text.
  ///
  /// In en, this message translates to:
  /// **'Below you can add the water you consumed during your day by clicking the button below.'**
  String get liquid_add_new_event_lower_text;

  /// No description provided for @sport_favorite_upper_text.
  ///
  /// In en, this message translates to:
  /// **'Here you can add your favorite exercises by clicking the button on the upper right.'**
  String get sport_favorite_upper_text;

  /// No description provided for @sport_favorite_lower_text.
  ///
  /// In en, this message translates to:
  /// **'Below you will see your favorite exercise history.'**
  String get sport_favorite_lower_text;

  /// No description provided for @food_favorite_upper_text.
  ///
  /// In en, this message translates to:
  /// **'Here you can add your favorite foods by clicking the button on the upper right.'**
  String get food_favorite_upper_text;

  /// No description provided for @food_favorite_lower_text.
  ///
  /// In en, this message translates to:
  /// **'Below you will see the list of your grouped favorites.'**
  String get food_favorite_lower_text;

  /// No description provided for @recommendations_explaining_card.
  ///
  /// In en, this message translates to:
  /// **'Based on your profile, we recommend the foods to include in your diet. The foods are differentiated by color: in green, foods associated with your objectives; in blue, foods recommended to reach the minimum requirements of all micronutrients; and in orange, foods that you consume frequently.'**
  String get recommendations_explaining_card;

  /// No description provided for @recipes_explaining_card.
  ///
  /// In en, this message translates to:
  /// **'Here you have a selection of recommended recipes for your diet. You can save the ones you like the most as favorites.'**
  String get recipes_explaining_card;

  /// No description provided for @food_list_explaining_card.
  ///
  /// In en, this message translates to:
  /// **'Here\'s the list of foods you\'ve selected based on our recommendations and how often you eat them.'**
  String get food_list_explaining_card;

  /// No description provided for @confirmation_required.
  ///
  /// In en, this message translates to:
  /// **'Confirmation required'**
  String get confirmation_required;

  /// No description provided for @cancel_registry.
  ///
  /// In en, this message translates to:
  /// **'Cancel registry?'**
  String get cancel_registry;

  /// No description provided for @code_expired_error.
  ///
  /// In en, this message translates to:
  /// **'Code expired. Try it again with a new one.'**
  String get code_expired_error;

  /// No description provided for @sign_in_error.
  ///
  /// In en, this message translates to:
  /// **'Error signing in. Try again.'**
  String get sign_in_error;

  /// No description provided for @sign_out_error.
  ///
  /// In en, this message translates to:
  /// **'Error signing out. Try again.'**
  String get sign_out_error;

  /// No description provided for @mandatory_fields_not_filled_body.
  ///
  /// In en, this message translates to:
  /// **'The following fields are not filled:'**
  String get mandatory_fields_not_filled_body;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @sex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// No description provided for @birthdate.
  ///
  /// In en, this message translates to:
  /// **'Birthdate'**
  String get birthdate;

  /// No description provided for @foods_selection.
  ///
  /// In en, this message translates to:
  /// **'Selected foods:'**
  String get foods_selection;

  /// No description provided for @synchronize_events_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error synchronizing your events. Try again later.'**
  String get synchronize_events_error;

  /// No description provided for @email_sent_error.
  ///
  /// In en, this message translates to:
  /// **'Please check your email for code.'**
  String get email_sent_error;

  /// No description provided for @confirmation_code.
  ///
  /// In en, this message translates to:
  /// **'Confirmation code'**
  String get confirmation_code;

  /// No description provided for @error_confirmation_code.
  ///
  /// In en, this message translates to:
  /// **'Confirmation code is empty'**
  String get error_confirmation_code;

  /// No description provided for @incorrect_confirmation_code.
  ///
  /// In en, this message translates to:
  /// **'Confirmation code is incorrect'**
  String get incorrect_confirmation_code;

  /// No description provided for @routine_time_day_error.
  ///
  /// In en, this message translates to:
  /// **'Have you selected routine time or day?'**
  String get routine_time_day_error;

  /// No description provided for @provide_name.
  ///
  /// In en, this message translates to:
  /// **'Please provide a name'**
  String get provide_name;

  /// No description provided for @password_save_successfully.
  ///
  /// In en, this message translates to:
  /// **'Your password has been saved successfully!'**
  String get password_save_successfully;

  /// No description provided for @log_out.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get log_out;

  /// No description provided for @data_and_privacy.
  ///
  /// In en, this message translates to:
  /// **'Data and privacy'**
  String get data_and_privacy;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @feedback_support.
  ///
  /// In en, this message translates to:
  /// **'Feedback & Support'**
  String get feedback_support;

  /// No description provided for @whatsapp_contact.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp contact'**
  String get whatsapp_contact;

  /// No description provided for @feedback_form.
  ///
  /// In en, this message translates to:
  /// **'Feedback form'**
  String get feedback_form;

  /// No description provided for @legal_text.
  ///
  /// In en, this message translates to:
  /// **'Legal texts'**
  String get legal_text;

  /// No description provided for @legal_advise.
  ///
  /// In en, this message translates to:
  /// **'Legal advise'**
  String get legal_advise;

  /// No description provided for @privacy_polic.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy_polic;

  /// No description provided for @cookies_policy.
  ///
  /// In en, this message translates to:
  /// **'Cookies policy'**
  String get cookies_policy;

  /// No description provided for @view_policy.
  ///
  /// In en, this message translates to:
  /// **'View Policy'**
  String get view_policy;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @all_rights_reserved.
  ///
  /// In en, this message translates to:
  /// **'2025 - All rights reserved'**
  String get all_rights_reserved;

  /// No description provided for @whatsapp_chat_text.
  ///
  /// In en, this message translates to:
  /// **'Hi! I have a question about the app. Could you assist me?'**
  String get whatsapp_chat_text;

  /// No description provided for @needed_account_confirmation_message.
  ///
  /// In en, this message translates to:
  /// **'Before you create your profile you need to confirm your email account. You\'re about to receive a confirmation code in your registered email.'**
  String get needed_account_confirmation_message;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @slow_cooking.
  ///
  /// In en, this message translates to:
  /// **'We are slow cooking this section.'**
  String get slow_cooking;

  /// No description provided for @empty_events_calendar.
  ///
  /// In en, this message translates to:
  /// **'There is no food or physical activity recorded on this day!!'**
  String get empty_events_calendar;

  /// No description provided for @add_liquid_calendar.
  ///
  /// In en, this message translates to:
  /// **'Add drink'**
  String get add_liquid_calendar;

  /// No description provided for @add_sport_calendar.
  ///
  /// In en, this message translates to:
  /// **'Add sport'**
  String get add_sport_calendar;

  /// No description provided for @activity_type.
  ///
  /// In en, this message translates to:
  /// **'Work activity type, not counting sport or training'**
  String get activity_type;

  /// No description provided for @recommended_foods.
  ///
  /// In en, this message translates to:
  /// **'Recommended foods'**
  String get recommended_foods;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @foods_name.
  ///
  /// In en, this message translates to:
  /// **'Food\'s name'**
  String get foods_name;

  /// No description provided for @sports_name.
  ///
  /// In en, this message translates to:
  /// **'Sport\'s name'**
  String get sports_name;

  /// No description provided for @drinks_name.
  ///
  /// In en, this message translates to:
  /// **'Drink\'s name'**
  String get drinks_name;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'Enter here...'**
  String get enter;

  /// No description provided for @save_favorite.
  ///
  /// In en, this message translates to:
  /// **'Save favorite'**
  String get save_favorite;

  /// No description provided for @save_food.
  ///
  /// In en, this message translates to:
  /// **'Save food'**
  String get save_food;

  /// No description provided for @favorite_saved.
  ///
  /// In en, this message translates to:
  /// **'Your favorite has been successfully saved!'**
  String get favorite_saved;

  /// No description provided for @skip_verification_code_message.
  ///
  /// In en, this message translates to:
  /// **'If you skip this step you will be able to confirm your user further.'**
  String get skip_verification_code_message;

  /// No description provided for @add_liquid_title.
  ///
  /// In en, this message translates to:
  /// **'Add liquid'**
  String get add_liquid_title;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'By continuing you accept the data and privacy policy'**
  String get privacy_policy;

  /// No description provided for @accept_all.
  ///
  /// In en, this message translates to:
  /// **'Accept all'**
  String get accept_all;

  /// No description provided for @privacy_html.
  ///
  /// In en, this message translates to:
  /// **'<h2>Privacy Policy</h2><p>The Owner informs you about its <b>Privacy Policy</b> regarding the processing and protection of personal data of users that may be collected while using the mobile application (“the App”).</p><p>In this regard, the Owner guarantees compliance with the applicable personal data protection regulations, as reflected in the <b>Spanish Organic Law 3/2018</b>, of December 5, on the Protection of Personal Data and Guarantee of Digital Rights (LOPD GDD). It also complies with <b>Regulation (EU) 2016/679</b> of the European Parliament and of the Council of April 27, 2016, on the protection of natural persons (GDPR).</p><p>Use of the App implies acceptance of this Privacy Policy as well as the conditions included in the Legal Notice.</p><h3>Identity of the Controller</h3><ul><li><b>Controller:</b> NUTRENAISSANCE S.L.U.</li><li><b>Tax ID:</b> B42981100</li><li><b>Address:</b> Calle de Peña Goñi, 2. 02 IZ., Gipuzkoa - Spain</li><li><b>Email:</b> info@nutrenaissance.com</li><li><b>Website:</b> https://nutrenaissance.com</li></ul><h3>Principles Applied in Data Processing</h3><p>When processing your personal data, the Owner will apply the following principles in line with the GDPR:</p><ul><li><b>Lawfulness, fairness, and transparency:</b> Consent will always be required for processing personal data for one or more specific purposes, which will be previously communicated with full transparency.</li><li><b>Data minimization:</b> Only the data strictly necessary for the stated purposes will be collected.</li><li><b>Storage limitation:</b> Data will be kept only as long as necessary for the purposes of the processing. For subscriptions, inactive records will be periodically reviewed and deleted.</li><li><b>Integrity and confidentiality:</b> Data will be processed in a way that ensures security, confidentiality, and integrity. The Owner takes all necessary precautions to prevent unauthorized access or misuse.</li></ul><h3>Collection of Personal Data</h3><p>To use the App, you must create an account and provide certain personal information. The data collected may include:</p><ul><li><b>Identification data:</b> name, surname, email address, and login credentials.</li><li><b>Basic health and nutrition data:</b> weight, height, body mass index (BMI), muscle mass, and other measurements you choose to provide in order to use the App’s features.</li><li><b>Usage data:</b> interactions with the App, preferences, and activity logs necessary for improving the service.</li></ul><p>This information is essential for the App to provide personalized nutrition-related services. By entering this data, you consent to its collection, use, and processing in accordance with this Privacy Policy.</p><h3>User Rights</h3><p>You have the right to:</p><ul><li>Request access to your stored data.</li><li>Request rectification or erasure.</li><li>Request limitation of processing.</li><li>Object to processing.</li></ul><p>The right to data portability does not apply.</p><p>The exercise of these rights is personal and must therefore be carried out directly by the data subject by sending a request, along with a copy of a valid ID, to: <b>info@nutrenaissance.com</b>.</p><p>The exercise of these rights does not include any data the Owner is obliged to keep for administrative, legal, or security purposes. You also have the right to effective judicial protection and to lodge a complaint with the <b>Spanish Data Protection Agency</b> if you believe your data has been misused.</p><h3>Purpose of Data Processing</h3><p>When you use the App, send an email to the Owner, or subscribe to a newsletter, you are providing personal information (such as IP address, name, surname, physical address, email address, phone number, etc.). By providing this information, you consent to its collection, use, management, and storage under the terms described in this Privacy Policy.</p><p>The purposes of data processing include:</p><ul><li>Ensuring compliance with the Legal Notice and applicable law.</li><li>Improving the services offered through the App.</li><li>Managing the Owner’s presence on social media platforms.</li></ul><p><b>Social Media:</b> If you follow the Owner on social networks, data processing will be governed by this Privacy Policy and by the terms and conditions of each social platform. The Owner will use social media data only to manage its presence and inform you about activities, never to send individual advertising.</p><h3>Data Security</h3><p>To protect your personal data, the Owner takes all reasonable precautions and follows industry best practices to prevent loss, misuse, unauthorized access, disclosure, alteration, or destruction.</p><p>Your data will not be shared with third parties except when legally required or when necessary for service provision (with your prior consent and under strict security measures).</p><h3>Third-Party Content and Services</h3><p>The App may include links or embedded content (e.g., videos, articles) from external websites. These sites may collect data, use cookies, and track your interaction. The Owner is not responsible for the processing of personal data by external websites.</p><h3>Cookies and Tracking Technologies</h3><p>The App may use cookies or similar technologies necessary for its proper operation. For more information, please review the applicable cookie notices or settings available within the App.</p><h3>Legal Basis for Processing</h3><p>The legal basis for processing your data is your consent.</p><h3>Categories of Personal Data</h3><ul><li>Identifying data.</li><li>No special categories of data are processed.</li></ul><h3>Data Retention</h3><p>Personal data will be kept until you request its deletion.</p><h3>Data Recipients</h3><p><b>Google Analytics:</b> A web analytics service provided by Google Inc. (1600 Amphitheatre Parkway, Mountain View, California, CA 94043, USA). Google Analytics may use cookies to analyze App usage. Data may be stored on servers in the United States. More information: Google Privacy Policy.</p><h3>Non-Identifying Data</h3><p>When using the App, non-identifiable data may be collected, such as IP address, geolocation, usage patterns, and browsing habits. This data is used for statistical analysis and service improvement.</p><h3>Accuracy of Personal Data</h3><p>You agree that the data provided to the Owner is accurate, complete, and up to date, and you are solely responsible for its accuracy.</p><h3>Acceptance and Consent</h3><p>By using the App, you acknowledge that you have been informed of the terms regarding personal data protection, and you accept and consent to the processing of your data as described in this Privacy Policy.</p><h3>Changes to This Privacy Policy</h3><p>The Owner reserves the right to update this Privacy Policy to adapt it to legal changes or industry practices. This Privacy Policy will remain in effect until replaced by a duly published updated version.</p>'**
  String get privacy_html;

  /// No description provided for @privacy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_title;

  /// No description provided for @tip_text.
  ///
  /// In en, this message translates to:
  /// **'<p>Based on your profile, we recommend foods to include in your diet, differentiated by color.</p>\n<ul><li><b class=blue-text>In blue</b>, foods related to your goals.</li>\n<li><b class=green-text>In green</b>, foods recommended to help you meet the minimum requirements of all micronutrients.</li>\n<li><b class=yellowish-green-text>In a neutral color</b>, foods you consume frequently.</li></ul>'**
  String get tip_text;

  /// No description provided for @begin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get begin;

  /// No description provided for @fiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get fiber;

  /// No description provided for @supplements.
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get supplements;

  /// No description provided for @supplement.
  ///
  /// In en, this message translates to:
  /// **'Supplement'**
  String get supplement;

  /// No description provided for @recal_nutrients.
  ///
  /// In en, this message translates to:
  /// **'Recalculating \nnutrients'**
  String get recal_nutrients;

  /// No description provided for @lorem_ipsum.
  ///
  /// In en, this message translates to:
  /// **'Lorem ipsum dolor sit amet consectetur. Aliquet arcu ac non donec eget id. Netus sem ac etiam nunc vitae donec morbi. Eget consequat lacus semper nullam. Commodo euismod turpis commodo aenean vitae nibh faucibus pellentesque. Turpis eget scelerisque faucibus aenean.'**
  String get lorem_ipsum;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Its functions are various and fundamental for the body and tissues. They are naturally present in meats, fish and shellfish, eggs, legumes and their derivatives, and dairy products.'**
  String get protein;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Lipids or fats are essential nutrients and their main function is energy. We naturally consume them through unrefined vegetable oils, nuts, seeds, oily fish, avocado or eggs.'**
  String get fat;

  /// No description provided for @carbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Its function is energetic. They are naturally present in cereals, tubers, legumes, fruits, vegetables, dairy products,and in sugars such as honey or white sugar.'**
  String get carbohydrates;

  /// No description provided for @gross_kcal.
  ///
  /// In en, this message translates to:
  /// **'Gross Kcal (ingested)'**
  String get gross_kcal;

  /// No description provided for @gross_average_kcal.
  ///
  /// In en, this message translates to:
  /// **'Average Kcal ingested:'**
  String get gross_average_kcal;

  /// No description provided for @gross_description.
  ///
  /// In en, this message translates to:
  /// **'They represent the amount of energy obtained through food, crucial for the proper functioning of the body and its daily activities.'**
  String get gross_description;

  /// No description provided for @spent_Kcal_description.
  ///
  /// In en, this message translates to:
  /// **'Calories consumed during physical activity.'**
  String get spent_Kcal_description;

  /// No description provided for @basal_metabolic.
  ///
  /// In en, this message translates to:
  /// **'Basal Metabolism'**
  String get basal_metabolic;

  /// No description provided for @basal_metabolic_description.
  ///
  /// In en, this message translates to:
  /// **'It is the energy we use in resting conditions to maintain the body\'s vital functions and homeostasis. (60-75%).'**
  String get basal_metabolic_description;

  /// No description provided for @food_induced_thermo.
  ///
  /// In en, this message translates to:
  /// **'Food-induced thermogenesis'**
  String get food_induced_thermo;

  /// No description provided for @absorption_expense.
  ///
  /// In en, this message translates to:
  /// **'Energy expenditure associated with digestion, absorption and metabolism of food consumed. (10%)'**
  String get absorption_expense;

  /// No description provided for @energy_expenditure.
  ///
  /// In en, this message translates to:
  /// **'Energy expenditure by activity'**
  String get energy_expenditure;

  /// No description provided for @energy_expenditure_description.
  ///
  /// In en, this message translates to:
  /// **'It is the additional amount of calories burned during the practice of specific physical activities, it varies according to the type and intensity of the exercise. (15-30%)'**
  String get energy_expenditure_description;

  /// No description provided for @sugar_description.
  ///
  /// In en, this message translates to:
  /// **'Free sugars are those that are added to food and drinks, as well as sugars found naturally in honey, syrups, fruit juices, and fruit juice concentrates.\n\n\n Above all, we find them in ultra-processed foods: cookies, pastries, sweets, candys, sauces, soft drinks, colas, sugary and flavored dairy products, ice creams. Not healthy and the less the better.'**
  String get sugar_description;

  /// No description provided for @fiber_description.
  ///
  /// In en, this message translates to:
  /// **'Its effects on health are multiple and it is essential to have a healthy microbiota.\n\n\nWe obtain it from foods of plant origin. Above all, if we consume them whole and whole.'**
  String get fiber_description;

  /// No description provided for @water_description.
  ///
  /// In en, this message translates to:
  /// **'Water is the best option to hydrate ourselves.\n\nWe also obtain water from infusions, broths, purees, vegetables or fruits.'**
  String get water_description;

  /// No description provided for @minimum_water_required.
  ///
  /// In en, this message translates to:
  /// **'Minimum liquids required'**
  String get minimum_water_required;

  /// No description provided for @minimum_water_description.
  ///
  /// In en, this message translates to:
  /// **'Drinking water is essential. Adjust the water intake recommendation based on your physical activity, the climate conditions, and your dietary habits. .\n\nThe more activity you do, the more water you will have to drink.\n\n\n'**
  String get minimum_water_description;

  /// No description provided for @micros_keep_eye_on.
  ///
  /// In en, this message translates to:
  /// **'Micros to keep an eye on'**
  String get micros_keep_eye_on;

  /// No description provided for @item_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get item_title;

  /// No description provided for @item_saved_as_favorite.
  ///
  /// In en, this message translates to:
  /// **'This item will also be saved as a favorite'**
  String get item_saved_as_favorite;

  /// No description provided for @item_saved_as_routine.
  ///
  /// In en, this message translates to:
  /// **'This item will also be saved as a routine'**
  String get item_saved_as_routine;

  /// No description provided for @item_saved_as_workout.
  ///
  /// In en, this message translates to:
  /// **'This item will also be saved as a workout'**
  String get item_saved_as_workout;

  /// No description provided for @workouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// No description provided for @combo_name_required.
  ///
  /// In en, this message translates to:
  /// **'Please provide a name for your combo'**
  String get combo_name_required;

  /// No description provided for @please_enter_amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter the amount'**
  String get please_enter_amount;

  /// No description provided for @please_select_unit.
  ///
  /// In en, this message translates to:
  /// **'Please select a unit'**
  String get please_select_unit;

  /// No description provided for @please_select_cooking_method.
  ///
  /// In en, this message translates to:
  /// **'Please select a cooking method'**
  String get please_select_cooking_method;

  /// No description provided for @please_enter_duration.
  ///
  /// In en, this message translates to:
  /// **'Please enter the duration'**
  String get please_enter_duration;

  /// No description provided for @please_select_intensity.
  ///
  /// In en, this message translates to:
  /// **'Please select the intensity'**
  String get please_select_intensity;

  /// No description provided for @add_faeces.
  ///
  /// In en, this message translates to:
  /// **'Add Faeces'**
  String get add_faeces;

  /// No description provided for @add_urine.
  ///
  /// In en, this message translates to:
  /// **'Add Urine'**
  String get add_urine;

  /// No description provided for @food_label.
  ///
  /// In en, this message translates to:
  /// **'Food Label'**
  String get food_label;

  /// No description provided for @search_food_hint.
  ///
  /// In en, this message translates to:
  /// **'Type to search for food'**
  String get search_food_hint;

  /// No description provided for @search_activity_hint.
  ///
  /// In en, this message translates to:
  /// **'Type to search for an activity'**
  String get search_activity_hint;

  /// No description provided for @search_supplement_hint.
  ///
  /// In en, this message translates to:
  /// **'Type to search for a supplement'**
  String get search_supplement_hint;

  /// No description provided for @search_drink_hint.
  ///
  /// In en, this message translates to:
  /// **'Type to search for a drink'**
  String get search_drink_hint;

  /// No description provided for @new_day_message.
  ///
  /// In en, this message translates to:
  /// **'It\'s a new day! Go back to see today\'s data.'**
  String get new_day_message;

  /// No description provided for @health_sync_settings.
  ///
  /// In en, this message translates to:
  /// **'Health App Sync'**
  String get health_sync_settings;

  /// No description provided for @health_sync_title.
  ///
  /// In en, this message translates to:
  /// **'Sync with your health apps'**
  String get health_sync_title;

  /// No description provided for @health_sync_description.
  ///
  /// In en, this message translates to:
  /// **'Connect to automatically import your workouts, steps, and active calories'**
  String get health_sync_description;

  /// No description provided for @health_sync_connect.
  ///
  /// In en, this message translates to:
  /// **'Connect Now'**
  String get health_sync_connect;

  /// No description provided for @health_sync_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get health_sync_skip;

  /// No description provided for @health_sync_enable.
  ///
  /// In en, this message translates to:
  /// **'Enable health data sync'**
  String get health_sync_enable;

  /// No description provided for @health_sync_last_sync.
  ///
  /// In en, this message translates to:
  /// **'Last synced: {time}'**
  String health_sync_last_sync(String time);

  /// No description provided for @health_sync_now.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get health_sync_now;

  /// No description provided for @health_sync_syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get health_sync_syncing;

  /// No description provided for @health_sync_success.
  ///
  /// In en, this message translates to:
  /// **'Health data synced successfully'**
  String get health_sync_success;

  /// No description provided for @health_sync_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to sync health data'**
  String get health_sync_error;

  /// No description provided for @health_sync_no_permission.
  ///
  /// In en, this message translates to:
  /// **'Health data access not granted'**
  String get health_sync_no_permission;

  /// No description provided for @health_sync_not_available.
  ///
  /// In en, this message translates to:
  /// **'Health data sync is not available on this device'**
  String get health_sync_not_available;

  /// No description provided for @health_sync_data_types.
  ///
  /// In en, this message translates to:
  /// **'Synced Data Types'**
  String get health_sync_data_types;

  /// No description provided for @health_sync_source_apple.
  ///
  /// In en, this message translates to:
  /// **'Apple Health'**
  String get health_sync_source_apple;

  /// No description provided for @health_sync_source_health_connect.
  ///
  /// In en, this message translates to:
  /// **'Health Connect'**
  String get health_sync_source_health_connect;

  /// No description provided for @health_sync_activities_imported.
  ///
  /// In en, this message translates to:
  /// **'{count} activities imported'**
  String health_sync_activities_imported(int count);

  /// No description provided for @health_sync_hc_setup_title.
  ///
  /// In en, this message translates to:
  /// **'One more step'**
  String get health_sync_hc_setup_title;

  /// No description provided for @health_sync_hc_setup_body.
  ///
  /// In en, this message translates to:
  /// **'For your workouts to appear in NutRenaissance, your fitness apps (e.g. Samsung Health, Fitbit, Garmin) need to share data with Health Connect.'**
  String get health_sync_hc_setup_body;

  /// No description provided for @health_sync_hc_setup_step1.
  ///
  /// In en, this message translates to:
  /// **'Open Health Connect'**
  String get health_sync_hc_setup_step1;

  /// No description provided for @health_sync_hc_setup_step2.
  ///
  /// In en, this message translates to:
  /// **'Tap \'App permissions\''**
  String get health_sync_hc_setup_step2;

  /// No description provided for @health_sync_hc_setup_step3.
  ///
  /// In en, this message translates to:
  /// **'Select your fitness app and allow data sharing'**
  String get health_sync_hc_setup_step3;

  /// No description provided for @health_sync_hc_setup_open.
  ///
  /// In en, this message translates to:
  /// **'Open Health Connect'**
  String get health_sync_hc_setup_open;

  /// No description provided for @health_sync_hc_setup_done.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get health_sync_hc_setup_done;

  /// No description provided for @health_sync_section_title.
  ///
  /// In en, this message translates to:
  /// **'Health Data Sync'**
  String get health_sync_section_title;

  /// No description provided for @health_sync_enable_link.
  ///
  /// In en, this message translates to:
  /// **'Enable Health Data Sync'**
  String get health_sync_enable_link;

  /// No description provided for @health_sync_toggle_description.
  ///
  /// In en, this message translates to:
  /// **'Enable data synchronization with other health apps'**
  String get health_sync_toggle_description;

  /// No description provided for @health_sync_hc_install_message.
  ///
  /// In en, this message translates to:
  /// **'You need to install the Health Connect app in order to integrate with your other health apps and/or smart devices. Please click the link below to install.'**
  String get health_sync_hc_install_message;

  /// No description provided for @health_sync_hc_install_button.
  ///
  /// In en, this message translates to:
  /// **'Install Health Connect'**
  String get health_sync_hc_install_button;

  /// No description provided for @health_sync_hc_connect_message.
  ///
  /// In en, this message translates to:
  /// **'Open Health Connect to connect your health apps and smart devices so their data can be synced with NutreNaissance.'**
  String get health_sync_hc_connect_message;

  /// No description provided for @health_sync_hc_open_button.
  ///
  /// In en, this message translates to:
  /// **'Open Health Connect'**
  String get health_sync_hc_open_button;

  /// No description provided for @health_sync_card_enabled.
  ///
  /// In en, this message translates to:
  /// **'Health Sync Enabled'**
  String get health_sync_card_enabled;

  /// No description provided for @health_sync_card_never_synced.
  ///
  /// In en, this message translates to:
  /// **'Never synced'**
  String get health_sync_card_never_synced;

  /// No description provided for @distance_label.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance_label;

  /// No description provided for @heart_rate_label.
  ///
  /// In en, this message translates to:
  /// **'Heart rate'**
  String get heart_rate_label;

  /// No description provided for @sleeping_hours.
  ///
  /// In en, this message translates to:
  /// **'Sleeping hours'**
  String get sleeping_hours;

  /// No description provided for @of_target.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get of_target;

  /// No description provided for @hours_last_night.
  ///
  /// In en, this message translates to:
  /// **'hours last night.'**
  String get hours_last_night;

  /// No description provided for @steps_for_today.
  ///
  /// In en, this message translates to:
  /// **'steps for today.'**
  String get steps_for_today;

  /// No description provided for @no_activity_recorded.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded.'**
  String get no_activity_recorded;

  /// No description provided for @no_routines_scheduled.
  ///
  /// In en, this message translates to:
  /// **'No routines scheduled.'**
  String get no_routines_scheduled;

  /// No description provided for @activity_diary.
  ///
  /// In en, this message translates to:
  /// **'Routine diary'**
  String get activity_diary;

  /// No description provided for @logged.
  ///
  /// In en, this message translates to:
  /// **'LOGGED'**
  String get logged;

  /// No description provided for @programmed.
  ///
  /// In en, this message translates to:
  /// **'PROGRAMMED'**
  String get programmed;

  /// No description provided for @empty_record.
  ///
  /// In en, this message translates to:
  /// **'No data recorded'**
  String get empty_record;

  /// No description provided for @activities_programmed.
  ///
  /// In en, this message translates to:
  /// **'Activities programmed'**
  String get activities_programmed;

  /// No description provided for @remaining_kcal.
  ///
  /// In en, this message translates to:
  /// **'REMAINING KCAL'**
  String get remaining_kcal;

  /// No description provided for @burned_kcal.
  ///
  /// In en, this message translates to:
  /// **'KCAL SPENT'**
  String get burned_kcal;

  /// No description provided for @routine_label.
  ///
  /// In en, this message translates to:
  /// **'ROUTINE'**
  String get routine_label;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
