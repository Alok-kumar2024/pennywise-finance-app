abstract class AuthRepository {

  Future<void> login(String email, String password);

  Future<void> signup(String email, String password);

  Future<void> logout();

  Stream<bool> get authStateChanges;
}
