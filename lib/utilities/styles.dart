import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/cupertino.dart';

//LabelStyle
final labelStyle = GoogleFonts.muli(
    textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold));

//HintStyle
final hintStyle = GoogleFonts.muli(
    textStyle: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600));

//BoxDecoration
final boxDecorationStyle = BoxDecoration(
  color: Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

final commonColor = Color(0xFF73AEF5);

Widget backgroundWidget() {
  return Container(
    height: double.infinity,
    width: double.infinity,
    decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
          Color(0xFF73AEF5),
          Color(0xFF61A4F1),
          Color(0xFF478DE0),
          Color(0xFF398AE5),
        ],
            stops: [
          0.1,
          0.4,
          0.7,
          0.9
        ])),
  );
}

Future _promptUser(BuildContext context, String message) {
  return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Text(
            '$message',
            style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        );
      });
}

Future _promptUserSuccess(BuildContext context, String message) {
  return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.done,
                size: 50,
                color: Colors.green,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '$message',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      });
}

Future _showUserProgress(BuildContext context, String message) {
  return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$message...',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(color: Colors.black, fontSize: 16)),
              ),
              SizedBox(
                height: 10,
              ),
              SpinKitDualRing(
                color: Colors.greenAccent[700],
                size: 100,
              )
            ],
          ),
        );
      });
}
