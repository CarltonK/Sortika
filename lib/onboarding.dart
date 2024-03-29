import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth/analytics/analytics_funnels.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/global/progressDialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wealth/models/usermodel.dart';
import 'package:wealth/services/permissions.dart';
import 'package:wealth/services/sms.dart';

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  //PageView Controller
  final PageController _pageController = PageController(initialPage: 0);
  //Define number of screens
  final int _numPages = 4;
  DateTime rightnow = DateTime.now();
  //Placeholder for current page
  int _currentPage = 0;
  Firestore _firestore = Firestore.instance;
  AnalyticsFunnel funnel = AnalyticsFunnel();
  ReadSMS readSMS = new ReadSMS();
  PermissionService permissionService = new PermissionService();
  final FirebaseMessaging fcm = FirebaseMessaging();
  Helper helper = new Helper();
  String token;

  Future checkFirstSeen() async {
    token = await fcm.getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    if (_seen) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return CustomProgressDialog(
              message:
                  'Loading...\n\nBe patient, we are computing your passive savings');
        },
      );
      checkLoginStatus().then((value) async {
        if (value == null) {
          print(null);
          Navigator.of(context).pushReplacementNamed('/login');
        } else {
          DocumentSnapshot doc =
              await _firestore.collection("users").document(value).get();
          User user = User.fromJson(doc.data);
          DateTime lastLogin = user.lastLogin.toDate();
          bool smsPulled = user.smsPulled;
          //Analytics Event - LOGIN
          await funnel.logLogin();
          readSMS.readMPESA(user.uid, lastLogin, smsPulled).then((value) async {
            if (value) {
              if (user.preExisting) {
                print('The new token for ${user.uid} is $token');
                await helper.updateToken(user.uid, token);
              }
              FirebaseAuth.instance.currentUser().then((valueUser) {
                valueUser.getIdToken().then((valueTok) {
                  Navigator.of(context)
                      .pushReplacementNamed('/home', arguments: user);
                });
              });
            } else {
              print('There is an error getting SMS Permissions. Let us retry');
              await permissionService.requestSmsPermission();
            }
          });
        }
      });
    } else {
      await funnel.logOnBoardingStart();
      await prefs.setBool('seen', true);
    }
  }

  Future checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uid');
    return uid;
  }

  TextStyle _titleStyle() {
    return GoogleFonts.muli(
        textStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 0.5,
            fontWeight: FontWeight.bold));
  }

  TextStyle _subtitleStyle() {
    return GoogleFonts.muli(
        textStyle: TextStyle(color: Colors.white, fontSize: 19));
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
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
          color: isActive ? Colors.white : Color(0xFF73AEF5),
          borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget singlePage(AssetImage asset, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Image(
            fit: BoxFit.fitHeight,
            image: asset,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: _titleStyle(),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: _subtitleStyle(),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    checkFirstSeen();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future _permissionsDialog() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'ATTENTION',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold)),
        ),
        content: Text(
          'We wish to notify you that we are requesting the following information from your device to aid in processing and serving you better\n\n'
          'We require SMS Permissions to scan M-PESA SMS and prompt you to save according to your spending habits\n\n'
          'Sortika complies with data privacy policies as stipulated by our laws and international laws. We only use your data for the prescribed use.',
          style: GoogleFonts.muli(
              textStyle: TextStyle(color: Colors.black, fontSize: 16)),
        ),
        actions: <Widget>[
          FlatButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/login'),
              child: Text(
                'PROCEED',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                0.1,
                0.4,
                0.7,
                0.9
              ],
                  colors: [
                Color(0xFF73AEF5),
                Color(0xFF61A4F1),
                Color(0xFF478DE0),
                Color(0xFF398AE5),
              ])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(top: 30),
                child: FlatButton(
                    onPressed: () {
                      setState(() {
                        _pageController.animateToPage(4,
                            duration: Duration(milliseconds: 3),
                            curve: Curves.ease);
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
              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: EdgeInsets.all(40),
                child: PageView(
                  physics: ClampingScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: <Widget>[
                    singlePage(
                        AssetImage('assets/images/borrow.png'),
                        'You can Borrow from as low as 1%',
                        'Place and price your loan request to thousands of lenders on Sortika and get an instant reply'),
                    singlePage(
                        AssetImage('assets/images/invest.png'),
                        'Invest in tens of investment asset classes',
                        'Create an investment portfolio that meets your return expectation and risk profile'),
                    singlePage(
                        AssetImage('assets/images/save.png'),
                        'You can create customized savings goals',
                        'Create your financial goals and we ensure you meet each and every one of them'),
                    singlePage(
                        AssetImage('assets/images/group.png'),
                        'Create a savings group and invite friends to contribute',
                        'Your chama can now save remotely and ensure that members meet their targets')
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
              _currentPage != _numPages - 1
                  ? Expanded(
                      child: Align(
                      alignment: FractionalOffset.bottomRight,
                      child: FlatButton(
                          onPressed: () {
                            _pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20, top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('Next',
                                    style: GoogleFonts.muli(
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600))),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(CupertinoIcons.forward,
                                    color: Colors.white)
                              ],
                            ),
                          )),
                    ))
                  : Text('')
            ],
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPages - 1
          ? Container(
              height: 70,
              width: double.infinity,
              color: Color(0xFF398AE5),
              child: GestureDetector(
                onTap: () async {
                  //Analytics Event - TUTORIAL COMPLETE
                  await funnel.logOnBoardingEnd();
                  //Show Permissions Popup
                  _permissionsDialog();
                },
                child: Center(
                  child: Text(
                    'Get started'.toUpperCase(),
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            )
          : Text(''),
    );
  }
}
