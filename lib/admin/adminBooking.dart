import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/admin/admin_api/admin_helper.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/global/errorMessage.dart';
import 'package:wealth/global/successMessage.dart';
import 'package:wealth/global/warningMessage.dart';
import 'package:wealth/models/bookingModel.dart';
import 'package:wealth/models/investmentModel.dart';

class AdminBooking extends StatefulWidget {
  @override
  _AdminBookingState createState() => _AdminBookingState();
}

class _AdminBookingState extends State<AdminBooking> {
  final styleLabel =
      GoogleFonts.muli(textStyle: TextStyle(color: Colors.black, fontSize: 15));

  //Investment Asset Class
  String classInvestment;
  //Investment Goal
  String goalInvestment;
  num returnVal;

  Future<List<InvestmentModel>> fetchData;
  Helper helper = new Helper();

  List<InvestmentModel> _classes = [];
  List<dynamic> _types = [];

  //Participants placeholder
  double _booking = 0;

  AdminHelper adminHelp = AdminHelper();

  Widget _investClassWidget() {
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
        child: FutureBuilder<List<InvestmentModel>>(
          future: fetchData,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasData) {
                  _classes = snapshot.data;
                  return DropdownButton(
                    items: _classes
                        .map((map) => DropdownMenuItem(
                              value: map.title,
                              child: Text(
                                map.title,
                                style: GoogleFonts.muli(
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ))
                        .toList(),
                    underline: Divider(
                      color: Colors.transparent,
                    ),
                    value: classInvestment,
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
                    onChanged: (value) => selectedChange(value),
                  );
                }
                return LinearProgressIndicator();
              case ConnectionState.waiting:
                return LinearProgressIndicator();
              default:
                return LinearProgressIndicator();
            }
          },
        ));
  }

  void selectedChange(String value) {
    setState(() {
      goalInvestment = 'Choose a goal';
      _types = [
        {'name': 'Choose a goal', 'return': 0}
      ];
      classInvestment = value;
      _types = List.from(_types)..addAll(getgoalByTitle(value));
      print(_types);
    });
  }

  getgoalByTitle(String value) => _classes
      .map((map) => map)
      .where((item) => item.title == value)
      .map((item) => item.types)
      .expand((i) => i)
      .toList();

  Widget _investTypeWidget() {
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
        value: goalInvestment,
        disabledHint: Text(
          'Please select a class',
          style: GoogleFonts.muli(
              textStyle: TextStyle(fontWeight: FontWeight.w600)),
        ),
        items: _types.map((map) {
          String name = map['name'];
          returnVal = map['return'];
          return DropdownMenuItem(
            value: name,
            child: Text(
              '$name ($returnVal%)',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
            ),
          );
        }).toList(),
        underline: Divider(
          color: Colors.transparent,
        ),
        icon: Icon(
          CupertinoIcons.down_arrow,
          color: Colors.black,
        ),
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            goalInvestment = value;
            print(goalInvestment);
          });
        },
      ),
    );
  }

  Widget _bookingSliderWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Slider.adaptive(
              value: _booking,
              inactiveColor: Colors.grey[100],
              divisions: 10,
              min: 0,
              max: 10,
              label: _booking.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _booking = value;
                });
              }),
        ),
        Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '${_booking.toInt().toString()} %',
                style: styleLabel,
              ),
            ))
      ],
    );
  }

  Widget _bookingTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Booking',
          style: styleLabel,
        ),
        SizedBox(
          height: 10,
        ),
        _bookingSliderWidget()
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData = helper.getInvestmentddData();
  }

  Future dialogInfo(String message) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return WarningMessage(message: message);
      },
    );
  }

  Future dialogError(String message) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return ErrorMessage(message: message);
      },
    );
  }

  Future dialogSuccess(String message) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return SuccessMessage(message: message);
      },
    );
  }

  bookInvestment() {
    if (_booking == 0) {
      dialogInfo('Please select the booking value');
    } else if (classInvestment == null) {
      dialogInfo('Please select the goal class');
    } else if (goalInvestment == null || goalInvestment == 'Choose a goal') {
      dialogInfo('Please select the goal type');
    } else {
      BookingModel model = BookingModel(
          booking: _booking,
          name: goalInvestment,
          time: Timestamp.now(),
          title: classInvestment,
          returnVal: returnVal);
      // print(model.toJSON());
      adminHelp
          .bookInvestment(model)
          .then((value) => dialogSuccess(
              'You have successfully booked a return for $goalInvestment'))
          .catchError((error) => dialogError(error.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Asset Class',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            _investClassWidget(),
            SizedBox(
              height: 30,
            ),
            Text(
              'Investment Goal',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            _investTypeWidget(),
            SizedBox(
              height: 30,
            ),
            _bookingTF()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: bookInvestment,
        child: Icon(Icons.done),
        tooltip: 'Book an Investment',
      ),
    );
  }
}
