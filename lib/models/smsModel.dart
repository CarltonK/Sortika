class SMS {
  String address;
  String body;
  DateTime date;

  SMS({this.address, this.body, this.date});

  Map<String, dynamic> toJSON() {
    return {'address': address, 'body': body, 'date': date};
  }

  factory SMS.fromJson(Map<String, dynamic> json) =>
      SMS(address: json['address'], body: json['body'], date: json['date']);
}
