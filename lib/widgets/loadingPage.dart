import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            'Loading',
            style: GoogleFonts.muli(
                textStyle: TextStyle(
                    color: Colors.black, letterSpacing: 1, fontSize: 20)),
          ),
          SizedBox(
            height: 20,
          ),
          SpinKitWave(
            color: Colors.blue,
            type: SpinKitWaveType.center,
            size: 250,
          )
        ],
      ),
    );
  }
}
