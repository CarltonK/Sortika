import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth/api/helper.dart';

class Insights extends StatefulWidget {
  final String uid;

  Insights({@required this.uid});

  @override
  _InsightsState createState() => _InsightsState();
}

class _InsightsState extends State<Insights> {
  String _itemType;

  Helper helper = new Helper();

  Future incVexpe;

  List<DropdownMenuItem> entryTypes = [
    DropdownMenuItem(
      value: 'income',
      child: Text(
        'Income',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
    DropdownMenuItem(
      value: 'expense',
      child: Text(
        'Expense',
        style: GoogleFonts.muli(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    ),
  ];

  Widget _typeEntry() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton(
        items: entryTypes,
        underline: Divider(
          color: Colors.transparent,
        ),
        value: _itemType,
        hint: Text(
          'Type',
          style: GoogleFonts.muli(textStyle: TextStyle()),
        ),
        icon: Icon(
          CupertinoIcons.down_arrow,
          color: Colors.black,
        ),
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            _itemType = value;
          });
          print(_itemType);
        },
      ),
    );
  }

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
          content: Form(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _typeEntry(),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style:
                    GoogleFonts.muli(textStyle: TextStyle(color: Colors.black)),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Amount',
                  hintStyle: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w300)),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
              ),
            ],
          )),
          actions: [
            FlatButton(
                onPressed: () {},
                child: Text(
                  'ADD',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  )),
                ))
          ],
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
                            fontWeight: FontWeight.w600,)),
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

                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: Duration(seconds: 1),
                          height:
                              (MediaQuery.of(context).size.height * 0.3) * 0.2,
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
                          height:
                              (MediaQuery.of(context).size.height * 0.3) * 0.2,
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

  Widget _containerPassvActive() {
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
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: LineChart(incomeVExpenseData()),
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
                color: color,
                borderRadius: BorderRadius.circular(16)
              ),
            ),
            title: Text(
              text,
              style: GoogleFonts.quicksand(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
            subtitle: Text(
              subtitle,
              style: GoogleFonts.quicksand(
                color: Colors.black,
              ),
            ),
          );
  }

   Widget _containerKey() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)
      ),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Incomes
            singleColorKey(Colors.green, 'INCOMES',''),
            //Expenses
            singleColorKey(Colors.red, 'EXPENSES',''),
            //PassiveSavings
            singleColorKey(Colors.blue, 'PASSIVE SAVINGS','These are savings you make when you complete the M-PESA prompt'),
            //Active Savings
            singleColorKey(Colors.purple, 'ACTIVE SAVINGS','These are savings you make deposit money via Paybill')
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
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: LineChart(incomeVExpenseData()),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    incVexpe = helper.getIncomeVExpenses(widget.uid);
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
            SizedBox(height: 10,),
            _containerIncVExp(),
            SizedBox(
              height: 30,
            ),
            _containerPassvActive(),
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
