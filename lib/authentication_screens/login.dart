import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Checkbox Value
  bool _rememberMe = false;

  //FocusNodes
  final focusPassword = FocusNode();

  //Identifiers
  String _phone, _password;

  //Handle Phone Input
  void _handleSubmittedPhone(String value) {
    _phone = value;
    print('Phone: ' + _phone);
  }

  //Handle Password Input
  void _handleSubmittedPassword(String password) {
    _password = password;
    print('Password: ' + _password);
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
          height: 20,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: boxDecorationStyle,
          height: 60,
          child: TextFormField(
              keyboardType: TextInputType.phone,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.white,
              )),
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(focusPassword);
              },
              textInputAction: TextInputAction.next,
              onSaved: _handleSubmittedPhone,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.phone, color: Colors.white),
                  hintText: 'Enter your Phone Number',
                  hintStyle: hintStyle)),
        )
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
          height: 20,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: boxDecorationStyle,
          height: 60,
          child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.white,
              )),
              onFieldSubmitted: (value) {
                FocusScope.of(context).unfocus();
              },
              onSaved: _handleSubmittedPassword,
              focusNode: focusPassword,
              obscureText: true,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                  hintText: 'Enter your Password',
                  hintStyle: hintStyle)),
        )
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

  //Remember Me Checkbox
  Widget _checkBoxRemember() {
    return Container(
      height: 20,
      child: Row(
        children: <Widget>[
          Theme(
              data: ThemeData(unselectedWidgetColor: Colors.white),
              child: Checkbox(
                  value: _rememberMe,
                  checkColor: Colors.greenAccent[700],
                  activeColor: Colors.white,
                  onChanged: (bool value) {
                    setState(() {
                      _rememberMe = value;
                    });
                  })),
          Text(
            'Remember me',
            style: labelStyle,
          )
        ],
      ),
    );
  }

  //LOGIN Button
  Widget _loginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5,
        onPressed: () {
          Navigator.of(context).pushNamed('/home');
        },
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.white,
        child: Text(
          'LOGIN',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
                  letterSpacing: 1.5,
                  color: Color(0xFF527DAA),
                  fontSize: 18,
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

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
            () {},
            AssetImage(
              'assets/logos/facebook.jpg',
            ),
          ),
          _buildSocialBtn(
            () {},
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
              text: 'Don\'t have an Account? ',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              )),
            ),
            TextSpan(
              text: 'Sign Up',
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

    focusPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: <Widget>[
            Container(
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
            ),
            Container(
              height: double.infinity,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 100),
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
                    _phoneTF(),
                    SizedBox(
                      height: 30,
                    ),
                    _passwordTF(),
                    _forgotPasswordBtn(),
                    _checkBoxRemember(),
                    _loginBtn(),
                    _signInWith(),
                    _buildSocialBtnRow(),
                    _buildSignupBtn(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
