import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/loanModel.dart';
import 'package:wealth/utilities/styles.dart';

class UpdateLoan extends StatefulWidget {
  @override
  _UpdateLoanState createState() => _UpdateLoanState();
}

class _UpdateLoanState extends State<UpdateLoan> {
  final _formKey = GlobalKey<FormState>();
  static LoanModel loan;
  Map<String, dynamic> loanData;

  double _amount;
  //Handle Password Input
  void _handleSubmittedAmount(String value) {
    _amount = double.parse(value);
    print('Amount: ' + _amount.toString());
  }

  double _interest;
  //Handle Password Input
  void _handleSubmittedInterest(String value) {
    _interest = double.parse(value);
    print('Interest: ' + _interest.toString());
  }

  bool _hasTextChanged = false;
  DateTime rightNow = DateTime.now();
  AuthService authService = new AuthService();
  Helper helper = new Helper();

  Widget _receiptText() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: 'You have received a loan request from  ',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black))),
              TextSpan(
                  text: loan.borrowerName,
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      decoration: TextDecoration.underline)),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _containerAmount() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Amount',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextFormField(
                autofocus: false,
                initialValue: loan.loanAmountTaken.toString(),
                keyboardType: TextInputType.number,
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.black,
                )),
                onChanged: (value) {
                  setState(() {
                    _hasTextChanged = true;
                  });
                },
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
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    suffixText: 'KES',
                    suffixStyle: hintStyleBlack,
                    labelText: 'Loan Amount',
                    labelStyle: hintStyleBlack)),
          )
        ],
      ),
    );
  }

  Widget _containerInterest() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Interest',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextFormField(
                autofocus: false,
                initialValue: loan.loanInterest.toString(),
                keyboardType: TextInputType.number,
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.black,
                )),
                onChanged: (value) {
                  setState(() {
                    _hasTextChanged = true;
                  });
                },
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                validator: (value) {
                  //Check if phone is available
                  if (value.isEmpty) {
                    return 'Interest Rate is required';
                  }
                  if (value.startsWith('0')) {
                    return 'Interest is less than 1%';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onSaved: _handleSubmittedInterest,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    suffixText: '%',
                    suffixStyle: hintStyleBlack,
                    labelText: 'Interest Rate',
                    labelStyle: hintStyleBlack)),
          )
        ],
      ),
    );
  }

  Widget _containerDuration() {
    //Date Parsing and Formatting
    Timestamp dateRetrieved = loan.loanEndDate;
    var formatter = new DateFormat('d MMM y');
    String date = formatter.format(dateRetrieved.toDate());

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ending',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextFormField(
                keyboardType: TextInputType.number,
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                  color: Colors.black,
                )),
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                enabled: false,
                decoration: InputDecoration(
                  hintText: date,
                  hintStyle: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                  border: InputBorder.none,
                )),
          )
        ],
      ),
    );
  }

  Widget _cardTerms() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _containerAmount(),
              SizedBox(
                height: 10,
              ),
              _containerInterest(),
              SizedBox(
                height: 10,
              ),
              _containerDuration()
            ],
          ),
        ),
      ),
    );
  }

  Widget _lIc() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Loan + Interest Cover',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        Text('${loan.loanIC.toString()} %',
            style: GoogleFonts.muli(
              textStyle:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
            ))
      ],
    );
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
                  'Updating Loan Terms...',
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
                  'Your loan revision has been sent successfully',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
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

  void _updateBtnPressed() async {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      //Change Loan Updated
      _showUserProgress();
      //Create an activity
      ActivityModel updateAct = new ActivityModel(
          activity: 'You updated a loan request',
          activityDate: Timestamp.fromDate(rightNow));
      await authService.postActivity(loanData['uid'], updateAct);

      helper
          .updateLoanDoc(loanData['docId'], _amount, _interest)
          .whenComplete(() {
        //Pop that dialog
        Navigator.of(context).pop();
        //Show a success message for two seconds
        _promptUserSuccess();
      }).catchError((error) {
        _promptUser(error);
      });
    }
  }

  Widget _btnUpdate() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: _hasTextChanged ? _updateBtnPressed : null,
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

  @override
  Widget build(BuildContext context) {
    loanData = ModalRoute.of(context).settings.arguments;
    loan = LoanModel.fromJson(loanData);
    //print(loanData);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: commonColor,
        title: Text('Update Request',
            style: GoogleFonts.muli(textStyle: TextStyle())),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _receiptText(),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Terms',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _cardTerms(),
                  SizedBox(
                    height: 20,
                  ),
                  _lIc(),
                  _btnUpdate()
                ],
              ),
            ),
          ),
          value: SystemUiOverlayStyle.light),
    );
  }
}
