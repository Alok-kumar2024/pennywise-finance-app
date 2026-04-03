abstract class TokenRepository {
  Future<void> saveAccessToken(String token);

  Future<String?> getAccessToken();

  Future<void> deleteAccessToken();
}
