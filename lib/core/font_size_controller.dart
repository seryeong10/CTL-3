import 'package:flutter/material.dart';

/// 앱 전체 글씨 크기를 관리하는 전역 상태
class FontSizeController extends ChangeNotifier {
  static final FontSizeController _instance = FontSizeController._internal();
  factory FontSizeController() => _instance;
  FontSizeController._internal();

  String _fontSize = '보통'; // 작게 / 보통 / 크게

  String get fontSize => _fontSize;

  double get scaleFactor {
    switch (_fontSize) {
      case '작게': return 0.85;
      case '크게': return 1.18;
      default:     return 1.0;
    }
  }

  void setFontSize(String size) {
    _fontSize = size;
    notifyListeners();
  }
}
