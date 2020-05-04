import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/autoCreateModel.dart';
import 'package:wealth/utilities/styles.dart';

class AutoCreate extends StatefulWidget {
  final String uid;
  AutoCreate({this.uid});

  @override
  _AutoCreateState createState() => _AutoCreateState();
}

class _AutoCreateState extends State<AutoCreate> {
  final _formKey = GlobalKey<FormState>();

  //Set an average loan to be 30 days
  static DateTime rightNow = DateTime.now();
  static DateTime oneMonthFromNow = rightNow.add(Duration(days: 30));

  DateTime _date;
  String _dateDay = oneMonthFromNow.day.toString();
  int _dateMonth = oneMonthFromNow.month;
  String _dateYear = oneMonthFromNow.year.toString();
  static String docID;

  String currentRate;
  List<DropdownMenuItem> items = [
    DropdownMenuItem(
        value: 'low',
        child: Text(
          '< 10.5 %',
          style: GoogleFonts.muli(
              textStyle:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        )),
    DropdownMenuItem(
        value: 'med',
        child: Text(
          '10.5 %  <  X  <=  18 %',
          style: GoogleFonts.muli(
              textStyle:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        )),
    DropdownMenuItem(
        value: 'high',
        child: Text(
          '> 18 %',
          style: GoogleFonts.muli(
              textStyle:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        ))
  ];

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

  double _amount;
  //Handle Password Input
  void _handleSubmittedAmount(String value) {
    _amount = double.parse(value);
    print('Amount: ' + _amount.toString());
  }

  Widget _targetAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Target amount',
          style: labelStyle,
        ),
        SizedBox(
          height: 5,
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
              //Check if phone is available
              if (value.isEmpty) {
                return 'Amount is required';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onSaved: _handleSubmittedAmount,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon:
                    Icon(FontAwesome5.money_bill_alt, color: Colors.white),
                labelText: 'Enter the target amount',
                labelStyle: hintStyle))
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
        child: DropdownButton(
          items: items,
          underline: Divider(
            color: Colors.transparent,
          ),
          value: currentRate,
          hint: Text(
            'Rate in %',
            style: GoogleFonts.muli(textStyle: TextStyle()),
          ),
          icon: Icon(
            CupertinoIcons.down_arrow,
            color: Colors.black,
          ),
          isExpanded: true,
          onChanged: (value) async {
            setState(() {
              currentRate = value;
              print(currentRate);
            });
          },
        ));
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
                  'Creating your goals...',
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

  Future _showReturnRateAmount() async {
    return showCupertinoModalPopup(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: StreamBuilder(
            stream: _firestore.collection('autocreates')
              .where("uid",isEqualTo: widget.uid)
              .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data.documents[0].data["returnInterestRate"] != null) {
                docID = snapshot.data.documents[0].documentID;
                return Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sentiment_very_satisfied, color: Colors.greenAccent[700],size: 100,),
                      SizedBox(height: 10,),
                      Text(
                        'Interest Rate: ${snapshot.data.documents[0].data["returnInterestRate"].toStringAsFixed(2)} %', 
                        style: GoogleFonts.muli(
                          textStyle: TextStyle(
                          ))
                      ),
                      SizedBox(height: 10,),
                      Text(
                        'Return Amount: ${snapshot.data.documents[0].data["returnAmount"].toStringAsFixed(2)} KES', 
                      style: GoogleFonts.muli(
                        textStyle: TextStyle(
                        )
                      ),
                      )
                    ],
                  ),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SpinKitDoubleBounce(
                    size: 100,
                    color: Colors.greenAccent[700],
                  ),
                ],
              );
            },),
        );
      });
  }

  void _createBtnPressed() async {
    if (_date == null) {
      _promptUser("Please select the targeted end date");
    } else if (currentRate == null) {
      _promptUser("Please select the expected return rate");
    } else {
      final FormState form = _formKey.currentState;
      if (form.validate()) {
        form.save();
        //Show a progress Dialog
        _showUserProgress();
        AutoCreateModel model = new AutoCreateModel(
            amount: _amount,
            endDate: Timestamp.fromDate(_date),
            returnRate: currentRate,
            uid: widget.uid);
        await authService.createAutoGoal(model);
        ActivityModel autoGoals = new ActivityModel(
            activity: 'You autocreated goals', activityDate: Timestamp.now());
        await authService.postActivity(widget.uid, autoGoals);
        //Pop Dialog
        Timer(Duration(seconds: 3), () => Navigator.of(context).pop());
        //Show return rate
        Timer(Duration(seconds: 4), () => _showReturnRateAmount());
        //Pop dialog after 2 seconds
        Timer(Duration(seconds: 10), () => Navigator.of(context).pop());
        //Delete the document
        Timer(Duration(seconds: 11), () async {
          await _firestore.collection('autocreates').document(docID).delete();
        });
      }
    }
  }

  Widget _createGoalBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: _createBtnPressed,
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.white,
        child: Text(
          'CREATE GOALS',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF73AEF5),
        elevation: 0,
        title: Text('Autocreate goals',
            style: GoogleFonts.muli(textStyle: TextStyle())),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              backgroundWidget(),
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _targetAmount(),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Choose an End Date',
                          style: labelStyle,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        _investmentDurationWidget(),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Expected Return',
                          style: labelStyle,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        _investClassWidget(),
                        currentRate == null
                        ? Container()
                        : SizedBox(height: 20,),
                        currentRate == null
                        ? Container()
                        : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Risk Profile', style: GoogleFonts.muli(textStyle: TextStyle(color: Colors.white, fontSize: 12)),),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                currentRate == 'low' ? 'LOW' : currentRate == 'med' ? 'MEDIUM' : 'HIGH', 
                              style: GoogleFonts.muli(textStyle: TextStyle(color: Colors.white, fontSize: 20)))
                            ],
                          ),
                        ),
                        _createGoalBtn()
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
