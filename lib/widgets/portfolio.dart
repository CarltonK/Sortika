import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart' as pie;
import 'package:wealth/api/helper.dart';
import 'package:wealth/widgets/unsuccessfull_error.dart';

class Portfolio extends StatefulWidget {
  final String uid;
  Portfolio({this.uid});
  @override
  _PortfolioState createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  final titleStyle = GoogleFonts.muli(
      textStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5));
  //Page Controller
  PageController _controller = PageController(viewportFraction: 0.9);

  List<Color> chartColors = [Colors.pink];

  Map<String, double> dataMap = Map();
  final String category = 'Saving';

  Firestore _firestore = Firestore.instance;
  Helper helper = new Helper();
  Future transactionsData;

  @override
  void initState() {
    super.initState();
    transactionsData = helper.getTransactions(widget.uid, category);
  }

  LineChartData mainData() {
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
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 10,
          textStyle: const TextStyle(
            color: Colors.white,
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
            color: Colors.white,
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
              case 7:
                return '70k';
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
          colors: chartColors,
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

  Future _filterByTime() {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
            'Filter',
            style: GoogleFonts.muli(textStyle: TextStyle(color: Colors.black)),
          ),
          actions: [
            CupertinoActionSheetAction(
              child: Text(
                '24 Hrs',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal)),
              ),
              onPressed: () {},
            ),
            CupertinoActionSheetAction(
              child: Text(
                '7 Days',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal)),
              ),
              onPressed: () {},
            ),
            CupertinoActionSheetAction(
              child: Text(
                '30 Days',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal)),
              ),
              onPressed: () {},
            ),
            CupertinoActionSheetAction(
              child: Text(
                'Lifetime',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal)),
              ),
              onPressed: () {},
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(
              'CANCEL',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.normal)),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }

  Widget _portfolioSummary() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: PageView(
          scrollDirection: Axis.horizontal,
          controller: _controller,
          onPageChanged: (value) {
            _controller.animateToPage(value,
                duration: Duration(milliseconds: 200), curve: Curves.ease);
          },
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Money Market',
                  style: GoogleFonts.muli(
                      textStyle:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                SizedBox(
                  height: 5,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                          tileMode: TileMode.clamp,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.lightBlue[400],
                            Colors.greenAccent[400]
                          ],
                          stops: [
                            0,
                            1.0
                          ]),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () => _filterByTime(),
                                  child: Icon(
                                    CupertinoIcons.time,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '10000 KES',
                                  style: GoogleFonts.muli(
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: LineChart(mainData()),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.trending_up, color: Colors.white),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '10 KES',
                                  style: GoogleFonts.muli(
                                      textStyle: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal)),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _singleTransaction(DocumentSnapshot doc) {
    print(doc.data);

    String action = doc.data['transactionAction'];
    String goal = doc.data['transactionGoal'];
    var amount = doc.data['transactionAmount'];
//    String category = doc.data['transactionCategory'];
    //Date and Time Formatting
    int numberTime = doc.data['transactionTime'];
    String year = numberTime.toString().substring(0, 4);
    String month = numberTime.toString().substring(4, 6);
    String day = numberTime.toString().substring(6, 8);
    String hour = numberTime.toString().substring(8, 10);
    String minutes = numberTime.toString().substring(10, 12);

    String date =
        year + "-" + month + "-" + day + " at " + hour + ":" + minutes;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            child: action == 'Deposit'
                ? Icon(Icons.arrow_upward)
                : Icon(Icons.arrow_downward),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[50],
            ),
            padding: EdgeInsets.all(16),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action,
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: action == 'Deposit'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600)),
                      ),
                      Text(
                        goal == null ? 'General' : goal,
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal)),
                      ),
                      SizedBox(height: 3),
                      Text(
                        date,
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal)),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${amount.toStringAsFixed(2)} KES',
                        style: GoogleFonts.muli(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _savingsTransactions() {
    return LimitedBox(
      maxHeight: MediaQuery.of(context).size.height * 0.5,
      child: FutureBuilder<QuerySnapshot>(
        future: transactionsData,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.none:
              return UnsuccessfullError(
                  message: 'You have not made any savings transactions');
            case ConnectionState.done:
              if (snapshot.data.documents.length > 0) {
                return ListView(
                  children: snapshot.data.documents
                      .map((doc) => _singleTransaction(doc))
                      .toList(),
                );
              } else {
                return UnsuccessfullError(
                    message: 'You have not made any savings transactions');
              }
              break;
            case ConnectionState.waiting:
              return SpinKitDoubleBounce(
                size: 100,
                color: Colors.greenAccent[700],
              );
            default:
              return SpinKitDoubleBounce(
                size: 100,
                color: Colors.greenAccent[700],
              );
          }
        },
      ),
    );
  }

  Future<QuerySnapshot> _getPieChartData() async {
    QuerySnapshot queries = await _firestore
        .collection("users")
        .document(widget.uid)
        .collection("goals")
        .where("goalCategory", isEqualTo: 'Saving')
        .getDocuments();
    return queries;
  }

  Map _retrieveAssets(List<DocumentSnapshot> docs) {
    docs.forEach((element) {
      var allocation = element.data["goalAllocation"];
      dataMap.putIfAbsent(element.data["goalClass"], () => allocation);
    });
    print(dataMap);
    return dataMap;
  }

  Widget _assetAllocation() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: FutureBuilder<Object>(
          future: _getPieChartData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
              case ConnectionState.none:
                return UnsuccessfullError(
                    message: 'You do not have any savings');
              case ConnectionState.done:
                if (snapshot.data.documents.length == 0) {
                  return UnsuccessfullError(
                      message: 'You do not have any savings');
                }
                return pie.PieChart(
                  dataMap: _retrieveAssets(snapshot.data.documents),
                  animationDuration: Duration(milliseconds: 500),
                  chartType: pie.ChartType.disc,
                  showChartValuesInPercentage: true,
                  showChartValueLabel: false,
                  showChartValues: false,
                  initialAngle: 0,
                  chartRadius: MediaQuery.of(context).size.width * 0.5,
                  chartValueStyle: pie.defaultChartValueStyle.copyWith(
                    color: Colors.blueGrey[900].withOpacity(0.9),
                  ),
                  chartValueBackgroundColor: Colors.grey[200],
                  showLegends: true,
                );
              case ConnectionState.waiting:
                return SpinKitDoubleBounce(
                  size: 100,
                  color: Colors.greenAccent[700],
                );
              default:
                return SpinKitDoubleBounce(
                  size: 100,
                  color: Colors.greenAccent[700],
                );
            }
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Allocation',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            _assetAllocation(),
            SizedBox(
              height: 10,
            ),
            // Text(
            //   'Summary',
            //   style: GoogleFonts.muli(
            //       textStyle: TextStyle(
            //           color: Colors.black,
            //           fontSize: 20,
            //           fontWeight: FontWeight.bold)),
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            // _portfolioSummary(),
            // SizedBox(
            //   height: 10,
            // ),
            Text(
              'Transactions',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            _savingsTransactions()
          ],
        ),
      ),
    );
  }
}
