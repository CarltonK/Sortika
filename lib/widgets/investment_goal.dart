import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/global/progressDialog.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/global/warningMessage.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/goalmodel.dart';
import 'package:wealth/models/investmentModel.dart';
import 'package:wealth/utilities/styles.dart';

class InvestmentGoal extends StatefulWidget {
  final String uid;
  InvestmentGoal({Key key, @required this.uid}) : super(key: key);
  @override
  _InvestmentGoalState createState() => _InvestmentGoalState();
}

class _InvestmentGoalState extends State<InvestmentGoal> {
  final styleLabel =
      GoogleFonts.muli(textStyle: TextStyle(color: Colors.white, fontSize: 15));

  //Investment Asset Class
  String classInvestment;
  //Investment Goal
  String goalInvestment;
  //Placeholder of amount
  double targetAmount = 0;

  Future<List<InvestmentModel>> fetchData;
  Helper helper = new Helper();

  List<InvestmentModel> _classes = [];
  List<dynamic> _types = [];

  //Set an average loan to be 30 days
  static DateTime rightNow = DateTime.now();
  static DateTime oneMonthFromNow = rightNow.add(Duration(days: 30));

  DateTime _date;
  String _dateDay = oneMonthFromNow.day.toString();
  int _dateMonth = oneMonthFromNow.month;
  String _dateYear = oneMonthFromNow.year.toString();

  Firestore _firestore = Firestore.instance;
  AuthService authService = new AuthService();

  //List

  //Month Names
  List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  Widget _investClassWidget() {
    return Container(
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
        child: FutureBuilder<List<InvestmentModel>>(
          future: fetchData,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasData) {
                  _classes = snapshot.data;
                  return DropdownButton(
                    items: _classes
                        .map((map) => DropdownMenuItem(
                              value: map.title,
                              child: Text(
                                map.title,
                                style: GoogleFonts.muli(
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ))
                        .toList(),
                    underline: Divider(
                      color: Colors.transparent,
                    ),
                    value: classInvestment,
                    hint: Text(
                      '',
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
                    onChanged: (value) => selectedChange(value),
                  );
                }
                return LinearProgressIndicator();
              case ConnectionState.waiting:
                return LinearProgressIndicator();
              default:
                return LinearProgressIndicator();
            }
          },
        ));
  }

  void selectedChange(String value) {
    setState(() {
      goalInvestment = 'Choose a goal';
      _types = [
        {'name': 'Choose a goal', 'return': 0}
      ];
      classInvestment = value;
      _types = List.from(_types)..addAll(getgoalByTitle(value));
      print(_types);
    });
  }

  getgoalByTitle(String value) => _classes
      .map((map) => map)
      .where((item) => item.title == value)
      .map((item) => item.types)
      .expand((i) => i)
      .toList();

