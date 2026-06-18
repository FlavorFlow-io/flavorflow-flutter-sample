import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter/widgets.dart' show AssetImage, ImageProvider;

import 'branding_model.dart';

/// A loaded branding artifact paired with a resolvable logo image.
///
/// Keeping the [ImageProvider] alongside the parsed [Branding] lets the
/// production app resolve the logo from the asset bundle while tests inject
/// an in-memory image — neither the widget tree nor the model needs to know
/// where the bytes come from.
@immutable
class BrandingBundle {
  const BrandingBundle({required this.branding, required this.logo});

  final Branding branding;
  final ImageProvider logo;
}

/// Loads `assets/branding/branding.json` (the artifact FlavorFlow injects at
/// build time) and turns it into a validated [BrandingBundle].
///
/// This is deliberately fail-fast: a missing file, malformed JSON, or a
/// contract violation throws rather than silently falling back to default
/// colors. [BrandingProviderScope] surfaces the failure as an error screen.
class BrandingLoader {
  const BrandingLoader._();

  /// Asset key of the injected branding manifest.
  static const String manifestAssetKey = 'assets/branding/branding.json';

  /// Loads and validates the branding artifact from [bundle]
  /// (defaults to the app's [rootBundle]).
  static Future<BrandingBundle> load({AssetBundle? bundle}) async {
    final assets = bundle ?? rootBundle;

    final String raw;
    try {
      raw = await assets.loadString(manifestAssetKey);
    } catch (_) {
      throw const BrandingFormatException(
        'Missing $manifestAssetKey. FlavorFlow must inject a branding.json '
        'into assets/branding/ before the app is built.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      throw BrandingFormatException('branding.json is not valid JSON: ${e.message}');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const BrandingFormatException('branding.json must be a JSON object.');
    }

    final branding = Branding.fromJson(decoded);
    return BrandingBundle(
      branding: branding,
      logo: AssetImage(branding.logoAssetKey, bundle: bundle),
    );
  }
}
