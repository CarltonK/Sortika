import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/global/progressDialog.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/global/warningMessage.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/groupModel.dart';
import 'package:wealth/utilities/styles.dart';
import 'package:uuid/uuid.dart';

class GroupSavings extends StatefulWidget {
  final String uid;
  GroupSavings({Key key, @required this.uid}) : super(key: key);
  @override
  _GroupSavingsState createState() => _GroupSavingsState();
}

class _GroupSavingsState extends State<GroupSavings> {
  //Form Key
  final _formKey = GlobalKey<FormState>();

  //FocusNodes
  final focusObjective = FocusNode();
  final focusAmount = FocusNode();
  final focusAmountPP = FocusNode();

  //Identifiers
  String _name, _objective;
  double _amount, _amountpp;
  String _groupCode;

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
          style: labelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.text,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.white,
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
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[200])),
                errorStyle: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.red[200],
                )),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon: Icon(Icons.people, color: Colors.white),
                labelText: 'Give your group a name',
                labelStyle: hintStyle))
      ],
    );
  }

  //Group Name
  Widget _groupObjective() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Group Objective',
          style: labelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.text,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.white,
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
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[200])),
                errorStyle: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.red[200],
                )),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon: Icon(Icons.people, color: Colors.white),
                labelText: 'What is the objective of the group?',
                labelStyle: hintStyle))
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
          style: labelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.number,
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.white,
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
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[200])),
                errorStyle: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.red[200],
                )),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon:
                    Icon(FontAwesome5.money_bill_alt, color: Colors.white),
                labelText: 'What is your target?',
                labelStyle: hintStyle))
      ],
    );
  }

  //Target Amount
  //Group Name
  Widget _groupTargetAmountpp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Minimum amount per person',
          style: labelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.number,
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
                return 'Please provide a personal contribution amount';
              }

              return null;
            },
            focusNode: focusAmountPP,
            textInputAction: TextInputAction.done,
            onSaved: _handleSubmittedAmountpp,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[200])),
                errorStyle: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.red[200],
                )),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon:
                    Icon(FontAwesome5.money_bill_alt, color: Colors.white),
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
              inactiveColor: Colors.white,
              divisions: 10,
              min: 1,
              max: 500,
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
                    style: labelStyle,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    members.toInt() == 1 ? Icons.person : Icons.people,
                    color: Colors.white,
                  )
                ],
              ),
            ))
      ],
    );
  }

  //Group Registration Status
  Widget _groupRegistrationStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Is this group registered?',
          style: labelStyle,
        ),
        Container(
          child: Row(
            children: <Widget>[
              Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.white),
                  child: Checkbox(
                      value: _isRegistered,
                      checkColor: Colors.greenAccent[700],
                      activeColor: Colors.white,
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
          style: labelStyle,
        ),
        Container(
          child: Theme(
              data: ThemeData(unselectedWidgetColor: Colors.white),
              child: Checkbox(
                  value: _canSeeSavings,
                  checkColor: Colors.greenAccent[700],
                  activeColor: Colors.white,
                  onChanged: (bool value) {
                    setState(() {
                      _canSeeSavings = value;
                    });
                  })),
        )
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

  Future _createGroupGoal(GroupModel model) async {
    try {
      //This is the name of the collection we will be reading
      final String _collectionUpper = 'users';
      final String _collectionLower = 'goals';
      var document =
          _firestore.collection(_collectionUpper).document(widget.uid);

      //Save goal to goals subcollection
      await document
          .collection(_collectionLower)
          .document()
          .setData(model.toJson());

      //Save group to groups collection
      await _firestore.collection("groups").document().setData(model.toJson());

      //Create an activity
      ActivityModel groupSavingsAct = new ActivityModel(
          activity: 'You created a group called $_name',
          activityDate: Timestamp.fromDate(rightNow));
      await authService.postActivity(widget.uid, groupSavingsAct);
    } catch (e) {
      print(e.toString());
      return e;
    }
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

        _groupCode = codeGenerator();

        GroupModel model = new GroupModel(
            groupAdmin: widget.uid,
            goalAmountSaved: 0,
            goalCategory: 'Group',
            goalCreateDate: Timestamp.fromDate(rightNow),
            goalEndDate: Timestamp.fromDate(_date),
            goalName: _name,
            members: membersList,
            goalAllocation: 0,
            groupCode: _groupCode,
            groupMembersTargeted: members.toInt(),
            groupMembers: 1,
            uid: widget.uid,
            groupObjective: _objective,
            isGoalDeletable: true,
            isGroupRegistered: _isRegistered,
            shouldMemberSeeSavings: _canSeeSavings,
            goalAmount: _amount,
            targetAmountPerp: _amountpp);

        _createGroupGoal(model).then((value) {
          _promptUserSuccess('Your group has been created successfully');
        }).catchError((error) {
          if (error.toString().contains('PERMISSION_DENIED')) {
          _promptUser('Your session has expired. Please login again');
        }
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
        color: Colors.white,
        child: Text(
          'CREATE GROUP',
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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                  style: labelStyle,
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
                  style: labelStyle,
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
