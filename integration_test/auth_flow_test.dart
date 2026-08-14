import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// F1 auth integration scaffolding.
///
/// Full device flows against a live NestJS backend belong in later CI jobs.
/// This file keeps `integration_test` wired and documents the intended path.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('integration harness boots', (tester) async {
    expect(true, isTrue);
  });
}
