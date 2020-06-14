import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/global/errorMessage.dart';
import 'package:wealth/global/progressDialog.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/models/bankModel.dart';
import 'package:wealth/models/cardModel.dart';
import 'package:wealth/models/days.dart';
import 'package:wealth/models/usermodel.dart';
import 'package:wealth/utilities/inputFormatter.dart';
import 'package:wealth/utilities/styles.dart';
import 'package:wealth/models/phoneVerificationModel.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  //Form Key
  final _formPhone = GlobalKey<FormState>();
  final _formOtp = GlobalKey<FormState>();
  final _formCard = GlobalKey<FormState>();
  final _formBank = GlobalKey<FormState>();
  //Identifiers
  double _passiveRate;
  double _loanLimitRate;

  bool _isReminderDaily = false;
  bool _isReminderWeekly = false;

  String _prefferedPaymentMethod;
  String _prefferedWithdrawalMethod;

  static bool _isPayByMpesa;
  bool _isWithdrawByMpesa = false;
  List<Days> _days = [];

  bool _isPayByCard = false;
  bool _isWithdrawToBank = false;

  User user;
  Helper helper = new Helper();

  var _card = new PaymentCard();
  var _paymentCard = new PaymentCard();
  var _bankDetals = BankModel();
  var _autoValidate = false;

  TextEditingController numberController = new TextEditingController();

  String _phone;
  String _otp;
  String _billing;

  final focusNumber = FocusNode();
  final focusCVV = FocusNode();
  final focusExpiry = FocusNode();
  final focusBilling = FocusNode();

  final focusSwiftCode = FocusNode();
  final focusAccName = FocusNode();
  final focusAccNumber = FocusNode();

  //Handle Phone Input
  void _handleSubmittedPhone(String value) {
    _phone = value.trim();
    print('Phone: ' + _phone);
  }

  void _handleSubmittedOtp(String value) {
    _otp = value.trim();
    print('OTP: ' + _otp);
  }

  void _handleSubmittedCardName(String value) {
    _card.name = value.trim();
    _paymentCard.name = value.trim();
    print('Card Name: ' + _card.name);
  }

  void _handleSubmittedCardNumber(String value) {
    _paymentCard.number = value.trim();
    print('Card Number: ' + _paymentCard.number);
  }

  void _handleSubmittedCardCvv(String value) {
    _paymentCard.cvv = int.parse(value);
    print('Card CVV: ' + _paymentCard.cvv.toString());
  }

  void _handleSubmittedCardExpiry(String value) {
    List<int> expiryDate = CardUtils.getExpiryDate(value);
    _paymentCard.month = expiryDate[0];
    _paymentCard.year = expiryDate[1];
    print('Card Expiry: ' + expiryDate.toString());
  }

  void _handleSubmittedCardBilling(String value) {
    _billing = value.trim();
    _paymentCard.address = value.trim();
    print('Card Billing: ' + _billing);
  }

  String _nameBank;
  String _branchBank;
  String _bankCode;
  String _bankSwift;
  String _bankAccName;
  String _bankAccNum;

  void _handleSubmittedBankCode(String value) {
    _bankCode = value.trim();
    _bankDetals.bankName = value.trim();
    print('Bank Code: ' + _bankCode);
  }

  void _handleSubmittedBankSwift(String value) {
    _bankSwift = value.trim();
    _paymentCard.address = value.trim();
    print('Bank Swift Code: ' + _bankSwift);
  }

  void _handleSubmittedBankAccName(String value) {
    _bankAccName = value.trim();
    _bankDetals.bankAccountName = value.trim();
    print('Bank Acc Name: ' + _bankAccName);
  }

  void _handleSubmittedBankAccNum(String value) {
    _bankAccNum = value.trim();
    _bankDetals.bankAccountNumber = value.trim();
    print('Bank Acc Num: ' + _bankAccNum);
  }

  TimeOfDay _defaultTime = TimeOfDay(hour: 8, minute: 00);

  Widget _backgroundWidget() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color(0xFF73AEF5),
            Color(0xFF73AEF5),
            Color(0xFF73AEF5),
            Color(0xFF73AEF5),
          ],
              stops: [
            0.1,
            0.4,
            0.7,
            0.9
          ])),
    );
  }

  Widget _passiveWidget() {
    _passiveRate = double.parse(user.passiveSavingsRate.toString());
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passive Savings',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'The current rate is ${_passiveRate.toStringAsFixed(0)} %',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w300)),
          ),
          Row(
            children: [
              Text(
                '1 %',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Slider(
                  value: _passiveRate,
                  activeColor: Colors.lightBlue,
                  inactiveColor: Colors.grey[200],
                  onChangeEnd: (value) => helper
                      .changePassiveRate(user.uid, value.ceilToDouble())
                      .whenComplete(() => showCupertinoModalPopup(
                          context: context,
                          builder: (context) => SuccessMessage(
                              message:
                                  'You have changed your passive savings rate to ${value.ceilToDouble()} %. Please login again to view changes'))),
                  onChanged: (value) {
                    setState(() {
                      _passiveRate = value;
                    });
                  },
                  min: 1,
                  max: 10,
                ),
              ),
              Text(
                '10 %',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _limitWidget() {
    _loanLimitRate = double.parse(user.loanLimitRatio.toString());
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loan Limit',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'The current limit is ${_loanLimitRate.toStringAsFixed(0)} %',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w300)),
          ),
          Row(
            children: [
              Text(
                '75 %',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Slider(
                  value: _loanLimitRate,
                  activeColor: Colors.lightBlue,
                  inactiveColor: Colors.grey[200],
                  onChanged: (value) {
                    // setState(() {
                    //   _loanLimitRate = value;
                    // });
                  },
                  min: 75,
                  max: 500,
                ),
              ),
              Text(
                '500 %',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _isDaily() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Text(
              'Daily',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
              child: Container(
            child: Theme(
                data: ThemeData(unselectedWidgetColor: Colors.white),
                child: Checkbox(
                    value: _isReminderDaily,
                    checkColor: Colors.blue,
                    activeColor: Colors.white,
                    onChanged: (bool value) {
                      setState(() {
                        _isReminderDaily = value;
                        print('Daily: $_isReminderDaily');
                      });
                    })),
          ))
        ],
      ),
    );
  }

  Future _showWeekdays() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Container(
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: allDays.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${allDays[index].day}',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold))),
                  trailing: Container(
                    child: Theme(
                        data: ThemeData(unselectedWidgetColor: Colors.blue),
                        child: Checkbox(
                            value: allDays[index].selected,
                            checkColor: Colors.white,
                            activeColor: Colors.blue,
                            onChanged: (bool value) {
                              if (!_days.contains(allDays[index])) {
                                _days.add(allDays[index]);
                              }
                              setState(() {
                                allDays[index].selected =
                                    !allDays[index].selected;
                              });
                            })),
                  ),
                  leading: Icon(Icons.view_day),
                  selected: allDays[index].selected,
                  onTap: () {
                    _days.add(allDays[index]);
                    setState(() {
                      allDays[index].selected = !allDays[index].selected;
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _isWeekly() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Text(
                  'Weekly',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                  child: Container(
                child: Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.white),
                    child: Checkbox(
                        value: _isReminderWeekly,
                        checkColor: Colors.blue,
                        activeColor: Colors.white,
                        onChanged: (bool value) {
                          setState(() {
                            _isReminderWeekly = value;
                            print('Weekly: $_isReminderWeekly');
                            if (value) {
                              _showWeekdays();
                            }
                          });
                        })),
              ))
            ],
          ),
        ],
      ),
    );
  }

  Widget _isCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Text(
              'Card',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
              child: Container(
            child: Theme(
                data: ThemeData(unselectedWidgetColor: Colors.white),
                child: Checkbox(
                    value: _isPayByCard,
                    checkColor: Colors.blue,
                    activeColor: Colors.white,
                    onChanged: (bool value) {
                      setState(() {
                        _isPayByCard = value;
                      });
                      if (value) {
                        //Show card Dialog;
                        _cardDialog();
                        //Set Mpesa to be false
                        _isPayByMpesa = false;
                        _prefferedPaymentMethod = 'card';
                        print(
                            'Preferred Payment Method: $_prefferedPaymentMethod');
                      } else {
                        _prefferedPaymentMethod = null;
                      }
                    })),
          ))
        ],
      ),
    );
  }

  Future _mpesaNumberDialog() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'M-Pesa Number',
            style: GoogleFonts.muli(textStyle: TextStyle()),
          ),
          content: Form(
              key: _formPhone,
              child: TextFormField(
                  autofocus: false,
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
                      labelText: 'Enter your Phone Number',
                      labelStyle: hintStyleBlack))),
          actions: [
            FlatButton(
                onPressed: _setPhone,
                child: Text('Verify',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold))))
          ],
        );
      },
    );
  }

  Future _otpDialog() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Please enter the code we sent to you',
            style: GoogleFonts.muli(textStyle: TextStyle()),
          ),
          content: Form(
              key: _formOtp,
              child: TextFormField(
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
                    //Check if otp is available
                    if (value.isEmpty) {
                      return 'OTP is required';
                    }

                    //Check if otp has 5 digits
                    if (value.length != 5) {
                      return 'OTP should be 5 digits';
                    }

                    return null;
                  },
                  maxLength: 5,
                  autovalidate: true,
                  textInputAction: TextInputAction.done,
                  onSaved: _handleSubmittedOtp,
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
                      labelText: 'Enter the 5 digit code',
                      labelStyle: hintStyleBlack))),
          actions: [
            FlatButton(
                onPressed: _setOtp,
                child: Text('Verify',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold))))
          ],
        );
      },
    );
  }

  void _setPhone() {
    final form = _formPhone.currentState;
    if (form.validate()) {
      form.save();
      Navigator.of(context).pop();
      //Show a progress dialog
      showCupertinoModalPopup(
        context: context,
        builder: (context) =>
            CustomProgressDialog(message: 'Processing your request'),
      );
      PhoneVerificationModel model =
          new PhoneVerificationModel(uid: user.uid, phone: user.phone);

      helper
          .phoneVerify(model)
          .catchError((error) => {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => ErrorMessage(
                      message:
                          'You had sent in a similar request. Please use the code we sent to you.'),
                )
              })
          .whenComplete(() {
        Navigator.of(context).pop();
        //Show OTP Popup
        _otpDialog();
      });
    }
  }

  void _setOtp() {
    final form = _formOtp.currentState;
    if (form.validate()) {
      form.save();
      //Show a progress dialog
      showCupertinoModalPopup(
        context: context,
        builder: (context) =>
            CustomProgressDialog(message: 'Processing your request'),
      );
      PhoneVerificationModel model = new PhoneVerificationModel(
          uid: user.uid, phone: user.phone, genCode: _otp);
      helper.verifyOtp(model).catchError((error) {
        Navigator.of(context).pop();
        showCupertinoModalPopup(
          context: context,
          builder: (context) => ErrorMessage(
              message: 'Your request could not be completed. Please try again'),
        );
      }).then((value) async {
        if (value) {
          Navigator.of(context).pop();
          showCupertinoModalPopup(
            context: context,
            builder: (context) => SuccessMessage(
                message: 'You have verified your phone number successfully'),
          );
        } else if (value == false) {
          showCupertinoModalPopup(
            context: context,
            builder: (context) =>
                ErrorMessage(message: 'You have entered a wrong code'),
          );
        } else {
          showCupertinoModalPopup(
            context: context,
            builder: (context) => ErrorMessage(message: value.toString()),
          );
        }
      });
    }
  }

  Future _cardDialog() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Debit/Credit Card',
            style: GoogleFonts.muli(textStyle: TextStyle()),
          ),
          content: Form(
              key: _formCard,
              autovalidate: _autoValidate,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.text,
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                          color: Colors.black,
                        )),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(focusNumber);
                        },
                        validator: (value) {
                          //Check if name is available
                          if (value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onSaved: _handleSubmittedCardName,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            labelText: 'Enter the name on the card',
                            labelStyle: hintStyleBlack)),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                          new LengthLimitingTextInputFormatter(19),
                          new CardNumberInputFormatter()
                        ],
                        controller: numberController,
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                          color: Colors.black,
                        )),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(focusCVV);
                        },
                        validator: CardUtils.validateCardNum,
                        focusNode: focusNumber,
                        textInputAction: TextInputAction.next,
                        onSaved: _handleSubmittedCardNumber,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            labelText: 'Enter your Card Number',
                            prefixIcon:
                                CardUtils.getCardIcon(_paymentCard.type),
                            labelStyle: hintStyleBlack)),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: TextFormField(
                                autofocus: false,
                                inputFormatters: [
                                  WhitelistingTextInputFormatter.digitsOnly,
                                  new LengthLimitingTextInputFormatter(4),
                                ],
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.muli(
                                    textStyle: TextStyle(
                                  color: Colors.black,
                                )),
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(focusExpiry);
                                },
                                validator: CardUtils.validateCVV,
                                focusNode: focusCVV,
                                textInputAction: TextInputAction.next,
                                onSaved: _handleSubmittedCardCvv,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black)),
                                    errorBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red)),
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black)),
                                    labelText: 'CVV',
                                    labelStyle: hintStyleBlack))),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                              autofocus: false,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                new LengthLimitingTextInputFormatter(4),
                                new CardMonthInputFormatter()
                              ],
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                color: Colors.black,
                              )),
                              onFieldSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(focusBilling);
                              },
                              validator: CardUtils.validateDate,
                              focusNode: focusExpiry,
                              textInputAction: TextInputAction.next,
                              onSaved: _handleSubmittedCardExpiry,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.red)),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  labelText: 'MM/YY',
                                  labelStyle: hintStyleBlack)),
                        )
                      ],
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
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        validator: (value) {
                          //Check if phone is available
                          if (value.isEmpty) {
                            return 'Billing Address is required';
                          }

                          return null;
                        },
                        focusNode: focusBilling,
                        textInputAction: TextInputAction.done,
                        onSaved: _handleSubmittedCardBilling,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            labelText: 'Billing Address',
                            labelStyle: hintStyleBlack))
                  ],
                ),
              )),
          actions: [
            FlatButton(
                onPressed: _setCard,
                child: Text('Verify',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold))))
          ],
        );
      },
    );
  }

  void _setCard() {
    final form = _formCard.currentState;
    if (!form.validate()) {
      setState(() {
        _autoValidate = true; // Start validating on every change.
      });
    } else {
      form.save();
    }
  }

  Widget _bankName() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton(
        items: itemsBanks,
        underline: Divider(
          color: Colors.transparent,
        ),
        value: _nameBank,
        hint: Text(
          'Bank Name',
          style: GoogleFonts.muli(textStyle: TextStyle()),
        ),
        icon: Icon(
          CupertinoIcons.down_arrow,
          color: Colors.black,
        ),
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            _nameBank = value;
            _bankDetals.bankName = _nameBank;
          });
        },
      ),
    );
  }

  Widget _bankBranch() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton(
        items: itemsBranches,
        underline: Divider(
          color: Colors.transparent,
        ),
        value: _branchBank,
        hint: Text(
          'Bank Branch',
          style: GoogleFonts.muli(textStyle: TextStyle()),
        ),
        icon: Icon(
          CupertinoIcons.down_arrow,
          color: Colors.black,
        ),
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            _branchBank = value;
            _bankDetals.bankBranch = _branchBank;
          });
          //print(goal);
        },
      ),
    );
  }

  List<DropdownMenuItem> itemsBanks = [
    DropdownMenuItem(
      value: 'ncba',
      child: Text(
        'NCBA',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'kcb',
      child: Text(
        'KCB',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  List<DropdownMenuItem> itemsBranches = [
    DropdownMenuItem(
      value: 'uph',
      child: Text(
        'Upper Hill',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'gty',
      child: Text(
        'Garden City',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  Future _bankDialog() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Bank Account',
            style: GoogleFonts.muli(textStyle: TextStyle()),
          ),
          content: Form(
              key: _formBank,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _bankName(),
                    SizedBox(
                      height: 10,
                    ),
                    _bankBranch(),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: TextFormField(
                              autofocus: false,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                color: Colors.black,
                              )),
                              onFieldSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(focusSwiftCode);
                              },
                              validator: (value) {
                                //Check if phone is available
                                if (value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              onSaved: _handleSubmittedBankCode,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.red)),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  labelText: 'Bank Code',
                                  labelStyle: hintStyleBlack)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                              autofocus: false,
                              keyboardType: TextInputType.text,
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                color: Colors.black,
                              )),
                              onFieldSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(focusAccName);
                              },
                              validator: (value) {
                                //Check if phone is available
                                if (value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                              focusNode: focusSwiftCode,
                              textInputAction: TextInputAction.next,
                              onSaved: _handleSubmittedBankSwift,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.red)),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  labelText: 'Swift Code',
                                  labelStyle: hintStyleBlack)),
                        )
                      ],
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
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(focusAccNumber);
                        },
                        validator: (value) {
                          //Check if phone is available
                          if (value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        focusNode: focusAccName,
                        textInputAction: TextInputAction.next,
                        onSaved: _handleSubmittedBankAccName,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            labelText: 'Account Name',
                            labelStyle: hintStyleBlack)),
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
                          //Check if phone is available
                          if (value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        focusNode: focusAccNumber,
                        textInputAction: TextInputAction.done,
                        onSaved: _handleSubmittedBankAccNum,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            labelText: 'Account Number',
                            labelStyle: hintStyleBlack))
                  ],
                ),
              )),
          actions: [
            FlatButton(
                onPressed: _setBank,
                child: Text('Verify',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold))))
          ],
        );
      },
    );
  }

  void _setBank() {
    final form = _formBank.currentState;
    if (form.validate()) {
      form.save();
    }
  }

  Widget _isMpesa() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Text(
              'M-Pesa',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
              child: Container(
            child: Theme(
                data: ThemeData(unselectedWidgetColor: Colors.white),
                child: Checkbox(
                    value: _isPayByMpesa,
                    checkColor: Colors.blue,
                    activeColor: Colors.white,
                    onChanged: (bool value) {
                      //Check if the box is selected
                      if (value) {
                        //Show Mpesa Number Dialog
                        _mpesaNumberDialog();
                        //Set Card to be False
                        _isPayByCard = false;
                        _prefferedPaymentMethod = 'mpesa';
                        print(
                            'Preffered Payment Method: $_prefferedPaymentMethod');
                      } else {
                        _prefferedPaymentMethod = null;
                      }
                    })),
          ))
        ],
      ),
    );
  }

  Widget _iswithdrawMpesa() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Text(
              'Send to M-Pesa',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
              child: Container(
            child: Theme(
                data: ThemeData(unselectedWidgetColor: Colors.white),
                child: Checkbox(
                    value: _isPayByMpesa,
                    checkColor: Colors.blue,
                    activeColor: Colors.white,
                    onChanged: (bool value) {
                      setState(() {
                        _isPayByMpesa = value;
                      });
                      //Check if the box is selected
                      if (value) {
                        //Show Mpesa dialog
                        _mpesaNumberDialog();
                        //Set bank payment to false
                        _isWithdrawToBank = false;
                        _prefferedWithdrawalMethod = 'mpesa';
                        print(
                            'Preferred Withdrawal Method: $_prefferedWithdrawalMethod');
                      } else {
                        _prefferedWithdrawalMethod = null;
                      }
                    })),
          ))
        ],
      ),
    );
  }

  Widget _iswithdrawBank() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Text(
              'Send to Bank Account',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
              child: Container(
            child: Theme(
                data: ThemeData(unselectedWidgetColor: Colors.white),
                child: Checkbox(
                    value: _isWithdrawToBank,
                    checkColor: Colors.blue,
                    activeColor: Colors.white,
                    onChanged: (bool value) {
                      setState(() {
                        _isWithdrawToBank = value;
                      });
                      if (value) {
                        //Show the bank details dialog
                        _bankDialog();
                        //Disable payment by m-pesa
                        _isWithdrawByMpesa = false;
                        _prefferedWithdrawalMethod = 'bank';
                        print(
                            'Preferred Withdrawal Method: $_prefferedWithdrawalMethod');
                      } else {
                        _prefferedWithdrawalMethod = null;
                      }
                    })),
          ))
        ],
      ),
    );
  }

  Widget _reminder() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isDaily(),
          _isWeekly(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    _defaultTime != null
                        ? '${_defaultTime.format(context)}'
                        : '',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal)),
                  )
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
                onPressed: () {
                  showTimePicker(context: context, initialTime: TimeOfDay.now())
                      .then((value) {
                    setState(() {
                      _defaultTime = value;
                    });
                  });
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Future _UpdateUserPrefs(User model) async {}

  void _updatePrefs() {
    //Check if there is a preferred payment method
    if (_prefferedPaymentMethod == null) {
      _promptUser('Please select your preferred payment method');
    } else if (_prefferedWithdrawalMethod == null) {
      _promptUser('Please select your preferred withdrawal method');
    } else {}
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
                  'Your preferences have been updated',
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
                  'Updating your preferences...',
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

  Widget _updateBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: RaisedButton(
        elevation: 2,
        onPressed: _updatePrefs,
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.white,
        child: Text(
          'UPDATE',
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

  Widget _paymentMethod() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isMpesa(),
          //_isCard()
        ],
      ),
    );
  }

  Widget _withdrawMethod() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //_iswithdrawBank(),
          _iswithdrawMpesa()
        ],
      ),
    );
  }

  @override
  void initState() {
    _paymentCard.type = CardType.Invalid;
    numberController.addListener(_getCardTypeFrmNumber);
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Retreieve User
    user = ModalRoute.of(context).settings.arguments;
    _isPayByMpesa = user.phoneVerified;
    //print('Settings UID: $uid');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF73AEF5),
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.muli(
              textStyle: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              _backgroundWidget(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _passiveWidget(),
                      SizedBox(
                        height: 30,
                      ),
                      _limitWidget(),
                      SizedBox(
                        height: 30,
                      ),
                      // Text(
                      //   'Reminders',
                      //   style: GoogleFonts.muli(
                      //       textStyle: TextStyle(
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.w700)),
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // _reminder(),
                      // SizedBox(
                      //   height: 30,
                      // ),
                      Text(
                        'Preffered payment method',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _paymentMethod(),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'Preffered withdrawal method',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _withdrawMethod(),
                      //_updateBtn()
                    ],
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
