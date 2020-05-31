class SMSRequest {
  String smsData;

  SMSRequest({this.smsData});

  Map<String, dynamic> toJson() => {
        "sms_data": smsData,
      };
}
