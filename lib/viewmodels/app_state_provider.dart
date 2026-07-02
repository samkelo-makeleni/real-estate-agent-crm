import 'package:flutter/widgets.dart';

import 'app_state.dart';

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(
      provider != null,
      'AppStateProvider was not found in the widget tree',
    );
    return provider!.notifier!;
  }
}
