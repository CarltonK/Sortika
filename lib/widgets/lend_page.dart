import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/loanModel.dart';
import 'package:wealth/utilities/styles.dart';

class LendPage extends StatefulWidget {
  final String uid;
  final String token;
  LendPage({Key key, @required this.uid, @required this.token})
      : super(key: key);

  @override
  _LendPageState createState() => _LendPageState();
}

class _LendPageState extends State<LendPage> {
  final styleLabel =
      GoogleFonts.muli(textStyle: TextStyle(color: Colors.white, fontSize: 15));

  //Placeholder of amount
  double targetAmount = 0;

  void _handleSubmittedAmount(String value) {
    targetAmount = double.parse(value.trim());
    print('Amount: ' + targetAmount.toString());
  }

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

  Widget _loanDurationWidget() {
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
                  size: 100,
                  color: Colors.green,
                ),
                Text(
                  'Your lending application has been received',
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
                  'Sending your request...',
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

  Future _lendLoan(LoanModel model) async {
    //Change the Loan Fund Goal
    QuerySnapshot query = await _firestore
        .collection('users')
        .document(widget.uid)
        .collection('goals')
        .where('goalCategory', isEqualTo: 'Loan Fund')
        .limit(1)
        .getDocuments();
    if (query.documents.length == 1) {
      DocumentSnapshot doc = query.documents[0];
      await _firestore
          .collection('users')
          .document(widget.uid)
          .collection('goals')
          .document(doc.documentID)
          .updateData({'goalAmount': model.loanAmountTaken});
      //Add request to Loans Collections
      final String _collection = "loans";
      await _firestore
          .collection(_collection)
          .document()
          .setData(model.toJson());
    }
  }

  void _lendBtnPressed() async {
    if (targetAmount == 0) {
      _promptUser("Please select the amount you want to lend");
    } else if (_date == null) {
      _promptUser("Please select the payback date");
    } else {
      LoanModel loanModel = new LoanModel(
        loanLender: widget.uid,
        loanEndDate: Timestamp.fromDate(_date),
        loanLenderToken: widget.token,
        loanAmountTaken: targetAmount,
      );

      //Create an activity
      ActivityModel lendingAct = new ActivityModel(
          activity:
              'You have put up ${targetAmount.toInt().toString()} for lending to prospective borrowers',
          activityDate: Timestamp.fromDate(rightNow));
      await authService.postActivity(widget.uid, lendingAct);

      //Show a dialog
      _showUserProgress();

      _lendLoan(loanModel).whenComplete(() {
        //Pop that dialog
        //Show a success message for two seconds
        Timer(Duration(seconds: 2), () => Navigator.of(context).pop());

        //Show a success message for two seconds
        Timer(Duration(seconds: 3), () => _promptUserSuccess());
      }).catchError((error) {
        //Show a success message for two seconds
        Timer(Duration(seconds: 2), () => Navigator.of(context).pop());

        //Show a success message for two seconds
        Timer(Duration(seconds: 3), () => _promptUser(error));
      });
    }
  }

  Widget _lendBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: _lendBtnPressed,
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.white,
        child: Text(
          'LEND',
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

  Widget _lendAmountWidget() {
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
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon:
                    Icon(FontAwesome5.money_bill_alt, color: Colors.white),
                suffixText: 'KES',
                errorStyle: hintStyleBlack,
                suffixStyle: hintStyle,
                labelText: '',
                labelStyle: hintStyle))
      ],
    );
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '* You could also borrow from your fund at your own defined rate *',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'How much are you willing to lend?',
              style: styleLabel,
            ),
            _lendAmountWidget(),
            SizedBox(
              height: 30,
            ),
            Text(
              'Until when?',
              style: styleLabel,
            ),
            _loanDurationWidget(),
            SizedBox(
              height: 10,
            ),
            _lendBtn()
          ],
        ),
      ),
    );
  }
}
