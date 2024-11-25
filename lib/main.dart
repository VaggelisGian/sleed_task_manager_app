import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleed_task_manager_app/screens/home_screen.dart';
import './screens/splash_screen.dart';
import '../components/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_page.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'viewmodel/add_task_screen_model.dart';
import 'viewmodel/history_screen_viewmodel.dart';
import 'viewmodel/home_screen_viewmodel.dart';
import 'viewmodel/login_viewmodel.dart';
import 'viewmodel/main_screen_viewmodel.dart';
import 'viewmodel/settings_viewmodel.dart';
import 'viewmodel/theme_provider.dart';
import './components/globals.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  final timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // Request notification permissions for Android 13 and higher
  if (defaultTargetPlatform == TargetPlatform.android) {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }
  // Request notification permissions for iOS and macOS
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    print('Notification permission granted: $result');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => MainScreenViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeScreenViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryScreenViewModel()),
        ChangeNotifierProvider(create: (_) => AddTaskScreenViewModel(null)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const Color hintColor = Color(0xFF772E25);
    const Color hintColorDark = Color(0xFFC44536);
    const Color selectionColor = Color.fromARGB(255, 204, 124, 115);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: Utils.scaffoldMessengerKey,
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            hintColor: hintColor,
            scaffoldBackgroundColor: Colors.grey[100],
            dialogBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Colors.white,
              error: Colors.red,
              onPrimary: Colors.white,
              onSecondary: Colors.grey,
              onSurface: Colors.black,
              surface: Colors.white,
              onError: Colors.white,
            ),
            shadowColor: Colors.black26,
            primaryTextTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFFEDDDD4)),
              bodyMedium: TextStyle(color: Color(0xFFC44536)),
              bodySmall: TextStyle(color: Colors.black),
            ),
            dividerColor: Colors.grey[900],
            bannerTheme: MaterialBannerThemeData(backgroundColor: Colors.grey[400]),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[100],
              iconTheme: const IconThemeData(color: Colors.black),
              titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black),
              bodySmall: TextStyle(color: Colors.black),
            ),
            datePickerTheme: DatePickerThemeData(
              weekdayStyle: const TextStyle(color: Colors.black),
              headerForegroundColor: Colors.black,
              todayForegroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey;
                }
                return Colors.black;
              }),
              backgroundColor: Colors.white,
              elevation: .5,
            ),
            dialogTheme: DialogTheme(
              titleTextStyle: TextStyle(color: Theme.of(context).hintColor),
              contentTextStyle: TextStyle(color: Theme.of(context).hintColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            cupertinoOverrideTheme: CupertinoThemeData(
              primaryColor: hintColor,
              primaryContrastingColor: hintColorDark,
              textTheme: CupertinoTextThemeData(
                primaryColor: hintColor,
                textStyle: TextStyle(color: Colors.black),
                actionTextStyle: TextStyle(color: hintColor),
                tabLabelTextStyle: TextStyle(color: hintColor),
                navTitleTextStyle: TextStyle(color: Colors.black),
                navLargeTitleTextStyle: TextStyle(color: Colors.black),
                navActionTextStyle: TextStyle(color: hintColor),
              ),
              barBackgroundColor: Colors.grey[100],
              scaffoldBackgroundColor: Colors.grey[100],
              brightness: Brightness.light,
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: hintColor,
              selectionColor: selectionColor,
              selectionHandleColor: hintColor,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            hintColor: hintColorDark,
            scaffoldBackgroundColor: Colors.grey[900],
            dialogBackgroundColor: Colors.black,
            colorScheme: ColorScheme.dark(
              primary: Colors.black,
              error: Colors.red[500]!,
              onPrimary: Colors.white,
              onSecondary: Colors.grey,
              onSurface: Colors.white,
              surface: Colors.grey,
              onError: Colors.white,
            ),
            shadowColor: Colors.black12,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white),
            ),
            dividerColor: Colors.grey[100],
            bannerTheme: MaterialBannerThemeData(backgroundColor: Colors.grey[600]),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            primaryTextTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFFEDDDD4)),
              bodyMedium: TextStyle(color: Color(0xFF772E25)),
              bodySmall: TextStyle(color: Colors.white),
            ),
            datePickerTheme: DatePickerThemeData(
              weekdayStyle: const TextStyle(color: Colors.white),
              headerForegroundColor: Colors.white,
              todayForegroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.black;
                }
                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey;
                }
                return Colors.white;
              }),
              backgroundColor: const Color(0xff31343b),
              elevation: .5,
            ),
            cupertinoOverrideTheme: CupertinoThemeData(
              primaryColor: hintColorDark,
              primaryContrastingColor: hintColor,
              textTheme: CupertinoTextThemeData(
                primaryColor: hintColorDark,
                textStyle: TextStyle(color: Colors.white),
                actionTextStyle: TextStyle(color: hintColorDark),
                tabLabelTextStyle: TextStyle(color: hintColorDark),
                navTitleTextStyle: TextStyle(color: Colors.white),
                navLargeTitleTextStyle: TextStyle(color: Colors.white),
                navActionTextStyle: TextStyle(color: hintColorDark),
              ),
              barBackgroundColor: Colors.grey[900],
              scaffoldBackgroundColor: Colors.grey[900],
              brightness: Brightness.dark,
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: hintColorDark,
              selectionColor: selectionColor,
              selectionHandleColor: hintColorDark,
            ),
          ),
          home: const MainScreen(),
        );
      },
    );
  }
}
