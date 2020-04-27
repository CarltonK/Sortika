import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/usermodel.dart';
import 'package:wealth/widgets/borrow_page.dart';
import 'package:wealth/widgets/group_savings.dart';
import 'package:wealth/widgets/investment_goal.dart';
import 'package:wealth/widgets/lend_page.dart';
import 'package:wealth/widgets/savings_goal.dart';

class AchievePreference extends StatefulWidget {
  @override
  _AchievePreferenceState createState() => _AchievePreferenceState();
}

class _AchievePreferenceState extends State<AchievePreference> {
  //PageView Controller
  final PageController _pageController = PageController(initialPage: 0);
  //Define number of screens
  final int _numPages = 2;
  //Placeholder for current page
  int _currentPage = 0;

  //Color Changer
  Color color = Colors.blue;

  //UID Placeholder
  static String uid;

  Firestore _firestore = Firestore.instance;

  TextStyle _subtitleStyle() {
    return GoogleFonts.muli(
        textStyle:
            TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 0.5));
  }

  //Final Dropdown item
  String goal;

  //Define Dropdown Menu Items
  List<DropdownMenuItem> items = [
    DropdownMenuItem(
      value: 'Borrow Money',
      child: Text(
        'Borrow Money',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'Lend Money',
      child: Text(
        'Lend Money',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'Save Money',
      child: Text(
        'Save Money',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'Invest Money',
      child: Text(
        'Invest Money',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'Group Savings',
      child: Text(
        'Group Savings',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    )
  ];

  //Page One
  Widget _pageOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Image(
            fit: BoxFit.fitHeight,
            image: AssetImage('assets/images/borrow.png'),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          'Tell us what you want to achieve with Sortika',
          textAlign: TextAlign.center,
          style: _subtitleStyle(),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 12),
          height: 60,
          child: DropdownButton(
            items: items,
            underline: Divider(
              color: Colors.transparent,
            ),
            value: goal,
            hint: Text(
              'Goal',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
            ),
            icon: Icon(
              CupertinoIcons.down_arrow,
              color: Colors.black,
            ),
            isExpanded: true,
            onChanged: (value) {
              setState(() {
                goal = value;
                //Change color according to value of goal
                if (value == 'Borrow Money') {
                  color = Colors.brown;
                }
                if (value == 'Lend Money') {
                  color = Color(0xFF73AEF5);
                }
                if (value == 'Save Money') {
                  color = Colors.green;
                }
                if (value == 'Invest Money') {
                  color = Colors.red[600];
                }
                if (value == 'Group Savings') {
                  color = Colors.purple;
                }
              });
            },
          ),
        )
      ],
    );
  }

  //Page Two
  //Determined by page one selection

  Widget _pageTwo() {
    return goal == 'Borrow Money'
        ? BorrowPage(uid: uid)
        : goal == 'Lend Money'
            ? LendPage(uid: uid)
            : goal == 'Save Money'
                ? SavingsGoal(uid: uid)
                : goal == 'Invest Money'
                    ? InvestmentGoal(uid: uid)
                    : GroupSavings(uid: uid);
  }

  Future _promptUserToSelectGoal() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              'Please select  a goal',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black)),
            ),
            message: Icon(
              Icons.warning,
              size: 50,
              color: Colors.red,
            ),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red)),
                )),
          );
        });
  }

  Future<User> _userSkips() async {
    //Retrieve USER DOC
    DocumentSnapshot userDoc =
        await _firestore.collection("users").document(uid).get();
    User user = User.fromJson(userDoc.data);
    return user;
  }

  Future _showUserProgress() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Logging you in for the first time...',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                SizedBox(
                  height: 10,
                ),
                SpinKitDualRing(
                  color: Colors.greenAccent[700],
                  size: 100,
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    //Retrieve UID
    uid = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: <Widget>[
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: double.infinity,
              width: double.infinity,
              color: color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(top: 30),
                    child: FlatButton(
                        onPressed: () {
                          // print('I want to skip and go home page');
                          //Show a dialog first
                          _showUserProgress();
                          //Takes you directly to home page
                          Timer(Duration(seconds: 3), () {
                            _userSkips().then((value) => Navigator.of(context)
                                .popAndPushNamed('/home', arguments: value));
                          });
                        },
                        child: Text(
                          'Skip',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600)),
                        )),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(30),
                      child: PageView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: <Widget>[
                          _pageOne(),
                          _pageTwo(),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      _currentPage + 2 != _numPages
                          ? Expanded(
                              child: Align(
                              alignment: FractionalOffset.bottomLeft,
                              child: FlatButton(
                                  onPressed: () {
                                    _pageController.previousPage(
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.ease);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10, top: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(CupertinoIcons.back,
                                            color: Colors.white),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text('Back',
                                            style: GoogleFonts.muli(
                                                textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w600))),
                                      ],
                                    ),
                                  )),
                            ))
                          : Text(''),
                      _currentPage != _numPages
                          ? Expanded(
                              child: Align(
                              alignment: FractionalOffset.bottomRight,
                              child: FlatButton(
                                  onPressed: () {
                                    //Page One. Goal must not be null
                                    if (_currentPage == 0) {
                                      if (goal == null) {
                                        // print('Please enter a goal');
                                        //Show a prompt
                                        _promptUserToSelectGoal();
                                      } else {
                                        _pageController.nextPage(
                                            duration:
                                                Duration(milliseconds: 500),
                                            curve: Curves.ease);
                                      }
                                    }
                                    //Page Two
                                    //Peer to Peer request, then create a loan fund goal
                                    if (_currentPage == 1) {
                                      //Show a dialog first
                                      _showUserProgress();
                                      //Fetch user data
                                      Timer(Duration(seconds: 3), () {
                                        _userSkips().then((value) {
                                          Navigator.of(context).popAndPushNamed(
                                              '/home',
                                              arguments: value);
                                        });
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10, top: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                            _currentPage != _numPages - 1
                                                ? 'Next'
                                                : 'Proceed',
                                            style: GoogleFonts.muli(
                                                textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w600))),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(CupertinoIcons.forward,
                                            color: Colors.white)
                                      ],
                                    ),
                                  )),
                            ))
                          : Text(''),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
