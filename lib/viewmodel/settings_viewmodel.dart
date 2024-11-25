import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/utils.dart';
import '../data/db_helper.dart';
import '../screens/login_page.dart';
import '../viewmodel/main_screen_viewmodel.dart';
import '../viewmodel/home_screen_viewmodel.dart';

class SettingsViewModel extends ChangeNotifier {
  Future<void> syncData(BuildContext context, String userId) async {
    try {
      Utils().showLoadingDialog(context, "Synchronizing Data...");
      await DatabaseHelper.instance.syncFromFirebase(userId);
      await DatabaseHelper.instance.syncToFirebase(userId);
      Utils().showCustomSnackBar("Data synchronized successfully");

      Provider.of<MainScreenViewModel>(context, listen: false).notifyDataChanged();

      Provider.of<HomeScreenViewModel>(context, listen: false).refreshTaskList();
    } catch (e) {
      Utils().showCustomSnackBar("$e");
    }
    Navigator.pop(context);
  }

  Future<void> signOut(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Utils().showCustomSnackBar('Successfully signed out');
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginSignupPage()),
      (Route<dynamic> route) => false,
    );
  }
}
