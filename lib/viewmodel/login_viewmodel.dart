import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import '../components/utils.dart';
import '../screens/home_screen.dart';
import '../components/globals.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger('signInWithGoogle');

  bool isSignUp = false;
  bool isForgotPassword = false;
  bool _isAuthChecked = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  LoginViewModel() {
    _setupLogging();
    checkAuthentication();
  }

  void toggleForm() {
    isSignUp = !isSignUp;
    isForgotPassword = false;
    notifyListeners();
  }

  Future<User?> signInWithEmailPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        Utils().showCustomSnackBar("Please verify your email address before signing in.");
        return null;
      }
      return user;
    } catch (e) {
      Utils().showCustomSnackBar("Login failed. Please check your credentials.");
      return null;
    }
  }

  Future<User?> signUpWithEmailPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Utils().showCustomSnackBar(
          "A verification email has been sent to your email address. Please verify your email before signing in.",
        );
      }
      return user;
    } catch (error) {
      String errorMessage = "Sign up failed. Please try again.";
      if (error.toString().contains('email-already-in-use')) {
        errorMessage = "This email is already taken.";
      } else if (error.toString().contains('weak-password')) {
        errorMessage = "Password should be at least 6 characters.";
      }
      Utils().showCustomSnackBar(errorMessage);
      return null;
    }
  }

  void checkAuthentication() async {
    if (_isAuthChecked) return;
    _isAuthChecked = true;

    User? user = _auth.currentUser;
    print('user: $user');
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Utils().navigateTo(globalContext, HomeScreen(userId: user.uid), false);
      });
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);
      return userCredential;
    } on PlatformException catch (e, s) {
      _logger.severe('Error Code: ${e.code}');
      _logger.severe('Error Message: ${e.message}');
      _logger.severe('Error Details: ${e.details}');
      _logger.severe('Stack Trace: $s');
      Utils().showCustomSnackBar("Google Sign-In failed: ${e.message}");
      return null;
    } catch (e, s) {
      _logger.severe('Error: $e');
      _logger.severe('Stack Trace: $s');
      Utils().showCustomSnackBar("An unexpected error occurred. Please try again.");
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Utils().showCustomSnackBar("If the email is registered, a password reset email has been sent.");
    } catch (e) {
      Utils().showCustomSnackBar("Failed to send password reset email");
    }
  }

  void clearTextFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }
}
