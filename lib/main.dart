import 'package:flutter/material.dart';
import 'package:wealth/authentication_screens/login.dart';
import 'package:wealth/authentication_screens/passwordreset.dart';
import 'package:wealth/authentication_screens/registration.dart';
import 'package:wealth/home_screens/create_goal.dart';
import 'package:wealth/home_screens/deposit.dart';
import 'package:wealth/home_screens/home.dart';
import 'package:wealth/home_screens/profile.dart';
import 'package:wealth/home_screens/rate.dart';
import 'package:wealth/onboarding.dart';
import 'package:wealth/pre_login/achieve_preference.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sortika',
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        //On Boarding Page
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
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
