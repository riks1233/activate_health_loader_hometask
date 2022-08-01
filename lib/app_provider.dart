import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  // Here, loaded value is an integer from 0 to 100, to eliminate floating point number problems
  // when doing calculations, like adding 0.1 to 0.2, which will result in 0.30000000000000004.
  int _loadedValue = 0;
  int get loadedValue => _loadedValue;
  set loadedValue(int value)
  {
    _loadedValue = value;
    notifyListeners();
  }

}
