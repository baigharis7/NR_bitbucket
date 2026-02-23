import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/validator_utils.dart';

void main() {
  group('Email Validation (isEmail)', () {
    test('should return true for valid email format', () {
      expect(isEmail('test@example.com'), true);
      expect(isEmail('user.name@domain.co'), true);
      expect(isEmail('user-name@domain.org'), true);
      expect(isEmail('user_name@domain.net'), true);
    });

    test('should return false for null or empty string', () {
      expect(isEmail(null), false);
      expect(isEmail(''), false);
    });

    test('should return false for invalid email format', () {
      expect(isEmail('invalid'), false);
      expect(isEmail('invalid@'), false);
      expect(isEmail('@domain.com'), false);
      expect(isEmail('invalid@domain'), false);
      expect(isEmail('invalid@.com'), false);
      expect(isEmail('invalid@domain.c'), false); // TLD too short
    });

    test('should return true for email with valid TLD lengths', () {
      expect(isEmail('test@example.co'), true); // 2 char TLD
      expect(isEmail('test@example.com'), true); // 3 char TLD
      expect(isEmail('test@example.info'), true); // 4 char TLD
    });
  });

  group('Password Validation (validatePasswordOrNull)', () {
    group('Login Mode', () {
      test('should return null for any password in login mode', () {
        expect(validatePasswordOrNull(true, null), null);
        expect(validatePasswordOrNull(true, ''), null);
        expect(validatePasswordOrNull(true, 'short'), null);
        expect(validatePasswordOrNull(true, 'anypassword'), null);
      });
    });

    group('Registration Mode', () {
      test('should return emptyPasswordError for empty password', () {
        expect(validatePasswordOrNull(false, null), FormErrorTypes.emptyPasswordError);
        expect(validatePasswordOrNull(false, ''), FormErrorTypes.emptyPasswordError);
      });

      test('should return error for password shorter than 8 characters', () {
        expect(validatePasswordOrNull(false, 'Aa1!'), FormErrorTypes.invalidPasswordError);
        expect(validatePasswordOrNull(false, 'Aa1!abc'), FormErrorTypes.invalidPasswordError);
      });

      test('should return error for password without lowercase letter', () {
        expect(validatePasswordOrNull(false, 'AAAAAAAA1!'), FormErrorTypes.invalidPasswordError);
      });

      test('should return error for password without uppercase letter', () {
        expect(validatePasswordOrNull(false, 'aaaaaaaa1!'), FormErrorTypes.invalidPasswordError);
      });

      test('should return error for password without digit', () {
        expect(validatePasswordOrNull(false, 'Aaaaaaaaa!'), FormErrorTypes.invalidPasswordError);
      });

      test('should return error for password without special character', () {
        expect(validatePasswordOrNull(false, 'Aaaaaaaa1'), FormErrorTypes.invalidPasswordError);
      });

      test('should return null for valid password with all requirements', () {
        expect(validatePasswordOrNull(false, 'Password1!'), null);
        expect(validatePasswordOrNull(false, 'Abcdefg1@'), null);
        expect(validatePasswordOrNull(false, 'MyP@ssw0rd'), null);
      });

      test('should accept various special characters', () {
        // Test different special characters
        expect(validatePasswordOrNull(false, 'Password1!'), null);
        expect(validatePasswordOrNull(false, 'Password1@'), null);
        expect(validatePasswordOrNull(false, 'Password1#'), null);
        expect(validatePasswordOrNull(false, 'Password1\$'), null);
        expect(validatePasswordOrNull(false, 'Password1%'), null);
        expect(validatePasswordOrNull(false, 'Password1^'), null);
        expect(validatePasswordOrNull(false, 'Password1&'), null);
        expect(validatePasswordOrNull(false, 'Password1*'), null);
        expect(validatePasswordOrNull(false, 'Password1('), null);
        expect(validatePasswordOrNull(false, 'Password1)'), null);
        expect(validatePasswordOrNull(false, 'Password1_'), null);
        expect(validatePasswordOrNull(false, 'Password1+'), null);
        expect(validatePasswordOrNull(false, 'Password1-'), null);
        expect(validatePasswordOrNull(false, 'Password1='), null);
        expect(validatePasswordOrNull(false, 'Password1['), null);
        expect(validatePasswordOrNull(false, 'Password1]'), null);
        expect(validatePasswordOrNull(false, 'Password1{'), null);
        expect(validatePasswordOrNull(false, 'Password1}'), null);
        expect(validatePasswordOrNull(false, 'Password1;'), null);
        expect(validatePasswordOrNull(false, 'Password1:'), null);
        expect(validatePasswordOrNull(false, 'Password1,'), null);
        expect(validatePasswordOrNull(false, 'Password1.'), null);
        expect(validatePasswordOrNull(false, 'Password1<'), null);
        expect(validatePasswordOrNull(false, 'Password1>'), null);
        expect(validatePasswordOrNull(false, 'Password1?'), null);
        expect(validatePasswordOrNull(false, 'Password1/'), null);
      });
    });
  });

  group('Touched Fields Validation Behavior', () {
    // These tests document the expected validation behavior for the touched fields pattern

    test('empty fields should return errors (validated on submit via touched fields)', () {
      // Password validation - empty should return emptyPasswordError
      expect(validatePasswordOrNull(false, ''), FormErrorTypes.emptyPasswordError);
      expect(validatePasswordOrNull(false, null), FormErrorTypes.emptyPasswordError);
    });

    test('non-empty fields with invalid content should return errors', () {
      // Invalid email format
      expect(isEmail('notanemail'), false);

      // Invalid password (too short, missing requirements)
      expect(validatePasswordOrNull(false, 'short'), FormErrorTypes.invalidPasswordError);
    });

    test('non-empty fields with valid content should return null (no error)', () {
      // Valid email
      expect(isEmail('valid@email.com'), true);

      // Valid password
      expect(validatePasswordOrNull(false, 'ValidPass1!'), null);
    });
  });

  group('Edge Cases', () {
    test('email with special characters in local part', () {
      expect(isEmail('user.name+tag@example.com'), false); // + not in pattern
      expect(isEmail('user_name@example.com'), true);
      expect(isEmail('user-name@example.com'), true);
      expect(isEmail('user.name@example.com'), true);
    });

    test('password exactly 8 characters with all requirements', () {
      expect(validatePasswordOrNull(false, 'Abcdef1!'), null);
    });

    test('password with only spaces should fail', () {
      expect(validatePasswordOrNull(false, '        '), FormErrorTypes.invalidPasswordError);
    });

    test('very long valid password should pass', () {
      expect(validatePasswordOrNull(false, 'ThisIsAVeryLongPassword123!WithAllRequirements'), null);
    });
  });
}
