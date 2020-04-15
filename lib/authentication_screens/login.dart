import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/utilities/styles.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Form Key
  final _formKey = GlobalKey<FormState>();
  //Checkbox Value
  bool _rememberMe = false;

  //FocusNodes
  final focusPassword = FocusNode();

  //Identifiers
  String _email, _password;

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

//     Widget _loginEmail() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           'Email',
//           style: GoogleFonts.quicksand(
//               textStyle: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   letterSpacing: .2,
//                   fontWeight: FontWeight.bold)),
//         ),
//         SizedBox(
//           height: 10,
//         ),
//         TextFormField(
//           autofocus: false,
//           style: GoogleFonts.quicksand(
//               textStyle: TextStyle(color: Colors.white, fontSize: 18)),
//           decoration: InputDecoration(
//               errorStyle: GoogleFonts.quicksand(
//                 textStyle: TextStyle(color: Colors.white),
//               ),
//               enabledBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white)),
//               focusedBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white, width: 1.5)),
//               errorBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.red)),
// //              labelText: 'Please enter your email',
// //              labelStyle: GoogleFonts.quicksand(
// //                  textStyle: TextStyle(color: Colors.white)),
//               icon: Icon(
//                 Icons.email,
//                 color: Colors.white,
//               )),
//           keyboardType: TextInputType.emailAddress,
//           validator: (value) {
//             if (value.isEmpty) {
//               return 'Email is required';
//             }
//             return null;
//           },
//           onFieldSubmitted: (value) {
//             FocusScope.of(context).requestFocus(_focusPass);
//           },
//           textInputAction: TextInputAction.next,
//           onSaved: _emailHandler,
//         )
//       ],
//     );
//   }

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
          height: 20,
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

              return null;
            },
            textInputAction: TextInputAction.next,
            onSaved: _handleSubmittedEmail,
            decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.mail, color: Colors.white),
                hintText: 'Enter your email address',
                hintStyle: hintStyle))
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
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.lock, color: Colors.white),
                hintText: 'Enter your Password',
                hintStyle: hintStyle))
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
                  checkColor: Colors.blue,
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

  void _loginProcess() {
    //Validate Fields
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
    }
  }

  //LOGIN Button
  Widget _loginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5,
        onPressed: _loginProcess,
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: <Widget>[
            _backgroundColor(),
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
                      _checkBoxRemember(),
                      _loginBtn(),
                      _signInWith(),
                      _buildSocialBtnRow(),
                      _buildSignupBtn(),
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
