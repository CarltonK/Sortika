import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
