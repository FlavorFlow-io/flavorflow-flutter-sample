import 'package:flutter/material.dart';

import '../../branding/branding_provider.dart';

/// The single, client-agnostic home screen.
///
/// Every brand-specific value (logo, name, tagline, colors) is read from the
/// injected [BrandingProvider]; there is nothing client-specific in this file.
/// Swapping `branding.json` is the only thing that changes what this renders.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = BrandingProvider.of(context);
    final branding = provider.branding;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(branding.appName)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image(
                  image: provider.logo,
                  width: 96,
                  height: 96,
                  // Deterministic in tests: no fade-in animation frame to race.
                  gaplessPlayback: true,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                branding.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                branding.tagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 28),
              _PaletteCard(),
              const SizedBox(height: 20),
              FilledButton(onPressed: () {}, child: const Text('Primary action')),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () {}, child: const Text('Secondary action')),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  Chip(label: Text('Material 3')),
                  Chip(label: Text('Client-agnostic')),
                  Chip(label: Text('FlavorFlow')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A card of labelled color swatches so goldens capture the applied palette.
class _PaletteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final swatches = <(String, Color, Color)>[
      ('Primary', scheme.primary, scheme.onPrimary),
      ('Secondary', scheme.secondary, scheme.onSecondary),
      ('Tertiary', scheme.tertiary, scheme.onTertiary),
      ('Error', scheme.error, scheme.onError),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (label, bg, fg) in swatches) ...[
              Container(
                height: 44,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                color: bg,
                child: Text(label, style: TextStyle(color: fg)),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
