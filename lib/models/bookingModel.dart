import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  String title;
  String name;
  num booking;
  final time = Timestamp.now();
  num returnVal;

  BookingModel({this.title, this.name, this.booking, this.returnVal});

  Map<String, dynamic> toJSON() => {
        'name': name,
        'title': title,
        'booking': booking,
        'returnVal': returnVal
      };
}
