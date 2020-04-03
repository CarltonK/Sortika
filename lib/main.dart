import 'package:flutter/material.dart';
import 'package:wealth/authentication_screens/login.dart';
import 'package:wealth/authentication_screens/passwordreset.dart';
import 'package:wealth/authentication_screens/registration.dart';
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
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
