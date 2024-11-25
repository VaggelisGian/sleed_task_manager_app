import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../components/utils.dart';
import '../data/db_helper.dart';
import 'home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_page.dart';
import '../viewmodel/theme_provider.dart';
import '../viewmodel/settings_viewmodel.dart';

class Settings extends StatefulWidget {
  final String userId;

  const Settings({required this.userId, super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).appBarTheme.iconTheme?.color,
            ),
            onPressed: () => Navigator.pop(context)),
        title: Text(
          'Settings',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(25.0, 60.0, 25.0, 25.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('images/sleed_logo.jpg', width: 100.0, height: 100.0),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Task Manager",
                  style: TextStyle(fontSize: 20.0, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 5.0, left: 25.0, right: 20.0, bottom: 60.0),
              ),
              Divider(color: Theme.of(context).dividerColor),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 40.0, right: 20.0, bottom: 30.0),
                child: GestureDetector(
                  onTap: () {
                    Utils().showAlertDialog(context, widget.userId);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).bannerTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: Text(
                      "CLEAR ALL DATA",
                      style: TextStyle(fontSize: 15.0, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ),
              ),
              Divider(color: Theme.of(context).dividerColor),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 40.0, right: 20.0, bottom: 30.0),
                child: GestureDetector(
                  onTap: () => settingsViewModel.syncData(context, widget.userId),
                  child: Container(
                    alignment: Alignment.center,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).bannerTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: Text(
                      "SYNC ALL DATA",
                      style: TextStyle(fontSize: 15.0, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ),
              ),
              Divider(color: Theme.of(context).dividerColor),
              Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 20.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 60.0,
                  child: InkWell(
                    child: Text(
                      "Terms and Condition",
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    onTap: () => launchUrl(Uri.parse('https://github.com/VaggelisGian/sleed_task_manager_app')),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 20.0),
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 60.0,
                  child: InkWell(
                    child: Text(
                      "Privacy Policy",
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    onTap: () => launchUrl(Uri.parse('https://www.linkedin.com/in/vaggelis-giannopoulos-ab1588212/')),
                  ),
                ),
              ),
              Divider(color: Theme.of(context).dividerColor),
              Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 20.0, top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Dark Mode",
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    Switch(
                      value: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                      },
                      activeColor: Theme.of(context).hintColor,
                    ),
                  ],
                ),
              ),
              Divider(color: Theme.of(context).dividerColor),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 40.0, right: 20.0, bottom: 30.0),
                child: GestureDetector(
                  onTap: () => settingsViewModel.signOut(context),
                  child: Container(
                    alignment: Alignment.center,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).bannerTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: Text(
                      "SIGN OUT",
                      style: TextStyle(fontSize: 15.0, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "Vaggelis Giannopoulos",
                  style: TextStyle(fontSize: 15.0, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
