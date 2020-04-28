import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/goalmodel.dart';
import 'package:wealth/models/usermodel.dart';
import 'package:wealth/utilities/styles.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  //Form Key
  final _formKey = GlobalKey<FormState>();
  //FocusNodes
  final focusPhone = FocusNode();
  final focusEmail = FocusNode();
  final focusPassword = FocusNode();
  final focusConfirmPassword = FocusNode();

  //Password comparison
  final TextEditingController _passwording = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  //Identifiers
  String _names, _phone, _email, _password, _confirmpassword;

  //Firebase
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final Firestore _fireStore = Firestore.instance;

  //Authentication
  bool isLoading = false;
  dynamic result;
  bool callResponse = false;
  AuthService authService = AuthService();

  //Handle Name Input
  void _handleSubmittedName(String value) {
    _names = value.trim();
    print('Full Name: ' + _names);
  }

  //Handle Phone Input
  void _handleSubmittedPhone(String value) {
    _phone = value.trim();
    print('Phone: ' + _phone);
  }

  //Handle Phone Input
  void _handleSubmittedEmail(String value) {
    _email = value.trim();
    print('Email: ' + _email);
  }

  //Handle Password Input
  void _handleSubmittedPassword(String value) {
    _password = value.trim();
    print('Password: ' + _password);
  }

  //Handle Confirm Password Input
  void _handleSubmittedConfirmPassword(String value) {
    _confirmpassword = value.trim();
    print('Confirm Password: ' + _confirmpassword);
  }

  //Full Names Widget
  Widget _namesTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Full Name',
          style: labelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.text,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.white,
            )),
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(focusPhone);
            },
            validator: (value) {
              //Check if full name is available
              if (value.isEmpty) {
                return 'Full Name is required';
              }

              //Check if a space is available
              if (!value.contains(' ')) {
                return 'Please separate your individual names with a space';
              }

              return null;
            },
            textInputAction: TextInputAction.next,
            onSaved: _handleSubmittedName,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon: Icon(Icons.person, color: Colors.white),
                labelText: 'Enter your Full Name',
                labelStyle: hintStyle))
      ],
    );
  }

  //Phone Widget
  Widget _phoneTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Phone',
          style: labelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.white,
            )),
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(focusEmail);
            },
            validator: (value) {
              //Check if phone is available
              if (value.isEmpty) {
                return 'Phone number is required';
              }

              //Check if phone number has 10 digits
              if (value.length != 10) {
                return 'Phone number should be 10 digits';
              }

              //Check if phone number starts with 07
              if (!value.startsWith('07')) {
                return 'Phone number should start with 07';
              }

              return null;
            },
            focusNode: focusPhone,
            textInputAction: TextInputAction.next,
            onSaved: _handleSubmittedPhone,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon: Icon(Icons.phone, color: Colors.white),
                labelText: 'Enter your Phone Number',
                labelStyle: hintStyle))
      ],
    );
  }

  //Email Widget
  Widget _emailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: labelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.white,
            )),
            validator: (value) {
              //Check if email is empty
              if (value.isEmpty) {
                return 'Email is required';
              }

              //Check if @ is in email
              if (!value.contains('@')) {
                return 'Email format is invalid. @ is missing';
              }

              //Check if domain is available
              if (!value.contains('.')) {
                return 'Domain is required e.g gmail.com';
              }

              return null;
            },
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(focusPassword);
            },
            focusNode: focusEmail,
            textInputAction: TextInputAction.next,
            onSaved: _handleSubmittedEmail,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon: Icon(Icons.email, color: Colors.white),
                labelText: 'Enter your Email',
                labelStyle: hintStyle))
      ],
    );
  }

  //Password Widget
  Widget _passwordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: labelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            controller: _passwording,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.white,
            )),
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(focusConfirmPassword);
            },
            validator: (value) {
              //Check if password is empty
              if (value.isEmpty) {
                return 'Password is required';
              }

              //Check if password has 7 or more characters
              if (value.length < 7) {
                return 'A strong password should be more than 7 characters';
              }

              return null;
            },
            onSaved: _handleSubmittedPassword,
            focusNode: focusPassword,
            textInputAction: TextInputAction.next,
            obscureText: true,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon: Icon(Icons.lock, color: Colors.white),
                labelText: 'Enter your Password',
                labelStyle: hintStyle,
                helperText:
                    'A strong password should be more than 7 characters.\nIt should have a mixture of lower case and upper case characters,\nnumbers and symbols.',
                helperStyle: hintStyle))
      ],
    );
  }

  //Confirm Password Widget
  Widget _confirmPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Confirm Password',
          style: labelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            autovalidate: true,
            controller: _confirmPass,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.white,
            )),
            onFieldSubmitted: (value) {
              FocusScope.of(context).unfocus();
            },
            validator: (value) {
              //Check if passwords match
              if (value != _passwording.text) {
                return 'Passwords do not match';
              }

              // //Check if password is empty
              // if (value.isEmpty) {
              //   return 'Password confirmation is required';
              // }

              // //Check if password has 7 or more characters
              // if (value.length < 7) {
              //   return 'A strong password should be more than 7 characters';
              // }

              return null;
            },
            onSaved: _handleSubmittedConfirmPassword,
            focusNode: focusConfirmPassword,
            obscureText: true,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon: Icon(Icons.lock, color: Colors.white),
                hintText: 'Enter your Password again',
                hintStyle: hintStyle))
      ],
    );
  }

  //Authentication Service
  Future<bool> serverCall(User user) async {
    result = await authService.createUserEmailPass(user);
    print('This is the result: $result');

    if (result == 'Your password is weak. Please choose another') {
      callResponse = false;
      return false;
    } else if (result == "The email format entered is invalid") {
      callResponse = false;
      return false;
    } else if (result == "An account with the same email exists") {
      callResponse = false;
      return false;
    } else if (result == null) {
      result = "Please check your internet connection";
      callResponse = false;
      return false;
    } else {
      callResponse = true;
      return true;
    }
  }

  //Return user data
  Future goToNextPage(String uid) async {
    /*
    Before we go to the next page we need to auto create a loan fund goal
    */
    //This is the name of the collection we will be reading
    final String _collectionUpper = 'users';
    final String _collectionLower = 'goals';
    var document = _fireStore.collection(_collectionUpper).document(uid);

    //Loan Fund Goal ends in one year
    DateTime rightNow = DateTime.now();
    DateTime oneYearFromNow = rightNow.add(Duration(days: 365));

    //Create a goals collection and add the loan fund goal
    GoalModel goalModel = new GoalModel(
        goalCategory: 'Loan Fund',
        goalAllocation: 100,
        goalAmount: 5200,
        uid: uid,
        goalAmountSaved: 0,
        goalCreateDate: Timestamp.fromDate(rightNow),
        goalEndDate: Timestamp.fromDate(oneYearFromNow),
        isGoalDeletable: false);

    //Create an activity
    ActivityModel userRegActivity = new ActivityModel(
        activity: 'A Loan Fund Goal was autocreated for you',
        activityDate: Timestamp.fromDate(rightNow));
    await authService.postActivity(uid, userRegActivity);

    //Save goal to goals subcollection
    document
        .collection(_collectionLower)
        .document()
        .setData(goalModel.toJson())
        .whenComplete(() {
      Navigator.of(context)
          .pushReplacementNamed('/achieve-pref', arguments: uid);
    });
  }

  void _registerProcess() async {
    //Validate Fields
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      //Create an FCM Token
      String token = await _fcm.getToken();

      //Create an instance of a user
      User user = new User(
          fullName: _names,
          phone: _phone,
          email: _email,
          password: _password,
          registerDate: Timestamp.fromDate(DateTime.now()),
          token: token,
          platform: Platform.operatingSystem,
          dailyTarget: 0,
          weeklyTarget: 0,
          monthlyTarget: 0);

      //Show Progress Dialog
      setState(() {
        isLoading = true;
      });

      serverCall(user).whenComplete(() {
        if (callResponse) {
          // print('Successful response $result');
          //Show a welcome message
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return CupertinoActionSheet(
                title: Text(
                  'Thank you for joining us ${user.fullName.split(' ')[0]}',
                  style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black,
                  )),
                ),
              );
            },
          );

          //Disable the circular progress dialog
          setState(() {
            isLoading = false;
          });

          //Disable the keyboard from showing again
          FocusScope.of(context).unfocus();

          //Timed Function
          Timer(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });

          //Take user to next page to complete profile
          Timer(Duration(milliseconds: 2200), () {
            goToNextPage(authService.currentUser.uid);
          });
        } else {
          // print('Failed response: $result');

          //Disable the circular progress dialog
          setState(() {
            isLoading = false;
          });

          //Disable the keyboard from showing again
          FocusScope.of(context).unfocus();

          //Show an action sheet with result
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return CupertinoActionSheet(
                  title: Text(
                    '$result',
                    style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black,
                    )),
                  ),
                  cancelButton: CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.red,
                                fontSize: 25,
                                fontWeight: FontWeight.bold)),
                      )));
            },
          );
        }
      }).catchError((error) {
        // print('This is the error $error');

        //Disable the circular progress dialog
        setState(() {
          isLoading = false;
        });

        //Disable the keyboard from showing again
        FocusScope.of(context).unfocus();

        //Show an action sheet with error
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
                title: Text(
                  '$error',
                  style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black,
                  )),
                ),
                cancelButton: CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'CANCEL',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 25,
                              fontWeight: FontWeight.bold)),
                    )));
          },
        );
      });
    }
  }

  //Register Button
  Widget _registerBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.red,
                strokeWidth: 3,
              ),
            )
          : RaisedButton(
              elevation: 5,
              onPressed: _registerProcess,
              padding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: Colors.white,
              child: Text(
                'REGISTER',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        letterSpacing: 1.5,
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ),
    );
  }

  //Sign Up Button
  Widget _buildSignInBtn() {
    return FlatButton(
      onPressed: () => Navigator.of(context).pop(),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Already have an account? ',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              )),
            ),
            TextSpan(
              text: 'Sign In',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose FocusNodes
    super.dispose();
    focusPhone.dispose();
    focusEmail.dispose();
    focusPassword.dispose();
    focusConfirmPassword.dispose();
    //Dispose the TextEditingControllers
    _passwording.dispose();
    _confirmPass.dispose();
  }

  Widget _background() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color(0xFF73AEF5),
            Color(0xFF61A4F1),
            Color(0xFF478DE0),
            Color(0xFF398AE5),
          ],
              stops: [
            0.1,
            0.4,
            0.7,
            0.9
          ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: <Widget>[
            _background(),
            Container(
              height: double.infinity,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Create Account',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      _namesTF(),
                      SizedBox(
                        height: 30,
                      ),
                      _phoneTF(),
                      SizedBox(
                        height: 30,
                      ),
                      _emailTF(),
                      SizedBox(
                        height: 30,
                      ),
                      _passwordTF(),
                      SizedBox(
                        height: 30,
                      ),
                      _confirmPasswordTF(),
                      _registerBtn(),
                      _buildSignInBtn()
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
