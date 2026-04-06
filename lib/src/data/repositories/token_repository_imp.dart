import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pennywise/src/domain/repositories/token_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TokenRepositoryImp implements TokenRepository {
  final FlutterSecureStorage _storage;
  final SupabaseClient _supabase;
  final String _key = 'plaid_access_token';
  final String _skipKey = 'plaid_skipped';

  TokenRepositoryImp(this._storage, this._supabase);

  @override
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _key, value: token);

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _supabase.from('user_tokens').upsert({
        'user_id': userId,
        'token_value': token,
      });
    }
  }

  @override
  Future<String?> getAccessToken() async {
    String? localToken = await _storage.read(key: _key);
    if (localToken != null) return localToken;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('user_tokens')
          .select('token_value')
          .eq('user_id', userId)
          .maybeSingle();
      if (response != null) {
        String remoteToken = response['token_value'];
        // Restore it locally so tomorrow it loads instantly
        await _storage.write(key: _key, value: remoteToken);
        return remoteToken;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _key);

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _supabase.from('user_tokens').delete().eq('user_id', userId);
    }
  }

  @override
  Future<void> setPlaidSkipped() async {
    await _storage.write(key: _skipKey, value: "true");
  }

  @override
  Future<bool> hasSkippedPlaid() async {
    final value = await _storage.read(key: _skipKey);
    return value == "true";
  }
}
