import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/loanDuration.dart';
import 'package:wealth/utilities/styles.dart';

class InvestmentGoal extends StatefulWidget {
  @override
  _InvestmentGoalState createState() => _InvestmentGoalState();
}

class _InvestmentGoalState extends State<InvestmentGoal> {
  final styleLabel =
      GoogleFonts.muli(textStyle: TextStyle(color: Colors.white, fontSize: 15));

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Investment Asset Class',
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
                  if (value == 'fixed') {
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
            'Investment Goal',
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
                    inactiveColor: Colors.white,
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
                      style: labelStyle,
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
          )
        ],
      ),
    );
  }
}
