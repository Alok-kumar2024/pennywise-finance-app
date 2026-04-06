import 'package:pennywise/src/data/datasources/supabase_auth_data_source.dart';
import 'package:pennywise/src/domain/repositories/auth_repository.dart';

class AuthRepositoryImp implements AuthRepository {
  final SupabaseAuthDataSource _dataSource;

  AuthRepositoryImp(this._dataSource);

  @override
  // TODO: implement authStateChanges
  Stream<bool> get authStateChanges => _dataSource.authStateChanges;

  @override
  Future<void> login(String email, String password) async {
    await _dataSource.signInWithEmailPassword(email, password);
  }

  @override
  Future<void> signup(String name, String email, String password) async {
    await _dataSource.signUpWithEmailPassword(name, email, password);
  }

  @override
  Future<void> logout() async {
    await _dataSource.signOut();
  }

  @override
  Future<void> updatePassword(String password) async {
    await _dataSource.updatePassword(password);
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    await _dataSource.resetPasswordForEmail(email);
  }

  @override
  Future<void> signInWithGoogle() async {
    await _dataSource.signInWithGoogle();
  }

}
