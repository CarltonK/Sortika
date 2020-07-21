import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:sms/sms.dart';
import 'package:wealth/analytics/analytics_funnels.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/global/warningMessage.dart';
import 'package:wealth/home_screens/autoCreateHolder.dart';
import 'package:wealth/home_screens/budgetCalc.dart';
import 'package:wealth/home_screens/create_goal.dart';
import 'package:wealth/home_screens/deposit.dart';
import 'package:wealth/home_screens/financialRatios.dart';
import 'package:wealth/home_screens/help.dart';
import 'package:wealth/home_screens/insights.dart';
import 'package:wealth/home_screens/notifications.dart';
import 'package:wealth/home_screens/rate.dart';
import 'package:wealth/home_screens/sortikaLottery.dart';
import 'package:wealth/home_screens/sortikaSavings.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/goalmodel.dart';
import 'package:wealth/models/groupModel.dart';
import 'package:wealth/models/loanModel.dart';
import 'package:wealth/models/usermodel.dart';
import 'package:wealth/widgets/investmentPortfolio.dart';
import 'package:wealth/widgets/my_groups.dart';
import 'package:wealth/widgets/portfolio.dart';
import 'package:wealth/global/errorMessage.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/widgets/networkSensitive.dart';
import 'package:http/http.dart' as http;

