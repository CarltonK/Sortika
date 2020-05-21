import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  ErrorMessage({@required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.sentiment_dissatisfied,
              size: 100,
              color: Colors.red,
            ),
            Text(
              message,
              style: GoogleFonts.muli(
                  textStyle: TextStyle(color: Colors.black, fontSize: 16)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.muli(
                    textStyle: TextStyle(
                  letterSpacing: 1.5,
                  color: Colors.blue,
                  fontSize: 20,
                )),
              ))
        ]);
  }
}
