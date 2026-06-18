import 'dart:convert';
import 'dart:io';

import 'package:flavorflow_flutter_sample/branding/branding_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

/// Contract tests: every `branding.json` the FlavorFlow backend can produce
/// must parse into a valid [Branding]. If the backend ships a breaking schema
/// change, these tests fail first — before any visual regression.
void main() {
  group('Branding contract — fixtures parse', () {
    for (final fixture in discoverFixtures()) {
      test('"${fixture.name}" parses and validates', () {
        final json = jsonDecode(File(fixture.brandingJsonPath).readAsStringSync())
            as Map<String, dynamic>;
        final branding = Branding.fromJson(json);

        expect(branding.schemaVersion, lessThanOrEqualTo(kSupportedBrandingSchemaVersion));
        expect(branding.appName, isNotEmpty);
        expect(branding.packageId, isNotEmpty);
        expect(branding.logoFileName, isNotEmpty);
        expect(branding.tagline, isNotEmpty);
        expect(branding.colors.seed, isA<Color>());
        expect(File(fixture.logoPath).existsSync(), isTrue,
            reason: 'fixture "${fixture.name}" must ship its logo asset');
      });
    }
  });

  group('Branding contract — fail fast', () {
    Map<String, dynamic> validBase() => {
          'schemaVersion': 1,
          'appName': 'X',
          'packageId': 'io.x',
          'logo': 'logo.png',
          'colors': {'brightness': 'light', 'seed': '#112233'},
        };

    test('rejects a future schema version', () {
      final json = validBase()..['schemaVersion'] = kSupportedBrandingSchemaVersion + 1;
      expect(() => Branding.fromJson(json), throwsA(isA<BrandingFormatException>()));
    });

    test('rejects a missing seed color', () {
      final json = validBase();
      (json['colors'] as Map).remove('seed');
      expect(() => Branding.fromJson(json), throwsA(isA<BrandingFormatException>()));
    });

    test('rejects a malformed hex color', () {
      final json = validBase();
      (json['colors'] as Map)['seed'] = 'not-a-color';
      expect(() => Branding.fromJson(json), throwsA(isA<BrandingFormatException>()));
    });

    test('rejects an invalid brightness', () {
      final json = validBase();
      (json['colors'] as Map)['brightness'] = 'twilight';
      expect(() => Branding.fromJson(json), throwsA(isA<BrandingFormatException>()));
    });

    test('rejects an empty appName', () {
      final json = validBase()..['appName'] = '   ';
      expect(() => Branding.fromJson(json), throwsA(isA<BrandingFormatException>()));
    });

    test('accepts #RRGGBB and #AARRGGBB', () {
      final six = validBase();
      (six['colors'] as Map)['seed'] = '#FF8800';
      expect(Branding.fromJson(six).colors.seed.toARGB32(), 0xFFFF8800);

      final eight = validBase();
      (eight['colors'] as Map)['seed'] = '#80FF8800';
      expect(Branding.fromJson(eight).colors.seed.toARGB32(), 0x80FF8800);
    });
  });
}
