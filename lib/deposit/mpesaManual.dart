import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MpesaManual extends StatelessWidget {
  Widget _btnMpesaManual() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: RaisedButton(
        elevation: 3,
        onPressed: () {},
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.white,
        child: Text(
          'TAKE ME THERE',
          style: GoogleFonts.muli(
              textStyle: TextStyle(
            letterSpacing: 1.5,
            color: Colors.black,
            fontSize: 20,
          )),
        ),
      ),
    );
  }

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
          Text('Enter your PHONE NUMBER as account number',
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
          _btnMpesaManual()
        ],
      ),
    );
  }
}
