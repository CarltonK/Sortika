import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Create an instance of the permission handler
  final PermissionHandler _permissionHandler = PermissionHandler();

  //Request for a specific permission
  Future<bool> requestPermission(PermissionGroup permissionGroup) async {
    var result = await _permissionHandler.requestPermissions([permissionGroup]);
    print('Permission Result: $result');

    if (result[permissionGroup] == PermissionStatus.granted) {
      return true;
    }
    //Show permission request window
    await _permissionHandler
        .shouldShowRequestPermissionRationale(permissionGroup);
    return false;
  }

  //A permission function for viewing contacts on a device
  Future<bool> requestContactsPermission() async {
    return requestPermission(PermissionGroup.contacts);
  }

  //A permission function for reading SMS on a device
  Future<bool> requestSmsPermission() async {
    return requestPermission(PermissionGroup.sms);
  }
}
