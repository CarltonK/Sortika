import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/days.dart';
import 'package:wealth/utilities/styles.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  //Form Key
  final _formPhone = GlobalKey<FormState>();
  final _formCard = GlobalKey<FormState>();
  //Identifiers
  double _passiveRate = 5;
  double _loanLimitRate = 75;

  bool _isReminderDaily = false;
  bool _isReminderWeekly = false;

  String _prefferedPaymentMethod;
  String _prefferedWithdrawalMethod;

  bool _isPayByMpesa = false;
  bool _isWithdrawByMpesa = false;

  bool _isPayByCard = false;
  bool _isWithdrawToBank = false;

  String _phone;
  String _cardNumber;
  String _cvv;
  String _cardExpiry;
  String _billing;

  final focusCVV = FocusNode();
  final focusExpiry = FocusNode();
  final focusBilling = FocusNode();

  //Handle Phone Input
  void _handleSubmittedPhone(String value) {
    _phone = value.trim();
    print('Phone: ' + _phone);
  }

  void _handleSubmittedCardNumber(String value) {
    _cardNumber = value.trim();
    print('Card Number: ' + _cardNumber);
  }

  void _handleSubmittedCardCvv(String value) {
    _cvv = value.trim();
    print('Card CVV: ' + _cvv);
  }

  void _handleSubmittedCardExpiry(String value) {
    _cardExpiry = value.trim();
    print('Card Expiry: ' + _cardExpiry);
  }

  void _handleSubmittedCardBilling(String value) {
    _billing = value.trim();
    print('Card Billing: ' + _billing);
  }

  static String uid;

  String _nameBank;
  String _branchBank;

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
            'The current rate is ${_passiveRate.toInt().toString()} %',
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
            'The current limit is ${_loanLimitRate.toInt()} %',
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
                              setState(() {
                                allDays[index].selected =
                                    !allDays[index].selected;
                              });
                            })),
                  ),
                  leading: Icon(Icons.view_day),
                  visualDensity: VisualDensity.compact,
                  selected: allDays[index].selected,
                  onTap: () {
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

  void _setPhone() {
    final form = _formPhone.currentState;
    if (form.validate()) {
      form.save();
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                      autofocus: false,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                        color: Colors.black,
                      )),
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(focusCVV);
                      },
                      validator: (value) {
                        //Check if phone is available
                        if (value.isEmpty) {
                          return 'Card number is required';
                        }

                        return null;
                      },
                      autovalidate: true,
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
                              maxLength: 3,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                color: Colors.black,
                              )),
                              onFieldSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(focusExpiry);
                              },
                              validator: (value) {
                                //Check if phone is available
                                if (value.isEmpty) {
                                  return 'CVV is required';
                                }

                                if (value.length != 3) {
                                  return 'This number should be 3 digits';
                                }

                                return null;
                              },
                              focusNode: focusCVV,
                              autovalidate: true,
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
                                  prefixIcon:
                                      Icon(Icons.phone, color: Colors.black),
                                  labelText: 'CVV',
                                  labelStyle: hintStyleBlack))),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                            autofocus: false,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.muli(
                                textStyle: TextStyle(
                              color: Colors.black,
                            )),
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).requestFocus(focusBilling);
                            },
                            validator: (value) {
                              //Check if phone is available
                              if (value.isEmpty) {
                                return 'Expiry is required';
                              }
                              return null;
                            },
                            focusNode: focusExpiry,
                            autovalidate: true,
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
                                    borderSide: BorderSide(color: Colors.red)),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                labelText: 'MM/YYYY',
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
                      focusNode: focusBilling,
                      autovalidate: true,
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
    if (form.validate()) {
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
          });
          //print(goal);
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
          });
          //print(goal);
        },
      ),
    );
  }

  List<DropdownMenuItem> itemsBanks = [
    DropdownMenuItem(
      value: '',
      child: Text(
        'CBA',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  List<DropdownMenuItem> itemsBranches = [
    DropdownMenuItem(
      value: '',
      child: Text(
        'Upper Hill',
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
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(color: Colors.black)),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Bank Code',
                        hintStyle: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300)),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(color: Colors.black)),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Swift Code',
                        hintStyle: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300)),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style:
                    GoogleFonts.muli(textStyle: TextStyle(color: Colors.black)),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Account Name',
                  hintStyle: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w300)),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style:
                    GoogleFonts.muli(textStyle: TextStyle(color: Colors.black)),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Account Number',
                  hintStyle: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w300)),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
              )
            ],
          )),
          actions: [
            FlatButton(
                onPressed: () {},
                child: Text('Verify',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold))))
          ],
        );
      },
    );
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
                      setState(() {
                        _isPayByMpesa = value;
                      });
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
                    value: _isWithdrawByMpesa,
                    checkColor: Colors.blue,
                    activeColor: Colors.white,
                    onChanged: (bool value) {
                      setState(() {
                        _isWithdrawByMpesa = value;
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
                    '${_defaultTime.format(context)}',
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
                      value == null ? _defaultTime : _defaultTime = value;
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

  void _updatePrefs() {}

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
        children: [_isMpesa(), _isCard()],
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
        children: [_iswithdrawBank(), _iswithdrawMpesa()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //Retreieve UID
    uid = ModalRoute.of(context).settings.arguments;
    print('Settings UID: $uid');

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
                      Text(
                        'Reminders',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _reminder(),
                      SizedBox(
                        height: 30,
                      ),
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
                      _updateBtn()
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
