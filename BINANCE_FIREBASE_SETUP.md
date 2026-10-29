# Binance Clone — Supabase login + Firebase Push (Android)

## Already implemented
- Supabase email/password login and sign-up displayed before Home.
- On successful session, create a **0 USDT / 0 BTC** row in `b_balances` only if the owner does not have one.
- Home and Assets subscribe to `b_balances.owner_id == auth.uid()`.
- Push token registered in `b_device_tokens` after permission, with `owner_id`, `fcm_target`, `platform`, `last_seen_at`.
- Foreground: inline notification banner. Background/closed: normal OS notification.
- Sign out using the avatar on Home; its device token is removed.

## Connect to SAME Firebase project as Gmail Clone

Existing Firebase project ID: `mail-demo-push` (not a new Firebase project).
This Binance Android app has a **different package name** from Gmail Clone: `com.example.binance`.

1. Go to Firebase Console > choose `mail-demo-push` > Project settings > Your apps.
2. Add an **Android app**, package name **`com.example.binance`**.
   Do **not** choose/reuse the Gmail Android app registration.
3. Download the Android app's `google-services.json`. Save it as
   `android/app/google-services.json` (do not rename it). The file is client configuration, not a service-account key.
4. Install the CLI tools on your computer:
   ```powershell
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   ```
   If `flutterfire` isn't found, add Dart's Pub Cache bin folder to PATH:
   `%LOCALAPPDATA%\Pub\Cache\bin` (Windows).
5. From this repository's root, run:
   ```powershell
   flutterfire configure --project=mail-demo-push --platforms=android
   ```
   Choose the existing **`com.example.binance`** Android app if asked.
   This generates `lib/firebase_options.dart` and configures native Firebase.
   **This file doesn't exist before step 5: the app won't build until you run it.**
6. Add your existing Supabase URL and **publishable** client key in local `.env`
   (copy `.env.example`). Do not use a Supabase secret key in the mobile app.
7. Run:
   ```powershell
   flutter pub get
   flutter run
   ```
8. Sign in (or create an account), allow notifications, and inspect the
   `b_balances` and `b_device_tokens` rows in Supabase dashboard.
9. To test end to end, use Supabase **SQL Editor with admin access**, inserting
   `owner_id`, `sender_name`, `body`, and `amount` into `b_messages`
   for a test user. This should credit the user's balance and create a
   `b_notifications` row, triggering `binance-push` via database webhook.

### Server-side Firebase details

The existing `binance-push` Edge Function uses
`B_FIREBASE_SERVICE_ACCOUNT_JSON` if configured; otherwise it falls back to
the existing `G_FIREBASE_SERVICE_ACCOUNT_JSON` in this **same Supabase project**.
Because the Firebase project is shared, **do not download or upload another
service-account private key** unless the server actually lacks the existing one.
Never commit a service account JSON to GitHub.

The Edge Function remains an intentionally unprotected prototype webhook
(`verify_jwt=false`). Keep message inserts admin-only; don't use this
configuration as a production push endpoint.

### Auth note

Supabase may require email confirmation for first-time sign-ups. In this case
open the verification email and sign in afterward. Existing Supabase Auth users
can use their account credentials.

### Notes for testing

- No Flutter build was run by ChatGPT. The generated Firebase configuration,
  package resolution, and Android run must be completed on your PC.
- On startup, the app requests notification permission after a successful login.
- Sign out from the Home avatar. A logged-out device must not keep receiving
  another account's pushes.
- The original public `b_balances` row with `id=1` is no longer queried
  or readable anonymously. It was preserved in the database.
- Before using real funds, replace this demo wallet model with a properly
  audited ledger; push notifications are never a source of balance truth.
