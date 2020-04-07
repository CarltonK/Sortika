import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart';

class Portfolio extends StatefulWidget {
  @override
  _PortfolioState createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  //Page Controller
  PageController _controller = PageController(viewportFraction: 0.9);

  Map<String, double> dataMap = Map();
  List<Color> colorList = [
    Colors.blue,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();

    dataMap.putIfAbsent("SIB", () => 4);
    dataMap.putIfAbsent("MMF", () => 1);
  }

  @override
  Widget build(BuildContext context) {
    Widget _portfolioSummary() {
      return Expanded(
          child: PageView(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        onPageChanged: (value) {
          _controller.animateToPage(value,
              duration: Duration(milliseconds: 200), curve: Curves.ease);
        },
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.grey[200],
            elevation: 3,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                    child: PieChart(
                      dataMap: dataMap,
                      animationDuration: Duration(milliseconds: 500),
                      chartType: ChartType.ring,
                      showChartValuesInPercentage: true,
                      showChartValueLabel: false,
                      showChartValues: false,
                      initialAngle: 0,
                      chartRadius: MediaQuery.of(context).size.width / 2,
                      chartValueStyle: defaultChartValueStyle.copyWith(
                        color: Colors.blueGrey[900].withOpacity(0.9),
                      ),
                      chartValueBackgroundColor: Colors.grey[200],
                      showLegends: false,
                      colorList: colorList,
                    ),
                  )),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SIB',
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Rate',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    Text(
                                      '22%',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal)),
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Deposit',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    Text(
                                      '10000 KES',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal)),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.grey[200],
            elevation: 3,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                    child: PieChart(
                      dataMap: dataMap,
                      animationDuration: Duration(milliseconds: 500),
                      chartType: ChartType.ring,
                      showChartValuesInPercentage: true,
                      showChartValueLabel: false,
                      showChartValues: false,
                      initialAngle: 0,
                      chartRadius: MediaQuery.of(context).size.width / 2,
                      chartValueStyle: defaultChartValueStyle.copyWith(
                        color: Colors.blueGrey[900].withOpacity(0.9),
                      ),
                      chartValueBackgroundColor: Colors.grey[200],
                      showLegends: false,
                      colorList: colorList,
                    ),
                  )),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'MMF',
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Rate',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    Text(
                                      '11%',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal)),
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Deposit',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    Text(
                                      '10000 KES',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal)),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.grey[200],
            elevation: 3,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                    child: PieChart(
                      dataMap: dataMap,
                      animationDuration: Duration(milliseconds: 500),
                      chartType: ChartType.ring,
                      showChartValuesInPercentage: true,
                      showChartValueLabel: false,
                      showChartValues: false,
                      initialAngle: 0,
                      chartRadius: MediaQuery.of(context).size.width / 2,
                      chartValueStyle: defaultChartValueStyle.copyWith(
                        color: Colors.blueGrey[900].withOpacity(0.9),
                      ),
                      chartValueBackgroundColor: Colors.grey[200],
                      showLegends: false,
                      colorList: colorList,
                    ),
                  )),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SIB',
                              style: GoogleFonts.muli(
                                  textStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Rate',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    Text(
                                      '22%',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal)),
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Deposit',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    Text(
                                      '10000 KES',
                                      style: GoogleFonts.muli(
                                          textStyle: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal)),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      )),
                ],
              ),
            ),
          )
        ],
      ));
    }

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            'Summary',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.normal)),
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
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.normal)),
          ),
          Expanded(
              flex: 3,
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
              ))
        ],
      ),
    );
  }
}
