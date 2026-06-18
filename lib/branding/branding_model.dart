/// The FlavorFlow branding contract.
///
/// A [Branding] is the parsed, validated representation of the
/// `branding.json` artifact that FlavorFlow injects into
/// `assets/branding/` at build time. The Flutter application treats this
/// object as the single source of truth for everything client-specific —
/// it contains **no** hardcoded client data and **no** flavor registry.
///
/// This file is the canonical schema. The contract tests in
/// `test/contract/` validate that every fixture produced by the FlavorFlow
/// backend parses into a valid [Branding]; if the backend ships a breaking
/// change, those tests fail before the visual goldens do.
library;

import 'dart:ui' show Color;

/// The schema version this client understands.
///
/// [BrandingLoader] rejects any `branding.json` whose `schemaVersion` is
/// greater than this value, so a forward-incompatible backend change fails
/// fast with a descriptive error instead of rendering wrong colors.
const int kSupportedBrandingSchemaVersion = 1;

/// Raised when a `branding.json` payload cannot be turned into a valid
/// [Branding]. The message is intentionally descriptive so the fail-fast
/// error screen (and CI logs) point straight at the offending field.
class BrandingFormatException implements Exception {
  const BrandingFormatException(this.message);

  final String message;

  @override
  String toString() => 'BrandingFormatException: $message';
}

/// The two brightness modes a brand may request.
enum BrandBrightness {
  light,
  dark;

  static BrandBrightness parse(String? raw) {
    switch (raw) {
      case 'light':
        return BrandBrightness.light;
      case 'dark':
        return BrandBrightness.dark;
      default:
        throw BrandingFormatException(
          'colors.brightness must be "light" or "dark", got: ${raw ?? '<missing>'}',
        );
    }
  }
}

/// The color portion of the contract.
///
/// [seed] is mandatory and drives Material 3's `ColorScheme.fromSeed`. The
/// remaining roles are optional, tonally-correct overrides — when present
/// they replace the generated value for that single role only.
class BrandColors {
  const BrandColors({
    required this.seed,
    required this.brightness,
    this.primary,
    this.secondary,
    this.tertiary,
    this.error,
  });

  final Color seed;
  final BrandBrightness brightness;
  final Color? primary;
  final Color? secondary;
  final Color? tertiary;
  final Color? error;

  factory BrandColors.fromJson(Map<String, dynamic> json) {
    return BrandColors(
      seed: _parseColor(json, 'seed', required: true)!,
      brightness: BrandBrightness.parse(json['brightness'] as String?),
      primary: _parseColor(json, 'primary'),
      secondary: _parseColor(json, 'secondary'),
      tertiary: _parseColor(json, 'tertiary'),
      error: _parseColor(json, 'error'),
    );
  }
}

/// The fully-parsed branding artifact.
class Branding {
  const Branding({
    required this.schemaVersion,
    required this.appName,
    required this.packageId,
    required this.logoFileName,
    required this.colors,
    required this.tagline,
  });

  /// Version of the contract this payload was written against.
  final int schemaVersion;

  /// Human-facing application name, shown in-app. (The native launcher name
  /// is patched separately — see the README's "Native Platform Changes".)
  final String appName;

  /// The application id / bundle identifier this build targets. Informational
  /// inside the app; FlavorFlow patches the real native values.
  final String packageId;

  /// File name of the logo, relative to `assets/branding/`.
  final String logoFileName;

  /// Color + brightness contract used to build the [ThemeData].
  final BrandColors colors;

  /// Short subtitle rendered under the app name on the home screen.
  final String tagline;

  /// The asset key the running app uses to load the logo.
  String get logoAssetKey => 'assets/branding/$logoFileName';

  /// Parses and validates a decoded `branding.json` map. Throws
  /// [BrandingFormatException] with a precise message on any violation.
  factory Branding.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion is! int) {
      throw const BrandingFormatException(
        'schemaVersion is required and must be an integer.',
      );
    }
    if (schemaVersion > kSupportedBrandingSchemaVersion) {
      throw BrandingFormatException(
        'branding.json schemaVersion $schemaVersion is newer than this app '
        'supports (max $kSupportedBrandingSchemaVersion). Update the app.',
      );
    }

    final colorsRaw = json['colors'];
    if (colorsRaw is! Map<String, dynamic>) {
      throw const BrandingFormatException(
        'colors is required and must be an object.',
      );
    }

    return Branding(
      schemaVersion: schemaVersion,
      appName: _requireNonEmptyString(json, 'appName'),
      packageId: _requireNonEmptyString(json, 'packageId'),
      logoFileName: _requireNonEmptyString(json, 'logo'),
      colors: BrandColors.fromJson(colorsRaw),
      tagline: (json['tagline'] as String?)?.trim().isNotEmpty == true
          ? (json['tagline'] as String).trim()
          : 'Powered by FlavorFlow',
    );
  }
}

String _requireNonEmptyString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw BrandingFormatException('$key is required and must be a non-empty string.');
  }
  return value.trim();
}

/// Parses a `#RRGGBB` or `#AARRGGBB` hex string into a [Color].
Color? _parseColor(Map<String, dynamic> json, String key, {bool required = false}) {
  final raw = json[key];
  if (raw == null) {
    if (required) {
      throw BrandingFormatException('colors.$key is required.');
    }
    return null;
  }
  if (raw is! String) {
    throw BrandingFormatException('colors.$key must be a hex string, got: $raw');
  }
  var hex = raw.trim().replaceFirst('#', '').toUpperCase();
  if (hex.length == 6) {
    hex = 'FF$hex'; // assume opaque
  }
  if (hex.length != 8 || int.tryParse(hex, radix: 16) == null) {
    throw BrandingFormatException(
      'colors.$key must be "#RRGGBB" or "#AARRGGBB", got: $raw',
    );
  }
  return Color(int.parse(hex, radix: 16));
}
