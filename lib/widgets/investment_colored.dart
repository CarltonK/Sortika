import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/loanDuration.dart';
import 'package:wealth/utilities/styles.dart';

class InvestmentColored extends StatefulWidget {
  @override
  _InvestmentColoredState createState() => _InvestmentColoredState();
}

class _InvestmentColoredState extends State<InvestmentColored> {
  final styleLabel =
      GoogleFonts.muli(textStyle: TextStyle(color: Colors.black, fontSize: 15));

  //Investment Asset Class
  String classInvestment;
  //Investment Goal
  String goalInvestment;
  //Placeholder of amount
  double targetAmount = 0;

  //Define Dropdown Menu Items
  List<DropdownMenuItem> itemsAsset = [
    DropdownMenuItem(
      value: 'fixed',
      child: Text(
        'Fixed Income',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  List<DropdownMenuItem> itemsGoals = [
    DropdownMenuItem(
      value: 'billGoal',
      child: Text(
        'Treasury Bill (9.7%)',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  var _date;
  // static var formatter = new DateFormat('yMMMd');
  // String dateFormatted = formatter.format(_date);

  //Custom Period
  Widget _customPeriod() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.only(top: 10),
      height: 50,
      child: Text(_date == null ? 'December 25, 2020' : '${_date.toString()}',
          style: GoogleFonts.muli(
              textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
    );
  }

  Widget _proceedBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: () {},
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.blue,
        child: Text(
          'PROCEED',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
                  letterSpacing: 1.5,
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _amountSelector() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Slider.adaptive(
              value: targetAmount,
              inactiveColor: Colors.grey,
              divisions: 10,
              min: 0,
              max: 100000,
              label: targetAmount.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  targetAmount = value;
                });
              }),
        ),
        Expanded(
            flex: 1,
            child: Center(
              child: Text(
                '${targetAmount.toInt().toString()} KES',
                textAlign: TextAlign.center,
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ))
      ],
    );
  }

  Widget _enterDate() {
    return Row(
      children: [
        Expanded(child: _customPeriod()),
        Center(
          child: GestureDetector(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 1000)),
              ).then((value) {
                setState(() {
                  _date = value;
                });
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.date_range, size: 30, color: Colors.black),
            ),
          ),
        )
      ],
    );
  }

  Widget _periodSelector() {
    return Container(
      height: 70,
      child: ListView.builder(
        itemCount: durationGoalList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              if (durationGoalList.any((item) => item.isSelected)) {
                setState(() {
                  durationGoalList[index].isSelected =
                      !durationGoalList[index].isSelected;
                });
              } else {
                setState(() {
                  durationGoalList[index].isSelected = true;
                });
              }
              print(durationGoalList[index].duration);
            },
            child: Card(
              color: durationGoalList[index].isSelected
                  ? Colors.white
                  : Colors.white70,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                width: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.calendar_today,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${durationGoalList[index].duration}',
                      style: GoogleFonts.muli(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              letterSpacing: 2)),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _goalType() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton(
        items: itemsGoals,
        underline: Divider(
          color: Colors.transparent,
        ),
        value: goalInvestment,
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
            goalInvestment = value;
            //Change color according to value of goal
            if (value == 'billGoal') {
              // color = Colors.brown;
            }
          });
          //print(goal);
        },
      ),
    );
  }

  Widget _goalClass() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton(
        items: itemsAsset,
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
        onChanged: (value) {
          setState(() {
            classInvestment = value;
            //Change color according to value of goal
            if (value == 'fixed') {}
          });
          //print(goal);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Setup a new investment',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Investment Asset Class',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            _goalClass(),
            SizedBox(
              height: 20,
            ),
            Text(
              'Investment Goal',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            _goalType(),
            SizedBox(
              height: 20,
            ),
            Text(
              'Target Amount',
              style: styleLabel,
            ),
            SizedBox(
              height: 12,
            ),
            _amountSelector(),
            SizedBox(
              height: 20,
            ),
            Text(
              'Target Period',
              style: styleLabel,
            ),
            SizedBox(
              height: 10,
            ),
            _periodSelector(),
            SizedBox(
              height: 10,
            ),
            Text(
              '-- OR --',
              style: styleLabel,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'I want to set an end date',
              style: styleLabel,
            ),
            _enterDate(),
            _proceedBtn()
          ],
        ),
      ),
    );
  }
}
