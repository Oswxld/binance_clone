import 'package:binance/features/auth/presentation/binance_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows login screen and allows switching to registration',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BinanceLoginScreen()),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('binance-auth-email')), findsOneWidget);
    expect(find.byKey(const Key('binance-auth-password')), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    await tester.tap(find.byKey(const Key('binance-auth-toggle')));
    await tester.pump();

    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Already registered? Log in'), findsOneWidget);
  });

  testWidgets('rejects empty email and weak password before calling Supabase',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BinanceLoginScreen()),
    );
    await tester.tap(find.byKey(const Key('binance-auth-submit')));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });
}
