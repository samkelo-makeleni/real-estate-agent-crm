import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../viewmodels/app_state_provider.dart';
import '../../widgets/bgn_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isRegistering = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isRegistering && _password.text != _confirmPassword.text) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final appState = AppStateProvider.of(context);
      if (_isRegistering) {
        await appState.registerAgent(
          name: _name.text,
          email: _email.text,
          phone: _phone.text,
          password: _password.text,
        );
        if (!mounted) return;
        setState(() => _isRegistering = false);
        _showMessage('Agent account created. Sign in to continue.');
      } else {
        await appState.login(_email.text, _password.text);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: BgnLogo()),
                    const SizedBox(height: 20),
                    Text(
                      'Real Estate agent app',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.person_add_alt_1),
                          label: Text('Register'),
                        ),
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.login),
                          label: Text('Sign in'),
                        ),
                      ],
                      selected: {_isRegistering},
                      onSelectionChanged: _isSubmitting
                          ? null
                          : (selection) {
                              setState(() {
                                _isRegistering = selection.first;
                              });
                            },
                    ),
                    const SizedBox(height: 20),
                    if (_isRegistering) ...[
                      CustomTextField(
                        controller: _name,
                        label: 'Full name',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 14),
                    ],
                    CustomTextField(
                      controller: _email,
                      label: 'Email',
                      icon: Icons.mail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    if (_isRegistering) ...[
                      CustomTextField(
                        controller: _phone,
                        label: 'Phone / WhatsApp',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                    ],
                    CustomTextField(
                      controller: _password,
                      label: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    if (_isRegistering) ...[
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _confirmPassword,
                        label: 'Confirm password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                    ],
                    const SizedBox(height: 22),
                    CustomButton(
                      label: _isRegistering
                          ? 'Create agent account'
                          : 'Agent sign in',
                      icon: _isRegistering
                          ? Icons.person_add_alt_1
                          : Icons.login,
                      onPressed: _isSubmitting ? null : _submit,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.buyerDashboard);
                      },
                      icon: const Icon(Icons.home_work),
                      label: const Text('Browse properties as buyer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
