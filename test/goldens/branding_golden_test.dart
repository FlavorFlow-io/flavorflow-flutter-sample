import 'dart:convert';
import 'dart:io';

import 'package:flavorflow_flutter_sample/app.dart';
import 'package:flavorflow_flutter_sample/branding/branding_loader.dart';
import 'package:flavorflow_flutter_sample/branding/branding_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

/// Golden tests: for every fixture, render the (single, client-agnostic) app
/// with that brand's `branding.json` + logo and compare against a committed
/// golden. A FlavorFlow change that shifts the applied palette, the logo, or
/// the layout shows up here as a pixel diff.
///
/// The logo is loaded from the fixture bytes into a [MemoryImage] so the test
/// never depends on asset-bundle registration — exactly the brand the test
/// names is the brand that renders.
void main() {
  for (final fixture in discoverFixtures()) {
    testWidgets('renders "${fixture.name}" per the branding contract',
        (tester) async {
      // Deterministic surface size across machines.
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final branding = Branding.fromJson(
        jsonDecode(File(fixture.brandingJsonPath).readAsStringSync())
            as Map<String, dynamic>,
      );
      final logoBytes = File(fixture.logoPath).readAsBytesSync();
      final bundle = BrandingBundle(
        branding: branding,
        logo: MemoryImage(logoBytes),
      );

      await tester.pumpWidget(BrandedApp(bundle: bundle));

      // Decode the logo before snapshotting so it isn't a blank frame.
      await tester.runAsync(() async {
        await precacheImage(bundle.logo, tester.element(find.byType(BrandedApp)));
      });
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(BrandedApp),
        matchesGoldenFile('images/${fixture.name}.png'),
      );
    });
  }
}
