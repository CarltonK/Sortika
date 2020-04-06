import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:wealth/models/budgetItem.dart';
import 'package:wealth/utilities/styles.dart';

final menuLabelStyle = GoogleFonts.muli(
    textStyle: TextStyle(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isCollapsed = true;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 200);
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _menuScaleAnimation;
  Animation<Offset> _slideAnimation;
  PageController _controllerBudget = PageController(viewportFraction: 0.7);
  //Saved amount
  double saved = 2000;
  //String page Selection
  String _pageSelection = 'main';

  //Custom AppBar
  Widget _appBar() {
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
          'Sortika',
          style: GoogleFonts.muli(
              textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
        ),
        IconButton(icon: Icon(Icons.settings), onPressed: () {}),
      ],
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
                  height: 10,
                ),
                Text('15 KES',
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
                  height: 10,
                ),
                Text('100 KES',
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
                  height: 10,
                ),
                Text('434 KES',
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

  //Display Goals
  Widget _goalDisplay() {
    return Container(
      height: 200,
      child: PageView(
        controller: PageController(viewportFraction: 0.8),
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        children: [
          Container(
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
                      'Savings goal',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(fontWeight: FontWeight.w600)),
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
                            text: '2000',
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
                                  value: 2000,
                                  min: 0,
                                  max: 5000,
                                  onChanged: (value) {}),
                            ),
                            Text(
                              '5000',
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '70 %',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  fontSize: 18,
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
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(20)),
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Dec 25, 2020',
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
          ),
          Container(
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
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.only(bottomRight: Radius.circular(20)),
                        color: Colors.white),
                    child: Text(
                      'Investments goal',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(fontWeight: FontWeight.w600)),
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
                            text: '4500',
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
                              flex: 4,
                              child: Slider(
                                  value: 4500,
                                  min: 0,
                                  max: 5000,
                                  onChanged: (value) {}),
                            ),
                            Text(
                              '5000',
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '30 %',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  fontSize: 18,
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
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(20)),
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'May 1, 2020',
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
          ),
        ],
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
              fontWeight: FontWeight.w600,
              fontSize: 24,
            )),
          ),
          SizedBox(
            height: 5,
          ),
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'We went ahead and setup for you a loan fund goal of ',
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
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Divider(
              color: Colors.blueGrey,
              thickness: 1.5,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Savings targets',
            style: GoogleFonts.muli(
                textStyle: TextStyle(fontSize: 16, letterSpacing: 0.5)),
          ),
          SizedBox(
            height: 5,
          ),
          _targetSavings(),
        ],
      ),
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
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _appBar(),
                  SizedBox(
                    height: 10,
                  ),
                  _introText(),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Divider(
                      color: Colors.blueGrey,
                      thickness: 1.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Here are your goals',
                      style: GoogleFonts.muli(
                          textStyle:
                              TextStyle(fontSize: 16, letterSpacing: 0.5)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _goalDisplay()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  int _budget = 0;
  double _budgetSlector = 0;
  void _handleSubmittedBudget(String value) {
    _budget = int.parse(value);
    print('Budget: $_budget');
  }

  //Confirm Password Widget
  Widget _customGoalName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          decoration: boxDecorationStyle,
          height: 60,
          child: TextFormField(
              keyboardType: TextInputType.number,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.white,
              )),
              validator: (value) {
                if (value.isEmpty) {
                  return 'You have not entered an amount';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                FocusScope.of(context).unfocus();
              },
              onSaved: _handleSubmittedBudget,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.monetization_on, color: Colors.white),
                  hintText: 'Enter your budget',
                  hintStyle: hintStyle)),
        )
      ],
    );
  }

  //Planner Intro
  Widget _plannerIntro() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Set up a monthly budget',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                    fontSize: 18,
                  )),
                ),
              ),
              IconButton(
                icon: Icon(Icons.create),
                onPressed: () {
                  //Show a popup to enter budget
                  showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Container(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  _customGoalName(),
                                ],
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();

                                    //Dismiss the dialog
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text(
                                  'Submit',
                                  style: GoogleFonts.muli(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                ))
                          ],
                        );
                      });
                },
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: <Widget>[
              Text(
                'Total budget is',
                style: GoogleFonts.muli(textStyle: TextStyle()),
              ),
              SizedBox(
                width: 5,
              ),
              Text('${_budget.toInt().toString()} KES',
                  style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ))
            ],
          )
        ],
      ),
    );
  }

  //Budget Item currently active
  bool isItemActive = false;

  //Budget Item
  Widget _budgetItem(IconData icon, String title, int amount) {
    return AnimatedContainer(
      duration: duration,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: Colors.blue),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              child: Icon(
                icon,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.lightBlue)),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$title',
                style:
                    GoogleFonts.muli(textStyle: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '${amount.toString()} KES',
                style: labelStyle,
              ),
            ],
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }

  Widget _budgetScroll() {
    return Container(
      height: 80,
      child: PageView(
        scrollDirection: Axis.horizontal,
        controller: _controllerBudget,
        onPageChanged: (value) {},
        children: budgetItems
            .map((map) => _budgetItem(map.icon, map.title, map.amount))
            .toList(),
      ),
    );
  }

  Widget _planEditBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: Container(
            child: TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide())),
            ),
          )),
          IconButton(
            icon: Icon(Icons.keyboard),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Color _colorBudget = Colors.blue[800];
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
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _appBar(),
                  SizedBox(
                    height: 10,
                  ),
                  _plannerIntro(),
                  SizedBox(
                    height: 20,
                  ),
                  _budgetScroll(),
                  SizedBox(
                    height: 50,
                  ),
                  _planEditBox(),
                  SizedBox(
                    height: 30,
                  ),
                  AnimatedContainer(
                    duration: duration,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    height: 300,
                    width: screenWidth,
                    decoration: BoxDecoration(
                        color: _colorBudget,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40),
                            topLeft: Radius.circular(40))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Slider(
                              value: _budgetSlector,
                              min: 0,
                              max: (_budget == 0) ? 1000 : _budget.toDouble(),
                              activeColor: Colors.greenAccent[700],
                              inactiveColor: Colors.white,
                              onChanged: (value) {
                                setState(() {
                                  _budgetSlector = value;
                                  if (value > (_budget / 0.25)) {
                                    _colorBudget = Colors.red;
                                  } else {
                                    _colorBudget = Colors.blue[800];
                                  }
                                });
                              }),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Normal',
                            style: labelStyle,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'That\'s an acceptable range',
                            style: hintStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    ;
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
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 40),
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed('/profile'),
                        child: CircleAvatar(
                          radius: 50,
                          child: Icon(
                            Icons.person,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'Jon Snow',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(child: Container()),
              FlatButton(
                onPressed: () {
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
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text(
                  'Home',
                  style: menuLabelStyle,
                ),
              ),
              FlatButton(
                onPressed: () {},
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text(
                  'Investments',
                  style: menuLabelStyle,
                ),
              ),
              FlatButton(
                onPressed: () {},
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text(
                  'Savings',
                  style: menuLabelStyle,
                ),
              ),
              FlatButton(
                onPressed: () {},
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text(
                  'Groups',
                  style: menuLabelStyle,
                ),
              ),
              FlatButton(
                onPressed: () {},
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text(
                  'Loans',
                  style: menuLabelStyle,
                ),
              ),
              FlatButton(
                onPressed: () {},
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text(
                  'Wallet',
                  style: menuLabelStyle,
                ),
              ),
              FlatButton(
                onPressed: () {
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
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text(
                  'Planner',
                  style: menuLabelStyle,
                ),
              ),
              FlatButton(
                onPressed: () {},
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text(
                  'Promotions',
                  style: menuLabelStyle,
                ),
              ),
              Expanded(child: Container()),
              Container(
                padding: const EdgeInsets.only(left: 8),
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
                                'Check out our website https://www.sortika.com');
                          } catch (error) {
                            print('SHARE ERROR: $error');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 8),
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
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
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
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
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
                                    style: GoogleFonts.muli(
                                        textStyle: TextStyle()),
                                  ),
                                  actions: [
                                    FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'YES',
                                          style: GoogleFonts.muli(
                                              textStyle: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold)),
                                        )),
                                    FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
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
                    )
                  ],
                ),
              )
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
    final Duration duration = const Duration(milliseconds: 500);

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
                  ? _goalsPage(context)
                  : _plannerPage(context)
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
                          Navigator.of(context).pushNamed('/deposit');
                        },
                        child: Text('Deposit')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          //Pop the dialog first then open page
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed('/create-goal');
                        },
                        child: Text('Create a goal'))
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
