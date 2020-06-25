import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MpesaManual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Go to your M-PESA menu',
              style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.white),
              )),
          SizedBox(
            height: 15,
          ),
          Text('Enter SORTIKA paybill number 287450',
              style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.white),
              )),
          SizedBox(
            height: 15,
          ),
          Text(
              'Use the following as account numbers\n\n\t\t1) Wallet - SRTKWALLET\n\t\t2) General - SRTKGENERAL',
              style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.white),
              )),
          SizedBox(
            height: 15,
          ),
          Text('Enter the amount',
              style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.white),
              )),
          SizedBox(
            height: 15,
          ),
          Text('Enter your M-PESA pin',
              style: GoogleFonts.muli(
                textStyle: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }
}
