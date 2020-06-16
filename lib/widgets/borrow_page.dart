import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/analytics/analytics_funnels.dart';
import 'package:wealth/api/auth.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/global/errorMessage.dart';
import 'package:wealth/global/progressDialog.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/global/warningMessage.dart';
import 'package:wealth/models/activityModel.dart';
import 'package:wealth/models/loanModel.dart';
import 'package:wealth/utilities/styles.dart';

class BorrowPage extends StatefulWidget {
  final String uid;
  final String mytoken;
  final String name;
  final String phone;

  BorrowPage(
      {Key key,
      @required this.uid,
      @required this.mytoken,
      @required this.phone,
      @required this.name})
      : super(key: key);

  @override
  _BorrowPageState createState() => _BorrowPageState();
}

class _BorrowPageState extends State<BorrowPage> {
  AnalyticsFunnel funnel = AnalyticsFunnel();
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
  var _loanInviteeName;
  String _idInvitee;
  var _loanInviteetoken;

  Firestore _firestore = Firestore.instance;
  AuthService authService = new AuthService();
  Helper _helper = new Helper();

  final _formPhone = GlobalKey<FormState>();

  String _phone;
  String _phoneRetrieved;

  void _handleSubmittedAmount(String value) {
    amountLoan = double.parse(value.trim());
    print('Amount: ' + amountLoan.toString());
  }

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
              lenderName = widget.name;
              lenderToken = widget.mytoken;

              _idInvitee = null;
              takeLoanFrom = null;
              _loanInviteeName = null;
              _loanInviteetoken = null;
            }
            if (value == 'p2p') {
              lender = null;
              lenderName = null;
              lenderToken = null;
            }
          });
          print(lender);
        },
      ),
    );
  }

  Widget _loanAmountWidget() {
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
                return 'Loan Amount is required';
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
                    borderSide: BorderSide(color: Colors.red)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                prefixIcon:
                    Icon(FontAwesome5.money_bill_alt, color: Colors.white),
                suffixText: 'KES',
                suffixStyle: hintStyle,
                labelText: 'Enter loan amount',
                labelStyle: hintStyle))
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

  Future _specificBtnPressed() {
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
                    ))),
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
      DocumentSnapshot doc = query.documents.first;
      _phoneRetrieved = doc.data["phone"];
      _loanInviteeName = [doc.data["fullName"].split(' ')[0]];
      _loanInviteetoken = [doc.data["token"]];
      _idInvitee = doc.data['uid'];
      // print(_loanInviteeName);
      // print(_loanInviteetoken);
      // print(_phoneRetrieved);
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

      //Dismiss the form dialog first
      Navigator.of(context).pop();

      //Show a progress dialog
      _showUserProgress();

      _checkPhoneNumber().then((value) {
        //Pop the initial dialog
        Navigator.of(context).pop();
        if (value) {
          //Show the new dialog
          _promptLenderFound();
          if (_phoneRetrieved == widget.phone) {
            //print('Retrieved \t${_phoneRetrieved}\nMine: \t${widget.phone}');
            lender = widget.uid;
            takeLoanFrom = [widget.uid];
            lenderName = widget.name;
            lenderToken = widget.mytoken;
            setState(() {
              typeLoan = 'self';
            });
          } else {
            //print('Not Me');
            takeLoanFrom = [_idInvitee];
            lender = null;
            lenderName = null;
            lenderToken = null;
            //print(takeLoanFrom);
          }
        } else {
          //Show the new dialog
          _promptLenderNotFound();
          takeLoanFrom = null;
        }
      }).catchError((error) => _promptUser(error.toString()));
    }
  }

  Future _promptLenderFound() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return SuccessMessage(
              message:
                  'Your request will be sent to ${_loanInviteeName.first}');
        });
  }

  Future _promptSendToAll() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return SuccessMessage(
              message:
                  'Your request will be sent to everyone on Sortika who can fulfill your request');
        });
  }

  Future _promptLenderNotFound() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return ErrorMessage(
              message: 'The requested lender is not on Sortika');
        });
  }

  Widget _p2pButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            takeLoanFrom = 'All';
            _idInvitee = null;
            _loanInviteeName = null;
            _loanInviteetoken = null;
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
          return WarningMessage(message: message);
        });
  }

  Future _promptUserSuccess() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return SuccessMessage(
              message: 'Your loan application has been received');
        });
  }

  Future _showUserProgress() {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CustomProgressDialog(message: "Processing your request...");
        });
  }

  Future _applyForALoan(LoanModel model) async {
    //Add request to Loans Collections
    final String _collection = "loans";
    await _firestore.collection(_collection).document().setData(model.toJson());
    await funnel.logBorrowRequest(
        model.loanAmountTaken,
        typeLoan,
        model.loanTakenDate.toDate().toString(),
        model.loanEndDate.toDate().toString(),
        model.loanBorrower);
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
      //Show a dialog
      //First get the L+1C
      var cover = await _helper.getLoanInterestCover(widget.uid, amountLoan);
      if (cover == 'Infinity') {
        interestCoverLoan = 0;
      } else {
        interestCoverLoan = cover;
      }
      print('L + IC = $interestCoverLoan %');

      // Get the interest in amount
      //Compute the sIc(sortikaInterestComputed), cIc(clientInterestComputed), lfRepayment and loan balance
      var interestAmt = (amountLoan * (interestLoan / 100));
      var sIc = (interestAmt * 20) / 100;
      var cIc = (interestAmt * 80) / 100;
      var lfRepaymentAmt = amountLoan;
      var totalAmtToPay = (amountLoan * (1 + (interestLoan / 100)));
      var amtRepaid = 0;
      var loanBalance = totalAmtToPay - amtRepaid;
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
        sortikaInterestComputed: sIc,
        clientInterestComputed: cIc,
        lfrepaymentAmount: lfRepaymentAmt,
        loanAmountTaken: amountLoan,
        loanAmountRepaid: amtRepaid,
        loanBalance: loanBalance,
        loanInterest: interestLoan,
        loanEndDate: Timestamp.fromDate(_date),
        loanTakenDate: Timestamp.fromDate(rightNow),
        loanStatus: false,
        loanIC: interestCoverLoan,
        totalAmountToPay: totalAmtToPay,
      );

      print(loanModel.toJson());

      //Create an activity
      ActivityModel borrowAct = new ActivityModel(
          activity: loanModel.loanInvitees == "All"
              ? 'You sent a loan request to everyone on sortika who can fulfill the request'
              : loanModel.loanInviteeName == null
                  ? 'You sent a loan request to yourself'
                  : 'You sent a loan request to ${loanModel.loanInviteeName.first}',
          activityDate: Timestamp.fromDate(rightNow));
      await authService.postActivity(widget.uid, borrowAct);

      _applyForALoan(loanModel).whenComplete(() {
        //Show a success message for two seconds
        _promptUserSuccess();
      }).catchError((error) {
        //Show an error message
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
