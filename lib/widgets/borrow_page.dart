import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/loanModel.dart';
import 'package:wealth/utilities/styles.dart';

class BorrowPage extends StatefulWidget {
  final String uid;
  BorrowPage({Key key, @required this.uid}) : super(key: key);

  @override
  _BorrowPageState createState() => _BorrowPageState();
}

class _BorrowPageState extends State<BorrowPage> {
  final styleLabel =
      GoogleFonts.muli(textStyle: TextStyle(color: Colors.white, fontSize: 15));

  final styleAmount = GoogleFonts.muli(
      textStyle: TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  ));

  //Set an average loan to be 30 days
  static DateTime rightNow = DateTime.now();
  static DateTime oneMonthFromNow = rightNow.add(Duration(days: 30));

  DateTime _date;
  String _dateDay = oneMonthFromNow.day.toString();
  int _dateMonth = oneMonthFromNow.month;
  String _dateYear = oneMonthFromNow.year.toString();

  Firestore _firestore = Firestore.instance;

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

  //Placeholder of type
  String typeLoan;
  List<String> takeLoanFrom;

  //Placeholder of amount
  double amountLoan = 0;
  //Interest placeholder
  double interestLoan = 1;
  //L+IC placeholder
  double interestCoverLoan = 0;
  /*
  Loan + IC = (Loan Amount/Total Investments) * 100
  In the initial stage, it is 0%
  */

  //Define Dropdown Menu Items
  List<DropdownMenuItem> items = [
    DropdownMenuItem(
      value: 'self',
      child: Text(
        'Self Loan',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'p2p',
      child: Text(
        'Peer to Peer Loan',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  Widget _loanTypeDropdownWidget() {
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
        value: typeLoan,
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
            typeLoan = value;

            if (value == 'self') {
              takeLoanFrom = [widget.uid];
            }
            if (value == 'p2p') {}
          });
        },
      ),
    );
  }

  Widget _loanAmountWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Slider.adaptive(
              value: amountLoan,
              inactiveColor: Colors.white,
              divisions: 10,
              min: 0,
              max: 5000,
              label: amountLoan.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  amountLoan = value;
                });
              }),
        ),
        Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '${amountLoan.toInt().toString()} KES',
                style: labelStyle,
              ),
            ))
      ],
    );
  }

  Widget _loanInterestWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Slider.adaptive(
              value: interestLoan,
              inactiveColor: Colors.white,
              divisions: 20,
              min: 0,
              max: 20,
              label: interestLoan.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  interestLoan = value;
                });
              }),
        ),
        Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '${interestLoan.toInt().toString()} %',
                style: labelStyle,
              ),
            ))
      ],
    );
  }

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

  Widget _loanICWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Text(
            'Loan + Interest Cover',
            style: styleLabel,
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              '${interestCoverLoan.toInt().toString()} %',
              style: labelStyle,
            ),
          ),
        )
      ],
    );
  }

  Widget _p2pButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FlatButton(
          onPressed: () {},
          color: Colors.white70,
          child: Text(
            'All',
            style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.black, letterSpacing: 2)),
          ),
        ),
        FlatButton(
          onPressed: () {},
          color: Colors.blue,
          child: Text(
            'Specific',
            style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.white, letterSpacing: 2)),
          ),
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
                  'Your loan application has been received',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
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
                  'Processing your request...',
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

  Future _applyForALoan(LoanModel model) async {
    //Add request to Loans Collections
    final String _collection = "loans";
    await _firestore.collection(_collection).document().setData(model.toJson());
  }

  void _applyBtnPressed() {
    //Check if loan type is selected
    if (typeLoan == null) {
      _promptUser("Please select the type of loan you want");
    }
    //Check if amount is not the default of 0
    else if (amountLoan == 0) {
      _promptUser("Please select the loan amount you want");
    } else if (_date == null) {
      _promptUser("Please select the payback date");
    } else {
      //Create an instance of a Loan
      LoanModel loanModel = new LoanModel(
          loanAmountRepaid: 0,
          loanAmountTaken: amountLoan,
          loanInterest: interestLoan,
          loanIC: interestCoverLoan,
          loanTakenDate: rightNow,
          loanEndDate: _date,
          loanLenders: takeLoanFrom,
          loanBorrower: widget.uid);

      //Show a dialog
      _showUserProgress();

      _applyForALoan(loanModel).whenComplete(() {
        //Pop that dialog
        //Show a success message for two seconds
        Timer(Duration(seconds: 2), () => Navigator.of(context).pop());

        //Show a success message for two seconds
        Timer(Duration(seconds: 3), () => _promptUserSuccess());

        //Show a success message for two seconds
        Timer(Duration(seconds: 4), () => Navigator.of(context).pop());

        //Pop the dialog then redirect to home page
        Timer(Duration(milliseconds: 4500), () {
          Navigator.of(context).popAndPushNamed('/home', arguments: widget.uid);
        });
      }).catchError((error) {
        _promptUser(error);
      });
    }
  }

  Widget _applyBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: _applyBtnPressed,
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.white,
        child: Text(
          'APPLY',
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
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Which type of loan do you want ?',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            _loanTypeDropdownWidget(),
            SizedBox(
              height: 30,
            ),
            Text(
              'Amount',
              style: styleLabel,
            ),
            _loanAmountWidget(),
            SizedBox(
              height: 30,
            ),
            Text(
              'Interest Offer',
              style: styleLabel,
            ),
            _loanInterestWidget(),
            SizedBox(
              height: 30,
            ),
            Text(
              'I want to set an end date',
              style: styleLabel,
            ),
            _loanDurationWidget(),
            SizedBox(
              height: 30,
            ),
            _loanICWidget(),
            SizedBox(
              height: 30,
            ),
            typeLoan == 'p2p'
                ? Text(
                    'Who will receive the request',
                    style: styleLabel,
                  )
                : Text(''),
            SizedBox(
              height: 10,
            ),
            typeLoan == 'p2p' ? _p2pButtons() : Text(''),
            _applyBtn()
          ],
        ),
      ),
    );
  }
}
