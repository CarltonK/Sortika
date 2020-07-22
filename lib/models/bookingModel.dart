import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  String title;
  String name;
  num booking;
  Timestamp time;
  num returnVal;

  BookingModel(
      {this.title, this.name, this.booking, this.time, this.returnVal});

  Map<String, dynamic> toJSON() => {
        'name': name,
        'title': title,
        'time': time,
        'booking': booking,
        'returnVal': returnVal
      };
}
