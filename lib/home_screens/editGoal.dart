import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/global/progressDialog.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/global/warningMessage.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/goalmodel.dart';
import 'package:wealth/utilities/styles.dart';
import 'package:wealth/widgets/redeemGoal.dart';

class EditGoal extends StatefulWidget {
  @override
  _EditGoalState createState() => _EditGoalState();
}

class _EditGoalState extends State<EditGoal> {
  final _formKey = GlobalKey<FormState>();
  //Investment Asset Class
  String classInvestment;
  //Investment Goal
  String goalInvestment;

  //Retrieved data identifier
  Map<String, dynamic> data;
  GoalModel goalModel;
  String goalDocId;
  String token;

  DateTime _date;
  String _dateDay = '04';
  int _dateMonth = 7;
  String _dateYear = '2020';
  double amount;

  Firestore _firestore = Firestore.instance;
  AuthService authService = new AuthService();

  _handleSavedAmount(String value) {
    amount = double.parse(value);
    print(amount);
  }

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
                  'Deleting your goal...',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
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
                  size: 100,
                  color: Colors.green,
                ),
                Text(
                  'Your goal has been deleted',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  void _deleteGoal() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              'Are you sure?',
              style: GoogleFonts.muli(textStyle: TextStyle()),
            ),
            actions: [
              FlatButton(
                  onPressed: () async {
                    //Pop the dialog first
                    Navigator.of(context).pop();
                    //Delete goal in goals subcollection of user
                    final String _collectionUpper = "users";
                    final String _collectionLower = "goals";
                    //Get the user id
                    String uid = data["uid"];
                    //Get the doc id
                    String dId = data["docId"];

                    await _firestore
                        .collection(_collectionUpper)
                        .document(uid)
                        .collection(_collectionLower)
                        .document(dId)
                        .delete();

                    //Create an activity
                    ActivityModel deleteAct = new ActivityModel(
                        activity: 'You deleted a ${data["goalCategory"]} goal',
                        activityDate: Timestamp.now());
                    await authService.postActivity(uid, deleteAct);
                    //Show a success message for two seconds
                    Timer(Duration(seconds: 2), () => _promptUserSuccess());
                  },
                  child: Text(
                    'YES',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(color: Colors.red)),
                  )),
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'NO',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(color: Colors.green)),
                  ))
            ],
          );
        });
  }

  Widget _goalSummary() {
    /*
    Days Remaining Field
    */
    //Get the date today
    DateTime today = DateTime.now();
    //Get the timestamp from 'data'
    Timestamp retrievedTimestamp = data["goalEndDate"];
    //Convert timestamp to date
    DateTime endDate = retrievedTimestamp.toDate();
    //Get the difference in dates
    Duration difference = endDate.difference(today);
    int remainingDays = difference.inDays;

    /*
    Daily Savings Field
    */
    var totalSavings;
    //Check if the goal is Group or otherwise
    data["goalCategory"] == 'Group'
        ? totalSavings = data["targetAmountPerp"]
        : totalSavings = data["goalAmount"];
    //Divide the totalSavings by difference in days above
    double dailySavings = totalSavings / remainingDays;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
              color: commonColor, borderRadius: BorderRadius.circular(12)),
          width: MediaQuery.of(context).size.width * 0.4,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Days remaining',
                style:
                    GoogleFonts.muli(textStyle: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '$remainingDays',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: commonColor, borderRadius: BorderRadius.circular(12)),
          width: MediaQuery.of(context).size.width * 0.4,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Daily Savings',
                style:
                    GoogleFonts.muli(textStyle: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '${dailySavings.toStringAsFixed(2)}',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _tipsWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tips',
              style: GoogleFonts.muli(
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          SizedBox(
            height: 5,
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              child: Text(
                  'Your daily savings are 25% lower than the required amount. We have increased your daily savings by 50%',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(fontWeight: FontWeight.normal))),
            ),
          )
        ],
      ),
    );
  }

  Widget _goalType() {
    String type;
    //Check if the category is goal Fund
    data["goalCategory"] == 'Loan Fund'
        ? type = 'Loan Fund'
        : data["goalCategory"] == 'Group'
            ? type = 'Group'
            : type = data["goalClass"];

    return IgnorePointer(
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton(
          items: null,
          onTap: null,
          underline: Divider(
            color: Colors.transparent,
          ),
          value: goalInvestment,
          hint: Text(
            '$type',
            style: GoogleFonts.muli(textStyle: TextStyle()),
          ),
          icon: Icon(
            CupertinoIcons.down_arrow,
            color: Colors.black,
          ),
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              goalInvestment = value;
              //Change color according to value of goal
              if (value == 'billGoal') {
                // color = Colors.brown;
              }
            });
            //print(goal);
          },
        ),
      ),
    );
  }

  Widget _goalClass() {
    String goal;
    data["goalCategory"] == 'Loan Fund'
        ? goal = 'Loan Fund'
        : data["goalCategory"] == 'Group'
            ? goal = 'Group'
            : goal = data["goalType"];

    return IgnorePointer(
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton(
          items: null,
          underline: Divider(
            color: Colors.transparent,
          ),
          value: classInvestment,
          hint: Text(
            '$goal',
            style: GoogleFonts.muli(textStyle: TextStyle()),
          ),
          icon: Icon(
            CupertinoIcons.down_arrow,
            color: Colors.black,
          ),
          isExpanded: true,
          onChanged: (value) {
            setState(() {
              classInvestment = value;
            });
            //print(goal);
          },
        ),
      ),
    );
  }

  Widget _amountWidget() {
    //Check if the goal is a group
    var amount;
    data["goalCategory"] == 'Group'
        ? amount = data["targetAmountPerp"]
        : amount = data["goalAmount"];

    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 50,
                      child: TextFormField(
                        enabled: true,
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.black)),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please specify an amount';
                          }
                          return null;
                        },
                        onSaved: _handleSavedAmount,
                        decoration: InputDecoration(
                          hintText: '${amount.toStringAsFixed(2)}',
                          suffixText: ' KES',
                          suffixStyle: GoogleFonts.muli(
                              textStyle: TextStyle(color: Colors.black)),
                          hintStyle: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateBtnPressed() async {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      //Show a dialog
      _showUserUpdateProgress();
      //Update goal
      await _firestore
          .collection("users")
          .document(data["uid"])
          .collection("goals")
          .document(data["docId"])
          .updateData({'goalAmount': amount});

      ActivityModel updateGoal = new ActivityModel(
          activityDate: Timestamp.now(),
          activity: 'You updated your ${data['goalCategory']} goal');

      await authService.postActivity(data['uid'], updateGoal);
      //Pop dialog
      Navigator.of(context).pop();
      _promptUserUpdateSuccess();
    }
  }

  Future _promptUserUpdateSuccess() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return SuccessMessage(message: 'Your goal has been updated');
        });
  }

  Future _showUserUpdateProgress() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CustomProgressDialog(message: 'Updating your goal...');
        });
  }

  Widget _updateBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        disabledColor: Colors.grey,
        onPressed: _updateBtnPressed,
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: commonColor,
        child: Text(
          'UPDATE',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
            letterSpacing: 1.5,
            color: Colors.white,
            fontSize: 20,
          )),
        ),
      ),
    );
  }

  Widget _maturityDateWidget() {
    //Get the timestamp from 'data'
    Timestamp retrievedTimestamp = data["goalEndDate"];
    //Convert timestamp to date
    DateTime endDate = retrievedTimestamp.toDate();
    _dateDay = endDate.day.toString();
    _dateMonth = endDate.month;
    _dateYear = endDate.year.toString();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'End Date',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 16)),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
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
                            textStyle: TextStyle(color: Colors.black)),
                      ),
                      Text(
                        '--',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.black)),
                      ),
                      Text(
                        '${monthNames[_dateMonth - 1]}',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.black)),
                      ),
                      Text(
                        '--',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.black)),
                      ),
                      Text(
                        '$_dateYear',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                )),
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.black,
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
                        }
                      });
                    });
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _typeWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          Text('Type',
              style: GoogleFonts.muli(
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.normal))),
          SizedBox(
            height: 5,
          ),
          _goalType()
        ],
      ),
    );
  }

  Widget _specificGoalWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          Text('Goal',
              style: GoogleFonts.muli(
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.normal))),
          SizedBox(
            height: 5,
          ),
          _goalClass()
        ],
      ),
    );
  }

  Future redeemPressed() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: RedeemGoal(
            docId: goalDocId,
            goalModel: goalModel,
            token: token,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      },
    );
  }

  Future cannotRedeemPressed(String message) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return WarningMessage(message: message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //Retrieve the data
    data = ModalRoute.of(context).settings.arguments;
    goalDocId = data['docId'];
    token = data['token'];
    goalModel = GoalModel.fromJson(data);
    // print('EDIT GOAL PAGE DATA: $data');

    return Scaffold(
        appBar: AppBar(
          backgroundColor: commonColor,
          title: Text('Edit ${data["goalCategory"]} Goal',
              style: GoogleFonts.muli(textStyle: TextStyle())),
          actions: [
            data["isGoalDeletable"]
                ? data['goalAmountSaved'] == 0
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: _deleteGoal,
                      )
                    : Text('')
                : Text('')
          ],
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _goalSummary(),
                        SizedBox(
                          height: 30,
                        ),
                        _typeWidget(),
                        SizedBox(
                          height: 30,
                        ),
                        _specificGoalWidget(),
                        SizedBox(
                          height: 30,
                        ),
                        _amountWidget(),
                        SizedBox(
                          height: 30,
                        ),
                        _maturityDateWidget(),
                        _updateBtn()
                      ],
                    ),
                  ),
                ),
              ),
            ),
            value: SystemUiOverlayStyle.light),
        floatingActionButton: goalModel.goalCategory == 'Group'
            ? Container()
            : MaterialButton(
                color: Colors.greenAccent[700],
                elevation: 16,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Redeem',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(color: Colors.white))),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(Icons.redeem, color: Colors.white)
                    ],
                  ),
                ),
                onPressed: () {
                  if (goalModel.goalCategory == 'Loan Fund') {
                    if (goalModel.goalAmountSaved > 200) {
                      redeemPressed();
                    } else {
                      cannotRedeemPressed(
                          'We hold a non-redeemable fee of 200 KES for all Loan Fund Goals. You have saved ${goalModel.goalAmountSaved.toStringAsFixed(2)} KES');
                    }
                  }
                  if (goalModel.goalCategory == 'Investment' ||
                      goalModel.goalCategory == 'Saving') {
                    if (goalModel.goalAmountSaved > 0) {
                      if (goalModel.goalAmountSaved >= goalModel.goalAmount) {
                        redeemPressed();
                      } else {
                        var remaining =
                            goalModel.goalAmount - goalModel.goalAmountSaved;
                        cannotRedeemPressed(
                            'You have not reached the target. You have saved ${goalModel.goalAmountSaved.toStringAsFixed(2)} KES. You need to save ${remaining.toStringAsFixed(2)} KES to reach the target.');
                      }
                    } else {
                      var remaining =
                          goalModel.goalAmount - goalModel.goalAmountSaved;
                      cannotRedeemPressed(
                          'You have not reached the target. You have saved ${goalModel.goalAmountSaved.toStringAsFixed(2)} KES. You need to save ${remaining.toStringAsFixed(2)} KES to reach the target.');
                    }
                  }
                }));
  }
}
