import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/helper.dart';
import 'package:wealth/widgets/manualCapture.dart';
import 'package:wealth/widgets/unsuccessfull_error.dart';

class Insights extends StatefulWidget {
  final String uid;

  Insights({@required this.uid});

  @override
  _InsightsState createState() => _InsightsState();
}

class _InsightsState extends State<Insights> {
  Helper helper = new Helper();

  Future incVexpe;
  Future activeVincome;
  Future passVexp;

  Future _addIncorExp() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Custom entry',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ),
          content: ManualCapture(
            uid: widget.uid,
          ),
        );
      },
    );
  }

  LineChartData incomeVExpenseData() {
    return LineChartData(
      gridData: FlGridData(
          // drawVerticalLine: true,
          // getDrawingHorizontalLine: (value) {
          //   return const FlLine(
          //     color: Color(0xff37434d),
          //     strokeWidth: 1,
          //   );
          // },
          // getDrawingVerticalLine: (value) {
          //   return const FlLine(
          //     color: Color(0xff37434d),
          //     strokeWidth: 1,
          //   );
          // },
          ),
      clipToBorder: true,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 10,
          textStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'MAR';
              case 5:
                return 'JUN';
              case 8:
                return 'SEP';
              case 11:
                return 'DEC';
            }
            return '';
          },
          margin: 6,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '10k';
              case 3:
                return '30k';
              case 5:
                return '50k';
            }
            return '';
          },
          reservedSize: 20,
          margin: 6,
        ),
      ),
      borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
          ),
        ),
      ],
    );
  }

  Widget _containerIncVExp() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Incomes v Expenses',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                  ),
                  Text(
                    'Captured from SMS',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                    )),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _addIncorExp(),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: incVexpe,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    int total = snapshot.data['total'];
                    int incomeCount = snapshot.data["incomes"].documents.length;
                    int expenseCount =
                        snapshot.data['expenses'].documents.length;
                    double receivedAmount = snapshot.data['receivedAmount'];
                    double sentAmount = snapshot.data['sentAmount'];

                    if (incomeCount == 0 && expenseCount == 0) {
                      return UnsuccessfullError(
                          message: 'We have not captured any data');
                    } else {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: Duration(seconds: 1),
                            height: (MediaQuery.of(context).size.height * 0.3) *
                                0.2,
                            width: (MediaQuery.of(context).size.width) *
                                (incomeCount / total),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomRight: Radius.circular(30))),
                            child: Center(
                              child: Text(
                                '${receivedAmount.toStringAsFixed(0)} KES',
                                style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    textStyle: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          AnimatedContainer(
                            duration: Duration(seconds: 1),
                            height: (MediaQuery.of(context).size.height * 0.3) *
                                0.2,
                            width: (MediaQuery.of(context).size.width) *
                                (expenseCount / total),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomRight: Radius.circular(30))),
                            child: Center(
                              child: Text(
                                '${sentAmount.toStringAsFixed(0)} KES',
                                style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    textStyle: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return UnsuccessfullError(
                        message: 'We have not captured any data');
                  }
                  break;
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return SpinKitDoubleBounce(
                    size: (MediaQuery.of(context).size.height * 0.3) / 2,
                    color: Colors.greenAccent[700],
                  );
                case ConnectionState.none:
                  return Text('none');
                default:
                  return SpinKitDoubleBounce(
                    size: (MediaQuery.of(context).size.height * 0.3) / 2,
                    color: Colors.greenAccent[700],
                  );
              }
            },
          )
        ],
      ),
    );
  }

  Widget _containerPassvExp() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passive Savings v Expenses',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ),
          SizedBox(
            height: 10,
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: passVexp,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    int total = snapshot.data['total'];
                    int passiveCount =
                        snapshot.data["passive"].documents.length;
                    int expensesCount =
                        snapshot.data['expenses'].documents.length;
                    double passiveAmount = snapshot.data['passiveAmount'];
                    double sentAmount = snapshot.data['sentAmount'];

                    if (passiveCount == 0 && expensesCount == 0) {
                      return UnsuccessfullError(
                          message: 'We have not captured any data');
                    } else {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: Duration(seconds: 1),
                            height: (MediaQuery.of(context).size.height * 0.3) *
                                0.2,
                            width: (MediaQuery.of(context).size.width) *
                                (passiveCount / total),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomRight: Radius.circular(30))),
                            child: Center(
                              child: Text(
                                '${passiveAmount.toStringAsFixed(0)} KES',
                                style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    textStyle: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          AnimatedContainer(
                            duration: Duration(seconds: 1),
                            height: (MediaQuery.of(context).size.height * 0.3) *
                                0.2,
                            width: (MediaQuery.of(context).size.width) *
                                (expensesCount / total),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomRight: Radius.circular(30))),
                            child: Center(
                              child: Text(
                                '${sentAmount.toStringAsFixed(0)} KES',
                                style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    textStyle: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return UnsuccessfullError(
                        message: 'We have not captured any data');
                  }
                  break;
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return SpinKitDoubleBounce(
                    size: (MediaQuery.of(context).size.height * 0.3) / 2,
                    color: Colors.greenAccent[700],
                  );
                case ConnectionState.none:
                  return Text('none');
                default:
                  return SpinKitDoubleBounce(
                    size: (MediaQuery.of(context).size.height * 0.3) / 2,
                    color: Colors.greenAccent[700],
                  );
              }
            },
          )
        ],
      ),
    );
  }

  Widget singleColorKey(Color color, String text, String subtitle) {
    return ListTile(
      leading: Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(16)),
      ),
      title: Text(
        text,
        style: GoogleFonts.quicksand(
            color: color, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.quicksand(color: Colors.black, fontSize: 12),
      ),
    );
  }

  Widget _containerKey() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Incomes
            singleColorKey(Colors.green, 'INCOMES',
                'This is any MPESA message with the keyword "received"'),
            //Expenses
            singleColorKey(Colors.red, 'EXPENSES',
                'This is any MPESA message with the keyword "sent"'),
            //PassiveSavings
            singleColorKey(Colors.blue, 'PASSIVE SAVINGS',
                'These are savings you make when you complete the M-PESA prompt'),
            //Active Savings
            singleColorKey(Colors.purple, 'ACTIVE SAVINGS',
                'These are savings you make deposit money via Paybill')
          ],
        ),
      ),
    );
  }

  Widget _containerActvPassIncs() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Savings v Income',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ),
          SizedBox(
            height: 10,
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: activeVincome,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    int total = snapshot.data['total'];
                    int incomeCount = snapshot.data["incomes"].documents.length;
                    int activeCount = snapshot.data['active'].documents.length;
                    double receivedAmount = snapshot.data['receivedAmount'];
                    double activeAmount = snapshot.data['activeAmount'];

                    if (incomeCount == 0 && activeCount == 0) {
                      return UnsuccessfullError(
                          message: 'We have not captured any data');
                    } else {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: Duration(seconds: 1),
                            height: (MediaQuery.of(context).size.height * 0.3) *
                                0.2,
                            width: (MediaQuery.of(context).size.width) *
                                (activeCount / total),
                            decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomRight: Radius.circular(30))),
                            child: Center(
                              child: Text(
                                '${activeAmount.toStringAsFixed(0)} KES',
                                style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    textStyle: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          AnimatedContainer(
                            duration: Duration(seconds: 1),
                            height: (MediaQuery.of(context).size.height * 0.3) *
                                0.2,
                            width: (MediaQuery.of(context).size.width) *
                                (incomeCount / total),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomRight: Radius.circular(30))),
                            child: Center(
                              child: Text(
                                '${receivedAmount.toStringAsFixed(0)} KES',
                                style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    textStyle: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return Text(snapshot.data.length.toString());
                  }
                  break;
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return SpinKitDoubleBounce(
                    size: (MediaQuery.of(context).size.height * 0.3) / 2,
                    color: Colors.greenAccent[700],
                  );
                case ConnectionState.none:
                  return Text('none');
                default:
                  return SpinKitDoubleBounce(
                    size: (MediaQuery.of(context).size.height * 0.3) / 2,
                    color: Colors.greenAccent[700],
                  );
              }
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    incVexpe = helper.getIncomeVExpenses(widget.uid);
    activeVincome = helper.getActiveVIncome(widget.uid);
    passVexp = helper.getPassiveVExpense(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Key',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
            ),
            SizedBox(
              height: 5,
            ),
            _containerKey(),
            SizedBox(
              height: 10,
            ),
            _containerIncVExp(),
            SizedBox(
              height: 30,
            ),
            _containerPassvExp(),
            SizedBox(
              height: 30,
            ),
            _containerActvPassIncs(),
          ],
        ),
      ),
    );
  }
}
