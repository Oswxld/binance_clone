import 'home_balance.dart';

abstract interface class HomeRepository {
  Future<HomeBalance> fetchBalance();
}
