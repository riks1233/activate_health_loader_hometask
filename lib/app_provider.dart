import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  double _loadedValue = 0.0;
  double get loadedValue => _loadedValue;
  set loadedValue(double value)
  {
    _loadedValue = value;
    notifyListeners();
  }

}
