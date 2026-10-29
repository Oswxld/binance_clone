import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/home_repository_impl.dart';
import '../domain/home_balance.dart';
import '../domain/home_repository.dart';
import '../domain/wallet_display_currency.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(Supabase.instance.client),
);

/// One persistent Realtime subscription shared by Home and Assets.
/// StreamProvider exposes AsyncValue<HomeBalance> to both screens.
final homeBalanceProvider = StreamProvider<HomeBalance>(
  (ref) => ref.read(homeRepositoryProvider).watchBalance(),
);

// Shared across the IndexedStack tabs; selecting in Assets updates Home.
final displayCurrencyProvider =
    NotifierProvider<DisplayCurrencyNotifier, WalletDisplayCurrency>(
  DisplayCurrencyNotifier.new,
);

class DisplayCurrencyNotifier extends Notifier<WalletDisplayCurrency> {
  @override
  WalletDisplayCurrency build() => WalletDisplayCurrency.kes;

  void select(WalletDisplayCurrency currency) => state = currency;
}
