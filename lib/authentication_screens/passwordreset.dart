import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';
import 'package:wealth/api/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:wealth/models/usermodel.dart';
import 'dart:async';

class PasswordResetScreen extends StatefulWidget {
  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  //Form Key
  final _formKey = GlobalKey<FormState>();
  //Identifiers
  String _email;

  //Authentication
  bool isLoading = false;
  dynamic result;
  bool callResponse = false;
  AuthService authService = AuthService();

  //Handle Email Input
  void _handleSubmittedEmail(String value) {
    _email = value.trim();
    print('Email: ' + _email);
  }

  //Phone Widget
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
              FocusScope.of(context).unfocus();
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
                hintText: 'Enter your Email address',
                hintStyle: hintStyle))
      ],
    );
  }

  Future<bool> serverCall(User user) async {
    result = await authService.resetPass(user);
    print('This is the result: $result');

    if (result == "Please register first") {
      callResponse = false;
      return false;
    } else if (result == "Invalid Email. Please enter the correct email") {
      callResponse = false;
      return false;
    } else {
      callResponse = true;
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

  void _resetProcess() {
    //Validate Fields
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      //Create an instance of a user
      User user = new User(
        email: _email,
      );

      //Show Progress Dialog
      setState(() {
        isLoading = true;
      });

      serverCall(user).whenComplete(() {
          //Disable the circular progress dialog
          setState(() {
            isLoading = false;
          });
          FocusScope.of(context).unfocus();
        if (callResponse) {
          print('Successful response $result');

          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return CupertinoActionSheet(
                title: Text(
                  'Your request has been received',
                  style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black,
                  )),
                ),
                message: Text(
                  'A password reset link has been sent to your email',
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
          //Timed Function
          Timer(Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });
          Timer(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
        } else {
          print('Failed response: $result');
          //Show an action sheet with result
          showErrorSheet(result);
        }
      }).catchError((error) {
        print('This is the error $error');
        FocusScope.of(context).unfocus();
        //Disable the circular progress dialog
        setState(() {
          isLoading = false;
        });

        //Show an action sheet with error
        showErrorSheet(error);
      });
    }
  }

  //Reset Button
  Widget _resetBtn() {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
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
              onPressed: _resetProcess,
              padding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: Colors.white,
              child: Text(
                'RESET',
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
                        'Password Reset',
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
                      _resetBtn()
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
