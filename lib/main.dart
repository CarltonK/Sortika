import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:wealth/authentication_screens/login.dart';
import 'package:wealth/authentication_screens/passwordreset.dart';
import 'package:wealth/authentication_screens/registration.dart';
import 'package:wealth/home_screens/borrowAll.dart';
import 'package:wealth/home_screens/create_goal.dart';
import 'package:wealth/home_screens/deposit.dart';
import 'package:wealth/home_screens/editGoal.dart';
import 'package:wealth/home_screens/editGroup.dart';
import 'package:wealth/home_screens/help.dart';
import 'package:wealth/home_screens/home.dart';
import 'package:wealth/home_screens/notifications.dart';
import 'package:wealth/home_screens/payLoan.dart';
import 'package:wealth/home_screens/profile.dart';
import 'package:wealth/home_screens/rate.dart';
import 'package:wealth/home_screens/settings.dart';
import 'package:wealth/home_screens/updateLoan.dart';
import 'package:wealth/onboarding.dart';
import 'package:wealth/pre_login/achieve_preference.dart';
import 'package:wealth/home_screens/admin.dart';

void main() {
  //Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = false;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  //Initialize Firebase Analytics
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sortika',
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      routes: {
        '/': (context) => OnBoarding(),
        //Authentication Screens
        '/login': (context) => LoginScreen(),
        '/registration': (context) => RegistrationScreen(),
        '/password-reset': (context) => PasswordResetScreen(),
        //Pre-Login Screens
        '/achieve-pref': (context) => AchievePreference(),
        //Home Screens
        '/home': (context) => Home(),
        '/profile': (context) => ProfilePage(),
        '/create-goal': (context) => CreateGoal(),
        '/deposit': (context) => Deposit(),
        '/rate': (context) => Rate(),
        '/help': (context) => Help(),
        '/settings': (context) => Settings(),
        '/edit-goal': (context) => EditGoal(),
        '/borrow': (context) => BorrowAll(),
        '/edit-group': (context) => EditGroup(),
        '/pay-loan': (context) => PayLoan(),
        '/update-loan': (context) => UpdateLoan(),
        '/notifications': (context) => NotificationsPage(),
        //Admin
        '/admin': (context) => AdminHome(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
