import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/models/loanModel.dart';
import 'package:wealth/authentication_screens/login.dart';
import 'package:wealth/home_screens/budgetCalc.dart';
import 'package:wealth/home_screens/financialRatios.dart';
import 'package:wealth/home_screens/insights.dart';
import 'package:wealth/home_screens/sortikaLottery.dart';
import 'package:wealth/home_screens/sortikaSavings.dart';
import 'package:wealth/models/goalmodel.dart';
import 'package:wealth/models/usermodel.dart';
import 'package:wealth/widgets/group_savings_colored.dart';
import 'package:wealth/widgets/investment_colored.dart';
import 'package:wealth/widgets/my_groups.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth/widgets/portfolio.dart';
import 'package:wealth/widgets/savings_colored.dart';

final menuLabelStyle = GoogleFonts.muli(
    textStyle: TextStyle(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  //Authentication
  AuthService authService = AuthService();

  static String uid;
  User userData;

  bool isCollapsed = true;
  double screenWidth, screenHeight;
  //Animation Duration
  final Duration duration = const Duration(milliseconds: 200);
  static String dp;

  //Controllers
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _menuScaleAnimation;
  Animation<Offset> _slideAnimation;

  final Firestore _firestore = Firestore.instance;

  //Saved amount
  double saved = 2000;
  //String page Selection
  String _pageSelection = 'main';

  //PageView Controller
  final PageController _pageController = PageController(initialPage: 0);
  //Define number of screens
  final int _numPages = 2;
  final int _numPlannerPages = 3;
  //Placeholder for current page
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  List<Widget> _buildPlannerPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPlannerPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  //Page Indicator i.e Slider
  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: 8,
      width: isActive ? 24 : 16,
      decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.lightBlue[100],
          borderRadius: BorderRadius.circular(12)),
    );
  }

  //Custom AppBar
  // Widget _appBar() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     mainAxisSize: MainAxisSize.max,
  //     children: [
  //       IconButton(
  //         icon: Icon(Icons.subject),
  //         onPressed: () {
  //           setState(() {
  //             if (isCollapsed) {
  //               _controller.forward();
  //             } else {
  //               _controller.reverse();
  //             }
  //             isCollapsed = !isCollapsed;
  //           });
  //         },
  //       ),
  //       Text(
  //         'Sortika',
  //         style: GoogleFonts.muli(
  //             textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
  //       ),
  //       IconButton(
  //           icon: Icon(Icons.settings),
  //           onPressed: () => Navigator.of(context).pushNamed('/settings')),
  //     ],
  //   );
  // }

  //Goals Page
  Widget _goalsPage(context, String uid) {
    return AnimatedPositioned(
      duration: duration,
      curve: Curves.ease,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.4 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          elevation: 10,
          animationDuration: duration,
          borderRadius: isCollapsed
              ? BorderRadius.circular(0)
              : BorderRadius.circular(30),
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(
              top: 25,
            ),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                        icon: Icon(Icons.subject),
                        onPressed: () {
                          setState(() {
                            if (isCollapsed) {
                              _controller.forward();
                            } else {
                              _controller.reverse();
                            }
                            isCollapsed = !isCollapsed;
                          });
                        },
                      ),
                      Text(
                        'Home',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 24)),
                      ),
                      IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/settings')),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _introText(),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Here are your goals',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _goalDisplay(uid),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Activity',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: Icon(Icons.filter_list),
                          onPressed: () {
                            _filterActivity();
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _filterActivity() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
            'Filter',
            style: GoogleFonts.muli(textStyle: TextStyle(color: Colors.black)),
          ),
          actions: [
            CupertinoActionSheetAction(
              child: Text(
                '24 Hrs',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal)),
              ),
              onPressed: () {},
            ),
            CupertinoActionSheetAction(
              child: Text(
                '7 Days',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal)),
              ),
              onPressed: () {},
            ),
            CupertinoActionSheetAction(
              child: Text(
                '30 Days',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal)),
              ),
              onPressed: () {},
            ),
            CupertinoActionSheetAction(
              child: Text(
                'Lifetime',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal)),
              ),
              onPressed: () {},
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(
              'CANCEL',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.normal)),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }

  //Savings Target Breakdown
  Widget _targetSavings() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
            margin: EdgeInsets.symmetric(horizontal: 5),
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Daily',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.white)),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('15',
                    style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ))
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
            margin: EdgeInsets.symmetric(horizontal: 5),
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Weekly',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.white)),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('100',
                    style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ))
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
            margin: EdgeInsets.symmetric(horizontal: 5),
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Monthly',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.white)),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('434',
                    style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ))
              ],
            ),
          ),
        ),
      ],
    );
  }

  //This represents a single Goal on home page
  Widget _singleGoalWidget(DocumentSnapshot doc) {
    GoalModel model = GoalModel.fromJson(doc.data);

    //Create a map from which you can add as argument to pass into edit goal page
    Map<String, dynamic> editData = doc.data;
    //Add uid to this map
    editData["uid"] = uid;
    editData["docId"] = doc.documentID;

    //Date Parsing and Formatting
    Timestamp dateRetrieved = model.goalEndDate;
    var formatter = new DateFormat('d MMM y');
    String date = formatter.format(dateRetrieved.toDate());

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
            tileMode: TileMode.clamp,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.lightBlue[400], Colors.greenAccent[400]],
            stops: [0, 1.0]),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(20)),
                  color: Colors.white),
              child: Text(
                model.goalName == null
                    ? '${model.goalCategory}'
                    : '${model.goalName}',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context)
                  .pushNamed('/edit-goal', arguments: editData),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(20)),
                    color: Colors.transparent),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'You have saved ',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(color: Colors.white))),
                  TextSpan(
                      text: '${model.goalAmountSaved.toInt().toString()}',
                      style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )),
                ])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '0',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Slider(
                            value: model.goalAmountSaved,
                            min: 0,
                            max: model.goalAmount,
                            onChanged: (value) {}),
                      ),
                      Text(
                        '${model.goalAmount.toInt().toString()}',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(20)),
                  color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Allocation',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${model.goalAllocation.toInt().toString()} %',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                  color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Ends on',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '$date',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Future<User> _retrieveUser() async {
  //   if (uid != null) {
  //     var document = await _firestore.collection("users").document(uid).get();
  //     userData = User.fromJson(document.data);
  //     return userData;
  //   }
  //   return null;
  // }

  //Display Goals in horizontal scroll view
  Widget _goalDisplay(String uid) {
    return Container(
      height: 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection("users")
            .document(uid)
            .collection("goals")
            .orderBy("goalCreateDate")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return PageView(
              controller: PageController(viewportFraction: 0.8),
              scrollDirection: Axis.horizontal,
              pageSnapping: true,
              children: snapshot.data.documents
                  .map((map) => _singleGoalWidget(map))
                  .toList(),
            );
          }
          return SpinKitDoubleBounce(
            color: Colors.greenAccent[700],
            size: 100,
          );
        },
      ),
    );
  }

  //Introduction Text
  Widget _introText() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Jon',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 5,
          ),
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'We went ahead and setup for you a loan fund goal of  ',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(color: Colors.black))),
            TextSpan(
                text: '5200',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    decoration: TextDecoration.underline)),
          ])),
          SizedBox(
            height: 20,
          ),
          Text(
            'Savings targets',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 5,
          ),
          _targetSavings(),
        ],
      ),
    );
  }

  //Savings Page
  Widget _savingsPage(context) {
    return AnimatedPositioned(
      duration: duration,
      curve: Curves.ease,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.4 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          elevation: 10,
          animationDuration: duration,
          borderRadius: isCollapsed
              ? BorderRadius.circular(0)
              : BorderRadius.circular(30),
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(
              top: 25,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      icon: Icon(Icons.subject),
                      onPressed: () {
                        setState(() {
                          if (isCollapsed) {
                            _controller.forward();
                          } else {
                            _controller.reverse();
                          }
                          isCollapsed = !isCollapsed;
                        });
                      },
                    ),
                    Text(
                      'Savings',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 24)),
                    ),
                    IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/settings')),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: PageView(
                  controller: _pageController,
                  onPageChanged: (value) {
                    setState(() {
                      _currentPage = value;
                      _pageController.animateToPage(value,
                          duration: Duration(milliseconds: 100),
                          curve: Curves.ease);
                    });
                  },
                  children: [
                    Portfolio(),
                    SavingsColored(
                      uid: uid,
                    )
                  ],
                )),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Loans Page
  Widget _loansPage(context) {
    return AnimatedPositioned(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            elevation: 10,
            animationDuration: duration,
            borderRadius: isCollapsed
                ? BorderRadius.circular(0)
                : BorderRadius.circular(30),
            color: Colors.white,
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(
                top: 25,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                        icon: Icon(Icons.subject),
                        onPressed: () {
                          setState(() {
                            if (isCollapsed) {
                              _controller.forward();
                            } else {
                              _controller.reverse();
                            }
                            isCollapsed = !isCollapsed;
                          });
                        },
                      ),
                      Text(
                        'Loans',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 24)),
                      ),
                      IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/settings')),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Limits',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _loanLimits(),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Borrowing History',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection("loans")
                        .where("loanBorrower", isEqualTo: uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return PageView(
                          scrollDirection: Axis.horizontal,
                          controller: PageController(viewportFraction: 0.85),
                          children: snapshot.data.documents
                              .map((map) => _singleLoanTaken(map))
                              .toList(),
                        );
                      }
                      return SpinKitDoubleBounce(
                        color: Colors.greenAccent[700],
                        size: 100,
                      );
                    },
                  )),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Lending History',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection("loans")
                        .where("loanLenders", arrayContains: uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return PageView(
                          scrollDirection: Axis.horizontal,
                          controller: PageController(viewportFraction: 0.85),
                          children: snapshot.data.documents.map((map) {
                            if (map.data["loanBorrower"] == uid) {
                              String docId = map.documentID;
                              snapshot.data.documents.removeWhere(
                                  (element) => element.documentID == docId);
                              return Center(
                                child: Text(
                                  'You have not received any loan requests',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.muli(
                                      textStyle: TextStyle(fontSize: 16)),
                                ),
                              );
                            } else {
                              return _singleLoanGiven(map);
                            }
                          }).toList(),
                        );
                      }
                      return SpinKitDoubleBounce(
                        color: Colors.greenAccent[700],
                        size: 100,
                      );
                    },
                  ))
                ],
              ),
            ),
          ),
        ),
        curve: Curves.ease,
        top: 0,
        bottom: 0,
        left: isCollapsed ? 0 : 0.6 * screenWidth,
        right: isCollapsed ? 0 : -0.4 * screenWidth,
        duration: duration);
  }

  Widget _loanLimits() {
    return Card(
      elevation: 10,
      margin: EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.greenAccent[700], width: 1.5)),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Borrow',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(fontSize: 16, letterSpacing: 0.5)),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '5,000 KES',
                  style: GoogleFonts.muli(
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lend',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(fontSize: 16, letterSpacing: 0.5)),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '8,000 KES',
                  style: GoogleFonts.muli(
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _singleLoanTaken(DocumentSnapshot doc) {
    //Retrieve LoanModel from doc
    LoanModel model = LoanModel.fromJson(doc.data);

    //Placeholder Map to be passed to pay loan page
    Map<String, dynamic> loanData = doc.data;
    loanData["uid"] = uid;
    loanData["docId"] = doc.documentID;

    //Date Parsing and Formatting
    Timestamp dateRetrieved = model.loanEndDate;
    var formatter = new DateFormat('d MMM y');
    String date = formatter.format(dateRetrieved.toDate());

    double amount = model.loanAmountTaken;
    double interest = model.loanInterest;
    double totalAmount = (amount * (100 + interest)) / 100;

    loanData["totalAmount"] = totalAmount;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
            tileMode: TileMode.clamp,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.lightBlue[400], Colors.greenAccent[400]],
            stops: [0, 1.0]),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(20)),
                  color: Colors.white),
              child: Text(
                model.loanLenders.contains(uid) ? 'Self Loan' : 'Loan Fund',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context)
                  .pushNamed('/pay-loan', arguments: loanData),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(20)),
                    color: Colors.transparent),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'You have repaid ',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(color: Colors.white))),
                  TextSpan(
                      text: '${model.loanAmountRepaid.toInt().toString()}',
                      style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )),
                ])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '0',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Slider(
                            value: model.loanAmountRepaid,
                            min: 0,
                            max: double.parse(totalAmount.round().toString()),
                            onChanged: (value) {}),
                      ),
                      Text(
                        '${totalAmount.round().toString()}',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'You borrowed ',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(color: Colors.white))),
                  TextSpan(
                      text: '${model.loanAmountTaken.toInt().toString()}',
                      style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )),
                ]))
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                  color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Ends on',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '$date',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                  color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Interest',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${model.loanInterest.toString()} %',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future _loanAcceptance() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                EvilIcons.check,
                color: Colors.greenAccent[700],
                size: 50,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Loan + Interest Cover = XXX',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.black)),
              )
            ],
          ),
        );
      },
    );
  }

  Future _lendingOptions() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              'Loan Options',
              style:
                  GoogleFonts.muli(textStyle: TextStyle(color: Colors.black)),
            ),
            actions: [
              CupertinoActionSheetAction(
                  onPressed: () {
                    //Pop the Action Sheet First
                    Navigator.of(context).pop();

                    //Show an alert dialog with L+IC
                    _loanAcceptance();
                  },
                  child: Text(
                    'ACCEPT',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(fontWeight: FontWeight.bold)),
                  )),
              CupertinoActionSheetAction(
                  onPressed: () {
                    //Pop the Action Sheet First
                    Navigator.of(context).pop();

                    Navigator.of(context).pushNamed('/update-loan');
                  },
                  child: Text(
                    'UPDATE',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(fontWeight: FontWeight.bold)),
                  )),
            ],
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'REJECT',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red)),
                )),
          );
        });
  }

  Widget _singleLoanGiven(DocumentSnapshot doc) {
    //Retrieve LoanModel from doc
    LoanModel model = LoanModel.fromJson(doc.data);

    //Placeholder Map to be passed to pay loan page
    Map<String, dynamic> loanData = doc.data;
    loanData["uid"] = uid;
    loanData["docId"] = doc.documentID;

    //Date Parsing and Formatting
    Timestamp dateRetrieved = model.loanEndDate;
    var formatter = new DateFormat('d MMM y');
    String date = formatter.format(dateRetrieved.toDate());

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
            tileMode: TileMode.clamp,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.lightBlue[400], Colors.greenAccent[400]],
            stops: [0, 1.0]),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(20)),
                  color: Colors.white),
              child: Text(
                '${model.loanBorrower}',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                _lendingOptions();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(20)),
                    color: Colors.transparent),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'They have repaid ',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(color: Colors.white))),
                  TextSpan(
                      text: '${model.loanAmountRepaid.toInt().toString()}',
                      style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )),
                ])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '0',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Slider(
                            value: model.loanAmountRepaid,
                            min: 0,
                            max: model.loanAmountTaken,
                            onChanged: (value) {}),
                      ),
                      Text(
                        '${model.loanAmountTaken.toInt().toString()}',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                  color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Ends on',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '$date',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                  color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Interest',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${model.loanInterest.toString()}',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  //Wallet Page
  Widget _walletPage(context) {
    return AnimatedPositioned(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            elevation: 10,
            animationDuration: duration,
            borderRadius: isCollapsed
                ? BorderRadius.circular(0)
                : BorderRadius.circular(30),
            color: Colors.white,
            child: Container(
              padding: EdgeInsets.only(
                top: 25,
              ),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //App Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          icon: Icon(Icons.subject),
                          onPressed: () {
                            setState(() {
                              if (isCollapsed) {
                                _controller.forward();
                              } else {
                                _controller.reverse();
                              }
                              isCollapsed = !isCollapsed;
                            });
                          },
                        ),
                        Text(
                          'Wallet',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 24)),
                        ),
                        IconButton(
                            icon: Icon(Icons.settings), onPressed: () {}),
                      ],
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance',
                              style: GoogleFonts.muli(textStyle: TextStyle()),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              '1,200 KES',
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                            )
                          ],
                        )),
                    Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        elevation: 4,
                        child: ExpansionTile(
                          title: Text('Earnings',
                              style: GoogleFonts.muli(
                                textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green),
                              )),
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.grey[200],
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          child: Icon(
                                            Icons.arrow_upward,
                                            color: Colors.green,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: Colors.grey[50],
                                          ),
                                          padding: EdgeInsets.all(16),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Loan Fund',
                                                      style: GoogleFonts.muli(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    ),
                                                    Text(
                                                      '',
                                                      style: GoogleFonts.muli(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '2000 KES',
                                                      style: GoogleFonts.muli(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    ),
                                                    Text(
                                                      '23 Dec',
                                                      style: GoogleFonts.muli(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
                    Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        elevation: 4,
                        child: ExpansionTile(
                          title: Text(
                            'Withdrawals',
                            style: GoogleFonts.muli(
                                textStyle: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600)),
                          ),
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.grey[200],
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          child: Icon(
                                            Icons.arrow_downward,
                                            color: Colors.red,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: Colors.grey[50],
                                          ),
                                          padding: EdgeInsets.all(16),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'M-PESA',
                                                      style: GoogleFonts.muli(
                                                          textStyle: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    ),
                                                    Text(
                                                      '',
                                                      style: GoogleFonts.muli(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '2000 KES',
                                                      style: GoogleFonts.muli(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    ),
                                                    Text(
                                                      '23 Dec',
                                                      style: GoogleFonts.muli(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
        curve: Curves.ease,
        top: 0,
        bottom: 0,
        left: isCollapsed ? 0 : 0.6 * screenWidth,
        right: isCollapsed ? 0 : -0.4 * screenWidth,
        duration: duration);
  }

  Widget _groupsPage(context) {
    return AnimatedPositioned(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            elevation: 10,
            animationDuration: duration,
            borderRadius: isCollapsed
                ? BorderRadius.circular(0)
                : BorderRadius.circular(30),
            color: Colors.white,
            child: Container(
              padding: EdgeInsets.only(
                top: 25,
              ),
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                        icon: Icon(Icons.subject),
                        onPressed: () {
                          setState(() {
                            if (isCollapsed) {
                              _controller.forward();
                            } else {
                              _controller.reverse();
                            }
                            isCollapsed = !isCollapsed;
                          });
                        },
                      ),
                      Text(
                        'Groups',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 24)),
                      ),
                      IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/settings')),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: PageView(
                    controller: _pageController,
                    onPageChanged: (value) {
                      setState(() {
                        _currentPage = value;
                        _pageController.animateToPage(value,
                            duration: Duration(milliseconds: 100),
                            curve: Curves.ease);
                      });
                    },
                    children: [
                      MyGroups(uid: uid),
                      GroupSavingsColored(uid: uid)
                    ],
                  )),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicator(),
                  ),
                  SizedBox(
                    height: 5,
                  )
                ],
              ),
            ),
          ),
        ),
        curve: Curves.ease,
        top: 0,
        bottom: 0,
        left: isCollapsed ? 0 : 0.6 * screenWidth,
        right: isCollapsed ? 0 : -0.4 * screenWidth,
        duration: duration);
  }

  Widget _investmentPage(context) {
    return AnimatedPositioned(
      duration: duration,
      curve: Curves.ease,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.4 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          elevation: 10,
          animationDuration: duration,
          borderRadius: isCollapsed
              ? BorderRadius.circular(0)
              : BorderRadius.circular(30),
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(
              top: 25,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      icon: Icon(Icons.subject),
                      onPressed: () {
                        setState(() {
                          if (isCollapsed) {
                            _controller.forward();
                          } else {
                            _controller.reverse();
                          }
                          isCollapsed = !isCollapsed;
                        });
                      },
                    ),
                    Text(
                      'Investments',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 24)),
                    ),
                    IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/settings')),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: PageView(
                  controller: _pageController,
                  onPageChanged: (value) {
                    setState(() {
                      _currentPage = value;
                      _pageController.animateToPage(value,
                          duration: Duration(milliseconds: 100),
                          curve: Curves.ease);
                    });
                  },
                  children: [
                    Portfolio(),
                    InvestmentColored(
                      uid: uid,
                    )
                  ],
                )),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Planning Page
  Widget _plannerPage(context) {
    return AnimatedPositioned(
      duration: duration,
      curve: Curves.ease,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.4 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          elevation: 10,
          animationDuration: duration,
          borderRadius: isCollapsed
              ? BorderRadius.circular(0)
              : BorderRadius.circular(30),
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(
              top: 25,
            ),
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      icon: Icon(Icons.subject),
                      onPressed: () {
                        setState(() {
                          if (isCollapsed) {
                            _controller.forward();
                          } else {
                            _controller.reverse();
                          }
                          isCollapsed = !isCollapsed;
                        });
                      },
                    ),
                    Text(
                      'Planner',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 24)),
                    ),
                    IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/settings')),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: PageView(
                  controller: _pageController,
                  onPageChanged: (value) {
                    setState(() {
                      _currentPage = value;
                      _pageController.animateToPage(value,
                          duration: Duration(milliseconds: 100),
                          curve: Curves.ease);
                    });
                  },
                  children: [BudgetCalc(), Insights(), FinancialRatios()],
                )),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPlannerPageIndicator(),
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _promoPage(context) {
    return AnimatedPositioned(
      duration: duration,
      curve: Curves.ease,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.4 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          elevation: 10,
          animationDuration: duration,
          borderRadius: isCollapsed
              ? BorderRadius.circular(0)
              : BorderRadius.circular(30),
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(
              top: 25,
            ),
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      icon: Icon(Icons.subject),
                      onPressed: () {
                        setState(() {
                          if (isCollapsed) {
                            _controller.forward();
                          } else {
                            _controller.reverse();
                          }
                          isCollapsed = !isCollapsed;
                        });
                      },
                    ),
                    Text(
                      'Promotions',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 24)),
                    ),
                    IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/settings')),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: PageView(
                        controller: _pageController,
                        onPageChanged: (value) {
                          setState(() {
                            _currentPage = value;
                            _pageController.animateToPage(value,
                                duration: Duration(milliseconds: 100),
                                curve: Curves.ease);
                          });
                        },
                        children: [SortikaSavings(), SortikaLottery()])),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.6).animate(_controller);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _menuHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed('/profile', arguments: uid),
                child: CircleAvatar(
                  child: Icon(
                    Icons.person,
                    size: 40,
                  ),
                  radius: 40,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Jon Snow',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              )
            ],
          ),
          IconButton(
              icon: Icon(
                Icons.message,
                color: Colors.white,
                size: 35,
              ),
              onPressed: () =>
                  Navigator.of(context).pushNamed('/notifications'))
        ],
      ),
    );
  }

  Widget _menuFooter() {
    return Container(
      padding: const EdgeInsets.only(left: 16),
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            elevation: 10,
            color: Color(0xFF73AEF5),
            child: InkWell(
              splashColor: Colors.greenAccent[700],
              onTap: () {
                //Implement Firebase Dynamic Links Here
                //Else use share package
                try {
                  Share.share('Check out our website https://www.sortika.com');
                } catch (error) {
                  print('SHARE ERROR: $error');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Share',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300)),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Icon(Icons.share, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          Card(
            elevation: 10,
            color: Color(0xFF73AEF5),
            child: InkWell(
              splashColor: Colors.greenAccent[700],
              onTap: () => Navigator.of(context).pushNamed('/rate'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Rate',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300)),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Icon(Icons.rate_review, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          Card(
            elevation: 10,
            color: Color(0xFF73AEF5),
            child: InkWell(
              splashColor: Colors.greenAccent[700],
              onTap: () => Navigator.of(context).pushNamed('/help'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Help',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300)),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Icon(Icons.feedback, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          Card(
            elevation: 10,
            color: Color(0xFF73AEF5),
            child: InkWell(
              splashColor: Colors.greenAccent[700],
              onTap: () {
                showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text(
                          'Are you sure',
                          style: GoogleFonts.muli(textStyle: TextStyle()),
                        ),
                        actions: [
                          FlatButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await authService.logout();
                                Navigator.of(context).popAndPushNamed('/login');
                              },
                              child: Text(
                                'YES',
                                style: GoogleFonts.muli(
                                    textStyle: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold)),
                              )),
                          FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'NO',
                                style: GoogleFonts.muli(
                                    textStyle: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold)),
                              ))
                        ],
                      );
                    });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Exit',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300)),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Icon(Icons.exit_to_app, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Menu Items
  Widget _menu(context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _menuHeader(),
              Expanded(child: Container()),

              //Home Menu Item
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: InkWell(
                  splashColor: Colors.blueGrey,
                  onTap: () {
                    setState(() {
                      _pageSelection = 'main';
                      if (isCollapsed) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                      isCollapsed = !isCollapsed;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    color: Colors.transparent,
                    child: Text(
                      'Home',
                      style: menuLabelStyle,
                    ),
                  ),
                ),
              ),

              //Investments Menu Item
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: InkWell(
                  splashColor: Colors.blueGrey,
                  onTap: () {
                    setState(() {
                      _pageSelection = 'invest';
                      if (isCollapsed) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                      isCollapsed = !isCollapsed;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    color: Colors.transparent,
                    child: Text(
                      'Investments',
                      style: menuLabelStyle,
                    ),
                  ),
                ),
              ),

              //Savings Menu Item
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: InkWell(
                  splashColor: Colors.blueGrey,
                  onTap: () {
                    setState(() {
                      _pageSelection = 'save';
                      if (isCollapsed) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                      isCollapsed = !isCollapsed;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    color: Colors.transparent,
                    child: Text(
                      'Savings',
                      style: menuLabelStyle,
                    ),
                  ),
                ),
              ),

              //Groups Menu Item
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: InkWell(
                  splashColor: Colors.blueGrey,
                  onTap: () {
                    setState(() {
                      _pageSelection = 'group';
                      if (isCollapsed) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                      isCollapsed = !isCollapsed;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    color: Colors.transparent,
                    child: Text(
                      'Groups',
                      style: menuLabelStyle,
                    ),
                  ),
                ),
              ),

              //Loans Menu Item
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: InkWell(
                  splashColor: Colors.blueGrey,
                  onTap: () {
                    setState(() {
                      _pageSelection = 'loan';
                      if (isCollapsed) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                      isCollapsed = !isCollapsed;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    color: Colors.transparent,
                    child: Text(
                      'Loans',
                      style: menuLabelStyle,
                    ),
                  ),
                ),
              ),

              //Wallet Menu Item
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: InkWell(
                  splashColor: Colors.blueGrey,
                  onTap: () {
                    setState(() {
                      _pageSelection = 'wallet';
                      if (isCollapsed) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                      isCollapsed = !isCollapsed;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    color: Colors.transparent,
                    child: Text(
                      'Wallet',
                      style: menuLabelStyle,
                    ),
                  ),
                ),
              ),

              //Planner Menu Item
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: InkWell(
                  splashColor: Colors.blueGrey,
                  onTap: () {
                    setState(() {
                      _pageSelection = 'plan';
                      if (isCollapsed) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                      isCollapsed = !isCollapsed;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    color: Colors.transparent,
                    child: Text(
                      'Planner',
                      style: menuLabelStyle,
                    ),
                  ),
                ),
              ),

              //Promotions and Incentives Menu Item
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: InkWell(
                  splashColor: Colors.blueGrey,
                  onTap: () {
                    setState(() {
                      _pageSelection = 'promo';
                      if (isCollapsed) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                      isCollapsed = !isCollapsed;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    color: Colors.transparent,
                    child: Text(
                      'Promotions',
                      style: menuLabelStyle,
                    ),
                  ),
                ),
              ),
              Expanded(child: Container()),
              _menuFooter()
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //Get the size of the screen
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    //Retrieve the uid
    uid = ModalRoute.of(context).settings.arguments;
    print('Retrieved UID: $uid');

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isCollapsed) {
                      _controller.forward();
                    } else {
                      _controller.reverse();
                    }
                    isCollapsed = !isCollapsed;
                  });
                },
                child: Container(
                  height: screenHeight,
                  width: screenWidth,
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
              ),
              _menu(context),
              _pageSelection == 'main'
                  ? _goalsPage(context, uid)
                  : _pageSelection == 'invest'
                      ? _investmentPage(context)
                      : _pageSelection == 'save'
                          ? _savingsPage(context)
                          : _pageSelection == 'group'
                              ? _groupsPage(context)
                              : _pageSelection == 'loan'
                                  ? _loansPage(context)
                                  : _pageSelection == 'wallet'
                                      ? _walletPage(context)
                                      : _pageSelection == 'plan'
                                          ? _plannerPage(context)
                                          : _promoPage(context)
            ],
          ),
          value: SystemUiOverlayStyle.light),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) {
                return CupertinoActionSheet(
                  actions: [
                    CupertinoActionSheetAction(
                        onPressed: () {
                          //Pop the dialog first then open page
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed('/borrow', arguments: uid);
                        },
                        child: Text(
                          'Borrow',
                          style: GoogleFonts.muli(textStyle: TextStyle()),
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          //Pop the dialog first then open page
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed('/deposit');
                        },
                        child: Text(
                          'Deposit',
                          style: GoogleFonts.muli(textStyle: TextStyle()),
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          //Pop the dialog first then open page
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed('/create-goal', arguments: uid);
                        },
                        child: Text(
                          'Create a goal',
                          style: GoogleFonts.muli(textStyle: TextStyle()),
                        )),
                  ],
                );
              });
        },
        splashColor: Colors.blue,
        child: Icon(Icons.add),
        backgroundColor: Colors.greenAccent[700],
      ),
    );
  }
}
