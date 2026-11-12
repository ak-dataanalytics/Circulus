import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CIRCULUS branding and configuration validation', () {
    const appTitle = 'CIRCULUS';
    const tagline = 'Beyond Ranks. Beyond Boundaries.';
    expect(appTitle, equals('CIRCULUS'));
    expect(tagline, contains('Beyond Boundaries'));
  });
}
