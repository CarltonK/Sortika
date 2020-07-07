import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wealth/authentication_screens/login.dart';
import 'package:wealth/authentication_screens/passwordreset.dart';
import 'package:wealth/authentication_screens/registration.dart';
import 'package:wealth/home_screens/borrowAll.dart';
import 'package:wealth/home_screens/editGoal.dart';
import 'package:wealth/home_screens/editGroup.dart';
import 'package:wealth/home_screens/home.dart';
import 'package:wealth/home_screens/payLoan.dart';
import 'package:wealth/home_screens/profile.dart';
import 'package:wealth/home_screens/settings.dart';
import 'package:wealth/home_screens/updateLoan.dart';
import 'package:wealth/onboarding.dart';
import 'package:wealth/pre_login/achieve_preference.dart';
import 'package:wealth/admin/admin.dart';
import 'package:wealth/home_screens/reviseLoan.dart';
import 'package:wealth/enums/connectivityStatus.dart';
import 'package:wealth/services/connectivity_service.dart';

void main() {
  Crashlytics.instance.enableInDevMode = false;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<ConnectivityStatus>(
      builder: (context) => ConnectivityService().connectionStreamController,
      child: MaterialApp(
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
          '/settings': (context) => Settings(),
          '/edit-goal': (context) => EditGoal(),
          '/borrow': (context) => BorrowAll(),
          '/edit-group': (context) => EditGroup(),
          '/pay-loan': (context) => PayLoan(),
          '/update-loan': (context) => UpdateLoan(),
          '/negotiate': (context) => ReviseLoan(),
          //Admin
          '/admin': (context) => AdminHome(),
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}
