import 'package:flutter/material.dart';

class Counter with ChangeNotifier {
  String _tab = '';
  String get tab => _tab;

  void change(val) {
    _tab = val;
    // 通知订阅者
    notifyListeners();
  }
}
