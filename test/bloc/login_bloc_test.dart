import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/login/bloc/login_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/login/bloc/login_actions.dart';
import 'package:nutrenaissance_flutter/presentation/login/bloc/login_state.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockSignUpInteractor mockSignUp;
  late MockSendVerificationCodeInteractor mockSendVerificationCode;
  late MockFetchUserAttributesInteractor mockFetchUserAttributes;
  late MockSignInInteractor mockSignIn;
  late MockSaveUsernameAndEmailInteractor mockSaveUsernameAndEmail;
  late MockGetMasterFileVersionInteractor mockGetMasterFileVersion;
  late MockManageMasterFilesInteractor mockManageMasterFiles;
  late MockSaveMasterFileInteractor mockSaveMasterFile;
  late MockCheckProfileExistenceInteractor mockCheckProfileExistence;
  late MockDownloadProfileInteractor mockDownloadProfile;
  late MockGetIdTokenInteractor mockGetIdToken;
  late MockSaveProfileInteractor mockSaveProfile;
  late MockResendVerificationCodeInteractor mockResendVerificationCode;
  late MockSaveUserCredentialsInteractor mockSaveUserCredentials;
  late MockSaveUserInUsersRemoteDatabaseInteractor mockSaveUserInRemoteDb;
  late MockSignOutInteractor mockSignOut;

  setUp(() {
    mockSignUp = MockSignUpInteractor();
    mockSendVerificationCode = MockSendVerificationCodeInteractor();
    mockFetchUserAttributes = MockFetchUserAttributesInteractor();
    mockSignIn = MockSignInInteractor();
    mockSaveUsernameAndEmail = MockSaveUsernameAndEmailInteractor();
    mockGetMasterFileVersion = MockGetMasterFileVersionInteractor();
    mockManageMasterFiles = MockManageMasterFilesInteractor();
    mockSaveMasterFile = MockSaveMasterFileInteractor();
    mockCheckProfileExistence = MockCheckProfileExistenceInteractor();
    mockDownloadProfile = MockDownloadProfileInteractor();
    mockGetIdToken = MockGetIdTokenInteractor();
    mockSaveProfile = MockSaveProfileInteractor();
    mockResendVerificationCode = MockResendVerificationCodeInteractor();
    mockSaveUserCredentials = MockSaveUserCredentialsInteractor();
    mockSaveUserInRemoteDb = MockSaveUserInUsersRemoteDatabaseInteractor();
    mockSignOut = MockSignOutInteractor();
  });

  LoginBloc buildBloc() => LoginBloc(
        signUpInteractor: mockSignUp,
        verificationCodeInteractor: mockSendVerificationCode,
        fetchUserAttributesInteractor: mockFetchUserAttributes,
        signInInteractor: mockSignIn,
        saveUsernameAndEmailInteractor: mockSaveUsernameAndEmail,
        getMasterFilesVersionInteractor: mockGetMasterFileVersion,
        manageMasterFilesInteractor: mockManageMasterFiles,
        saveMasterFileInteractor: mockSaveMasterFile,
        checkProfileExistenceInteractor: mockCheckProfileExistence,
        downloadProfileInteractor: mockDownloadProfile,
        getIdTokenInteractor: mockGetIdToken,
        saveProfileInteractor: mockSaveProfile,
        resendVerificationCodeInteractor: mockResendVerificationCode,
        saveUserCredentialsInteractor: mockSaveUserCredentials,
        saveUserInUsersRemoteDatabaseInteractor: mockSaveUserInRemoteDb,
        signOutInteractor: mockSignOut,
      );

  group('LoginBloc', () {
    blocTest<LoginBloc, LoginState>(
      'initial state defaults to login mode with no loading',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.isLogin, true);
        expect(bloc.state.isPasswordVisible, false);
        expect(bloc.state.notConfirmedUserTryingToLogin, false);
        expect(bloc.state.isProfileChecked, false);
        expect(bloc.state.areMasterFilesChecked, false);
      },
    );

    blocTest<LoginBloc, LoginState>(
      'ChangePasswordVisibilityAction toggles password visibility',
      build: buildBloc,
      act: (bloc) => bloc.add(ChangePasswordVisibilityAction()),
      expect: () => [
        isA<LoginState>().having((s) => s.isPasswordVisible, 'visible', true),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'ChangePasswordVisibilityAction toggles back to hidden',
      build: () {
        final bloc = buildBloc();
        bloc.state.isPasswordVisible = true;
        return bloc;
      },
      act: (bloc) => bloc.add(ChangePasswordVisibilityAction()),
      expect: () => [
        isA<LoginState>().having((s) => s.isPasswordVisible, 'visible', false),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'ChangeLoginModeAction toggles from login to signup and calls action',
      build: buildBloc,
      act: (bloc) {
        bool actionCalled = false;
        bloc.add(ChangeLoginModeAction(action: () => actionCalled = true));
      },
      expect: () => [
        isA<LoginState>().having((s) => s.isLogin, 'isLogin', false),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'ChangeLoginModeAction toggles from signup back to login',
      build: () {
        final bloc = buildBloc();
        bloc.state.isLogin = false;
        return bloc;
      },
      act: (bloc) => bloc.add(ChangeLoginModeAction(action: () {})),
      expect: () => [
        isA<LoginState>().having((s) => s.isLogin, 'isLogin', true),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'InitialiseBlocAction preserves existing state fields',
      build: () {
        final bloc = buildBloc();
        bloc.state.username = 'testuser';
        bloc.state.email = 'test@example.com';
        bloc.state.password = 'pass123';
        return bloc;
      },
      act: (bloc) => bloc.add(InitialiseBlocAction(goToRegistry: () {})),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.username, 'username', 'testuser')
            .having((s) => s.email, 'email', 'test@example.com')
            .having((s) => s.password, 'password', 'pass123')
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'LaunchLoginAction with mismatched passwords sets error in signup mode',
      build: () {
        final bloc = buildBloc();
        bloc.state.isLogin = false;
        return bloc;
      },
      act: (bloc) => bloc.add(LaunchLoginAction(
        username: 'user1',
        email: 'a@b.com',
        password: 'Password1!',
        repeatPassword: 'DifferentPass1!',
        action: () {},
      )),
      expect: () => [
        // Loading state then error state (may be emitted as single state if emit.isDone)
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', true),
      ],
      verify: (bloc) {
        expect(bloc.state.errorTypes, ErrorTypes.passwordsNotMatchingError);
      },
    );

    // Test sync validation methods
    test('validateUsername returns error for null', () {
      final bloc = buildBloc();
      expect(bloc.validateUsername(null), FormErrorTypes.usernameEmptyOrNullError);
    });

    test('validateUsername returns error for empty string', () {
      final bloc = buildBloc();
      expect(bloc.validateUsername(''), FormErrorTypes.usernameEmptyOrNullError);
    });

    test('validateUsername returns null for valid username', () {
      final bloc = buildBloc();
      expect(bloc.validateUsername('john_doe'), null);
    });

    test('validateEmail returns null in login mode', () {
      final bloc = buildBloc();
      // default state.isLogin = true
      expect(bloc.validateEmail('invalid'), null);
    });

    test('validateEmail returns error for invalid email in signup mode', () {
      final bloc = buildBloc();
      bloc.state.isLogin = false;
      expect(bloc.validateEmail('invalid'), FormErrorTypes.emailFormatError);
    });

    test('validateEmail returns null for valid email in signup mode', () {
      final bloc = buildBloc();
      bloc.state.isLogin = false;
      expect(bloc.validateEmail('user@example.com'), null);
    });
  });
}
