import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/goalmodel.dart';
import 'package:wealth/utilities/styles.dart';

class SavingsGoal extends StatefulWidget {
  final String uid;
  SavingsGoal({Key key, @required this.uid}) : super(key: key);

  @override
  _SavingsGoalState createState() => _SavingsGoalState();
}

class _SavingsGoalState extends State<SavingsGoal> {
  //Form Key
  final _formKey = GlobalKey<FormState>();

  final styleLabel =
      GoogleFonts.muli(textStyle: TextStyle(color: Colors.white, fontSize: 15));

  //Goal placeholder
  String classSavings;
  String typeSavings;
  double targetAmount = 0;
  String goalName;

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

  void _handleSubmittedGoalName(String value) {
    setState(() {
      goalName = value;
    });
    print('Goal Name: $goalName');
  }

  List<DropdownMenuItem> itemsGoals = [
    DropdownMenuItem(
      value: 'utility',
      child: Text(
        'Utility goals',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'custom',
      child: Text(
        'Create my own goal',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  List<DropdownMenuItem> itemsTypes = [
    DropdownMenuItem(
      value: 'loan',
      child: Text(
        'Loan repayment',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'custom',
      child: Text(
        'I have a custom goal',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  //Custom goal name
  Widget _customGoalName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.text,
            maxLines: 1,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.blue,
            )),
            onFieldSubmitted: (value) {
              FocusScope.of(context).unfocus();
            },
            validator: (value) {
              //Check if email is empty
              if (value.isEmpty) {
                return 'Goal Name is required';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onSaved: _handleSubmittedGoalName,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
                prefixIcon: Icon(Icons.mail, color: Colors.blue),
                labelText: 'Goal Name',
                labelStyle: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.blue[200],
                ))))
      ],
    );
  }

  Future _promptUser(String message) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text(
              '$message',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(color: Colors.black, fontSize: 16)),
            ),
          );
        });
  }

  Future _promptUserSuccess() {
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
                Icon(
                  Icons.done,
                  size: 50,
                  color: Colors.green,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Your savings goal has been created successfully',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
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
                  'Creating your goal...',
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

  Future _createSavingsGoal(GoalModel model) async {
    /*
    Before we go to the next page we need to auto create a savings goal
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
    //Check if goal class exists
    if (classSavings == null) {
      _promptUser("You haven't told us what you're saving towards");
    } else if (classSavings == 'custom' && goalName == null) {
      addGoalName();
    } else if (typeSavings == null) {
      _promptUser("You haven't selected the goal type");
    } else if (targetAmount == 0) {
      _promptUser("Please select an amount");
    } else if (_date == null) {
      _promptUser("You haven't selected the targeted completion date");
    } else {
      GoalModel goalModel = new GoalModel(
          goalAmount: targetAmount,
          goalCreateDate: Timestamp.fromDate(DateTime.now()),
          goalEndDate: Timestamp.fromDate(_date),
          goalCategory: 'Saving',
          goalClass: classSavings,
          goalName: goalName,
          goalType: typeSavings,
          uid: widget.uid,
          isGoalDeletable: true,
          goalAmountSaved: 0,
          goalAllocation: 0);

      //Create an activity
      ActivityModel investmentAct = new ActivityModel(
          activity: 'You created a new Savings Goal in the $classSavings class',
          activityDate: Timestamp.fromDate(rightNow));
      await authService.postActivity(widget.uid, investmentAct);

      //Show a dialog
      _showUserProgress();

      //  //Retrieve USER DOC
      //   DocumentSnapshot userDoc = await _firestore.collection("users").document(widget.uid).get();
      //   User user = User.fromJson(userDoc.data);

      _createSavingsGoal(goalModel).whenComplete(() {
        //Pop that dialog
        //Show a success message for two seconds
        Timer(Duration(seconds: 3), () => Navigator.of(context).pop());

        //Show a success message for two seconds
        Timer(Duration(seconds: 4), () => _promptUserSuccess());

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

  Future addGoalName() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    final form = _formKey.currentState;
                    if (form.validate()) {
                      form.save();
                      //Remove the dialog
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Create',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  ))
            ],
          );
        });
  }

  Widget _goalClass() {
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
        items: itemsGoals,
        underline: Divider(
          color: Colors.transparent,
        ),
        value: classSavings,
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
        onChanged: (value) {
          setState(() {
            classSavings = value;
            //Change color according to value of goal
            if (value == 'custom') {
              //Show a popup to create a goal
              addGoalName();
            }
          });
        },
      ),
    );
  }

  Widget _goalType() {
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
        items: itemsTypes,
        underline: Divider(
          color: Colors.transparent,
        ),
        value: typeSavings,
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
        onChanged: (value) {
          setState(() {
            typeSavings = value;
          });
        },
      ),
    );
  }

  Widget _savingsDurationWidget() {
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
                    print('Loan End Date: $_date');
                  } else {
                    _date = value;
                    print('Loan End Date: $_date');
                  }
                });
              });
            },
          )
        ],
      ),
    );
  }

  Widget _targetAmountWidget() {
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
              'What are you saving towards?',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            _goalClass(),
            SizedBox(
              height: 30,
            ),
            Text(
              'Please select the goal type',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            _goalType(),
            SizedBox(
              height: 30,
            ),
            Text(
              'How much are you targeting?',
              style: styleLabel,
            ),
            _targetAmountWidget(),
            SizedBox(
              height: 30,
            ),
            Text(
              'Please select an end date',
              style: styleLabel,
            ),
            _savingsDurationWidget(),
            classSavings == 'custom'
                ? SizedBox(
                    height: 30,
                  )
                : Container(),
            Text(
              classSavings == 'custom' && goalName != null
                  ? 'I have decided to create my own goal titled: ${goalName.toUpperCase()}'
                  : '',
              textAlign: TextAlign.left,
              style: styleLabel,
            ),
            _setGoalBtn()
          ],
        ),
      ),
    );
  }
}
