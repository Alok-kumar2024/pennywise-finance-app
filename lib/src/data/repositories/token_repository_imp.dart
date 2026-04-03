import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pennywise/src/domain/repositories/token_repository.dart';

class TokenRepositoryImp implements TokenRepository{
  final FlutterSecureStorage _storage;
  final String _key = 'plaid_access_token';

  TokenRepositoryImp(this._storage);

  @override
  Future<void> saveAccessToken(String token) async{
    await _storage.write(key: _key, value: token);
  }

  @override
  Future<String?> getAccessToken() async{
    return await _storage.read(key: _key);
  }

  @override
  Future<void> deleteAccessToken() async{

    await _storage.delete(key: _key);
  }

}