  Widget _investTypeWidget() {
    return Container(
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
      child: DropdownButton(
        value: goalInvestment,
        disabledHint: Text(
          'Please select a class',
          style: GoogleFonts.muli(
              textStyle: TextStyle(fontWeight: FontWeight.w600)),
        ),
        items: _types.map((map) {
          String name = map['name'];
          num retu = map['return'];
          return DropdownMenuItem(
            value: name,
            child: Text(
              '$name ($retu%)',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
            ),
          );
        }).toList(),
        underline: Divider(
          color: Colors.transparent,
        ),
        icon: Icon(
          CupertinoIcons.down_arrow,
          color: Colors.black,
        ),
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            goalInvestment = value;
            print(goalInvestment);
          });
        },
      ),
    );
  }

  Widget _investAmount() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Slider.adaptive(
              value: targetAmount,
              inactiveColor: Colors.white,
              divisions: 10,
              min: 0,
              max: 100000,
              label: targetAmount.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  targetAmount = value;
                });
              }),
        ),
        Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '${targetAmount.toInt().toString()} KES',
                textAlign: TextAlign.center,
                style: labelStyle,
              ),
            ))
      ],
    );
  }

  Widget _investmentDurationWidget() {
    return Container(
      child: Row(
        children: [
          Expanded(
              child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '$_dateDay',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.white)),
                ),
                Text(
                  '--',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.white)),
                ),
                Text(
                  '${monthNames[_dateMonth - 1]}',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.white)),
                ),
                Text(
                  '--',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.white)),
                ),
                Text(
                  '$_dateYear',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          )),
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
            onPressed: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 1000)),
              ).then((value) {
                setState(() {
                  if (value != null) {
                    _date = value;
                    _dateDay = _date.day.toString();
                    _dateMonth = _date.month;
                    _dateYear = _date.year.toString();
                    print('Investment End Date: $_date');
                  } else {
                    _date = value;
                    print('Investment End Date: $_date');
                  }
                });
              });
            },
          )
        ],
      ),
    );
  }

  Future _promptUser(String message) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return WarningMessage(message: message);
        });
  }

  Future _promptUserSuccess(String message) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return SuccessMessage(message: message);
        });
  }

  Future _showUserProgress(String message) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CustomProgressDialog(message: message);
        });
  }

  Future _createInvestmentGoal(GoalModel model) async {
    /*
    Before we go to the next page we need to auto create a investment goal
    */

    //This is the name of the collection we will be reading
    final String _collectionUpper = 'users';
    final String _collectionLower = 'goals';
    var document = _firestore.collection(_collectionUpper).document(widget.uid);

    //Save goal to goals subcollection
    await document
        .collection(_collectionLower)
        .document()
        .setData(model.toJson());
  }

  void _setBtnPressed() async {
    //Check if class is non null
    if (classInvestment == null) {
      _promptUser("Please specify an investment class");
    } else if (goalInvestment == null || goalInvestment == "Choose a goal") {
      _promptUser("Please select an investment goal");
    } else if (targetAmount == 0) {
      _promptUser("Please select your initial investment amount");
    } else if (_date == null) {
      _promptUser("You haven't selected the targeted completion date");
    }
    //Check if goal ends on the same day
    else if (_date.difference(rightNow).inDays < 1) {
      _promptUser('The goal end date is too soon');
    } else {
      GoalModel goalModel = new GoalModel(
          goalAmount: targetAmount,
          goalCreateDate: Timestamp.fromDate(DateTime.now()),
          goalEndDate: Timestamp.fromDate(_date),
          goalCategory: 'Investment',
          goalClass: classInvestment,
          uid: widget.uid,
          growth: 0,
          interest: 0,
          goalType: goalInvestment,
          isGoalDeletable: true,
          goalAmountSaved: 0,
          goalAllocation: 0);

      //Show a dialog
      _showUserProgress('Creating your goal...');

      //Create an activity
      ActivityModel investmentAct = new ActivityModel(
          activity:
              'You created a new Investment Goal in the $classInvestment class',
          activityDate: Timestamp.fromDate(rightNow));
      await authService.postActivity(widget.uid, investmentAct);

      _createInvestmentGoal(goalModel).whenComplete(() {
        //Pop that dialog
        //Show a success message for two seconds
        Timer(Duration(seconds: 3), () => Navigator.of(context).pop());

        //Show a success message for two seconds
        Timer(
            Duration(seconds: 4),
            () => _promptUserSuccess(
                'Your investment goal has been created successfully'));

        //Show a success message for two seconds
        Timer(Duration(seconds: 5), () => Navigator.of(context).pop());

        // //Pop the dialog then redirect to home page
        // Timer(Duration(milliseconds: 4500), () {
        //   Navigator.of(context).popAndPushNamed('/home', arguments: widget.uid);
        // });
      }).catchError((error) {
        _promptUser(error);
      });
    }
  }

  Widget _setGoalBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: _setBtnPressed,
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.white,
        child: Text(
          'SET GOAL',
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

  @override
  void initState() {
    super.initState();
    fetchData = helper.getInvestmentddData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Investment Asset Class',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            _investClassWidget(),
            SizedBox(
              height: 30,
            ),
            Text(
              'Investment Goal',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            _investTypeWidget(),
            SizedBox(
              height: 30,
            ),
            Text(
              'How much do you want to invest?',
              style: styleLabel,
            ),
            _investAmount(),
            SizedBox(
              height: 30,
            ),
            Text(
              'Until when?',
              style: styleLabel,
            ),
            _investmentDurationWidget(),
            _setGoalBtn()
          ],
        ),
      ),
    );
  }
}
