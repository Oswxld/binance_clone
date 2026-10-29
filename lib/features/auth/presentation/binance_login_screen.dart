import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/binance_palette.dart';

/// Email/password Supabase Auth, including first-time account registration.
class BinanceLoginScreen extends StatefulWidget {
  const BinanceLoginScreen({super.key});

  @override
  State<BinanceLoginScreen> createState() => _BinanceLoginScreenState();
}

class _BinanceLoginScreenState extends State<BinanceLoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate() || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
      _info = null;
    });
    try {
      final auth = Supabase.instance.client.auth;
      final email = _email.text.trim();
      final password = _password.text;
      if (_register) {
        final result = await auth.signUp(email: email, password: password);
        if (result.session == null && mounted) {
          setState(() {
            _info = 'Check your email to confirm your account, then sign in.';
          });
        }
      } else {
        await auth.signInWithPassword(email: email, password: password);
      }
      // BinanceAuthGate listens to onAuthStateChange and opens Home.
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not connect. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const foreground = BinancePalette.textPrimary;
    return Scaffold(
      backgroundColor: BinancePalette.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: BinancePalette.yellow,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.currency_bitcoin_rounded,
                        size: 31,
                        color: BinancePalette.canvas,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      _register ? 'Create an account' : 'Welcome back',
                      style: const TextStyle(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in with your Supabase account to view your wallet.',
                      style: TextStyle(
                        fontSize: 13,
                        color: BinancePalette.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('Email', style: TextStyle(color: foreground)),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const Key('binance-auth-email'),
                      controller: _email,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: _decoration('Email address'),
                      validator: (v) => v == null || !v.contains('@')
                          ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 18),
                    const Text('Password', style: TextStyle(color: foreground)),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const Key('binance-auth-password'),
                      controller: _password,
                      obscureText: _obscurePassword,
                      autofillHints: [
                        _register ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: _decoration('Password').copyWith(
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: BinancePalette.textMuted,
                          ),
                        ),
                      ),
                      validator: (v) => v == null || v.length < 6
                          ? 'Password must be at least 6 characters' : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(
                            color: BinancePalette.red, fontSize: 12,
                          )),
                    ],
                    if (_info != null) ...[
                      const SizedBox(height: 12),
                      Text(_info!,
                          style: const TextStyle(
                            color: BinancePalette.green, fontSize: 12,
                          )),
                    ],
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        key: const Key('binance-auth-submit'),
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: BinancePalette.yellow,
                          foregroundColor: BinancePalette.canvas,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: BinancePalette.canvas,
                                ),
                              )
                            : Text(_register ? 'Create account' : 'Log in',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                )),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        key: const Key('binance-auth-toggle'),
                        onPressed: _submitting ? null : () => setState(() {
                          _register = !_register;
                          _error = null;
                          _info = null;
                        }),
                        child: Text(
                          _register
                              ? 'Already registered? Log in'
                              : 'New here? Create an account',
                          style: const TextStyle(
                            color: BinancePalette.yellow,
                            fontSize: 13,
                          ),
                        ),
                      ),
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

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: BinancePalette.textMuted),
      filled: true,
      fillColor: BinancePalette.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: BinancePalette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: BinancePalette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: BinancePalette.yellow),
      ),
    );
  }
}
