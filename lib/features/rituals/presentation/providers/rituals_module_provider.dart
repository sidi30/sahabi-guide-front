import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rituals_state_manager.dart';

class RitualsModuleProvider extends StatelessWidget {
  final Widget child;

  const RitualsModuleProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RitualsStateManager>(
      create: (_) => RitualsStateManager(),
      child: child,
    );
  }
}

// Initialization helper
class RitualsModuleInitializer {
  static Future<void> initialize(BuildContext context) async {
    // Load initial data
    final stateManager = context.read<RitualsStateManager>();
    await Future.wait([
      stateManager.loadRituals(),
      stateManager.loadDuas(),
      stateManager.loadProgress(),
    ]);
  }
}
