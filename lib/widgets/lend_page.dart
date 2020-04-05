import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/models/loanDuration.dart';
import 'package:wealth/utilities/styles.dart';

class LendPage extends StatefulWidget {
  @override
  _LendPageState createState() => _LendPageState();
}

class _LendPageState extends State<LendPage> {
  final styleLabel =
      GoogleFonts.muli(textStyle: TextStyle(color: Colors.white, fontSize: 15));

  //Placeholder of amount
  double targetAmount = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are creating the loan fund goal that allows you to lend to Sortika customers against their investments at your agreed interest rate.',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                color: Colors.white,
              )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Divider(
                height: 2,
                thickness: 2,
                color: Colors.white,
              ),
            ),
            Text(
              '* You could also borrow from your fund at your own defined rate *',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Divider(
                height: 2,
                thickness: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'How much are you willing to lend?',
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
              height: 10,
            ),
            Text(
              'For how long?',
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
      ),
    );
  }
}
