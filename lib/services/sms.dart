import 'dart:convert';
import 'package:sms/sms.dart';
import 'package:http/http.dart' as http;
import 'package:wealth/services/permissions.dart';
// import 'package:wealth/models/smsModel.dart';
// import 'package:wealth/models/smsRequest.dart';

class ReadSMS {
  PermissionService _permissionsService = PermissionService();
  DateTime rightnow = DateTime.now();

  ReadSMS() {
    print('A new instance of readSMS class');
  }

  Future<bool> readMPESA(String uid, DateTime lastLogin) async {
    var status = await _permissionsService.requestSmsPermission();
    if (status == true) {
      // This function handles reading MPESA messages
      int diff = rightnow.difference(lastLogin).inMinutes + 1;
      print('Time Difference -> $diff');
      if (rightnow.difference(lastLogin).inMinutes > 1) {
        SmsQuery query = new SmsQuery();
        //Store the messages in a list
        List<SmsMessage> mpesaMessages = await query.querySms(
          kinds: [SmsQueryKind.Inbox],
          address: 'MPESA',
        );
        //How many are they ?
        print('All Messages Count: ${mpesaMessages.length}');
        //Initialize an empty list to hold SMS objects
        List<Map<String, dynamic>> smsList = [];
        List<Map<String, dynamic>> pastSmsList = [];
        //Get Todays Date
        //Read Contents by iterating through the list
        for (int i = 0; i < mpesaMessages.length; i++) {
          SmsMessage singleSMS = mpesaMessages[i];
          DateTime messageDate = singleSMS.date;
          Map<String, dynamic> data = {
            'address': singleSMS.address,
            'body': singleSMS.body,
            'date': singleSMS.date.millisecondsSinceEpoch,
            'uid': uid
          };
          if (rightnow.difference(messageDate).inMinutes <= diff) {
            // print(data);
            smsList.add(data);
          } else {
            pastSmsList.add(data);
          }
          //print(data);
          //Populate the List
        }
        print('Accepted Messages Count: ${smsList.length}');
        String data =
            json.encode({'sms_data': smsList, 'past_data': pastSmsList});
        // print(data);
        // //Try HTTP Post
        String url =
            'https://europe-west1-sortika-c0f5c.cloudfunctions.net/sortikaMain/api/v1/tusomerecords/9z5JjD9bGODXeSVpdNFW';
        var response = await http.post(url, body: data);
        //print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      return true;
    } else {
      //Executed if permission is not granted
      _permissionsService.requestSmsPermission();
      return false;
    }
  }
}
