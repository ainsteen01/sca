

import 'package:shared_preferences/shared_preferences.dart';

class SharedData {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> shareNumber(String number) async {
    final prefs = await _instance;
    await prefs.setString('mob_number', number);
  }

  Future<String?> getSharedNumber() async {
    final prefs = await _instance;
    return prefs.getString('mob_number');
  }
}

