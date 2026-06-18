import 'package:flutter/widgets.dart';

import 'app.dart';

/// Single, client-agnostic entry point.
///
/// There is exactly one `main`. There are no `main_<customer>.dart` variants
/// and no flavor switch — the running app discovers its identity entirely from
/// the `branding.json` FlavorFlow injects into `assets/branding/`.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlavorFlowApp());
}
