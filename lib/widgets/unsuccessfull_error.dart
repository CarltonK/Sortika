import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnsuccessfullError extends StatelessWidget {
  final String message;

  UnsuccessfullError({@required this.message});
  @override
  Widget build(BuildContext context) {
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
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.muli(
                textStyle:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
