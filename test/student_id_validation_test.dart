import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Student ID Validation Tests', () {
    // The regex pattern from login_screen.dart
    final RegExp regExp = RegExp(r'^(\d{3}-\d{2}-\d+|\d{16})$');

    test(
      'should accept format: 3 digits - 2 digits - any number of digits',
      () {
        // Valid patterns with 3-2-any digits format
        expect(regExp.hasMatch('123-45-6789'), true);
        expect(regExp.hasMatch('123-45-67890'), true);
        expect(regExp.hasMatch('123-45-678901'), true);
        expect(regExp.hasMatch('123-45-6'), true);
        expect(regExp.hasMatch('123-45-67'), true);
        expect(regExp.hasMatch('123-45-678'), true);
        expect(regExp.hasMatch('123-45-6789012345'), true);
      },
    );

    test('should accept format: exactly 16 digits', () {
      // Valid 16-digit pattern
      expect(regExp.hasMatch('1234567890123456'), true);
    });

    test('should reject invalid formats', () {
      // Invalid patterns
      expect(
        regExp.hasMatch('12-45-6789'),
        false,
      ); // Only 2 digits in first part
      expect(
        regExp.hasMatch('123-4-6789'),
        false,
      ); // Only 1 digit in second part
      expect(regExp.hasMatch('123-456-6789'), false); // 3 digits in second part
      expect(regExp.hasMatch('123456789012345'), false); // Only 15 digits
      expect(regExp.hasMatch('12345678901234567'), false); // 17 digits
      expect(regExp.hasMatch('123-45-'), false); // Missing third part
      expect(regExp.hasMatch('123-45'), false); // Missing third part
      expect(
        regExp.hasMatch('abc-45-6789'),
        false,
      ); // Letters instead of numbers
      expect(
        regExp.hasMatch('123-de-6789'),
        false,
      ); // Letters instead of numbers
      expect(
        regExp.hasMatch('123-45-abcd'),
        false,
      ); // Letters instead of numbers
      expect(regExp.hasMatch(''), false); // Empty string
      expect(regExp.hasMatch('123456'), false); // Too short without dashes
    });
    test('should reject mixed formats', () {
      // Invalid mixed formats
      expect(
        regExp.hasMatch('123-456789012345'),
        false,
      ); // Missing dashes but not exactly 16 digits
      expect(
        regExp.hasMatch('12-45-6789'),
        false,
      ); // Only 2 digits in first part
      expect(
        regExp.hasMatch('123-4-6789'),
        false,
      ); // Only 1 digit in second part
      expect(regExp.hasMatch('123-456-6789'), false); // 3 digits in second part
    });
  });
}
