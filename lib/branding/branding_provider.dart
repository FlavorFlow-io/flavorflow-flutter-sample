import 'package:flutter/widgets.dart';

import 'branding_loader.dart';
import 'branding_model.dart';

/// Dependency injection for the active [BrandingBundle], implemented with a
/// plain [InheritedWidget] — no external state-management package.
///
/// Place a [BrandingProvider] above the widget tree and read it anywhere with
/// `BrandingProvider.of(context)`.
class BrandingProvider extends InheritedWidget {
  const BrandingProvider({
    super.key,
    required this.bundle,
    required super.child,
  });

  final BrandingBundle bundle;

  /// The parsed branding contract.
  Branding get branding => bundle.branding;

  /// The resolvable logo image (asset-backed in production, in-memory in tests).
  ImageProvider get logo => bundle.logo;

  static BrandingProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<BrandingProvider>();
    assert(provider != null, 'No BrandingProvider found in context.');
    return provider!;
  }

  @override
  bool updateShouldNotify(BrandingProvider oldWidget) =>
      oldWidget.bundle != bundle;
}
