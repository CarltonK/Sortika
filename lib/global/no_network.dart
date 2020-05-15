import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class NoNetwork extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MaterialCommunityIcons.close_network,
            color: Colors.white,
            size: 250,
          ),
          SizedBox(height: 20),
          Text(
            'Please check your network connection',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }
}
