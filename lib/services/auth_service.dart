import '../models/user_model.dart';

class AuthService {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _currentUser = UserModel(
      id: 'agent-001',
      name: 'BGN Agent',
      email: email,
      role: UserRole.agent,
      phone: '+27 21 555 0148',
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  Future<void> signOut() async {
    _currentUser = null;
  }
}
