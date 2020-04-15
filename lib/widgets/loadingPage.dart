import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: SpinKitWave(
        color: Colors.blue,
        type: SpinKitWaveType.center,
        size: 150,
      ),
    );
  }
}
