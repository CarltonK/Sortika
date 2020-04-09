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
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
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
                    })),
          ))
        ],
      ),
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
