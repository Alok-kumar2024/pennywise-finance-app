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
  Future<void> signup(String email, String password) async {
    await _dataSource.signUpWithEmailPassword(email, password);
  }

  @override
  Future<void> logout() async {
    await _dataSource.signOut();
  }
}
