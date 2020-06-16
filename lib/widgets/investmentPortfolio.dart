import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart' as pie;
import 'package:wealth/api/helper.dart';
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

  String goal;

  Map<String, double> dataMap = Map();
  final String category = 'Investment';

  Helper helper = new Helper();

  Future investmentData;
  Future transactionsData;
  Future singleTransactionFuture;
  Future summaryData;

  DateTime rightNow = DateTime.now();

  @override
  void initState() {
    super.initState();
    investmentData = helper.getInvestmentData(widget.uid);
    transactionsData = helper.getTransactions(widget.uid, category);
    summaryData = helper.goalSummaryData(category, widget.uid);
  }

  Widget _portfolioSummary() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      child: FutureBuilder<Map<String, dynamic>>(
        future: summaryData,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.done:
            // return ListView.builder(
            //   itemCount: snapshot.data.length,
            //   scrollDirection: Axis.horizontal,
            //   itemBuilder: (context, index) {
            //     var currentItem = snapshot.data[index];
            //     print(currentItem);
            //     String type = currentItem['type'];
            //     num amountSaved = currentItem['amount'];
            //     num returnAsset = currentItem['return'];
            //     num interest = (amountSaved * returnAsset) / 100;
            //     num growth = (interest / (amountSaved - interest)) * 100;

            //     growth.isNaN ? growth = 0 : growth = growth;

            //     return Container(
            //       margin: EdgeInsets.symmetric(horizontal: 8),
            //       width: 250,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(12),
            //         gradient: LinearGradient(
            //             tileMode: TileMode.clamp,
            //             begin: Alignment.topLeft,
            //             end: Alignment.bottomRight,
            //             colors: [Colors.red[300], Colors.yellow[700]],
            //             stops: [0, 1.0]),
            //       ),
            //       child: Stack(
            //         children: [
            //           Align(
            //             alignment: Alignment.topLeft,
            //             child: Container(
            //               padding: EdgeInsets.symmetric(
            //                   vertical: 8, horizontal: 10),
            //               decoration: BoxDecoration(
            //                   borderRadius: BorderRadius.only(
            //                       bottomRight: Radius.circular(20)),
            //                   color: Colors.white),
            //               child: Text(
            //                 type,
            //                 style: GoogleFonts.muli(
            //                     textStyle:
            //                         TextStyle(fontWeight: FontWeight.w600)),
            //               ),
            //             ),
            //           ),
            //           Align(
            //               alignment: Alignment.center,
            //               child: RichText(
            //                 text: TextSpan(children: [
            //                   TextSpan(
            //                       text: 'You have saved ',
            //                       style: GoogleFonts.muli(
            //                           textStyle:
            //                               TextStyle(color: Colors.white))),
            //                   TextSpan(
            //                       text: '${amountSaved.toStringAsFixed(0)} KES',
            //                       style: GoogleFonts.muli(
            //                         textStyle: TextStyle(
            //                             color: Colors.white,
            //                             fontWeight: FontWeight.bold,
            //                             fontSize: 18),
            //                       )),
            //                 ]),
            //               )),
            //           Align(
            //             alignment: Alignment.bottomLeft,
            //             child: Container(
            //               padding: EdgeInsets.symmetric(
            //                   vertical: 5, horizontal: 10),
            //               decoration: BoxDecoration(
            //                   borderRadius: BorderRadius.only(
            //                       topRight: Radius.circular(20)),
            //                   color: Colors.transparent),
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.center,
            //                 mainAxisSize: MainAxisSize.min,
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 children: <Widget>[
            //                   Text(
            //                     'Interest Earned',
            //                     style: GoogleFonts.muli(
            //                         textStyle: TextStyle(
            //                             color: Colors.white,
            //                             fontWeight: FontWeight.w600)),
            //                   ),
            //                   SizedBox(
            //                     height: 5,
            //                   ),
            //                   Text(
            //                     '${interest.toStringAsFixed(1)}',
            //                     style: GoogleFonts.muli(
            //                         textStyle: TextStyle(
            //                             fontSize: 16,
            //                             color: Colors.white,
            //                             fontWeight: FontWeight.bold)),
            //                   )
            //                 ],
            //               ),
            //             ),
            //           ),
            //           Align(
            //             alignment: Alignment.bottomRight,
            //             child: Container(
            //               padding: EdgeInsets.symmetric(
            //                   vertical: 5, horizontal: 10),
            //               decoration: BoxDecoration(
            //                   borderRadius: BorderRadius.only(
            //                       topLeft: Radius.circular(20)),
            //                   color: Colors.transparent),
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.center,
            //                 mainAxisSize: MainAxisSize.min,
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 children: <Widget>[
            //                   Text(
            //                     'Growth Rate',
            //                     style: GoogleFonts.muli(
            //                         textStyle: TextStyle(
            //                             color: Colors.white,
            //                             fontWeight: FontWeight.w600)),
            //                   ),
            //                   SizedBox(
            //                     height: 5,
            //                   ),
            //                   Text(
            //                     '${growth.toStringAsFixed(1)} %',
            //                     style: GoogleFonts.muli(
            //                         textStyle: TextStyle(
            //                             fontSize: 16,
            //                             color: Colors.white,
            //                             fontWeight: FontWeight.bold)),
            //                   )
            //                 ],
            //               ),
            //             ),
            //           )
            //         ],
            //       ),
            //     );
            //   },
            // );
            case ConnectionState.none:
              return UnsuccessfullError(
                  message: 'You have not made any investments');
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
      height: MediaQuery.of(context).size.height * 0.51,
      child: FutureBuilder<QuerySnapshot>(
        future: investmentData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.none:
              return UnsuccessfullError(
                  message: 'You have not made any investments');
            case ConnectionState.done:
              if (snapshot.data.documents.length == 0) {
                return UnsuccessfullError(
                    message: 'You have not made any investments');
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
                chartRadius: MediaQuery.of(context).size.width * 0.5,
                chartValueStyle: pie.defaultChartValueStyle.copyWith(
                  color: Colors.blueGrey[900].withOpacity(0.9),
                ),
                chartValueBackgroundColor: Colors.grey[200],
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
            Text(
              'Summary',
              style: GoogleFonts.muli(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 20,
            ),
            _portfolioSummary(),
            SizedBox(
              height: 10,
            ),
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
