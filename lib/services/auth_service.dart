import '../core/config/supabase_config.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _AgentAccount {
  const _AgentAccount({required this.user, required this.password});

  final UserModel user;
  final String password;
}

class AuthService {
  UserModel? _currentUser;
  final Map<String, _AgentAccount> _agentsByEmail = {};

  UserModel? get currentUser => _currentUser;

  Future<UserModel> registerAgent({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (SupabaseConfig.isConfigured) {
      return _registerAgentWithSupabase(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
    }

    return _registerAgentInMemory(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (SupabaseConfig.isConfigured) {
      return _signInWithSupabase(email: email, password: password);
    }

    return _signInInMemory(email: email, password: password);
  }

  Future<void> signOut() async {
    if (SupabaseConfig.isConfigured) {
      await SupabaseConfig.client?.auth.signOut();
    }
    _currentUser = null;
  }

  Future<UserModel> _registerAgentWithSupabase({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }

    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Supabase is not configured.');
    }

    final normalizedEmail = email.trim().toLowerCase();
    try {
      final response = await client.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {
          'full_name': name.trim(),
          'phone': phone.trim(),
          'agency_name': 'BGN Real Estate',
        },
      );
      final user = response.user;
      if (user == null) {
        throw const AuthException('Could not create the agent account.');
      }

      await client.auth.signOut();
      return UserModel(
        id: user.id,
        name: name.trim(),
        email: normalizedEmail,
        role: UserRole.agent,
        phone: phone.trim(),
        createdAt: DateTime.now(),
      );
    } catch (error) {
      throw AuthException(_friendlyAuthError(error));
    }
  }

  Future<UserModel> _signInWithSupabase({
    required String email,
    required String password,
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Supabase is not configured.');
    }

    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthException('Could not sign in.');
      }

      _currentUser = await _loadCurrentUserFromSupabase(user.id);
      return _currentUser!;
    } catch (error) {
      throw AuthException(_friendlyAuthError(error));
    }
  }

  Future<UserModel> _loadCurrentUserFromSupabase(String userId) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Supabase is not configured.');
    }

    final row = await client
        .from('profiles')
        .select('id, full_name, email, phone, role, created_at')
        .eq('id', userId)
        .maybeSingle();

    if (row == null) {
      throw const AuthException(
        'Agent profile was not found. Run the signup trigger migration.',
      );
    }

    return UserModel(
      id: row['id'] as String,
      name: row['full_name'] as String? ?? 'Agent',
      email: row['email'] as String? ?? '',
      role: _roleFromSupabase(row['role'] as String?),
      phone: row['phone'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Future<UserModel> _registerAgentInMemory({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_agentsByEmail.containsKey(normalizedEmail)) {
      throw const AuthException(
        'An agent is already registered with this email.',
      );
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }

    final user = UserModel(
      id: 'agent-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      role: UserRole.agent,
      phone: phone.trim(),
      createdAt: DateTime.now(),
    );
    _agentsByEmail[normalizedEmail] = _AgentAccount(
      user: user,
      password: password,
    );
    return user;
  }

  Future<UserModel> _signInInMemory({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final account = _agentsByEmail[normalizedEmail];
    if (account == null) {
      throw const AuthException('Register as an agent before signing in.');
    }
    if (account.password != password) {
      throw const AuthException('Incorrect password.');
    }

    _currentUser = account.user;
    return _currentUser!;
  }

  UserRole _roleFromSupabase(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'viewer':
        return UserRole.viewer;
      case 'agent':
      default:
        return UserRole.agent;
    }
  }

  String _friendlyAuthError(Object error) {
    final message = error.toString().replaceFirst('AuthException: ', '');
    if (message.trim().isEmpty) {
      return 'Authentication failed.';
    }
    return message;
  }
}
