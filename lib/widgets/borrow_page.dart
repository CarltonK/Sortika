import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/loanDuration.dart';
import 'package:wealth/utilities/styles.dart';

class BorrowPage extends StatefulWidget {
  @override
  _BorrowPageState createState() => _BorrowPageState();
}

class _BorrowPageState extends State<BorrowPage> {
  final styleLabel =
      GoogleFonts.muli(textStyle: TextStyle(color: Colors.white, fontSize: 15));

  final styleAmount = GoogleFonts.muli(
      textStyle: TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  ));

  //Placeholder of type
  String typeLoan;
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
        'Self Loan',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'p2p',
      child: Text(
        'Peer to Peer Loan',
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
            Container(
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
                    //Change color according to value of goal
                    if (value == 'self') {
                      // color = Colors.brown;
                    }
                    if (value == 'p2p') {
                      // color = Colors.green;
                    }
                  });
                  //print(goal);
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Amount',
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
            ),
            Text(
              'Interest Offer',
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
            ),
            Text(
              'Period',
              style: styleLabel,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 70,
              child: ListView.builder(
                itemCount: durationList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      if (durationList.any((item) => item.isSelected)) {
                        setState(() {
                          durationList[index].isSelected =
                              !durationList[index].isSelected;
                        });
                      } else {
                        setState(() {
                          durationList[index].isSelected = true;
                        });
                      }
                      print(durationList[index].duration);
                    },
                    child: Card(
                      color: durationList[index].isSelected
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
                              '${durationList[index].duration}',
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
                    icon: Icon(Icons.date_range, size: 30, color: Colors.white),
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
              height: 10,
            ),
            Row(
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
            ),
            SizedBox(
              height: 10,
            ),
            typeLoan == 'p2p'
                ? Text(
                    'Who will receive the request',
                    style: styleLabel,
                  )
                : Text(''),
            SizedBox(
              height: 10,
            ),
            typeLoan == 'p2p'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {},
                        color: Colors.white70,
                        child: Text(
                          'All',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.black, letterSpacing: 2)),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {},
                        color: Colors.blue,
                        child: Text(
                          'Specific',
                          style: GoogleFonts.muli(
                              textStyle: TextStyle(
                                  color: Colors.white, letterSpacing: 2)),
                        ),
                      )
                    ],
                  )
                : Text('')
          ],
        ),
      ),
    );
  }
}
