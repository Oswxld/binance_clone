import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/home_balance.dart';
import '../domain/home_repository.dart';

/// Balances update instantly from the owner-scoped Supabase stream. KES
/// quotes refresh separately, so an HTTP outage never freezes allocation.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._client);

  final SupabaseClient _client;

  // Clearly labeled indicative DEMO rates used when no live quote is
  // available yet. They never change the underlying Supabase holdings.
  static const double _referenceUsdtKes = 130;
  static const double _referenceBtcKes = 10409400;

  @override
  Stream<HomeBalance> watchBalance() {
    final ownerId = _client.auth.currentUser?.id;
    if (ownerId == null) {
      return Stream<HomeBalance>.error(
        StateError('Sign in before watching a wallet balance.'),
      );
    }

    late final StreamController<HomeBalance> controller;
    StreamSubscription<List<Map<String, dynamic>>>? balanceSubscription;
    Timer? priceRefreshTimer;

    double usdt = 0;
    double btc = 0;
    double usdtKes = _referenceUsdtKes;
    double btcKes = _referenceBtcKes;
    double ethKes = 0;
    double bnbKes = 0;
    DateTime? lastSuccessfulQuote;
    bool hasSnapshot = false;
    bool fetchingPrices = false;

    void publish() {
      if (controller.isClosed || !hasSnapshot) return;
      if (usdt == 0 && btc == 0) {
        controller.add(const HomeBalance.zero());
        return;
      }
      final quoteIsOld = lastSuccessfulQuote == null ||
          DateTime.now().difference(lastSuccessfulQuote!) >
              const Duration(minutes: 5);
      controller.add(HomeBalance.valued(
        usdt: usdt,
        btc: btc,
        usdtKes: usdtKes,
        btcKes: btcKes,
        ethKes: ethKes,
        bnbKes: bnbKes,
        indicativeRates: quoteIsOld,
      ));
    }

    Future<void> refreshPrices() async {
      if (fetchingPrices || !hasSnapshot || controller.isClosed ||
          (usdt == 0 && btc == 0)) {
        return;
      }
      fetchingPrices = true;
      try {
        final uri = Uri.https(
          'api.coingecko.com',
          '/api/v3/simple/price',
          {'ids': 'bitcoin,tether,ethereum,binancecoin',
            'vs_currencies': 'kes'},
        );
        final response =
            await http.get(uri).timeout(const Duration(seconds: 12));
        if (response.statusCode != 200) {
          throw StateError('Price API HTTP ${response.statusCode}');
        }
        final prices = jsonDecode(response.body) as Map<String, dynamic>;
        final nextUsdtKes = (prices['tether']?['kes'] as num?)?.toDouble();
        final nextBtcKes = (prices['bitcoin']?['kes'] as num?)?.toDouble();
        if (nextUsdtKes == null || nextBtcKes == null ||
            !nextUsdtKes.isFinite || !nextBtcKes.isFinite ||
            nextUsdtKes <= 0 || nextBtcKes <= 0) {
          throw const FormatException('Invalid positive KES quotes');
        }
        usdtKes = nextUsdtKes;
        btcKes = nextBtcKes;
        // ETH/BNB are denomination quotes, not additional wallet holdings.
        // Never invent rates if CoinGecko omits these two fields.
        final nextEthKes = (prices['ethereum']?['kes'] as num?)?.toDouble();
        final nextBnbKes = (prices['binancecoin']?['kes'] as num?)?.toDouble();
        ethKes = nextEthKes != null && nextEthKes.isFinite && nextEthKes > 0
            ? nextEthKes : 0;
        bnbKes = nextBnbKes != null && nextBnbKes.isFinite && nextBnbKes > 0
            ? nextBnbKes : 0;
        lastSuccessfulQuote = DateTime.now();
        publish();
      } catch (_) {
        // Keep the last successful quote (or explicit indicative reference).
        // No fake zero balances and no disappearing allocation bar.
        publish();
      } finally {
        fetchingPrices = false;
      }
    }

    controller = StreamController<HomeBalance>(
      onListen: () {
        balanceSubscription = _client
            .from('b_balances')
            .stream(primaryKey: ['id'])
            .eq('owner_id', ownerId)
            .listen(
          (rows) {
            if (rows.isEmpty) {
              usdt = 0;
              btc = 0;
            } else {
              usdt = double.parse(rows.first['usdt_balance'].toString());
              btc = double.parse(rows.first['btc_balance'].toString());
            }
            hasSnapshot = true;
            // New holdings immediately recalculate the relative KES values.
            publish();
            // The rate request cannot block the Supabase subscription.
            if (lastSuccessfulQuote == null) {
              unawaited(refreshPrices());
            }
          },
          onError: (Object error, StackTrace stack) {
            if (!controller.isClosed) controller.addError(error, stack);
          },
        );
        // Market moves change the split even if holdings stay the same.
        priceRefreshTimer = Timer.periodic(
          const Duration(seconds: 90),
          (_) => unawaited(refreshPrices()),
        );
      },
      onCancel: () async {
        priceRefreshTimer?.cancel();
        await balanceSubscription?.cancel();
      },
    );
    return controller.stream;
  }
}
