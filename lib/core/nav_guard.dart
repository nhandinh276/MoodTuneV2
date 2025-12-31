import 'dart:async';

import 'package:flutter/material.dart';

class NavGuard {
  // ✅ gắn vào MaterialApp.navigatorKey
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  // ✅ queue để tránh push/pop cùng lúc (nguyên nhân _debugLocked)
  static Future<void> _queue = Future.value();

  static NavigatorState? get _nav => key.currentState;

  static Future<T?> push<T>(Route<T> route) {
    return _enqueue<T>(() async {
      final nav = _nav;
      if (nav == null) return null;
      await Future.delayed(Duration.zero); // chờ 1 microtask cho chắc
      return nav.push(route);
    });
  }

  static Future<T?> pushReplacement<T, TO>(Route<T> route, {TO? result}) {
    return _enqueue<T>(() async {
      final nav = _nav;
      if (nav == null) return null;
      await Future.delayed(Duration.zero);
      return nav.pushReplacement(route, result: result);
    });
  }

  static Future<bool> maybePop<T extends Object?>([T? result]) {
    return _enqueue<bool>(() async {
      final nav = _nav;
      if (nav == null) return false;
      await Future.delayed(Duration.zero);
      return nav.maybePop(result);
    }).then((v) => v ?? false);
  }

  static Future<T?> _enqueue<T>(Future<T?> Function() task) {
    final completer = Completer<T?>();

    _queue = _queue.then((_) async {
      try {
        final res = await task();
        completer.complete(res);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });

    return completer.future;
  }
}
