import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/groupModel.dart';
import 'package:wealth/utilities/styles.dart';

class GroupSavingsColored extends StatefulWidget {
  final String uid;
  GroupSavingsColored({Key key, @required this.uid}) : super(key: key);
  @override
  _GroupSavingsColoredState createState() => _GroupSavingsColoredState();
}

class _GroupSavingsColoredState extends State<GroupSavingsColored> {
  //Form Key
  final _formKey = GlobalKey<FormState>();

  //FocusNodes
  final focusObjective = FocusNode();
  final focusAmount = FocusNode();
  final focusAmountPP = FocusNode();

  //Identifiers
  String _name, _objective;
  double _amount, _amountpp;
  String gID;

  //Members
  double members = 1;

  //Group Registration status
  bool _isRegistered = false;
  bool _canSeeSavings = false;

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

  //Handle Name Input
  void _handleSubmittedName(String value) {
    _name = value.trim();
    print('Group Name: ' + _name);
  }

  //Handle Objective Input
  void _handleSubmittedObjective(String value) {
    _objective = value.trim();
    print('Group Objective: ' + _objective);
  }

  //Handle Amount Input
  void _handleSubmittedAmount(String value) {
    _amount = double.parse(value.trim());
    print('Amount: ' + _amount.toString());
  }

  //Handle Amount Per person Input
  void _handleSubmittedAmountpp(String value) {
    _amountpp = double.parse(value.trim());
    print('Amount pp: ' + _amountpp.toString());
  }

