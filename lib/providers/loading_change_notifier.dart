import 'package:flutter/material.dart';

class LoadingChangeNotifier with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  Future<void> withLoading<T>(Future<T> Function() asyncTask) async {
    try {
      _setLoading(true);
      await asyncTask();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool newLoadingState) {
    if (_loading != newLoadingState) {
      _loading = newLoadingState;
      notifyListeners();
    }
  }
}
