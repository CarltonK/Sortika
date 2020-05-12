import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class SortikaSavings extends StatefulWidget {
  @override
  _SortikaSavingsState createState() => _SortikaSavingsState();
}

class _SortikaSavingsState extends State<SortikaSavings> {
  Firestore _firestore = Firestore.instance;

  Widget _introText() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'You have accumulated  ',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(color: Colors.black))),
            TextSpan(
                text: '100 Points',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    decoration: TextDecoration.underline)),
          ])),
        ],
      ),
    );
  }

  Widget _cardRedeemItem(DocumentSnapshot doc) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), color: Colors.blue),
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                child: Icon(
                  Icons.label,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Color(0xFF73AEF5))),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  doc.data['name'],
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '${doc.data['points']} Points',
                  style: GoogleFonts.muli(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w400)),
                ),
              ],
            ),
            SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }

  Future<QuerySnapshot> getRedeemables() async {
    QuerySnapshot queries =
        await _firestore.collection('redeemables').getDocuments();
    return queries;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Savings Points',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 30,
          ),
          _introText(),
          SizedBox(
            height: 20,
          ),
          Text(
            'Here\'s what you can redeem',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
              color: Colors.black,
            )),
          ),
          Expanded(
              child: FutureBuilder<QuerySnapshot>(
                  future: getRedeemables(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView(
                        children: snapshot.data.documents
                            .map((map) => _cardRedeemItem(map))
                            .toList(),
                      );
                    }
                    return Center(
                      child: SpinKitDoubleBounce(
                        size: 200,
                        color: Colors.greenAccent[700],
                      ),
                    );
                  })),
        ],
      ),
    );
  }
}
