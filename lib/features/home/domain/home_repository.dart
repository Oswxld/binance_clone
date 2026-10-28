import 'home_balance.dart';

abstract interface class HomeRepository {
  /// Initial Supabase SELECT followed by Postgres UPDATE/INSERT events.
  Stream<HomeBalance> watchBalance();
}
