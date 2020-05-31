// import 'dart:convert';
// import 'package:sms/sms.dart';
// import 'package:http/http.dart' as http;
import 'package:wealth/services/permissions.dart';
// import 'package:wealth/models/smsModel.dart';
// import 'package:wealth/models/smsRequest.dart';

class ReadSMS {
  PermissionService _permissionsService = PermissionService();

  ReadSMS() {
    print('A new instance of readSMS class');
  }

  Future<bool> readMPESA(String uid) async {
    var status = await _permissionsService.requestSmsPermission();
    if (status == true) {
      //This function handles reading MPESA messages
      // SmsQuery query = new SmsQuery();
      // //Store the messages in a list
      // List<SmsMessage> mpesaMessages = await query.querySms(
      //   kinds: [SmsQueryKind.Inbox],
      //   address: 'MPESA',
      // );
      // //How many are they ?
      // print('Count: ${mpesaMessages.length}');
      // //Initialize an empty list to hold SMS objects
      // List<Map<String, dynamic>> smsList = [];
      // //Read Contents by iterating through the list
      // for (int i = 0; i < mpesaMessages.length; i++) {
      //   SmsMessage singleSMS = mpesaMessages[i];
      //   Map<String, dynamic> data = {
      //     'address': singleSMS.address,
      //     'body': singleSMS.body,
      //     'date': singleSMS.date.millisecondsSinceEpoch,
      //     'uid': uid
      //   };
      //   //print(data);
      //   //Populate the List
      //   smsList.add(data);
      // }
      // String data = json.encode({'sms_data': smsList});
      // print(data);
      // // //Try HTTP Post
      // String url =
      //     'https://us-central1-sortika-c0f5c.cloudfunctions.net/sortikaMain/api/v1/tusomerecords/9z5JjD9bGODXeSVpdNFW';
      // var response = await http.post(url, body: data);
      // //print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      return true;
    } else {
      //Executed if permission is not granted
      _permissionsService.requestSmsPermission();
      return false;
    }
  }
}
