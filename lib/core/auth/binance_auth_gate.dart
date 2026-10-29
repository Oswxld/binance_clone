import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/home/presentation/home_provider.dart';
import '../../features/auth/presentation/binance_login_screen.dart';
import '../presentation/app_shell.dart';
import '../notifications/binance_push_service.dart';
import '../theme/binance_palette.dart';

/// The home shell is only mounted after a real Supabase session and the
/// account's one-time, server-initialized starter wallet is ready.
class BinanceAuthGate extends ConsumerStatefulWidget {
  const BinanceAuthGate({super.key});

  @override
  ConsumerState<BinanceAuthGate> createState() => _BinanceAuthGateState();
}

class _BinanceAuthGateState extends ConsumerState<BinanceAuthGate> {
  late final SupabaseClient _client;
  late final BinancePushService _push;
  late final StreamSubscription<AuthState> _authSubscription;

  String? _readyOwnerId;
  String? _error;
  bool _loading = true;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _push = BinancePushService(_client, binanceScaffoldMessengerKey);
    _authSubscription = _client.auth.onAuthStateChange.listen(
      (state) => unawaited(_handleSession(state.session)),
    );
    unawaited(_handleSession(_client.auth.currentSession));
  }

  Future<void> _handleSession(Session? session) async {
    final user = session?.user;
    if (user?.id == _readyOwnerId && !_loading && _error == null) return;

    final generation = ++_generation;
    if (!mounted) return;

    if (user == null) {
      unawaited(_push.stop());
      ref.invalidate(homeBalanceProvider);
      setState(() {
        _readyOwnerId = null;
        _loading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _readyOwnerId = null;
      _loading = true;
      _error = null;
    });

    try {
      await _initializeStarterBalance();
      if (!mounted || generation != _generation) return;
      ref.invalidate(homeBalanceProvider);
      setState(() {
        _readyOwnerId = user.id;
        _loading = false;
      });
      // Push registration is nonblocking; lack of Firebase permission must
      // never prevent a user from seeing their own wallet.
      unawaited(_push.start(user.id));
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = 'Could not prepare your wallet. Check your connection and retry.';
        _loading = false;
      });
      debugPrint('Binance wallet bootstrap failed: $error');
    }
  }

  Future<void> _initializeStarterBalance() async {
    // The Edge Function validates the user's session, fetches the BTC/KES
    // exchange rate and awards the fixed demo starter balance only once.
    final response = await _client.functions.invoke(
      'binance-starter-wallet',
      body: <String, dynamic>{},
    );
    final data = response.data;
    if (data is! Map || data['ok'] != true) {
      throw StateError('Starter wallet initialization did not complete.');
    }
  }

  Future<void> _signOut() async {
    await _push.stop(unregister: true);
    await _client.auth.signOut();
  }

  @override
  void dispose() {
    _generation++;
    _authSubscription.cancel();
    unawaited(_push.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: BinancePalette.canvas,
        body: Center(
          child: CircularProgressIndicator(color: BinancePalette.yellow),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: BinancePalette.canvas,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined,
                      color: BinancePalette.textMuted, size: 38),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: BinancePalette.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () => _handleSession(_client.auth.currentSession),
                    child: const Text('Retry'),
                  ),
                  TextButton(
                    onPressed: _signOut,
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (_readyOwnerId == null) return const BinanceLoginScreen();
    return AppShell(
      key: ValueKey('binance-shell-$_readyOwnerId'),
      onSignOut: _signOut,
    );
  }
}
