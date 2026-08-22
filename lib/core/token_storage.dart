import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstraction over where the JWT lives, so tests can swap in an in-memory fake instead of the
/// real FlutterSecureStorage - which talks to a platform channel that only responds on a real
/// device/browser/emulator, not in a plain `flutter test` Dart VM run.
abstract class TokenStorage {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  static const _key = 'access_token';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
