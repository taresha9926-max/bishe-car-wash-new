import 'package:flutter/material.dart';
import 'app_state_notifier.dart';

class AppStateProvider extends InheritedNotifier<AppStateNotifier> {
  const AppStateProvider({
    super.key,
    required AppStateNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppStateNotifier of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }

  static AppStateNotifier read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppStateProvider>();
    final provider = element?.widget as AppStateProvider?;
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }
}
