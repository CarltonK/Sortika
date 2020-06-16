import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wealth/admin/admin_api/admin_helper.dart';
import 'package:wealth/global/progressDialog.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/global/warningMessage.dart';
import 'package:wealth/models/lotteryModel.dart';
import 'package:wealth/utilities/styles.dart';

class CreateLottery extends StatefulWidget {
  @override
  _CreateLotteryState createState() => _CreateLotteryState();
}

class _CreateLotteryState extends State<CreateLottery> {
  AdminHelper helper = new AdminHelper();

  Color color;
  //Participants placeholder
  double _subscriptionFee = 0;
  double _ticketFee = 50;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(Duration(hours: 1));

  //Form Key
  final _formKey = GlobalKey<FormState>();

  //Identifiers
  String _name;

  //Handle Phone Input
  void _handleSubmittedName(String value) {
    _name = value.trim();
    print('Name: ' + _name);
  }

  //Name Widget
  Widget _nameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Lottery Name',
          style: labelStyleBlack,
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
            autofocus: false,
            keyboardType: TextInputType.text,
            style: GoogleFonts.muli(
              textStyle: labelStyleBlack,
            ),
            validator: (value) {
              //Check if email is empty
              if (value.isEmpty) {
                return 'Lotter Name is required';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onSaved: _handleSubmittedName,
            decoration: InputDecoration(
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: color)),
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: color)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                border:
                    OutlineInputBorder(borderSide: BorderSide(color: color))))
      ],
    );
  }

  Widget _subscriptionSliderWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Slider.adaptive(
              value: _subscriptionFee,
              inactiveColor: Colors.green[100],
              divisions: 20,
              min: 0,
              max: 1000,
              label: _subscriptionFee.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _subscriptionFee = value;
                });
              }),
        ),
        Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '${_subscriptionFee.toInt().toString()} KES',
                style: labelStyleBlack,
              ),
            ))
      ],
    );
  }

  Widget _ticketSliderWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Slider.adaptive(
              value: _ticketFee,
              inactiveColor: Colors.green[100],
              divisions: 3,
              min: 50,
              max: 200,
              label: _ticketFee.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _ticketFee = value;
                });
              }),
        ),
        Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '${_ticketFee.toInt().toString()} KES',
                style: labelStyleBlack,
              ),
            ))
      ],
    );
  }

  Widget _subscriptionTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Subscription Fee',
          style: labelStyleBlack,
        ),
        SizedBox(
          height: 10,
        ),
        _subscriptionSliderWidget()
      ],
    );
  }

  Widget _ticketTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Ticket Fee',
          style: labelStyleBlack,
        ),
        SizedBox(
          height: 10,
        ),
        _ticketSliderWidget()
      ],
    );
  }

  Widget _startTimeTF() {
    //Date Parsing and Formatting
    var formatter = new DateFormat('EEE d MMM y HH:MM');
    String date = formatter.format(_startTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Start Time',
          style: labelStyleBlack,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              date,
              style: hintStyleBlack,
            ),
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    minTime: _startTime,
                    maxTime: DateTime(2022, 1, 1), onChanged: (date) {
                  print('change $date');
                  setState(() {
                    _startTime = date;
                  });
                }, onConfirm: (date) {
                  print('confirm $date');
                  _startTime = date;
                }, currentTime: DateTime.now());
              },
            )
          ],
        )
      ],
    );
  }

  Widget _endTimeTF() {
    //Date Parsing and Formatting
    var formatter = new DateFormat('EEE d MMM y HH:MM');
    String date = formatter.format(_endTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'End Time',
          style: labelStyleBlack,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              date,
              style: hintStyleBlack,
            ),
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    minTime: DateTime.now(),
                    maxTime: DateTime(2022, 1, 1), onChanged: (date) {
                  print('change $date');
                  setState(() {
                    _endTime = date;
                  });
                }, onConfirm: (date) {
                  print('confirm $date');
                  _endTime = date;
                }, currentTime: DateTime.now());
              },
            )
          ],
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

  Future _promptUserSuccess(String message) {
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return SuccessMessage(message: message);
        });
  }

  void createBtnPressed() {
    if (_name == null) {
      _promptUser('Please enter the name of the lottery');
    }
    if (_subscriptionFee == 0) {
      _promptUser('Please enter the subscription fee');
    }
    if (_endTime.difference(_startTime).isNegative) {
      _promptUser('The End Time must be after the Start Time');
    } else {
      final FormState form = _formKey.currentState;
      if (form.validate()) {
        form.save();

        LotteryModel lotMod = LotteryModel(
            participants: 0,
            end: Timestamp.fromDate(_endTime),
            start: Timestamp.fromDate(_startTime),
            name: _name,
            subscriptionFee: _subscriptionFee.toInt(),
            ticketFee: _ticketFee.toInt(),
            winner: null);

        helper
            .createLottery(lotMod)
            .then((value) =>
                _promptUserSuccess('The lottery club was created successfully'))
            .catchError((error) => _promptUser(error.toString()));
      }
    }
  }

  Widget _createBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5,
        onPressed: createBtnPressed,
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: color,
        child: Text(
          'CREATE',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
                  letterSpacing: 1.5,
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    color = Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create a new lottery'),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  _nameTF(),
                  SizedBox(
                    height: 20,
                  ),
                  _subscriptionTF(),
                  SizedBox(
                    height: 20,
                  ),
                  _ticketTF(),
                  SizedBox(
                    height: 20,
                  ),
                  _startTimeTF(),
                  SizedBox(
                    height: 20,
                  ),
                  _endTimeTF(),
                  _createBtn()
                ],
              ),
            ),
          ),
        ));
  }
}
