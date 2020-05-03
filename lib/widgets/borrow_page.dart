import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/loanModel.dart';
import 'package:wealth/services/permissions.dart';
import 'package:wealth/utilities/styles.dart';

class BorrowPage extends StatefulWidget {
  final String uid;
  final String mytoken;
  final String name;
  BorrowPage(
      {Key key,
      @required this.uid,
      @required this.mytoken,
      @required this.name})
      : super(key: key);

  @override
  _BorrowPageState createState() => _BorrowPageState();
}

class _BorrowPageState extends State<BorrowPage> {
  final PermissionService _service = PermissionService();

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
  String _loanInviteeName;
  String _idInvitee;
  String _loanInviteetoken;

  Firestore _firestore = Firestore.instance;
  AuthService authService = new AuthService();

  final _formPhone = GlobalKey<FormState>();

  String _phone;
  String _phoneRetrieved;
  void _handleSubmittedPhone(String value) {
    _phone = value.trim();
    print('Phone: ' + _phone);
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

  //Placeholder of type
  String typeLoan;
  var takeLoanFrom;
  String lender;
  String lenderName;
  String lenderToken;

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
        'Borrow from savings',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'p2p',
      child: Text(
        'Borrow from others',
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
              lender = widget.uid;
            }
            if (value == 'p2p') {
              lender = null;
            }
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
//
//  Future _showContactList(Iterable<Contact> contacts) {
//    return showCupertinoModalPopup(
//        context: context,
//        builder: (BuildContext context) {
//          return AlertDialog(
//            content: Container(
//              height: MediaQuery.of(context).size.height * 0.75,
//              width: MediaQuery.of(context).size.width,
//              child: ListView(
//                children: contacts.map((map) {
//                  return Container(
//                    child: ListTile(
//                      leading: Icon(Icons.person),
//                      title: Text(
//                        '${map.displayName}',
//                        style: GoogleFonts.muli(),
//                      ),
//                      subtitle: Text(
//                        map.phones.length == 0
//                            ? ''
//                            : '${map.phones.first.value}',
//                        style: GoogleFonts.muli(),
//                      ),
//                    ),
//                  );
//                }).toList(),
//              ),
//            ),
//          );
//        });
//  }

  Future _specificBtnPressed() async {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              'Phone Number',
              style: GoogleFonts.muli(textStyle: TextStyle()),
            ),
            content: Form(
                key: _formPhone,
                child: TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                      color: Colors.black,
                    )),
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                    },
                    validator: (value) {
                      //Check if phone is available
                      if (value.isEmpty) {
                        return 'Phone number is required';
                      }

                      //Check if phone number has 10 digits
                      if (value.length != 10) {
                        return 'Phone number should be 10 digits';
                      }

                      //Check if phone number starts with 07
                      if (!value.startsWith('07')) {
                        return 'Phone number should start with 07';
                      }

                      return null;
                    },
                    autovalidate: true,
                    textInputAction: TextInputAction.done,
                    onSaved: _handleSubmittedPhone,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        prefixIcon: Icon(Icons.phone, color: Colors.black),
                        labelText: '',
                        labelStyle: hintStyleBlack))),
            actions: [
              FlatButton(
                  onPressed: _checkValidity,
                  child: Text('Request',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold))))
            ],
          );
        });
  }

  Future<bool> _checkPhoneNumber() async {
    final String _collection = 'users';
    QuerySnapshot query = await _firestore
        .collection(_collection)
        .where("phone", isEqualTo: _phone)
        .getDocuments();
    int numDocs = query.documents.length;
    if (numDocs > 0) {
      DocumentSnapshot doc = query.documents[0];
      _phoneRetrieved = doc.data["phone"];
      _loanInviteeName = doc.data["fullName"].split(' ')[0];
      _loanInviteetoken = doc.data["token"];
      _idInvitee = doc.data['uid'];
      print(_loanInviteeName);
      print(_loanInviteetoken);
      return true;
    } else {
      return false;
    }
  }

  void _checkValidity() {
    //Dismiss the keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    //Validate the form
    final FormState form = _formPhone.currentState;
    if (form.validate()) {
      form.save();
      //Check if phone number exists in backend
      //Dismiss the form dialog
      Navigator.of(context).pop();
      //Show a dialog
      _showUserProgress();
      _checkPhoneNumber().then((value) {
        if (value) {
          //Pop the initial dialog
          Navigator.of(context).pop();
          //Show the new dialog
          _promptLenderFound();
          if (_phoneRetrieved == _phone) {
            lender = widget.uid;
            takeLoanFrom = widget.uid;
            lenderName = widget.name;
            lenderToken = widget.mytoken;
            setState(() {
              typeLoan = 'self';
            });
          } else {
            takeLoanFrom = _idInvitee;
          }
        } else {
          //Pop the initial dialog
          Navigator.of(context).pop();
          //Show the new dialog
          _promptLenderNotFound();
          takeLoanFrom = null;
          //Pop after a while and return the form
          Timer(Duration(seconds: 4), () => Navigator.pop(context));
          Timer(Duration(seconds: 5), () => _specificBtnPressed());
        }
      });
    }
  }

  Future _promptLenderFound() {
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
                  Icons.sentiment_satisfied,
                  size: 50,
                  color: Colors.green,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Your request will be sent to $_loanInviteeName',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  Future _promptSendToAll() {
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
                  Icons.sentiment_satisfied,
                  size: 50,
                  color: Colors.green,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Your request will be sent to everyone on Sortika who can fulfill your request',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  Future _promptLenderNotFound() {
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
                  Icons.sentiment_dissatisfied,
                  size: 50,
                  color: Colors.red,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'The requested lender is not on Sortika or you tried to send a'
                  ' loan request to yourself',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        });
  }

  Widget _p2pButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            takeLoanFrom = 'All';
            _promptSendToAll();
          },
          color: Colors.white70,
          child: Text(
            'All',
            style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.black, letterSpacing: 2)),
          ),
        ),
        FlatButton(
          onPressed: _specificBtnPressed,
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
                  'Processing your request...',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                  textAlign: TextAlign.center,
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

  void _applyBtnPressed() async {
    //Check if loan type is selected
    if (typeLoan == null) {
      _promptUser("Please select the type of loan you want");
    }
    //Check if amount is not the default of 0
    else if (amountLoan == 0) {
      _promptUser("Please select the loan amount you want");
    } else if (_date == null) {
      _promptUser("Please select the payback date");
    } else if (typeLoan == 'p2p' && takeLoanFrom == null) {
      _promptUser("You have not selected the recipient of your loan request");
    }
    //Check if goal ends on the same day
    else if (_date.difference(rightNow).inDays < 1) {
      _promptUser('The goal end date is too soon');
    } else {
      //Create an instance of a Loan
      LoanModel loanModel = new LoanModel(
        loanLender: lender,
        loanLenderName: lenderName,
        loanLenderToken: lenderToken,
        loanInvitees: takeLoanFrom,
        loanInviteeName: _loanInviteeName,
        tokenInvitee: _loanInviteetoken,
        loanBorrower: widget.uid,
        tokenBorrower: widget.mytoken,
        borrowerName: widget.name,
        loanAmountTaken: amountLoan,
        loanAmountRepaid: 0,
        loanInterest: interestLoan,
        loanEndDate: Timestamp.fromDate(_date),
        loanTakenDate: Timestamp.fromDate(rightNow),
        loanStatus: false,
        loanIC: interestCoverLoan,
        totalAmountToPay: (amountLoan * (1 + (interestLoan / 100))),
      );

      //Create an activity
      ActivityModel borrowAct = new ActivityModel(
          activity: 'You sent a borrow request',
          activityDate: Timestamp.fromDate(rightNow));
      await authService.postActivity(widget.uid, borrowAct);

      //Show a dialog
      _showUserProgress();

      _applyForALoan(loanModel).whenComplete(() {
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
            typeLoan == 'p2p'
                ? SizedBox(
                    height: 30,
                  )
                : Container(),
            typeLoan == 'p2p' ? _loanICWidget() : Container(),
            typeLoan == 'p2p'
                ? SizedBox(
                    height: 30,
                  )
                : Container(),
            typeLoan == 'p2p'
                ? Text(
                    'Who will receive the request',
                    style: styleLabel,
                  )
                : Container(),
            typeLoan == 'p2p'
                ? SizedBox(
                    height: 10,
                  )
                : Container(),
            typeLoan == 'p2p' ? _p2pButtons() : Text(''),
            _applyBtn()
          ],
        ),
      ),
    );
  }
}
