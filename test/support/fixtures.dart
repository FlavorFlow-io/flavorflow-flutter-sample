import 'dart:io';

/// A discovered contract fixture: one `branding.json` + its `logo.png`,
/// living under `test/fixtures/<name>/`.
class Fixture {
  const Fixture(this.name, this.dir);

  final String name;
  final String dir;

  String get brandingJsonPath => '$dir/branding.json';
  String get logoPath => '$dir/logo.png';
}

/// Enumerates every fixture under `test/fixtures/`, sorted by name so the
/// matrix order is stable. Tests are run from the package root, so the path
/// is relative to that.
///
/// When the `FF_ONLY_FIXTURE` environment variable is set, only that fixture
/// is returned — the CI matrix uses this so each job validates exactly one
/// brand and uploads only its own diff.
List<Fixture> discoverFixtures() {
  final only = Platform.environment['FF_ONLY_FIXTURE'];
  final root = Directory('test/fixtures');
  final fixtures = root
      .listSync()
      .whereType<Directory>()
      .where((d) => File('${d.path}/branding.json').existsSync())
      .map((d) => Fixture(d.path.split(Platform.pathSeparator).last, d.path))
      .where((f) => only == null || only.isEmpty || f.name == only)
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  return fixtures;
}
