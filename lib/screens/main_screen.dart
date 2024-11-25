import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/globals.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'login_page.dart';
import '../components/utils.dart';
import '../viewmodel/main_screen_viewmodel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainScreenViewModel = Provider.of<MainScreenViewModel>(context);

    return FutureBuilder<bool>(
      future: mainScreenViewModel.isLoggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasData && snapshot.data == true) {
          return FutureBuilder<String?>(
            future: getUserId(),
            builder: (context, userIdSnapshot) {
              if (userIdSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              } else if (userIdSnapshot.hasData && userIdSnapshot.data!.isNotEmpty) {
                return HomeScreen(userId: userIdSnapshot.data!);
              } else {
                return const LoginSignupPage();
              }
            },
          );
        } else {
          return const LoginSignupPage();
        }
      },
    );
  }
}
