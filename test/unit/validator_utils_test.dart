import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/validator_utils.dart';

void main() {
  // ── isEmail ─────────────────────────────────────────────────────────

  group('Email Validation (isEmail)', () {
    test('valid email passes', () {
      expect(isEmail('user@example.com'), true);
    });

    test('email with subdomain passes', () {
      expect(isEmail('user@mail.example.com'), true);
    });

    test('email with dots and hyphens passes', () {
      expect(isEmail('first.last@my-domain.org'), true);
    });

    test('invalid email without @ fails', () {
      expect(isEmail('userexample.com'), false);
    });

    test('invalid email without domain fails', () {
      expect(isEmail('user@'), false);
    });

    test('invalid email without TLD fails', () {
      expect(isEmail('user@example'), false);
    });

    test('null email fails', () {
      expect(isEmail(null), false);
    });

    test('empty string email fails', () {
      expect(isEmail(''), false);
    });
  });

  // ── validatePasswordOrNull ──────────────────────────────────────────

  group('Password Validation - Login Mode (validatePasswordOrNull)', () {
    test('empty password passes in login mode (no validation)', () {
      expect(
        validatePasswordOrNull(true, ''),
        null,
      );
    });

    test('null password passes in login mode (no validation)', () {
      expect(
        validatePasswordOrNull(true, null),
        null,
      );
    });

    test('any non-empty password passes in login mode', () {
      expect(validatePasswordOrNull(true, 'simple'), null);
    });

    test('weak password passes in login mode (no complexity check)', () {
      expect(validatePasswordOrNull(true, '123'), null);
    });
  });

  group('Password Validation - Signup Mode (validatePasswordOrNull)', () {
    test('short password (<8 chars) returns invalidPasswordError', () {
      expect(
        validatePasswordOrNull(false, 'Ab1!'),
        FormErrorTypes.invalidPasswordError,
      );
    });

    test('password without uppercase returns invalidPasswordError', () {
      expect(
        validatePasswordOrNull(false, 'abcdefg1!'),
        FormErrorTypes.invalidPasswordError,
      );
    });

    test('password without lowercase returns invalidPasswordError', () {
      expect(
        validatePasswordOrNull(false, 'ABCDEFG1!'),
        FormErrorTypes.invalidPasswordError,
      );
    });

    test('password without digit returns invalidPasswordError', () {
      expect(
        validatePasswordOrNull(false, 'Abcdefgh!'),
        FormErrorTypes.invalidPasswordError,
      );
    });

    test('password without special char returns invalidPasswordError', () {
      expect(
        validatePasswordOrNull(false, 'Abcdefg1'),
        FormErrorTypes.invalidPasswordError,
      );
    });

    test('valid complex password passes', () {
      expect(validatePasswordOrNull(false, 'Abcdefg1!'), null);
    });

    test('null password in signup returns emptyPasswordError', () {
      expect(
        validatePasswordOrNull(false, null),
        FormErrorTypes.emptyPasswordError,
      );
    });
  });
}
