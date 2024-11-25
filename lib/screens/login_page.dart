import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleed_task_manager_app/screens/home_screen.dart';
import '../components/utils.dart';
import '../viewmodel/login_viewmodel.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  LoginSignupPageState createState() => LoginSignupPageState();
}

class LoginSignupPageState extends State<LoginSignupPage> {
  late LoginViewModel loginViewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    loginViewModel = Provider.of<LoginViewModel>(context);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: Theme.of(context).hintColor,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: width,
                    height: height * 1.2,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Theme.of(context).primaryTextTheme.bodyMedium?.color,
                      shape: const RoundedRectangleBorder(),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 75,
                          offset: Offset(0, 0),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: width * 0.4,
                          top: height * 0.8,
                          child: Container(
                            width: width * 1,
                            height: height * 0.4,
                            decoration: ShapeDecoration(
                              color: Theme.of(context).primaryTextTheme.bodyLarge?.color,
                              shape: const OvalBorder(),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -width * 0.8,
                          top: -height * 0.63,
                          child: Container(
                            width: width * 2.2,
                            height: height * 0.96,
                            decoration: ShapeDecoration(
                              color: Theme.of(context).hintColor,
                              shape: const OvalBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: Container(),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Welcome,',
                          style: TextStyle(fontSize: height * 0.07, color: Colors.white),
                        ),
                        Text(
                          'Please Sign In to get started!',
                          style: TextStyle(fontSize: height * 0.03, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              height: 50.0,
                              width: 270.0,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Image.asset('images/google_logo.png', width: 33.0),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.015,
                                    ),
                                    Text(
                                      'Sign in with Google',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: MediaQuery.of(context).size.width * 0.045),
                                    ),
                                  ],
                                ),
                                onPressed: () async {
                                  final UserCredential? userCredential = await loginViewModel.signInWithGoogle(context);
                                  if (userCredential != null) {
                                    loginViewModel.clearTextFields();
                                    Utils().navigateTo(context, HomeScreen(userId: userCredential.user!.uid), true);
                                  }
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white,
                                      height: 20,
                                    ),
                                  ),
                                  Text(
                                    ' OR ',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white,
                                      height: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                                TextFormField(
                                  controller: loginViewModel.emailController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your Email',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(color: Colors.transparent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(color: Colors.transparent),
                                    ),
                                    fillColor: Theme.of(context).colorScheme.surface,
                                    filled: true,
                                  ),
                                ),
                              ],
                            ),
                            if (!loginViewModel.isForgotPassword)
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.025,
                              ),
                            if (!loginViewModel.isForgotPassword)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Password',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: loginViewModel.passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(color: Colors.transparent),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(color: Colors.transparent),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(color: Colors.transparent),
                                      ),
                                      fillColor: Theme.of(context).colorScheme.surface,
                                      filled: true,
                                    ),
                                  ),
                                ],
                              ),
                            if (loginViewModel.isSignUp && !loginViewModel.isForgotPassword)
                              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                            if (loginViewModel.isSignUp && !loginViewModel.isForgotPassword)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Confirm your password',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: loginViewModel.confirmPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Re-Enter your password',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(color: Colors.transparent),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(color: Colors.transparent),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(color: Colors.transparent),
                                      ),
                                      fillColor: Theme.of(context).colorScheme.surface,
                                      filled: true,
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                            ElevatedButton(
                              onPressed: () async {
                                bool isValidEmail(String email) {
                                  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  return regex.hasMatch(email);
                                }

                                if (loginViewModel.emailController.text.isEmpty ||
                                    (!loginViewModel.isForgotPassword &&
                                        loginViewModel.passwordController.text.isEmpty) ||
                                    (loginViewModel.isSignUp &&
                                        loginViewModel.confirmPasswordController.text.isEmpty)) {
                                  Utils().showCustomSnackBar("Please fill in all fields");
                                  return;
                                }

                                if (!isValidEmail(loginViewModel.emailController.text)) {
                                  Utils().showCustomSnackBar("Please enter a valid email address");
                                  return;
                                }

                                if (loginViewModel.isForgotPassword) {
                                  await loginViewModel.sendPasswordResetEmail(
                                      loginViewModel.emailController.text, context);
                                  loginViewModel.isForgotPassword = false;
                                  loginViewModel.notifyListeners();
                                } else if (loginViewModel.isSignUp) {
                                  if (loginViewModel.passwordController.text.length < 6) {
                                    Utils().showCustomSnackBar("Password should be at least 6 characters");
                                    return;
                                  }
                                  if (loginViewModel.confirmPasswordController.text ==
                                      loginViewModel.passwordController.text) {
                                    try {
                                      var user = await loginViewModel.signUpWithEmailPassword(
                                          loginViewModel.emailController.text,
                                          loginViewModel.passwordController.text,
                                          context);
                                      if (user != null) {
                                        loginViewModel.toggleForm();
                                      }
                                    } catch (e) {
                                      String errorMessage = "Sign up failed. Please try again.";
                                      if (e.toString().contains('email-already-in-use')) {
                                        errorMessage = "This email is already taken.";
                                      } else if (e.toString().contains('weak-password')) {
                                        errorMessage = "Password should be at least 6 characters.";
                                      }
                                      if (mounted) {
                                        Utils().showCustomSnackBar(errorMessage);
                                      }
                                    }
                                  } else {
                                    Utils().showCustomSnackBar("Passwords do not match");
                                  }
                                } else {
                                  var user = await loginViewModel.signInWithEmailPassword(
                                      loginViewModel.emailController.text,
                                      loginViewModel.passwordController.text,
                                      context);
                                  if (user != null) {
                                    final userId = user.uid;
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setString('userId', userId);
                                    loginViewModel.clearTextFields();
                                    Utils().navigateTo(
                                      context,
                                      HomeScreen(userId: userId),
                                      false,
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              ),
                              child: Text(
                                  loginViewModel.isForgotPassword
                                      ? 'Send Reset Email'
                                      : loginViewModel.isSignUp
                                          ? 'Sign Up'
                                          : 'Log In',
                                  style: TextStyle(color: Theme.of(context).hintColor)),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                            TextButton(
                              onPressed: () {
                                loginViewModel.isForgotPassword = !loginViewModel.isForgotPassword;
                                loginViewModel.notifyListeners();
                              },
                              child: Text(
                                loginViewModel.isForgotPassword ? "Back to Login" : "Forgot password?",
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: loginViewModel.toggleForm,
                              child: Text(
                                loginViewModel.isSignUp
                                    ? "Already have an account? Log in"
                                    : "Don't have an account? Sign up",
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
