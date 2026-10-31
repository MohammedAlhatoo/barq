import 'package:barq_customer/features/auth/data/phone_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('both local forms become the same server number', () {
    expect(PhoneNumber.normalize('0599123456'), '+970599123456');
    expect(PhoneNumber.normalize('599123456'), '+970599123456');
  });

  test('accepts 9 digits and rejects shorter or non-digit input', () {
    expect(PhoneNumber.isValid('599123456'), isTrue);
    expect(PhoneNumber.isValid('59912345'), isFalse);
    expect(PhoneNumber.isValid('05991234a6'), isFalse);
    expect(PhoneNumber.isValid(''), isFalse);
  });

  test('never builds a number the server refuses', () {
    expect(PhoneNumber.isValid('1234567890123'), isFalse);
    expect(PhoneNumber.isValid('0123456789012'), isTrue);
  });

  test('shows the number the way the design does', () {
    expect(PhoneNumber.display('+970599123456'), '059 912 3456');
    expect(PhoneNumber.display('+97059912'), '+97059912');
  });
}
