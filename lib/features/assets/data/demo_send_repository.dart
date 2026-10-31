import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Demo only: atomic debit of the CURRENT user's mock wallet.
abstract interface class DemoSendRepository {
  Future<void> deduct({required String asset, required double amount});
}
class SupabaseDemoSendRepository implements DemoSendRepository {
  const SupabaseDemoSendRepository(this.client);
  final SupabaseClient client;
  @override
  Future<void> deduct({required String asset, required double amount}) async {
    if (asset != 'USDT' && asset != 'BTC') throw ArgumentError('Invalid asset');
    if (amount <= 0 || !amount.isFinite) throw ArgumentError('Invalid amount');
    if (client.auth.currentUser == null) throw StateError('Not signed in');
    await client.rpc('b_demo_send_deduct', params: {
      'p_asset': asset,
      'p_amount': amount,
    });
  }
}
final demoSendRepositoryProvider = Provider<DemoSendRepository>(
  (ref) => SupabaseDemoSendRepository(Supabase.instance.client),
);
