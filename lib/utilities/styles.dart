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
