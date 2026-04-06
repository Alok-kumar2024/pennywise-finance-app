abstract class TokenRepository {
  Future<void> saveAccessToken(String token);

  Future<String?> getAccessToken();

  Future<void> deleteAccessToken();

  Future<void> setPlaidSkipped();

  Future<bool> hasSkippedPlaid();
}


