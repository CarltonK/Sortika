import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/loanDuration.dart';
import 'package:wealth/utilities/styles.dart';

class SavingsColored extends StatefulWidget {
  @override
  _SavingsColoredState createState() => _SavingsColoredState();
}

class _SavingsColoredState extends State<SavingsColored> {
  final styleLabel =
      GoogleFonts.muli(textStyle: TextStyle(color: Colors.black, fontSize: 15));

  //Goal placeholder
  String goalSavings;
  //Type placeholder
  String typeSavings;
  //Placeholder of amount
  double targetAmount = 0;

  List<DropdownMenuItem> itemsGoals = [
    DropdownMenuItem(
      value: 'utility',
      child: Text(
        'Utility goals',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'custom',
      child: Text(
        'Create my own goal',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  List<DropdownMenuItem> itemsTypes = [
    DropdownMenuItem(
      value: 'loan',
      child: Text(
        'Loan repayment',
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
      margin: EdgeInsets.only(top: 10),
      height: 50,
      child: Text(_date == null ? 'December 25, 2020' : '${_date.toString()}',
          style: GoogleFonts.muli(
              textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
    );
  }

  //Capture custom goal name
  String _customGoal = '';

  void _handleSubmittedGoalName(String value) {
    _customGoal = value;
    print('Goal Name: $_customGoal');
  }

  //Custom goal name
  Widget _customGoalName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          decoration: boxDecorationStyle,
          height: 60,
          child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.white,
              )),
              onFieldSubmitted: (value) {
                FocusScope.of(context).unfocus();
              },
              onSaved: _handleSubmittedGoalName,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                  hintText: 'Goal Name',
                  hintStyle: hintStyle)),
        )
      ],
    );
  }

  Widget _proceedBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
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
              'Setup a new savings goal',
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
              'What are you saving towards?',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            Container(
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
                value: goalSavings,
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
                    goalSavings = value;
                    //Change color according to value of goal
                    if (value == 'custom') {
                      //Show a popup to create a goal
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              content: Container(
                                child: Form(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      _customGoalName(),
                                    ],
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                    onPressed: () {},
                                    child: Text(
                                      'Create',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                    ))
                              ],
                            );
                          });
                    }
                  });
                  //print(goal);
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Please select the goal type',
              style: styleLabel,
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton(
                items: itemsTypes,
                underline: Divider(
                  color: Colors.transparent,
                ),
                value: typeSavings,
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
                    typeSavings = value;
                    //Change color according to value of goal
                    if (value == 'billGoal') {
                      // color = Colors.brown;
                    }
                  });
                  //print(goal);
                },
              ),
            ),
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
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Slider.adaptive(
                      value: targetAmount,
                      inactiveColor: Colors.grey[400],
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
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ))
              ],
            ),
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
            Container(
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
            ),
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
            Row(
              children: [
                Expanded(child: _customPeriod()),
                Center(
                  child: IconButton(
                    icon: Icon(Icons.date_range, size: 30, color: Colors.black),
                    splashColor: Colors.greenAccent[700],
                    onPressed: () {
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
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              goalSavings == 'custom'
                  ? 'I have decided to create a custom goal titled $_customGoal'
                  : '',
              style: styleLabel,
            ),
            _proceedBtn()
          ],
        ),
      ),
    );
  }
}
