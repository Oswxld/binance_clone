import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/home_repository_impl.dart';
import '../domain/home_balance.dart';
import '../domain/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(Supabase.instance.client),
);

/// AsyncValue<HomeBalance> supplies loading, data and error states for the UI.
final homeBalanceProvider = FutureProvider.autoDispose<HomeBalance>(
  (ref) => ref.read(homeRepositoryProvider).fetchBalance(),
);
