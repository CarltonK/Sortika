import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/global/warningMessage.dart';
import 'package:wealth/models/goalmodel.dart';
import 'package:wealth/models/investmentModel.dart';
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

  void _handleSubmittedAmount(String value) {
    targetAmount = double.parse(value.trim());
    print('Amount: ' + targetAmount.toString());
  }

  //Set an average loan to be 30 days
  static DateTime rightNow = DateTime.now();
  static DateTime oneMonthFromNow = rightNow.add(Duration(days: 30));

  Future<List<InvestmentModel>> fetchData;
  Helper helper = new Helper();

  List<InvestmentModel> _classes = [];
  List<dynamic> _types = [];

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

  Future _createSavingsGoal(GoalModel model) async {
    /*
    Before we go to the next page we need to auto create a savings goal
    */

    //This is the name of the collection we will be reading
    final String _collectionUpper = 'users';
    final String _collectionLower = 'goals';
    var document = _firestore.collection(_collectionUpper).document(widget.uid);

    try {
      //Save goal to goals subcollection
      await document
          .collection(_collectionLower)
          .document()
          .setData(model.toJson());

      // //Create an activity
      // ActivityModel investmentAct = new ActivityModel(
      //     activity: 'You created a new Savings Goal in the $classSavings class',
      //     activityDate: Timestamp.fromDate(rightNow));
      // await authService.postActivity(widget.uid, investmentAct);
    } catch (e) {
      throw e.toString();
    }
  }

  void _setBtnPressed() async {
    //Dismiss the keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    //Check if goal class exists
    if (classSavings == null) {
      _promptUser("You haven't told us what you're saving towards");
    } else if (classSavings == 'Custom' && goalName == null) {
      addGoalName();
    } else if (typeSavings == null) {
      _promptUser("You haven't selected the goal type");
    } else if (targetAmount == 0) {
      _promptUser("Please select an amount");
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
          goalCategory: 'Saving',
          goalClass: classSavings,
          goalName: goalName,
          growth: 0,
          interest: 0,
          goalType: typeSavings,
          uid: widget.uid,
          isGoalDeletable: true,
          goalAmountSaved: 0,
          goalAllocation: 0);

      //  //Retrieve USER DOC
      //   DocumentSnapshot userDoc = await _firestore.collection("users").document(widget.uid).get();
      //   User user = User.fromJson(userDoc.data);

      _createSavingsGoal(goalModel).then((value) {
        //Show a success message for two seconds
        _promptUserSuccess('Your savings goal has been created successfully');
      }).catchError((error) {
        if (error.toString().contains('PERMISSION_DENIED')) {
          _promptUser('Your session has expired. Please login again');
        }
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
                      //Dismiss the keyboard
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
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
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${map.title}',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    Text(
                                      '${map.subtitle}',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
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
      typeSavings = ' ';
      _types = [
        {'name': ' '}
      ];
      classSavings = value;
      _types = List.from(_types)..addAll(getgoalByTitle(value));
      print(_types);

      if (value == 'Custom') {
        addGoalName();
      }
    });
  }

  getgoalByTitle(String value) => _classes
      .map((map) => map)
      .where((item) => item.title == value)
      .map((item) => item.types)
      .expand((i) => i)
      .toList();

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
        value: typeSavings,
        disabledHint: Text(
          'Please select a class',
          style: GoogleFonts.muli(
              textStyle: TextStyle(fontWeight: FontWeight.w600)),
        ),
        items: _types.map((map) {
          String name = map['name'];
          return DropdownMenuItem(
            value: name,
            child: Text(
              name,
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
            typeSavings = value;
            print(typeSavings);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
            onChanged: _handleSubmittedAmount,
            validator: (value) {
              //Check if phone is available
              if (value.isEmpty) {
                return 'Amount is required';
              }
              return null;
            },
            autovalidate: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              errorBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              prefixIcon:
                  Icon(FontAwesome5.money_bill_alt, color: Colors.white),
              suffixText: 'KES',
              suffixStyle: hintStyle,
            ))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData = helper.getSavingsddData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
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
              classSavings == 'Custom'
                  ? IgnorePointer(
                      child: _goalType(),
                    )
                  : _goalType(),
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
                classSavings == 'Custom' && goalName != null
                    ? 'I have decided to create my own goal titled: ${goalName.toUpperCase()}'
                    : '',
                textAlign: TextAlign.left,
                style: styleLabel,
              ),
              _setGoalBtn()
            ],
          ),
        ),
      ),
    );
  }
}
