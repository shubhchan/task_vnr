import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_example/core/error/result.dart';
import 'package:offline_example/features/auth/domain/auth_repository.dart';
import 'package:offline_example/features/auth/presentation/auth_notifier.dart';
import 'package:offline_example/features/auth/presentation/login_screen.dart';
import 'package:provider/provider.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('login form validates before signing in', (tester) async {
    final repository = _MockAuthRepository();
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Success<void>(null));

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthNotifier>(
        create: (_) => AuthNotifier(repository),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    // Empty submit shows both required messages.
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    // Bad email is rejected.
    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter a valid email'), findsOneWidget);

    // Short password is rejected.
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Use at least 6 characters'), findsOneWidget);

    // Valid input reaches the repository.
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    verify(
      () => repository.login(email: 'user@example.com', password: '123456'),
    ).called(1);
  });
}
