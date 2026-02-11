import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for managing bottom navigation bar index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
