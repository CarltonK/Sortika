import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  //Identifiers
  double _passiveRate = 5;
  double _loanLimitRate = 75;

  bool _isReminderDaily = false;
  bool _isReminderWeekly = false;

  bool _isByMpesa = false;
  bool _isWithdrawByMpesa = false;

  bool _isByCard = false;
  bool _isWithdrawToBank = false;

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
            'The current rate is ${_passiveRate.toInt()} %',
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
                data: ThemeData(unselectedWidgetColor: Colors.purple),
                child: Checkbox(
                    value: _isReminderDaily,
                    checkColor: Colors.white,
                    activeColor: Colors.purple,
                    onChanged: (bool value) {
                      setState(() {
                        _isReminderDaily = value;
                      });
                    })),
          ))
        ],
      ),
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
                    data: ThemeData(unselectedWidgetColor: Colors.purple),
                    child: Checkbox(
                        value: _isReminderWeekly,
                        checkColor: Colors.white,
                        activeColor: Colors.purple,
                        onChanged: (bool value) {
                          setState(() {
                            _isReminderWeekly = value;
                          });
                        })),
              ))
            ],
          ),
          SizedBox(
            height: 10,
          ),
          _weekdaySelection()
        ],
      ),
    );
  }

  Widget _weekdaySelection() {
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'M',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Container(
              child: Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.purple),
                  child: Checkbox(
                      value: _isReminderWeekly,
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      onChanged: (bool value) {
                        setState(() {});
                      })),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'T',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Container(
              child: Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.purple),
                  child: Checkbox(
                      value: _isReminderWeekly,
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      onChanged: (bool value) {
                        setState(() {});
                      })),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'W',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Container(
              child: Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.purple),
                  child: Checkbox(
                      value: _isReminderWeekly,
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      onChanged: (bool value) {
                        setState(() {});
                      })),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'T',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Container(
              child: Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.purple),
                  child: Checkbox(
                      value: _isReminderWeekly,
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      onChanged: (bool value) {
                        setState(() {});
                      })),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'F',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Container(
              child: Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.purple),
                  child: Checkbox(
                      value: _isReminderWeekly,
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      onChanged: (bool value) {
                        setState(() {});
                      })),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'S',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Container(
              child: Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.purple),
                  child: Checkbox(
                      value: _isReminderWeekly,
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      onChanged: (bool value) {
                        setState(() {});
                      })),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'S',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Container(
              child: Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.purple),
                  child: Checkbox(
                      value: _isReminderWeekly,
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      onChanged: (bool value) {
                        setState(() {});
                      })),
            )
          ],
        ),
      ],
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
                data: ThemeData(unselectedWidgetColor: Colors.purple),
                child: Checkbox(
                    value: _isByCard,
                    checkColor: Colors.white,
                    activeColor: Colors.purple,
                    onChanged: (bool value) {
                      setState(() {
                        _isByCard = value;
                      });
                      if (value) {
                        _cardDialog();
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
              child: TextFormField(
            style: GoogleFonts.muli(textStyle: TextStyle(color: Colors.black)),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '07XXXXXXXX',
              hintStyle: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w300)),
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
            ),
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
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                style:
                    GoogleFonts.muli(textStyle: TextStyle(color: Colors.black)),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Card Number',
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
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: TextFormField(
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(color: Colors.black)),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'CVV',
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
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Expiry',
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
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Billing Address',
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
                data: ThemeData(unselectedWidgetColor: Colors.purple),
                child: Checkbox(
                    value: _isByMpesa,
                    checkColor: Colors.white,
                    activeColor: Colors.purple,
                    onChanged: (bool value) {
                      setState(() {
                        _isByMpesa = value;
                      });
                      //Check if the box is selected
                      if (value) {
                        _mpesaNumberDialog();
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
                data: ThemeData(unselectedWidgetColor: Colors.purple),
                child: Checkbox(
                    value: _isWithdrawByMpesa,
                    checkColor: Colors.white,
                    activeColor: Colors.purple,
                    onChanged: (bool value) {
                      setState(() {
                        _isWithdrawByMpesa = value;
                      });
                      //Check if the box is selected
                      if (value) {
                        _mpesaNumberDialog();
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
                data: ThemeData(unselectedWidgetColor: Colors.purple),
                child: Checkbox(
                    value: _isWithdrawToBank,
                    checkColor: Colors.white,
                    activeColor: Colors.purple,
                    onChanged: (bool value) {
                      setState(() {
                        _isWithdrawToBank = value;
                      });
                      if (value) {
                        _bankDialog();
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

  Widget _updateBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: RaisedButton(
        elevation: 2,
        onPressed: () {},
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
          )),
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
                        height: 20,
                      ),
                      _limitWidget(),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Reminders',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                      SizedBox(
                        height: 20,
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
                        height: 20,
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
                        height: 20,
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
