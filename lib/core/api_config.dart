import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb, defaultTargetPlatform, TargetPlatform;

/// The real, deployed Api - what every non-debug build (this app's actual Play Store release)
/// talks to. The Api is deployed as an IIS sub-application mounted at "/m-api" under the member
/// portal's own site (m.niqabatalashraaf.com) - see AshrafBack.Members.Api.csproj's hosting-model
/// comment and scripts/deploy-api.ps1's RemotePath. NO trailing "/api" here - every service call
/// (AuthService, DuesService, etc.) already prefixes its own path with "/api/..."; a previous fix
/// added "/api" here too, which combined with those calls into a doubled "/m-api/api/api/..."
/// (404) - confirmed live on 2026-09-14 by testing the exact doubled URL. Do not add "/api" back.
const _productionApiBaseUrl = 'https://m.niqabatalashraaf.com/m-api';

/// The Api project's base URL. Real builds (anything not run via plain `flutter run` in debug
/// mode - that includes `--release` and `--profile`, and definitely the Play Store build) always
/// point at the real deployed Api. Only a plain local debug run falls back to this dev machine's
/// locally-running Api, for convenient same-machine testing.
String defaultApiBaseUrl() {
  if (!kDebugMode) {
    return _productionApiBaseUrl;
  }
  if (kIsWeb) {
    return 'http://localhost:5470';
  }
  // Android emulators reach the host machine's localhost via the special 10.0.2.2 alias -
  // localhost from inside the emulator means the emulator itself.
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:5470';
  }
  return 'http://localhost:5470';
}
