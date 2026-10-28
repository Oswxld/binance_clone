# Binance Clone — Home screen

Flutter implementation of the supplied HTML dashboard. All **28 SVGs** are
extracted from the original markup in `assets/svgs/`; geometry and paths are
unchanged. Static home content matches the design, while the estimated KES
total is loaded from **Dwellio Supabase** and converted using current
CoinGecko BTC/KES and USDT/KES prices. No Binance wallet is connected.

## Start

1. Make a local `.env` at the **project root** (next to pubspec.yaml):
   ```env
   SUPABASE_URL=https://tspywzqhbrmuwimkvnae.supabase.co
   SUPABASE_PUBLISHABLE_KEY=your_client_safe_publishable_key
   ```
   You can use `SUPABASE_ANON_KEY` instead of `SUPABASE_PUBLISHABLE_KEY`.
   **Never use a service_role / secret key in a mobile app.**
2. Run `flutter pub get`, then `flutter run`.
3. Change the demo quantities in Dwellio > Table Editor >
   `public.b_balances` > row `id = 1`, columns
   `usdt_balance` and `btc_balance`.
4. Pull down on the dashboard to refresh the KES total.

`.env` is gitignored but bundled into a client app. The publishable key is
not secret: security must come from Postgres RLS. This demo's single balance
row is **intentionally readable by anyone with the public project key**
so it works without a login. **Do not store private or real user balances
in this table.** Editing is not available to app users.

The public CoinGecko API may rate limit requests; if rates cannot be fetched,
an error appears rather than misleading stale prices.

## Feature-first pragmatic DDD

```
lib/
  main.dart
  features/home/
    data/home_repository_impl.dart
    domain/home_balance.dart
    domain/home_repository.dart
    presentation/home_provider.dart
    presentation/home_screen.dart
assets/svgs/   # exact supplied SVG vector geometry
```

Other buttons, tabs, market prices and PNL are **visual placeholders only**.
There is no live trading, deposits, order placement or exchange authentication.
