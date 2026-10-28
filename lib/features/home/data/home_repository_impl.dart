import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/home_balance.dart';
import '../domain/home_repository.dart';

/// Only data layer for Home: Supabase balances + public spot price conversion.
/// CoinGecko's keyless endpoint is rate-limited; errors must never show fake values.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<HomeBalance> fetchBalance() async {
    final row = await _client
        .from('b_balances')
        .select('usdt_balance, btc_balance')
        .eq('id', 1)
        .single();

    final usdt = double.parse(row['usdt_balance'].toString());
    final btc = double.parse(row['btc_balance'].toString());

    // A freshly created table starts with zero balances, so it works even
    // while the public price API is unavailable.
    if (usdt == 0 && btc == 0) {
      return const HomeBalance(usdt: 0, btc: 0, totalKes: 0);
    }

    final uri = Uri.https('api.coingecko.com', '/api/v3/simple/price', {
      'ids': 'bitcoin,tether',
      'vs_currencies': 'kes',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw StateError(
        'Could not load current KES exchange prices '
        '(HTTP ${response.statusCode}). Pull down to retry.',
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final usdtKes = (data['tether']?['kes'] as num?)?.toDouble();
    final btcKes = (data['bitcoin']?['kes'] as num?)?.toDouble();
    if (usdtKes == null || btcKes == null || usdtKes <= 0 || btcKes <= 0) {
      throw const FormatException('Missing USDT/BTC KES market prices.');
    }
    return HomeBalance.valued(
      usdt: usdt,
      btc: btc,
      usdtKes: usdtKes,
      btcKes: btcKes,
    );
  }
}
