import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb, defaultTargetPlatform, TargetPlatform;

/// The real, deployed Api - what every non-debug build (this app's actual Play Store release)
/// talks to. The Api is deployed as an IIS sub-application mounted at "/m-api" under the member
/// portal's own site (m.niqabatalashraaf.com) - see AshrafBack.Members.Api.csproj's hosting-model
/// comment and scripts/deploy-api.ps1's RemotePath. Previously this pointed at
/// "https://m.niqabatalashraaf.com/api" (missing the "/m-api" mount point), which meant every
/// real request from the shipped app 404'd - fixed here to match the actual IIS layout.
const _productionApiBaseUrl = 'https://m.niqabatalashraaf.com/m-api/api';

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
