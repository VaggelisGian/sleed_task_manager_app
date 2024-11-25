import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreenViewModel extends ChangeNotifier {
  Future<bool>? _isLoggedInFuture;

  Future<bool> get isLoggedInFuture {
    _isLoggedInFuture ??= _checkLoginStatus();
    return _isLoggedInFuture!;
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    return userId != null && userId.isNotEmpty;
  }

  void notifyDataChanged() {
    notifyListeners();
  }
}
