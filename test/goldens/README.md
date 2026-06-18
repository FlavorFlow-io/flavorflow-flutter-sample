# Golden images

`images/<fixture>.png` is the committed reference render for each branding
fixture. The golden test (`branding_golden_test.dart`) renders the app with
that fixture's `branding.json` + `logo.png` and compares pixel-for-pixel.

Goldens are deterministic across machines because `flutter_test` renders text
with its built-in test font (no system fonts), so generate and verify them on
the same platform CI uses (Linux / `ubuntu-latest`).

- **Record / refresh:** `flutter test --update-goldens`
- **Verify:** `flutter test`

The `build-white-label.yml` workflow records goldens automatically the first
time a fixture has no committed image (and uploads them as artifacts); commit
those PNGs to lock the visual contract.

`failures/` (gitignored) holds the diff/expected/actual images written when a
verification fails.
