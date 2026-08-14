import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Testable wall-clock source. Prefer this over `DateTime.now()` in domain code.
final appClockProvider = Provider<Clock>((ref) => const Clock());
