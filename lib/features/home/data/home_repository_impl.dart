import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/home_balance.dart';
import '../domain/home_repository.dart';

/// Supabase database quantities + public USDT/BTC prices in KES.
/// The stream is shared between Home and Assets through Riverpod.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Stream<HomeBalance> watchBalance() {
    final ownerId = _client.auth.currentUser?.id;
    if (ownerId == null) {
      return Stream<HomeBalance>.error(
        StateError('Sign in before watching a wallet balance.'),
      );
    }
    return _client
        .from('b_balances')
        .stream(primaryKey: ['id'])
        .eq('owner_id', ownerId)
        .asyncMap((rows) async {
      if (rows.isEmpty) return const HomeBalance.zero();

      final row = rows.first;
      final usdt = double.parse(row['usdt_balance'].toString());
      final btc = double.parse(row['btc_balance'].toString());

      // Each authenticated account owns its own wallet. A zero balance
      // doesn't need an external quote; never invent nonzero holdings.
      if (usdt == 0 && btc == 0) return const HomeBalance.zero();

      try {
        final uri = Uri.https(
          'api.coingecko.com',
          '/api/v3/simple/price',
          {'ids': 'bitcoin,tether', 'vs_currencies': 'kes'},
        );
        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          throw StateError('Price API HTTP ${response.statusCode}');
        }

        final prices = jsonDecode(response.body) as Map<String, dynamic>;
        final usdtKes = (prices['tether']?['kes'] as num?)?.toDouble();
        final btcKes = (prices['bitcoin']?['kes'] as num?)?.toDouble();
        if (usdtKes == null || btcKes == null ||
            usdtKes <= 0 || btcKes <= 0) {
          throw const FormatException('Missing positive KES rates.');
        }
        return HomeBalance.valued(
          usdt: usdt,
          btc: btc,
          usdtKes: usdtKes,
          btcKes: btcKes,
        );
      } catch (_) {
        // Network/rate-limit failure: keep the streamed holdings visible,
        // but mark KES estimates unavailable instead of reporting fake KSh 0.
        return HomeBalance.unpriced(usdt: usdt, btc: btc);
      }
    });
  }
}
