import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart' as pie;

class Portfolio extends StatefulWidget {
  @override
  _PortfolioState createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  //Page Controller
  PageController _controller = PageController(viewportFraction: 0.9);

  Map<String, double> dataMap = Map();

  //Pie Chart Colors
  List<Color> colorList = [
    Colors.blue,
    Colors.yellow,
    Colors.red,
    Colors.green
  ];

  List<Color> chartColors = [Colors.pink];

  @override
  void initState() {
    super.initState();

    //Populate Pie Chart
    dataMap.putIfAbsent("Fixed Income", () => 4);
    dataMap.putIfAbsent("Crypto", () => 3);
    dataMap.putIfAbsent("Money Market", () => 2);
    dataMap.putIfAbsent("Equities", () => 1);
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

  @override
  Widget build(BuildContext context) {
    Widget _portfolioSummary() {
      return Container(
          height: MediaQuery.of(context).size.height * 0.45,
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
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
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
                                  Icon(
                                    CupertinoIcons.time,
                                    color: Colors.white,
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
                                  vertical: 10, horizontal: 10),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Equities',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
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
                                  Icon(
                                    CupertinoIcons.time,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '100000 KES',
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
                                  vertical: 10, horizontal: 10),
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
                                    '250 KES',
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
              )
            ],
          ));
    }

    Widget _investmentTransactions() {
      return Container(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      child: Icon(Icons.arrow_upward),
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
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deposit',
                                  style: GoogleFonts.muli(
                                      textStyle: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text(
                                  'MMF',
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
                                  '2000 KES',
                                  style: GoogleFonts.muli(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text(
                                  '23 Dec',
                                  style: GoogleFonts.muli(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal)),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      child: Icon(Icons.arrow_downward),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[50],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Withdraw',
                                  style: GoogleFonts.muli(
                                      textStyle: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text(
                                  'SIB',
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
                                  '4000 KES',
                                  style: GoogleFonts.muli(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text(
                                  '14 Jan',
                                  style: GoogleFonts.muli(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal)),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ));
    }

    Widget _assetAllocation() {
      return Container(
        height: MediaQuery.of(context).size.height * 0.3,
        child: pie.PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 500),
          chartType: pie.ChartType.ring,
          showChartValuesInPercentage: true,
          showChartValueLabel: false,
          showChartValues: false,
          initialAngle: 0,
          chartRadius: MediaQuery.of(context).size.width / 1.5,
          chartValueStyle: pie.defaultChartValueStyle.copyWith(
            color: Colors.blueGrey[900].withOpacity(0.9),
          ),
          chartValueBackgroundColor: Colors.grey[200],
          showLegends: true,
          colorList: colorList,
        ),
      );
    }

    final titleStyle = GoogleFonts.muli(
        textStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.5));

    return Container(
      height: double.infinity,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Asset Allocation',
              style: titleStyle,
            ),
            _assetAllocation(),
            Text(
              'Summary',
              style: titleStyle,
            ),
            SizedBox(
              height: 10,
            ),
            _portfolioSummary(),
            SizedBox(
              height: 10,
            ),
            Text(
              'Transactions',
              style: titleStyle,
            ),
            _investmentTransactions()
          ],
        ),
      ),
    );
  }
}
