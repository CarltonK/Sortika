import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wealth/enums/connectivityStatus.dart';
import 'package:wealth/global/no_network.dart';

class NetworkSensor extends StatelessWidget {
  final Widget child;
  final double opacity;

  const NetworkSensor({this.child, this.opacity = 0.7});

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    if (connectionStatus == ConnectivityStatus.Online) {
      return child;
    }

    return Opacity(opacity: opacity, child: Center(child: NoNetwork()));
  }
}
