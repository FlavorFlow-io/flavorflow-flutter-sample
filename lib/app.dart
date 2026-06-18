import 'package:flutter/material.dart';

import 'branding/branding_loader.dart';
import 'branding/branding_model.dart';
import 'branding/branding_provider.dart';
import 'features/home/home_page.dart';
import 'theme/app_theme.dart';

/// Root widget.
///
/// Loads the injected branding artifact once, then renders the themed app.
/// While loading it shows a neutral splash; if the contract is missing or
/// malformed it shows a descriptive error screen — never default colors.
///
/// A pre-loaded [BrandingBundle] can be supplied (used by tests / goldens);
/// when omitted it is loaded from the asset bundle via [BrandingLoader].
class FlavorFlowApp extends StatefulWidget {
  const FlavorFlowApp({super.key, this.preloaded});

  final BrandingBundle? preloaded;

  @override
  State<FlavorFlowApp> createState() => _FlavorFlowAppState();
}

class _FlavorFlowAppState extends State<FlavorFlowApp> {
  late final Future<BrandingBundle> _bundle =
      widget.preloaded != null ? Future.value(widget.preloaded) : BrandingLoader.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BrandingBundle>(
      future: _bundle,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _BrandingErrorApp(error: snapshot.error!);
        }
        if (!snapshot.hasData) {
          return const _SplashApp();
        }
        return BrandedApp(bundle: snapshot.data!);
      },
    );
  }
}

/// The themed application, built entirely from a resolved [BrandingBundle].
class BrandedApp extends StatelessWidget {
  const BrandedApp({super.key, required this.bundle});

  final BrandingBundle bundle;

  @override
  Widget build(BuildContext context) {
    return BrandingProvider(
      bundle: bundle,
      child: MaterialApp(
        title: bundle.branding.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.fromBranding(bundle.branding),
        home: const HomePage(),
      ),
    );
  }
}

class _SplashApp extends StatelessWidget {
  const _SplashApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

/// Fail-fast error surface shown when branding cannot be loaded or validated.
class _BrandingErrorApp extends StatelessWidget {
  const _BrandingErrorApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final message =
        error is BrandingFormatException ? (error as BrandingFormatException).message : '$error';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: const ColorScheme.dark()),
      home: Scaffold(
        backgroundColor: const Color(0xFF2B0B0B),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFFFB4AB), size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'Branding could not be loaded',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFFFDAD6)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
