import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:wealth/enums/connectivityStatus.dart';

class ConnectivityService {
  //Broadcast Status via a Stream
  StreamController<ConnectivityStatus> connectionStreamController =
      StreamController<ConnectivityStatus>();

  ConnectivityService() {
    //Stream which emits connection
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      //Convert result into enum
      var connectionStatus = getStatus(result);

      //Emit Stream
      connectionStreamController.add(connectionStatus);
    });
  }

  //Get ConnectivityStatus
  ConnectivityStatus getStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectivityStatus.Online;
      case ConnectivityResult.mobile:
        return ConnectivityStatus.Online;
      case ConnectivityResult.none:
        return ConnectivityStatus.Offline;
      default:
        return ConnectivityStatus.Offline;
    }
  }
}
