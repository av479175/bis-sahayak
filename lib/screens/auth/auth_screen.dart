import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/api_exception.dart';
import '../../providers/auth_provider.dart';

enum _AuthMode { login, register, verifyOtp }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  _AuthMode _mode = _AuthMode.login;
  bool _isSubmitting = false; // only used for register/verify — login has its own AsyncLoading

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authControllerProvider.notifier);

    switch (_mode) {
      case _AuthMode.login:
        await notifier.login(email: _emailController.text.trim(), password: _passwordController.text);
        return; // state/error handled via ref.listen below

      case _AuthMode.register:
        setState(() => _isSubmitting = true);
        try {
          await notifier.register(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          _showMessage('Registered! Check your email for the OTP.');
          setState(() => _mode = _AuthMode.verifyOtp);
        } catch (e) {
          _showMessage(e is ApiException ? e.message : 'Registration failed. Please try again.');
        } finally {
          if (mounted) setState(() => _isSubmitting = false);
        }
        return;

      case _AuthMode.verifyOtp:
        setState(() => _isSubmitting = true);
        try {
          await notifier.verifyEmail(email: _emailController.text.trim(), otp: _otpController.text.trim());
          _showMessage('Email verified — please log in.');
          _otpController.clear();
          setState(() => _mode = _AuthMode.login);
        } catch (e) {
          _showMessage(e is ApiException ? e.message : 'Verification failed. Please try again.');
        } finally {
          if (mounted) setState(() => _isSubmitting = false);
        }
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoginLoading = _mode == _AuthMode.login && authState.isLoading;
    final isBusy = isLoginLoading || _isSubmitting;

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (err, st) => _showMessage(err is ApiException ? err.message : 'Something went wrong.'),
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.verified_outlined, size: 64),
                const SizedBox(height: 12),
                Text('BIS Sahayak', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                Text(_subtitleFor(_mode), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 28),
                ..._fieldsFor(_mode),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isBusy ? null : _submit,
                  child: isBusy
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_buttonLabelFor(_mode)),
                ),
                const SizedBox(height: 12),
                if (_mode != _AuthMode.verifyOtp)
                  TextButton(
                    onPressed: isBusy
                        ? null
                        : () => setState(() => _mode = _mode == _AuthMode.login ? _AuthMode.register : _AuthMode.login),
                    child: Text(_mode == _AuthMode.login
                        ? 'New here? Create an account'
                        : 'Already have an account? Log in'),
                  ),
                if (_mode == _AuthMode.verifyOtp)
                  TextButton(
                    onPressed: isBusy ? null : () => setState(() => _mode = _AuthMode.login),
                    child: const Text('Back to log in'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleFor(_AuthMode mode) => switch (mode) {
        _AuthMode.login => 'Your AI guide to Indian Standards',
        _AuthMode.register => 'Create your account',
        _AuthMode.verifyOtp => 'Enter the OTP sent to your email',
      };

  String _buttonLabelFor(_AuthMode mode) => switch (mode) {
        _AuthMode.login => 'Log in',
        _AuthMode.register => 'Create account',
        _AuthMode.verifyOtp => 'Verify email',
      };

  List<Widget> _fieldsFor(_AuthMode mode) {
    switch (mode) {
      case _AuthMode.login:
        return [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
          ),
        ];
      case _AuthMode.register:
        return [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a username' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
          ),
        ];
      case _AuthMode.verifyOtp:
        return [
          TextFormField(
            controller: _emailController,
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'OTP'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter the OTP' : null,
          ),
        ];
    }
  }
}