  //Group Name
  Widget _groupName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Group Name',
          style: GoogleFonts.muli(
              textStyle:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.text,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
            maxLines: 1,
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(focusObjective);
            },
            validator: (value) {
              //Check if password is empty
              if (value.isEmpty) {
                return 'Group name is required';
              }

              return null;
            },
            textInputAction: TextInputAction.next,
            onSaved: _handleSubmittedName,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                errorStyle: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.red,
                )),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                prefixIcon: Icon(Icons.people, color: Colors.black),
                labelText: 'Give your group a name',
                labelStyle: hintStyleBlack))
      ],
    );
  }

  Widget _groupObjective() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Group Objective',
          style: labelStyleBlack,
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.text,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
            maxLines: 2,
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(focusAmount);
            },
            validator: (value) {
              //Check if password is empty
              if (value.isEmpty) {
                return 'Group objective is required';
              }

              return null;
            },
            focusNode: focusObjective,
            textInputAction: TextInputAction.next,
            onSaved: _handleSubmittedObjective,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                errorStyle: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.red,
                )),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                prefixIcon: Icon(Icons.people, color: Colors.black),
                labelText: 'What is the objective of the group?',
                labelStyle: hintStyleBlack))
      ],
    );
  }

  //Target Amount
  Widget _groupTargetAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Target Amount',
          style: labelStyleBlack,
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.number,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(focusAmountPP);
            },
            validator: (value) {
              //Check if password is empty
              if (value.isEmpty) {
                return 'You have not specified the target amount';
              }

              return null;
            },
            focusNode: focusAmount,
            textInputAction: TextInputAction.next,
            onSaved: _handleSubmittedAmount,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                errorStyle: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.red,
                )),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                prefixIcon:
                    Icon(FontAwesome5.money_bill_alt, color: Colors.black),
                labelText: 'What is your target?',
                labelStyle: hintStyleBlack))
      ],
    );
  }

  //Target Amount
  Widget _groupTargetAmountpp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Minimum amount per person',
          style: labelStyleBlack,
        ),
        SizedBox(
          height: 10,
        ),
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
                return 'Please provide a personal contribution amount';
              }

              return null;
            },
            focusNode: focusAmountPP,
            textInputAction: TextInputAction.done,
            onSaved: _handleSubmittedAmountpp,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                errorStyle: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.red,
                )),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                prefixIcon:
                    Icon(FontAwesome5.money_bill_alt, color: Colors.black),
                labelText: 'How much should each contribute?',
                labelStyle: hintStyle))
      ],
    );
  }

  //Group target membership
  Widget _groupMemberTarget() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Slider.adaptive(
              value: members,
              inactiveColor: Colors.black26,
              divisions: 15,
              min: 1,
              max: 150,
              label: members.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  members = value;
                });
              }),
        ),
        Expanded(
            flex: 1,
            child: Center(
              child: Row(
                children: <Widget>[
                  Text(
                    '${members.toInt().toString()}',
                    style: labelStyleBlack,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    members.toInt() == 1 ? Icons.person : Icons.people,
                    color: Colors.black,
                  )
                ],
              ),
            ))
      ],
    );
  }

  Widget _grouptDurationWidget() {
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

  //Group Registration Status
  Widget _groupRegistrationStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Is this group registered?',
          style: labelStyleBlack,
        ),
        Container(
          child: Row(
            children: <Widget>[
              Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.black),
                  child: Checkbox(
                      value: _isRegistered,
                      checkColor: Colors.white,
                      activeColor: Colors.black,
                      onChanged: (bool value) {
                        setState(() {
                          _isRegistered = value;
                        });
                      })),
            ],
          ),
        )
      ],
    );
  }

  //Widget Group Permissions. Should members see savings total
  Widget _shouldMembersSeeTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Should members see total savings?',
          style: labelStyleBlack,
        ),
        Container(
          child: Theme(
              data: ThemeData(unselectedWidgetColor: Colors.black),
              child: Checkbox(
                  value: _canSeeSavings,
                  checkColor: Colors.white,
                  activeColor: Colors.black,
                  onChanged: (bool value) {
                    setState(() {
                      _canSeeSavings = value;
                    });
                  })),
        )
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
                  'Your group has been created successfully',
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
                  'Creating your group...',
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

  Future _createGroupGoal(GroupModel model) async {
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

    //Save group to groups collection
    await _firestore.collection("groups").document().setData(model.toJson());
  }

  void createBtnPressed() async {
    if (_date == null) {
      _promptUser("Please select the target end date");
    }
    //Check if goal ends on the same day
    else if (_date.difference(rightNow).inDays < 1) {
      _promptUser('The goal end date is too soon');
    } else {
      final form = _formKey.currentState;
      if (form.validate()) {
        form.save();

        List<String> membersList = [widget.uid];

        GroupModel model = new GroupModel(
            groupAdmin: widget.uid,
            goalAmountSaved: 0,
            goalCategory: 'Group',
            goalCreateDate: Timestamp.now(),
            goalEndDate: Timestamp.fromDate(_date),
            goalName: _name,
            members: membersList,
            goalAllocation: 0,
            groupCode: gID,
            groupMembersTargeted: members.toInt(),
            groupMembers: 1,
            groupObjective: _objective,
            isGoalDeletable: true,
            isGroupRegistered: _isRegistered,
            shouldMemberSeeSavings: _canSeeSavings,
            goalAmount: _amount,
            uid: widget.uid,
            targetAmountPerp: _amountpp);

        //Create an activity
        ActivityModel groupSavingsAct = new ActivityModel(
            activity: 'You created a group called $_name',
            activityDate: Timestamp.fromDate(rightNow));
        await authService.postActivity(widget.uid, groupSavingsAct);

        //Show a dialog
        _showUserProgress();

        _createGroupGoal(model).whenComplete(() {
          //Pop that dialog
          //Show a success message for two seconds
          Timer(Duration(seconds: 3), () => Navigator.of(context).pop());

          //Show a success message for two seconds
          Timer(Duration(seconds: 4), () => _promptUserSuccess());

          //Show a success message for two seconds
          Timer(Duration(seconds: 5), () => Navigator.of(context).pop());
        }).catchError((error) {
          _promptUser(error);
        });
      }
    }
  }

  Widget _createGroupBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: createBtnPressed,
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.blue,
        child: Text(
          'CREATE GROUP',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
                  letterSpacing: 1.5,
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  generateUniqueCode() {
    var uuid = new Uuid();
    var splitId = uuid.v1().split('-');
    gID = splitId[0];
    print(gID);
  }

  @override
  void initState() {
    super.initState();
    generateUniqueCode();
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Setup a new group',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 30,
                ),
                _groupName(),
                SizedBox(
                  height: 30,
                ),
                _groupObjective(),
                SizedBox(
                  height: 30,
                ),
                _groupTargetAmount(),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'How many members are you targeting?',
                  style: labelStyleBlack,
                ),
                _groupMemberTarget(),
                SizedBox(
                  height: 20,
                ),
                _groupTargetAmountpp(),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Until when?',
                  style: labelStyleBlack,
                ),
                _grouptDurationWidget(),
                SizedBox(
                  height: 10,
                ),
                _groupRegistrationStatus(),
                _shouldMembersSeeTotal(),
                _createGroupBtn()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
