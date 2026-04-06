abstract class AuthRepository {
  Future<void> login(String email, String password);

  Future<void> signup(String name, String email, String password);

  Future<void> logout();

  Stream<bool> get authStateChanges;

  Future<void> updatePassword(String password);

  Future<void> resetPasswordForEmail(String email);

  Future<void> signInWithGoogle();

}
