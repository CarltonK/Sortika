import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart' as pie;
import 'package:wealth/api/helper.dart';
import 'package:wealth/models/goalmodel.dart';
import 'package:wealth/widgets/unsuccessfull_error.dart';

class InvestmentPortfolio extends StatefulWidget {
  final String uid;
  InvestmentPortfolio({this.uid});

  @override
  _InvestmenPortfolioState createState() => _InvestmenPortfolioState();
}

class _InvestmenPortfolioState extends State<InvestmentPortfolio> {
  final titleStyle = GoogleFonts.muli(
      textStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5));
  //Page Controller
  PageController _controller;

  String goal;

  Map<String, double> dataMap = Map();
  final String category = 'Investment';

  Helper helper = new Helper();

  Future investmentData;
  Future transactionsData;
  Future singleTransactionFuture;
  Future graphData;

  DateTime rightNow = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
    investmentData = helper.getInvestmentData(widget.uid);
    transactionsData = helper.getTransactions(widget.uid, category);
    graphData = helper.investmentSummaryData(category, widget.uid);
  }

  graphLineDraw(double month, double point) {
    return FlSpot(month, point);
  }

  LineChartData mainData(
      double amount, Timestamp end, List<DocumentSnapshot> list) {
    int daysDiff = end.toDate().month - 1;
    print(daysDiff);

    return LineChartData(
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
          margin: 5,
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
                return ((amount / 5) * 1).toStringAsFixed(0);
              case 2:
                return ((amount / 5) * 2).toStringAsFixed(0);
              case 3:
                return ((amount / 5) * 3).toStringAsFixed(0);
              case 4:
                return ((amount / 5) * 4).toStringAsFixed(0);
              case 5:
                return ((amount / 5) * 5).toStringAsFixed(0);
            }
            return '';
          },
          reservedSize: 35,
          margin: 10,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
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

  Widget _singlePortfolioView(Map<String, dynamic> element) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          element['name'],
          style: GoogleFonts.muli(
              textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        SizedBox(
          height: 5,
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                  tileMode: TileMode.clamp,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.lightBlue[400], Colors.greenAccent[400]],
                  stops: [0, 1.0]),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                          // onTap: () => _filterByTime(),
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
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: LineChart(mainData(element['total'],
                        element['endDate'], element['documents'])),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
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
    );
  }

  Widget _portfolioSummary() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: FutureBuilder<List<Map<String, dynamic>>>(
            future: graphData,
            builder: (context, snapshot) {
              print(snapshot.data);
              switch (snapshot.connectionState) {
                case ConnectionState.active:
                case ConnectionState.none:
                  return Text('none');
                case ConnectionState.done:
                  return PageView(
                    scrollDirection: Axis.horizontal,
                    controller: _controller,
                    onPageChanged: (value) {
                      _controller.animateToPage(value,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.ease);
                    },
                    children: snapshot.data
                        .map((element) => _singlePortfolioView(element))
                        .toList(),
                  );
                case ConnectionState.waiting:
                  return Center(
                    child: SpinKitDoubleBounce(
                      size: MediaQuery.of(context).size.height * 0.25,
                      color: Colors.greenAccent[700],
                    ),
                  );
                default:
                  return Center(
                    child: SpinKitDoubleBounce(
                      size: MediaQuery.of(context).size.height * 0.25,
                      color: Colors.greenAccent[700],
                    ),
                  );
              }
            }));
  }

  Widget _singleTransaction(DocumentSnapshot doc) {
    //print(doc.data);

    String action = doc.data['transactionAction'];
    String goal = doc.data['transactionGoal'];
    var amount = doc.data['transactionAmount'];
    //String category = doc.data['transactionCategory'];

    //Date and Time Formatting
    int numberTime = doc.data['transactionTime'];
    String year = numberTime.toString().substring(0, 4);
    String month = numberTime.toString().substring(4, 6);
    String day = numberTime.toString().substring(6, 8);
    String hour = numberTime.toString().substring(8, 10);
    String minutes = numberTime.toString().substring(10, 12);
//    String seconds = numberTime.toString().substring(12);

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
                        '$amount KES',
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

  Widget _investmentTransactions() {
    return LimitedBox(
      maxHeight: MediaQuery.of(context).size.height * 0.5,
      child: FutureBuilder<QuerySnapshot>(
        future: transactionsData,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.none:
              return UnsuccessfullError(
                  message: 'You have not made any investment transactions');
            case ConnectionState.done:
              if (snapshot.data.documents.length == 0) {
                return UnsuccessfullError(
                    message: 'You have not made any investment transactions');
              }
              return ListView(
                children: snapshot.data.documents
                    .map((doc) => _singleTransaction(doc))
                    .toList(),
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
        },
      ),
    );
  }

  Map _retrieveAssets(List<DocumentSnapshot> docs) {
    docs.forEach((element) {
      var allocation = element.data["goalAllocation"];
      dataMap.putIfAbsent(element.data["goalName"], () => allocation);
    });
    //print(dataMap);
    return dataMap;
  }

  Widget _assetAllocation() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: FutureBuilder<QuerySnapshot>(
        future: investmentData,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.documents.length == 0) {
              return Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sentiment_neutral,
                    size: 100,
                    color: Colors.red,
                  ),
                  Text(
                    'You do not have any investments',
                    style: GoogleFonts.muli(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ));
            }
            return pie.PieChart(
              dataMap: _retrieveAssets(snapshot.data.documents),
              animationDuration: Duration(milliseconds: 500),
              chartType: pie.ChartType.ring,
              legendStyle:
                  GoogleFonts.muli(textStyle: TextStyle(fontSize: 12.5)),
              showChartValues: true,
              showChartValueLabel: true,
              showChartValuesInPercentage: true,
              showLegends: true,
              initialAngle: 0,
              chartRadius: MediaQuery.of(context).size.width / 1.5,
              chartValueStyle: pie.defaultChartValueStyle.copyWith(
                color: Colors.blueGrey[900].withOpacity(0.9),
              ),
              chartValueBackgroundColor: Colors.grey[200],
            );
          }
          return SpinKitDoubleBounce(
            size: MediaQuery.of(context).size.height * 0.25,
            color: Colors.blue,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'Allocation',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            _assetAllocation(),
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
            _investmentTransactions()
          ],
        ),
      ),
    );
  }
}
