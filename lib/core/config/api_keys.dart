/// Build-time API keys, injected via `--dart-define` (or
/// `--dart-define-from-file=.env.json`).
///
/// Never hardcode keys here or in version control. The `.env.json` file is
/// gitignored and expected to live next to pubspec.yaml.
class ApiKeys {
  /// Stadia Maps tile API key. Empty string if not provided at build time;
  /// callers should fall back to a free tile source when missing.
  static const String stadiaMaps = String.fromEnvironment(
    'STADIA_API_KEY',
    defaultValue: '',
  );

  static bool get hasStadia => stadiaMaps.isNotEmpty;
}