final menuLabelStyle = GoogleFonts.muli(
    textStyle: TextStyle(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  //Services
  // static const MethodChannel platformService = MethodChannel('com.sortika.wealth/service');

  // Future<void> _getSMS() async {
  //   try {
  //     final int result = await platformService.invokeMethod('getSMS');
  //     print('Platform Service Result - $result');
  //   } on PlatformException catch (e) {
  //     print('Platform Service ERROR - ${e.details}');
  //   }
  // }

  //Authentication
  AuthService authService = AuthService();
  Helper helper = new Helper();
  AnalyticsFunnel funnel = AnalyticsFunnel();
  //Form Key
//  final _formKey = GlobalKey<FormState>();
  final _formWithdrawWallet = GlobalKey<FormState>();

  Future<PackageInfo> packageInfo;

  double _withdrawAmt;
  void _handleSubmittedWithdrawAmt(String value) {
    _withdrawAmt = double.parse(value.trim());
    print('Withdraw amount: ' + _withdrawAmt.toString());
  }

  static String uid;
  User userData;

  bool isCollapsed = true;
  double screenWidth, screenHeight;
  //Animation Duration
  final Duration duration = const Duration(milliseconds: 200);

  //Controllers
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _menuScaleAnimation;
  Animation<Offset> _slideAnimation;

  final Firestore _firestore = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  SmsReceiver _smsReceiver;

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
  Widget _appBar(String pageName) {
    return Row(
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
          '$pageName',
          style: GoogleFonts.muli(
              textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
        ),
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationsPage(
                          uid: uid,
                        )));
          },
        )
      ],
    );
  }

  //Goals Page
  Widget _goalsPage(context) {
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
              top: 30,
            ),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _appBar('Home'),
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
                  _goalDisplay(),
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
                        // IconButton(
                        //   icon: Icon(Icons.filter_list),
                        //   onPressed: () {
                        //     _filterActivity();
                        //   },
                        // )
                      ],
                    ),
                  ),
                  _activityDisplay(),
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
    var dailyTarget = userData.dailyTarget;
    var weeklyTarget = userData.weeklyTarget;
    var monthlyTarget = userData.monthlyTarget;

    return Row(
      mainAxisSize: MainAxisSize.max,
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
                Text('${dailyTarget.toStringAsFixed(2)}',
                    style: GoogleFonts.muli(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
                Text('${weeklyTarget.toStringAsFixed(2)}',
                    style: GoogleFonts.muli(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
                Text('${monthlyTarget.toStringAsFixed(2)}',
                    style: GoogleFonts.muli(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

    GroupModel groupModel;
    if (model.goalCategory == 'Group') {
      groupModel = GroupModel.fromJson(doc.data);
    }

    //Create a map from which you can add as argument to pass into edit goal page
    Map<String, dynamic> editData = doc.data;
    //Add uid to this map
    editData["uid"] = uid;
    editData["docId"] = doc.documentID;
    editData['token'] = userData.token;

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
                      text: '${model.goalAmountSaved.toStringAsFixed(1)}',
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
                            value: double.parse(
                                '${model.goalAmountSaved.toString()}'),
                            min: 0,
                            max: model.goalCategory == 'Group'
                                ? double.parse(
                                    groupModel.targetAmountPerp.toString())
                                : double.parse(model.goalAmount.toString()),
                            onChanged: (value) {}),
                      ),
                      Text(
                        model.goalCategory == 'Group'
                            ? '${groupModel.targetAmountPerp.toInt().toString()}'
                            : '${model.goalAmount.toInt().toString()}',
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
                    '${model.goalAllocation.toStringAsFixed(2)} %',
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

  Widget _singleAct(DocumentSnapshot doc) {
    ActivityModel model = ActivityModel.fromJson(doc.data);

    DateTime now = DateTime.now();
    Timestamp dateRetrieved = model.activityDate;
    DateTime retrieved = dateRetrieved.toDate();

    int timeDiff = now.difference(retrieved).inDays;
    String elapsed;

    if (timeDiff < 1) {
      int hours = now.difference(retrieved).inHours;
      if (hours < 1) {
        int minutes = now.difference(retrieved).inMinutes;
        elapsed = '$minutes minutes ago';
      } else if (hours == 1) {
        elapsed = '$hours hour ago';
      } else {
        elapsed = '$hours hours ago';
      }
    } else {
      if (timeDiff == 1) {
        elapsed = '$timeDiff day ago';
      } else {
        elapsed = '$timeDiff days ago';
      }
    }

    return ListTile(
      title: Text(
        model.activity,
        style: GoogleFonts.muli(textStyle: TextStyle()),
      ),
      leading: Icon(
        Icons.flag,
        color: Colors.green,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          '$elapsed',
          style: GoogleFonts.muli(textStyle: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  Widget _activityDisplay() {
    return Flexible(
      fit: FlexFit.loose,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: StreamBuilder(
            stream: _firestore
                .collection("users")
                .document(uid)
                .collection("activity")
                .orderBy("activityDate", descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.documents.length == 0) {
                  return Center(
                    child: Text(
                      'You have not recorded any activity',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  );
                }
                return LimitedBox(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                  child: ListView(
                    children: snapshot.data.documents
                        .map((map) => _singleAct(map))
                        .toList(),
                  ),
                );
              }
              return SpinKitDoubleBounce(
                color: Colors.greenAccent[700],
                size: 100,
              );
            }),
      ),
    );
  }

  //Display Goals in horizontal scroll view
  Widget _goalDisplay() {
    return Container(
      height: 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection("users")
            .document(uid)
            .collection("goals")
            .orderBy("goalAllocation", descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.documents.length == 0) {
              return Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sentiment_neutral,
                    size: 100,
                    color: Colors.red,
                  ),
                  Text(
                    'You have not defined any goals',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ],
              ));
            }
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
    //Difference in days
    var creationDate = userData.registerDate.toDate();
    int diff = DateTime.now().difference(creationDate).inDays;
    print(diff);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome ${userData.fullName.split(' ')[0]}',
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
            diff >= 1
                ? TextSpan(
                    text: 'Your current savings and investment rate is  ',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(color: Colors.black)))
                : TextSpan(
                    text:
                        'We went ahead and setup for you a loan fund goal of  ',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(color: Colors.black))),
            diff >= 1
                ? TextSpan(
                    text: '${userData.dailySavingsTarget.toStringAsFixed(2)}%',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                        decoration: TextDecoration.underline))
                : TextSpan(
                    text: '5200 KES',
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
              top: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _appBar('Savings'),
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
                    Portfolio(
                      uid: uid,
                    ),
                  ],
                )),
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
                top: 30,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _appBar('Loans'),
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
                      height: 10,
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
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection("loans")
                          .where("loanBorrower", isEqualTo: uid)
                          .orderBy("loanEndDate")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.documents.length == 0) {
                            return Center(
                              child: Text(
                                'You have not sent any loan requests',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.muli(
                                    textStyle: TextStyle(fontSize: 16)),
                              ),
                            );
                          }
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: PageView(
                              scrollDirection: Axis.horizontal,
                              controller:
                                  PageController(viewportFraction: 0.85),
                              children: snapshot.data.documents
                                  .map((map) => _singleLoanTaken(map))
                                  .toList(),
                            ),
                          );
                        }
                        return SpinKitDoubleBounce(
                          color: Colors.greenAccent[700],
                          size: 100,
                        );
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Invitation History',
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
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection("loans")
                          .where("loanInvitees", arrayContains: uid)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.documents.length == 0) {
                            return Center(
                              child: Text(
                                'You have not received any loan invitation requests',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.muli(
                                    textStyle: TextStyle(fontSize: 16)),
                              ),
                            );
                          }
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: PageView(
                              scrollDirection: Axis.horizontal,
                              controller:
                                  PageController(viewportFraction: 0.85),
                              children: snapshot.data.documents.map((map) {
                                return _singleLoanInvited(map);
                              }).toList(),
                            ),
                          );
                        }
                        return SpinKitDoubleBounce(
                          color: Colors.greenAccent[700],
                          size: 100,
                        );
                      },
                    ),
                    SizedBox(
                      height: 10,
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
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection("loans")
                          .where("loanLender", isEqualTo: uid)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.documents.length == 0) {
                            return Center(
                              child: Text(
                                'You have not received any loan requests',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.muli(
                                    textStyle: TextStyle(fontSize: 16)),
                              ),
                            );
                          }
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: PageView(
                              scrollDirection: Axis.horizontal,
                              controller:
                                  PageController(viewportFraction: 0.85),
                              children: snapshot.data.documents.map((map) {
                                return _singleLoanGiven(map);
                              }).toList(),
                            ),
                          );
                        }
                        return SpinKitDoubleBounce(
                          color: Colors.greenAccent[700],
                          size: 100,
                        );
                      },
                    )
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

  Widget _loanLimits() {
    return Card(
      elevation: 10,
      margin: EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.greenAccent[700], width: 1.5)),
      child: Container(
        padding: EdgeInsets.all(8),
        child: FutureBuilder(
          future: helper.getLoanLimit(userData.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //Convert Data to a Goal Model
              GoalModel mods = GoalModel.fromJson(snapshot.data.data);
              //Retrieve Loan Limit Ratio
              var ratio = userData.loanLimitRatio;
              double borrowAmount = (mods.goalAmountSaved * (ratio / 100));

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Borrow',
                        style: GoogleFonts.muli(
                            textStyle:
                                TextStyle(fontSize: 16, letterSpacing: 0.5)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${borrowAmount.toStringAsFixed(1)} KES',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
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
                            textStyle:
                                TextStyle(fontSize: 16, letterSpacing: 0.5)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${mods.goalAmountSaved.toStringAsFixed(1)} KES',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      )
                    ],
                  )
                ],
              );
            }
            return LinearProgressIndicator();
          },
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
                model.loanLender == uid
                    ? 'Self Loan'
                    : model.loanLender != null
                        ? "${model.loanLenderName}"
                        : model.loanInvitees.length == 1
                            ? '${model.loanInviteeName[0]}'
                            : '${model.loanInvitees.length} lenders found',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: model.loanStatus == 'Rejected'
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Text(
                      'Rejected',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  )
                : model.loanStatus == 'Completed'
                    ? Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Text(
                          'Completed',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      )
                    : model.loanStatus == 'Revised'
                        ? GestureDetector(
                            onTap: () => _lendingOptions(loanData),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20)),
                                  color: Colors.transparent),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : model.loanStatus == 'Revised2'
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                child: Text(
                                  'Revision',
                                  style: GoogleFonts.muli(
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                ))
                            : model.loanStatus
                                ? GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .pushNamed('/pay-loan',
                                            arguments: loanData),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 4),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20)),
                                          color: Colors.transparent),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    child: Text(
                                      'Pending',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
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
                model.loanStatus == 'Rejected'
                    ? Text('Your loan request has been rejected',
                        style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ))
                    : model.loanStatus == 'Revised'
                        ? Text('Your loan request has been revised',
                            style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ))
                        : model.loanStatus == 'Revised2'
                            ? Text('You have sent a revision',
                                style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ))
                            : model.loanStatus == 'Completed'
                                ? Text('This loan has been paid in full',
                                    style: GoogleFonts.muli(
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ))
                                : model.loanStatus
                                    ? RichText(
                                        text: TextSpan(children: [
                                        TextSpan(
                                            text: 'You have repaid ',
                                            style: GoogleFonts.muli(
                                                textStyle: TextStyle(
                                                    color: Colors.white))),
                                        TextSpan(
                                            text:
                                                '${model.loanAmountRepaid.toInt().toString()}',
                                            style: GoogleFonts.muli(
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            )),
                                      ]))
                                    : RichText(
                                        text: TextSpan(children: [
                                        TextSpan(
                                            text: 'You have requested ',
                                            style: GoogleFonts.muli(
                                                textStyle: TextStyle(
                                                    color: Colors.white))),
                                        TextSpan(
                                            text:
                                                '${model.loanAmountTaken.toInt().toString()}',
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
                            value:
                                double.parse(model.loanAmountRepaid.toString()),
                            min: 0,
                            max:
                                double.parse(model.totalAmountToPay.toString()),
                            onChanged: (value) {}),
                      ),
                      Text(
                        '${model.totalAmountToPay.toInt().toString()}',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
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
                            color: Colors.white, fontWeight: FontWeight.w500)),
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
                            color: Colors.white, fontWeight: FontWeight.w500)),
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

  Future _loanAcceptance(Map<String, dynamic> data) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return SuccessMessage(
            message:
                'We will send ${data['loanAmountTaken'].toString()} KES to ${data['borrowerName']}');
      },
    );
  }

  Future _loanRejection(Map<String, dynamic> data) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return ErrorMessage(
            message:
                'You have rejected a loan request from ${data['borrowerName']}');
      },
    );
  }

  Future _updateLoanDoc(String docId) async {
    //Change loanStatus to true
    await _firestore.collection("loans").document(docId).updateData({
      'loanStatus': true,
      'loanLender': uid,
      'loanLenderName': userData.fullName.split(' ')[0],
      'loanLenderToken': userData.token,
      'loanInvitees': null,
      'loanInviteeName': null,
      'tokenInvitee': null
    });
  }

  Future _updateRevision(String docId, String borrower) async {
    //Change loanStatus to true
    await _firestore.collection("loans").document(docId).updateData({
      'loanStatus': true,
      'loanInvitees': null,
      'loanInviteeName': null,
      'tokenInvitee': null
    });

    ActivityModel loanAcceptedAct = new ActivityModel(
        activity: 'Loan request accepted', activityDate: Timestamp.now());
    await authService.postActivity(borrower, loanAcceptedAct);
  }

  Future _promptUser(String message) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return WarningMessage(message: message);
        });
  }

  Future _lendingOptions(Map<String, dynamic> loanData) {
    print('Loan Data: $loanData');
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
                    loanData['loanStatus'] == 'Revised'
                        ? _updateRevision(
                                loanData['docId'], loanData['loanBorrower'])
                            .whenComplete(() => _loanAcceptance(loanData))
                        : _updateLoanDoc(loanData['docId']).then((value) {
                            _loanAcceptance(loanData);
                          }).catchError(
                            (error) => _promptUser(error.toString()));
                  },
                  child: Text(
                    'ACCEPT',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(fontWeight: FontWeight.bold)),
                  )),
              loanData['loanStatus'] != 'Revised2'
                  ? CupertinoActionSheetAction(
                      onPressed: () {
                        //Pop the Action Sheet First
                        Navigator.of(context).pop();

                        loanData['loanStatus'] == 'Revised'
                            ? Navigator.of(context)
                                .pushNamed('/negotiate', arguments: loanData)
                            : Navigator.of(context)
                                .pushNamed('/update-loan', arguments: loanData);
                      },
                      child: Text(
                        'UPDATE',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(fontWeight: FontWeight.bold)),
                      ))
                  : Container(),
            ],
            cancelButton: CupertinoActionSheetAction(
                onPressed: () async {
                  //Pop the Action Sheet First
                  Navigator.of(context).pop();
                  ActivityModel rejectAct = new ActivityModel(
                      activity: 'You rejected a loan request',
                      activityDate: Timestamp.now());
                  await authService.postActivity(uid, rejectAct);
                  await helper
                      .rejectLoanDoc(loanData['docId'])
                      .catchError((error) => _promptUser(error.toString()));
                  await funnel.logLoanRejection(
                      loanData['loanAmountTaken'],
                      loanData['loanTakenDate'].toDate().toString(),
                      loanData['loanEndDate'].toDate().toString());
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

  Widget _singleLoanInvited(DocumentSnapshot doc) {
    //Retrieve LoanModel from doc
    LoanModel model = LoanModel.fromJson(doc.data);
    print(model.loanStatus);

    //Placeholder Map to be passed to pay loan page
    Map<String, dynamic> loanData = doc.data;
    loanData["uid"] = uid;
    loanData["docId"] = doc.documentID;
    loanData['tokenMe'] = userData.token;
    loanData['nameMe'] = userData.fullName.split(' ')[0];

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
                model.loanBorrower == null
                    ? 'Pending'
                    : '${model.borrowerName}',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: model.loanStatus == true
                ? Container()
                : model.loanStatus == 'Revised'
                    ? Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Text(
                          'Revised',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      )
                    : model.loanStatus == 'Completed'
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Text(
                              'Completed',
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              _lendingOptions(loanData);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20)),
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
                model.loanStatus != 'Completed'
                    ? RichText(
                        text: TextSpan(children: [
                        TextSpan(
                            text: model.loanStatus == true
                                ? 'They have repaid '
                                : 'They have requested ',
                            style: GoogleFonts.muli(
                                textStyle: TextStyle(color: Colors.white))),
                        TextSpan(
                            text: model.loanAmountRepaid == null
                                ? 'Pending'
                                : '${model.loanAmountRepaid.toInt().toString()}',
                            style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            )),
                      ]))
                    : Text(
                        'This loan has been paid in full',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
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
                            value: model.loanAmountRepaid == null
                                ? 0
                                : double.parse(
                                    model.loanAmountRepaid.toString()),
                            min: 0,
                            max:
                                double.parse(model.totalAmountToPay.toString()),
                            onChanged: (value) {}),
                      ),
                      Text(
                        '${model.totalAmountToPay.toInt().toString()}',
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
                  Text(
                    model.loanInterest == null
                        ? 'Pending'
                        : '${model.loanInterest.toString()} %',
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

  Widget _singleLoanGiven(DocumentSnapshot doc) {
    //Retrieve LoanModel from doc
    LoanModel model = LoanModel.fromJson(doc.data);
    print(model.loanStatus);

    //Placeholder Map to be passed to pay loan page
    Map<String, dynamic> loanData = doc.data;
    loanData["uid"] = uid;
    loanData["docId"] = doc.documentID;
    loanData['tokenMe'] = userData.token;
    loanData['nameMe'] = userData.fullName.split(' ')[0];

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
                model.loanBorrower == null
                    ? 'Pending'
                    : '${model.borrowerName}',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: model.loanStatus == true
                ? Container()
                : model.loanStatus == 'Revised'
                    ? Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Text(
                          'Revised',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      )
                    : model.loanStatus == 'Completed'
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Text(
                              'Completed',
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              _lendingOptions(loanData);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20)),
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
                model.loanStatus != 'Completed'
                    ? RichText(
                        text: TextSpan(children: [
                        TextSpan(
                            text: model.loanStatus == true
                                ? 'They have repaid '
                                : 'They have requested ',
                            style: GoogleFonts.muli(
                                textStyle: TextStyle(color: Colors.white))),
                        TextSpan(
                            text: model.loanAmountRepaid == null
                                ? 'Pending'
                                : '${model.loanAmountRepaid.toInt().toString()}',
                            style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            )),
                      ]))
                    : Text(
                        'This loan has been paid in full',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
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
                            value: model.loanAmountRepaid == null
                                ? 0
                                : double.parse(
                                    model.loanAmountRepaid.toString()),
                            min: 0,
                            max:
                                double.parse(model.totalAmountToPay.toString()),
                            onChanged: (value) {}),
                      ),
                      Text(
                        '${model.totalAmountToPay.toInt().toString()}',
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
                  Text(
                    model.loanInterest == null
                        ? 'Pending'
                        : '${model.loanInterest.toString()} %',
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

  Widget walletItem(DocumentSnapshot doc) {
    String action = doc.data['transactionAction'];
    //String goal = doc.data['transactionGoal'];
    var amount = doc.data['transactionAmount'];
    //String category = doc.data['transactionCategory'];
    String code = doc.documentID;

    //Date and Time Formatting
    int numberTime = doc.data['transactionTime'];
    String year = numberTime.toString().substring(0, 4);
    String month = numberTime.toString().substring(4, 6);
    String day = numberTime.toString().substring(6, 8);
    String hour = numberTime.toString().substring(8, 10);
    String minutes = numberTime.toString().substring(10, 12);

    String date =
        year + "-" + month + "-" + day + " at " + hour + ":" + minutes;

    List<String> greenColorItems = ['Earning', 'Deposit', 'Redemption'];

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: Row(
        children: [
          Container(
            child: greenColorItems.contains(action)
                ? Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.arrow_downward,
                    color: Colors.red,
                  ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[50],
            ),
            padding: EdgeInsets.all(16),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        code,
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: greenColorItems.contains(action)
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600)),
                      ),
                      Text(
                        '$date',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.normal)),
                      )
                    ],
                  ),
                  Text(
                    '${double.parse(amount.toString()).toStringAsFixed(1)} KES',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.w600)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget walletHeader(String name, Color color) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: 4,
        child: ExpansionTile(
          title: Text('$name',
              style: GoogleFonts.muli(
                textStyle: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600, color: color),
              )),
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder<QuerySnapshot>(
                future: helper.getWalletTransactions(uid, name),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.data.documents.length > 0) {
                        return ListView(
                          children: snapshot.data.documents
                              .map((doc) => walletItem(doc))
                              .toList(),
                        );
                      } else {
                        return Center(
                          child: Text(
                            'You have not made any $name transactions',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.muli(textStyle: TextStyle()),
                          ),
                        );
                      }
                      break;
                    case ConnectionState.waiting:
                      return SpinKitDoubleBounce(
                        size: 100,
                        color: Colors.greenAccent[700],
                      );
                    default:
                      return SpinKitDoubleBounce(
                        size: 100,
                        color: Colors.greenAccent[700],
                      );
                  }
                },
              ),
            )
          ],
        ));
  }

  Widget _walletWithdrawTF(var amount) {
    return Form(
      key: _formWithdrawWallet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
              autofocus: false,
              keyboardType: TextInputType.number,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.black,
              )),
              onFieldSubmitted: (value) {
                FocusScope.of(context).unfocus();
              },
              validator: (value) {
                //Check if password is empty
                if (value.isEmpty) {
                  return 'Amount is required';
                }
                if (value.contains('-') || value.contains('.')) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) < 10) {
                  return 'You cannot withdraw less than 10 KES';
                }
                if (amount < double.parse(value) + 79) {
                  return 'Insufficient funds\nAmount >= 1000 ? Transaction = 79 KES\nAmount < 1000 ? Transaction = 40';
                }
                return null;
              },
              autovalidate: true,
              textInputAction: TextInputAction.done,
              onSaved: _handleSubmittedWithdrawAmt,
              obscureText: false,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue))))
        ],
      ),
    );
  }

  void _withdrawBtnPressed(var amount) async {
    final FormState form = _formWithdrawWallet.currentState;
    if (form.validate()) {
      form.save();
      //Dismiss the keyboard
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      //Dismiss the dialog
      Navigator.of(context).pop();
      //Check if money can be withdrawn
      helper
          .withdrawMoney(userData.uid, userData.phone, _withdrawAmt)
          .then((value) => showCupertinoModalPopup(
                context: context,
                builder: (context) => SuccessMessage(
                  message:
                      'We have received your withdrawal request. We are processing it.',
                ),
              ))
          .catchError((error) => showCupertinoModalPopup(
                context: context,
                builder: (context) => ErrorMessage(
                    message: error.toString().contains('PERMISSION_DENIED')
                        ? 'A withdrawal request is being processed, please wait while we process it. This should not take long'
                        : error.toString()),
              ));
    }
  }

  Future _withdrawFromWallet(var amount) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              'Enter Amount',
              style: GoogleFonts.muli(textStyle: TextStyle()),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_walletWithdrawTF(amount)],
            ),
            actions: [
              FlatButton(
                  onPressed: () => _withdrawBtnPressed(amount),
                  child: Text(
                    'WITHDRAW',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  )),
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ))
            ],
          );
        });
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
                top: 30,
              ),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //App Bar
                    _appBar('Wallet'),
                    StreamBuilder<DocumentSnapshot>(
                        stream: helper.getWalletBalance(uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var amount = snapshot.data.data['amount'];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Balance',
                                          style: GoogleFonts.muli(
                                              textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15)),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '${double.parse(amount.toString()).toStringAsFixed(2)} KES',
                                          style: GoogleFonts.muli(
                                              textStyle: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700)),
                                        )
                                      ],
                                    )),
                                IconButton(
                                  tooltip: 'Withdraw',
                                  icon: Icon(Icons.redeem),
                                  onPressed: () {
                                    if (userData.phoneVerified) {
                                      _withdrawFromWallet(amount);
                                    } else {
                                      showCupertinoModalPopup(
                                          context: context,
                                          builder: (context) => ErrorMessage(
                                              message:
                                                  'Please verify your phone number by setting your preffered withdrawal or deposit method in settings. If you have done so, please Login again'));
                                    }
                                  },
                                )
                              ],
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: LinearProgressIndicator(),
                          );
                        }),
                    walletHeader('Earning', Colors.green),
                    walletHeader('Withdrawal', Colors.red),
                    walletHeader('Deposit', Colors.green),
                    walletHeader('Payment', Colors.red),
                    walletHeader('Redemption', Colors.green),
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
                top: 30,
              ),
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _appBar('Groups'),
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
                      MyGroups(user: userData),
                    ],
                  )),
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
              top: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _appBar('Investments'),
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
                    InvestmentPortfolio(uid: uid),
                  ],
                )),
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
              top: 30,
            ),
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _appBar('Planner'),
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
                    BudgetCalc(),
                    Insights(uid: uid),
                    FinancialRatios()
                  ],
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
              top: 30,
            ),
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _appBar('Promotions'),
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
                      SortikaSavings(
                        user: userData,
                      ),
                      SortikaLottery(
                        user: userData,
                      )
                    ])),
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

  Future notificationPopup(Map<String, dynamic> message) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              '${message["notification"]["title"]}',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              )),
            ),
            content: Text(
              '${message["notification"]["body"]}',
              style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              )),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
                  ))
            ],
          );
        });
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
                  radius: 40,
                  backgroundImage: userData.photoURL != null
                      ? NetworkImage(userData.photoURL)
                      : null,
                ),
              ),
              SizedBox(height: 5),
              Text(
                userData.fullName,
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
                Icons.settings,
                color: Colors.white,
                size: 35,
              ),
              onPressed: () => Navigator.of(context)
                  .pushNamed('/settings', arguments: userData))
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
                  Share.share(
                      'Check out our app https://play.google.com/store/apps/details?id=com.sortika.wealth');
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
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Rate(uid: uid),
              )),
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
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Help(
                      future: packageInfo,
                    ),
                  )),
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

  Widget midfieldMenuItems() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          )
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              _menuHeader(),
              //SizedBox(height: 80),
              midfieldMenuItems(),
              //SizedBox(height: 80),
              _menuFooter()
            ],
          ),
        ),
      ),
    );
  }

  // void _onMessageReceived(SmsReceiver receiver) {
  //   receiver.onSmsReceived.listen((message) async {
  //     //print('A new message has been detected');
  //     // if (message.address == 'MPESA') {
  //     //   List<Map<String, dynamic>> smsList = [];
  //     //   Map<String, dynamic> map = {
  //     //     'address': message.address,
  //     //     'body': message.body,
  //     //     'date': message.date.millisecondsSinceEpoch,
  //     //     'uid': uid
  //     //   };
  //     //   smsList.add(map);
  //     //   String data = json.encode({'sms_data': smsList});
  //     //   print(data);
  //     //   // //Try HTTP Post
  //     //   String url =
  //     //       'https://europe-west1-sortika-c0f5c.cloudfunctions.net/sortikaMain/api/v1/tusomerecords/9z5JjD9bGODXeSVpdNFW';
  //     //   try {
  //     //     await http.post(url, body: data);
  //     //   } catch (e) {
  //     //     throw e.toString();
  //     //   }
  //     //   // var response = await http.post(url, body: data);
  //     //   // print('Response status: ${response.statusCode}');
  //     //   // print('Response body: ${response.body}');
  //     // }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.6).animate(_controller);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);

    // _smsReceiver = new SmsReceiver();
    // _onMessageReceived(_smsReceiver);

    //Handle Notifications
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        notificationPopup(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    packageInfo = PackageInfo.fromPlatform();
  }

  Widget _backgroundClr() {
    return Container(
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Get the size of the screen
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    //Retrieve the user
    userData = ModalRoute.of(context).settings.arguments;
    uid = userData.uid;
    //print('Retrieved UID: $uid');

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
                child: _backgroundClr(),
              ),
              NetworkSensor(child: _menu(context)),
              _pageSelection == 'main'
                  ? NetworkSensor(child: _goalsPage(context))
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
                  title: Text(
                    'Quick Actions',
                    style: GoogleFonts.muli(textStyle: TextStyle(fontSize: 16)),
                  ),
                  actions: [
                    CupertinoActionSheetAction(
                        onPressed: () {
                          Map<String, dynamic> data = {
                            'uid': userData.uid,
                            'token': userData.token,
                            'name': userData.fullName.split(' ')[0],
                            'phone': userData.phone
                          };
                          //Pop the dialog first then open page
                          Navigator.of(context)
                              .popAndPushNamed('/borrow', arguments: data);
                        },
                        child: Text(
                          'Borrow',
                          style: GoogleFonts.muli(textStyle: TextStyle()),
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          //Pop the dialog first then open page
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Deposit(
                                  uid: uid,
                                  phone: userData.phone,
                                ),
                              ));
                        },
                        child: Text(
                          'Deposit',
                          style: GoogleFonts.muli(textStyle: TextStyle()),
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          //Pop the dialog first then open page
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateGoal(
                                  uid: uid,
                                ),
                              ));
                        },
                        child: Text(
                          'Create a goal',
                          style: GoogleFonts.muli(textStyle: TextStyle()),
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          //Pop the dialog first then open page
                          Navigator.of(context).pop();
                          // Push to relevant route
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AutoCreateHolder(
                                        uid: uid,
                                      )));
                        },
                        child: Text(
                          'Autocreate Goals',
                          style: GoogleFonts.muli(textStyle: TextStyle()),
                        ))
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
