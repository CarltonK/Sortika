import 'dart:async';
import 'package:wealth/analytics/analytics_funnels.dart';
import 'package:wealth/widgets/networkSensitive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/models/usermodel.dart';
import 'package:wealth/utilities/styles.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AnalyticsFunnel funnel = AnalyticsFunnel();
  //Form Key
  final _formKey = GlobalKey<FormState>();

  //Firestore
  Firestore _firestore = Firestore.instance;

  //FocusNodes
  final focusPassword = FocusNode();

  //Identifiers
  String _email, _password;

  //Authentication
  bool isLoading = false;
  dynamic result;
  AuthService authService = AuthService();

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
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(focusPassword);
            },
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
                prefixIcon: Icon(Icons.mail, color: Colors.white),
                labelText: 'Enter your email address',
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
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.white,
            )),
            onFieldSubmitted: (value) {
              FocusScope.of(context).unfocus();
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
            textInputAction: TextInputAction.done,
            onSaved: _handleSubmittedPassword,
            focusNode: focusPassword,
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
                labelStyle: hintStyle))
      ],
    );
  }

  //Forgot Password Widget
  Widget _forgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
          onPressed: () => Navigator.of(context).pushNamed('/password-reset'),
          child: Text(
            'Forgot Password?',
            style: labelStyle,
          )),
    );
  }

  //LOGIN Button
  Widget _loginBtn() {
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
              onPressed: _loginProcess,
              padding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: Colors.white,
              child: Text(
                'LOGIN',
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

  //Sign In With
  Widget _signInWith() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: GoogleFonts.muli(
              textStyle:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
        ),
        SizedBox(height: 20.0),
        Text(
          'Sign in with',
          style: labelStyle,
        )
      ],
    );
  }

  //Social Buttons
  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  _googleBtnPressed() {
    authService.signInWithGoogle().then((value) async {
      print('Google Press Value -> $value');
      if (value != null) {
        final String uid = value.uid;
        await funnel.logLogin();

        //Retrieve USER DOC
        await _firestore
            .collection("users")
            .document(uid)
            .get()
            .then((document) async {
          User user = User.fromJson(document.data);

          if (user.designation == 'Admin') {
            Timer(Duration(milliseconds: 500), () {
              Navigator.of(context)
                  .pushReplacementNamed('/admin', arguments: user);
            });
          } else {
            //Try save credentials using shared preferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('uid', user.uid);

            Timer(Duration(milliseconds: 500), () {
              Navigator.of(context)
                  .pushReplacementNamed('/home', arguments: user);
            });
          }
        });
      }
    }).catchError((error) => showErrorSheet(error.toString()));
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
            () {
              showErrorSheet('Coming soon');
            },
            AssetImage(
              'assets/logos/facebook.jpg',
            ),
          ),
          _buildSocialBtn(
            _googleBtnPressed,
            AssetImage(
              'assets/logos/google.png',
            ),
          ),
        ],
      ),
    );
  }

  //Sign Up Button
  Widget _buildSignupBtn() {
    return FlatButton(
      onPressed: () => Navigator.of(context).pushNamed('/registration'),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Create Your Sortika Account',
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
    focusPassword.dispose();
    super.dispose();
  }

  Widget _backgroundColor() {
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

  Future<bool> serverCall(User user) async {
    result = await authService.signInEmailPass(user);
    print('This is the result: $result');

    if (result == 'Invalid credentials. Please try again') {
      return false;
    } else if (result == "The email format entered is invalid") {
      return false;
    } else if (result == "Please register first") {
      return false;
    } else if (result == "Your account has been disabled") {
      return false;
    } else if (result == "Too many requests. Please try again in 2 minutes") {
      return false;
    } else if (result ==
        "Please verify your email before signing in. We sent you an email earlier") {
      return false;
    } else {
      return true;
    }
  }

  Future showErrorSheet(String message) {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
            title: Text(
              message,
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
                  FocusScope.of(context).unfocus();
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

  Future showSuccessSheet() {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            'Welcome',
            style: GoogleFonts.quicksand(
                textStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.black,
            )),
          ),
          message: Center(
            child: LinearProgressIndicator(
              backgroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }

  void _loginProcess() async {
    //Validate Fields
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      User user = new User(email: _email, password: _password);

      setState(() {
        isLoading = true;
      });

      serverCall(user).then((value) async {
        print('Server Call Response: $value');
        //Disable the circular progress dialog
        setState(() {
          isLoading = false;
        });

        //Disable the keyboard from showing again
        FocusScope.of(context).unfocus();
        if (value) {
          //print('Successful response ${result}');
          showSuccessSheet();

          //Retrieve UID
          final String uid = result.uid;

          await funnel.logLogin();

          //Retrieve USER DOC
          await _firestore
              .collection("users")
              .document(uid)
              .get()
              .then((document) async {
            User user = User.fromJson(document.data);

            if (user.designation == 'Admin') {
              Timer(Duration(seconds: 1), () {
                Navigator.of(context).pop();
              });

              Timer(Duration(milliseconds: 1200), () {
                Navigator.of(context)
                    .pushReplacementNamed('/admin', arguments: user);
              });
            } else {
              //Try save credentials using shared preferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('uid', user.uid);

              Timer(Duration(seconds: 1), () {
                Navigator.of(context).pop();
              });

              Timer(Duration(milliseconds: 1200), () {
                Navigator.of(context)
                    .pushReplacementNamed('/home', arguments: user);
              });
            }
          }).catchError((error) {
            print('This is the error $error');
            //Show an action sheet with error
            showErrorSheet(error.toString());
          });
        } else {
          //print('Failed response: ${result}');
          //Show an action sheet with result
          showErrorSheet(result);
        }
      }).catchError((error) {
        print('This is the error $error');
        //Disable the circular progress dialog
        setState(() {
          isLoading = false;
        });

        //Disable the keyboard from showing again
        FocusScope.of(context).unfocus();

        //Show an action sheet with error
        showErrorSheet(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: <Widget>[
            _backgroundColor(),
            NetworkSensor(
              child: Container(
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
                          'Welcome',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        _emailTF(),
                        SizedBox(
                          height: 30,
                        ),
                        _passwordTF(),
                        _forgotPasswordBtn(),
                        _loginBtn(),
                        _buildSignupBtn(),
                        _signInWith(),
                        _buildSocialBtnRow(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
